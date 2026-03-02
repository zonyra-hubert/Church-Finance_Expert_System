% ============================================================
%  MODULE: loader
%  Purpose: Populate all Prolog facts from Neon (PostgreSQL)
%           at system startup.  Replaces every hard-coded fact
%           in the facts/ layer with live database rows.
%  Layer  : Database
%
%  Call order (handled automatically by church_finance.pl):
%    1. All facts/ modules are loaded (they declare dynamic predicates only)
%    2. This module is loaded – its initialization goal fires
%    3. db_load_all/0 opens Neon, SELECTs every table, asserts facts
%
%  NULL handling: PostgreSQL NULLs (anonymous donors) are
%  mapped to the Prolog atom `none` to preserve the existing
%  constraint-checking rules unchanged.
% ============================================================
:- module(loader, [
    db_load_all/0,
    db_reload/0
]).

:- use_module('../db/connection').

% ---- Dynamic target modules ----
:- use_module('../facts/members').
:- use_module('../facts/funds').
:- use_module('../facts/transactions').
:- use_module('../facts/budget').
:- use_module('../facts/historical_giving').
:- use_module('../facts/bank_records').

% ============================================================
%  db_load_all/0
%  Opens one connection, loads every table, closes cleanly.
% ============================================================
db_load_all :-
    format('[DB] Connecting to Neon Postgres...~n'),
    db_connect(Conn),
    (   catch(load_all_tables(Conn), E,
              ( db_disconnect(Conn),
                format('[DB] ERROR during load: ~w~n', [E]),
                throw(E) ))
    ->  db_disconnect(Conn),
        format('[DB] All facts loaded successfully.~n')
    ;   db_disconnect(Conn),
        format('[DB] WARNING: load_all_tables/1 failed.~n')
    ).

% ---- db_reload/0 ----
% Clears all previously asserted facts and re-fetches from
% the database.  Useful after bulk data changes.
db_reload :-
    retract_all_facts,
    db_load_all.

% ============================================================
%  Retract helpers – clear each dynamic predicate before reload
% ============================================================
retract_all_facts :-
    retractall(members:member(_, _, _, _)),
    retractall(funds:fund(_, _, _, _)),
    retractall(transactions:transaction(_, _, _, _, _, _, _, _)),
    retractall(budget_facts:budget(_, _)),
    retractall(budget_facts:expense_spent(_, _)),
    retractall(historical_giving:historical_giving(_, _, _)),
    retractall(bank_records:bank_deposit(_, _)),
    retractall(bank_records:audit_log(_, _, _, _, _, _, _, _)),
    retractall(bank_records:adjusting_journal_entries(_, _)),
    retractall(bank_records:reconciliation_hours(_, _)).

% ============================================================
%  load_all_tables(+Conn)
% ============================================================
load_all_tables(Conn) :-
    load_members(Conn),
    load_funds(Conn),
    load_budget(Conn),
    load_expense_spent(Conn),
    load_transactions(Conn),
    load_historical_giving(Conn),
    load_bank_deposits(Conn),
    load_audit_log(Conn),
    load_aje(Conn),
    load_recon_hours(Conn).

% ============================================================
%  Table loaders
%  Each loader:
%    1. SELECTs the relevant columns in a fixed order
%    2. Iterates over rows
%    3. Converts types (NULL → none, date → date/3, numeric → float)
%    4. assertz-es into the correct module
% ============================================================

% ---- Members -----------------------------------------------
load_members(Conn) :-
    db_query(Conn,
        "SELECT member_id, full_name, status, \"12_month_salary\" FROM members",
        Rows),
    maplist(assert_member, Rows),
    length(Rows, N),
    format('[DB]   members loaded: ~w rows~n', [N]).

assert_member(row(ID, Name, Status, Salary)) :-
    atom_string(IDAtom,     ID),
    atom_string(NameAtom,   Name),
    atom_string(StatusAtom, Status),
    to_float(Salary, SalaryF),
    assertz(members:member(IDAtom, NameAtom, StatusAtom, SalaryF)).

% ---- Funds -------------------------------------------------
load_funds(Conn) :-
    db_query(Conn,
        "SELECT fund_id, fund_name, fund_type, fund_status FROM funds",
        Rows),
    maplist(assert_fund, Rows),
    length(Rows, N),
    format('[DB]   funds loaded: ~w rows~n', [N]).

assert_fund(row(ID, Name, Type, Status)) :-
    maplist(atom_string_conv,
            [ID, Name, Type, Status],
            [IDa, Namea, Typea, Statusa]),
    assertz(funds:fund(IDa, Namea, Typea, Statusa)).

% ---- Budget ------------------------------------------------
load_budget(Conn) :-
    db_query(Conn,
        "SELECT category, allocated_amount FROM budget",
        Rows),
    maplist(assert_budget, Rows),
    length(Rows, N),
    format('[DB]   budget loaded: ~w rows~n', [N]).

assert_budget(row(Cat, Amt)) :-
    atom_string(CatAtom, Cat),
    to_float(Amt, AmtF),
    assertz(budget_facts:budget(CatAtom, AmtF)).

% ---- Expense Spent -----------------------------------------
load_expense_spent(Conn) :-
    db_query(Conn,
        "SELECT category, amount_spent FROM expense_spent",
        Rows),
    maplist(assert_expense_spent, Rows),
    length(Rows, N),
    format('[DB]   expense_spent loaded: ~w rows~n', [N]).

assert_expense_spent(row(Cat, Amt)) :-
    atom_string(CatAtom, Cat),
    to_float(Amt, AmtF),
    assertz(budget_facts:expense_spent(CatAtom, AmtF)).

% ---- Transactions ------------------------------------------
% member_id may be NULL (anonymous donors) → atom `none`
load_transactions(Conn) :-
    db_query(Conn,
        "SELECT txn_id, member_id, fund_id, amount, entry_method, service_date, entry_date, txn_type FROM transactions ORDER BY service_date, txn_id",
        Rows),
    maplist(assert_transaction, Rows),
    length(Rows, N),
    format('[DB]   transactions loaded: ~w rows~n', [N]).

assert_transaction(row(TID, MID, FID, Amt, Method, SvcDate, EntDate, Type)) :-
    atom_string(TIDa,    TID),
    null_to_none(MID, MIDa),
    atom_string(FIDa,    FID),
    to_float(Amt, AmtF),
    atom_string(Methoda, Method),
    pg_date_to_prolog(SvcDate, SvcD),
    pg_date_to_prolog(EntDate, EntD),
    atom_string(Typea,   Type),
    assertz(transactions:transaction(
        TIDa, MIDa, FIDa, AmtF, Methoda, SvcD, EntD, Typea)).

% ---- Historical Giving -------------------------------------
load_historical_giving(Conn) :-
    db_query(Conn,
        "SELECT member_id, giving_year, giving_month, amount FROM historical_giving ORDER BY member_id, giving_year, giving_month",
        Rows),
    maplist(assert_hist_giving, Rows),
    length(Rows, N),
    format('[DB]   historical_giving loaded: ~w rows~n', [N]).

assert_hist_giving(row(MID, Year, Month, Amt)) :-
    atom_string(MIDa, MID),
    to_int(Year, Y),
    to_int(Month, M),
    to_float(Amt, AmtF),
    assertz(historical_giving:historical_giving(MIDa, ym(Y, M), AmtF)).

% ---- Bank Deposits -----------------------------------------
load_bank_deposits(Conn) :-
    db_query(Conn,
        "SELECT deposit_date, total_deposited FROM bank_deposits",
        Rows),
    maplist(assert_bank_deposit, Rows),
    length(Rows, N),
    format('[DB]   bank_deposits loaded: ~w rows~n', [N]).

assert_bank_deposit(row(DepDate, Total)) :-
    pg_date_to_prolog(DepDate, D),
    to_float(Total, TotalF),
    assertz(bank_records:bank_deposit(D, TotalF)).

% ---- Audit Log ---------------------------------------------
load_audit_log(Conn) :-
    db_query(Conn,
        "SELECT log_id, txn_id, changed_by, change_date, reason, field_changed, old_value, new_value FROM audit_log ORDER BY change_date, log_id",
        Rows),
    maplist(assert_audit_log, Rows),
    length(Rows, N),
    format('[DB]   audit_log loaded: ~w rows~n', [N]).

assert_audit_log(row(LID, TID, By, CDate, Reason, Field, Old, New)) :-
    maplist(atom_string_conv,
            [LID, TID, By, Reason, Field, Old, New],
            [LIDa, TIDa, Bya, Reasona, Fielda, Olda, Newa]),
    pg_date_to_prolog(CDate, CD),
    assertz(bank_records:audit_log(
        LIDa, TIDa, Bya, CD, Reasona, Fielda, Olda, Newa)).

% ---- Adjusting Journal Entries -----------------------------
load_aje(Conn) :-
    db_query(Conn,
        "SELECT period, count FROM adjusting_journal_entries",
        Rows),
    maplist(assert_aje, Rows),
    length(Rows, N),
    format('[DB]   adjusting_journal_entries loaded: ~w rows~n', [N]).

assert_aje(row(Period, Count)) :-
    atom_string(Pa, Period),
    to_int(Count, C),
    assertz(bank_records:adjusting_journal_entries(Pa, C)).

% ---- Reconciliation Hours ----------------------------------
load_recon_hours(Conn) :-
    db_query(Conn,
        "SELECT period, hours FROM reconciliation_hours",
        Rows),
    maplist(assert_recon_hours, Rows),
    length(Rows, N),
    format('[DB]   reconciliation_hours loaded: ~w rows~n', [N]).

assert_recon_hours(row(Period, Hours)) :-
    atom_string(Pa, Period),
    to_float(Hours, H),
    assertz(bank_records:reconciliation_hours(Pa, H)).

% ============================================================
%  Type conversion utilities
% ============================================================

% atom_string_conv(+Str, -Atom) – safe string-or-atom to atom
atom_string_conv(X, A) :- atom_string(A, X).

% null_to_none(+OdbcValue, -PrologAtom)
%  ODBC returns SQL NULLs as the atom '$null$' (configured in db_connect/1).
%  We map them to `none` to match the existing Prolog rules.
null_to_none('$null$', none) :- !.
null_to_none(X,        A)    :- atom_string(A, X).

% to_float(+Value, -Float)
%  Handles numeric values that may arrive as integer, float, or atom.
to_float(V, F) :- float(V),   !, F = V.
to_float(V, F) :- integer(V), !, F is float(V).
to_float(V, F) :- atom(V),    !, atom_number(V, N), F is float(N).
to_float(V, F) :- number(V),  !, F is float(V).

% to_int(+Value, -Int)
to_int(V, I) :- integer(V), !, I = V.
to_int(V, I) :- number(V),  !, I is integer(V).
to_int(V, I) :- atom(V),    !, atom_number(V, N), I is integer(N).

% pg_date_to_prolog(+OdbcDate, -PrologDate)
%  The PostgreSQL ODBC driver may return DATE columns as date(Y,M,D) terms
%  or as a string '2026-02-01'.  Both forms are normalised here.
pg_date_to_prolog(date(Y,M,D), date(Y,M,D)) :- !.
pg_date_to_prolog(Str, date(Y,M,D)) :-
    ( atom(Str) -> atom_string(Str, S) ; S = Str ),
    split_string(S, "-", "", [YS, MS, DS]),
    number_string(Y, YS),
    number_string(M, MS),
    number_string(D, DS).

% ---- Auto-load on startup ----
% `now` fires when this directive is encountered during file loading,
% which is after all predicates above are defined.
:- initialization(db_load_all, now).
