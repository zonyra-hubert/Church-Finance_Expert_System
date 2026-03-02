% ============================================================
%  MODULE: reports
%  Purpose: Aggregate diagnostic report that exercises every
%           layer of the expert system in one query.
%  Layer  : Reporting
%
%  Entry point: run_full_audit/0
% ============================================================
:- module(reports, [run_full_audit/0]).

:- use_module(library(lists)).

% ---- Facts ----
:- use_module('../facts/members').
:- use_module('../facts/funds').
:- use_module('../facts/budget').
:- use_module('../facts/bank_records').

% ---- Validation ----
:- use_module('../validation/validation').

% ---- Inference ----
:- use_module('../inference/anomaly').
:- use_module('../inference/constraints').
:- use_module('../inference/metrics').

% ---- Ledger ----
:- use_module('../ledger/routing').

% ---- Accountability ----
:- use_module('../accountability/reconciliation').
:- use_module('../accountability/audit_trail').
:- use_module('../accountability/performance').
:- use_module('../accountability/tax_statements').

% ============================================================
%  run_full_audit/0
%  Prints a 12-section diagnostic report to the console.
% ============================================================
run_full_audit :-
    format('~n'),
    format('============================================================~n'),
    format('    CHURCH FINANCIAL MANAGEMENT EXPERT SYSTEM - REPORT      ~n'),
    format('    IntelliGents  |  Report Date: 2026-03-02                ~n'),
    format('============================================================~n'),

    % --------------------------------------------------
    format('~n[1] ANOMALOUS TRANSACTIONS (Amount > 500%% of 12-Month Avg)~n'),
    format('------------------------------------------------------------~n'),
    (   findall(TxnID-MemberID-Amount-Avg,
                anomalous_transaction(TxnID, MemberID, Amount, Avg),
                Anomalies),
        Anomalies \= []
    ->  forall(
            lists:member(TxnID-MemberID-Amount-Avg, Anomalies),
            ( member(MemberID, Name, _, _),
              format('  FLAG | TXN ~w | ~w (~w) | GHS ~2f submitted | Avg: GHS ~2f | ACTION: Verification Needed~n',
                     [TxnID, Name, MemberID, Amount, Avg]) )
        )
    ;   format('  None detected.~n')
    ),

    % --------------------------------------------------
    format('~n[2] INVALID FUND TRANSACTIONS (Closed or Non-Existent Funds)~n'),
    format('------------------------------------------------------------~n'),
    (   findall(TxnID-FundID-Reason,
                invalid_fund_transaction(TxnID, FundID, Reason),
                InvalidFunds),
        InvalidFunds \= []
    ->  forall(
            lists:member(TxnID-FundID-Reason, InvalidFunds),
            ( ( fund(FundID, FundName, _, _) -> true ; FundName = 'UNKNOWN FUND' ),
              format('  REJECTED | TXN ~w | Fund: ~w (~w) | Reason: ~w~n',
                     [TxnID, FundName, FundID, Reason]) )
        )
    ;   format('  None detected.~n')
    ),

    % --------------------------------------------------
    format('~n[3] GUEST TITHE ALERTS (Action: Create New Member Profile)~n'),
    format('------------------------------------------------------------~n'),
    (   findall(TxnID-MemberID,
                guest_tithe_alert(TxnID, MemberID),
                GuestAlerts),
        GuestAlerts \= []
    ->  forall(
            lists:member(TxnID-MemberID, GuestAlerts),
            ( member(MemberID, Name, _, _),
              format('  ALERT | TXN ~w | Guest: ~w (~w) | ACTION: Register as new member~n',
                     [TxnID, Name, MemberID]) )
        )
    ;   format('  None detected.~n')
    ),

    % --------------------------------------------------
    format('~n[4] UNATTRIBUTED / UNKNOWN MEMBER TRANSACTIONS~n'),
    format('------------------------------------------------------------~n'),
    (   findall(TxnID, unattributed_transaction(TxnID), Unatts),
        Unatts \= []
    ->  forall(
            lists:member(TxnID, Unatts),
            format('  INFO | TXN ~w | Donor: Anonymous (no Member_ID)~n', [TxnID])
        )
    ;   format('  None.~n')
    ),

    % --------------------------------------------------
    format('~n[5] ENTRY METHOD ERROR-PRONENESS ANALYSIS~n'),
    format('------------------------------------------------------------~n'),
    forall(
        valid_entry_method(Method),
        ( error_prone_channel(Method, Count),
          format('  Method: ~w | Irregular transactions: ~w~n', [Method, Count]) )
    ),

    % --------------------------------------------------
    format('~n[6] LEDGER ROUTING SUMMARY~n'),
    format('------------------------------------------------------------~n'),
    format('  >> RESTRICTED LEDGER (Restricted Funds - Open):~n'),
    (   findall(TxnID-FundID-Amount,
                route_to_restricted_ledger(TxnID, FundID, Amount),
                RestrictedEntries),
        RestrictedEntries \= []
    ->  forall(
            lists:member(TxnID-FundID-Amount, RestrictedEntries),
            ( fund(FundID, FundName, _, _),
              format('     POSTED | TXN ~w | ~w | GHS ~2f~n', [TxnID, FundName, Amount]) )
        )
    ;   format('     No entries.~n')
    ),
    format('  >> GENERAL LEDGER (Unrestricted Funds - Open):~n'),
    (   findall(TxnID-FundID-Amount,
                route_to_general_ledger(TxnID, FundID, Amount),
                GeneralEntries),
        GeneralEntries \= []
    ->  forall(
            lists:member(TxnID-FundID-Amount, GeneralEntries),
            ( fund(FundID, FundName, _, _),
              format('     POSTED | TXN ~w | ~w | GHS ~2f~n', [TxnID, FundName, Amount]) )
        )
    ;   format('     No entries.~n')
    ),

    % --------------------------------------------------
    format('~n[7] BUDGET STATUS (All Categories)~n'),
    format('------------------------------------------------------------~n'),
    forall(
        budget(Category, Allocated),
        ( expense_spent(Category, Spent),
          Remaining is Allocated - Spent,
          ( Remaining < 0
          ->  BStatus = 'OVER BUDGET'
          ;   Remaining < 0.1 * Allocated
          ->  BStatus = 'NEAR LIMIT'
          ;   BStatus = 'OK'
          ),
          format('  ~w | Allocated: GHS ~2f | Spent: GHS ~2f | Remaining: GHS ~2f | [~w]~n',
                 [Category, Allocated, Spent, Remaining, BStatus]) )
    ),

    % --------------------------------------------------
    format('~n[8] EXPENSE APPROVAL EXAMPLES~n'),
    format('------------------------------------------------------------~n'),
    forall(
        lists:member(Cat-Req, [maintenance-150.00, salaries-800.00, events-200.00]),
        ( approve_expense(Cat, Req, Decision, Msg),
          format('  ~w~n', [Msg]),
          format('     -> Decision: ~w~n', [Decision]) )
    ),

    % --------------------------------------------------
    format('~n[9] BANK RECONCILIATION~n'),
    format('------------------------------------------------------------~n'),
    total_manual_income(ManualTotal),
    ( bank_deposit(date(2026,2,28), BankAmt) ->
        format('  Manual Total  : GHS ~2f  (sum of open-fund income entries)~n', [ManualTotal]),
        format('  Bank Deposit  : GHS ~2f  (date(2026,2,28))~n', [BankAmt]),
        ( reconcile(date(2026,2,28), BankAmt, RStatus, Discrepancy) ->
            format('  Status        : ~w~n', [RStatus]),
            ( RStatus = discrepancy_found
            ->  format('  Discrepancy   : GHS ~2f  (Bank - Manual; investigate immediately)~n',
                       [Discrepancy])
            ;   format('  Discrepancy   : GHS 0.00~n')
            )
        ; format('  Reconcile failed (check data).~n')
        )
    ;   format('  No bank deposit record found for date(2026,2,28).~n')
    ),

    % --------------------------------------------------
    format('~n[10] AUDIT TRAIL (Logged Changes)~n'),
    format('------------------------------------------------------------~n'),
    (   findall(log(LID, TID, By, Dt, Rsn, Fld, Ov, Nv),
                audit_log(LID, TID, By, Dt, Rsn, Fld, Ov, Nv),
                AllLogs),
        AllLogs \= []
    ->  forall(
            lists:member(log(LID, TID, By, Dt, Rsn, Fld, Ov, Nv), AllLogs),
            format('  ~w | TXN ~w | By: ~w | Date: ~w | ~w: ~w -> ~w | "~w"~n',
                   [LID, TID, By, Dt, Fld, Ov, Nv, Rsn])
        )
    ;   format('  No audit entries on record.~n')
    ),

    % --------------------------------------------------
    format('~n[11] PERFORMANCE MONITORING~n'),
    format('------------------------------------------------------------~n'),
    ( aje_reduction(q1_2025, q1_2026, AJEReduction, AJEPct) ->
        format('  AJE Count - Q1 2025: 18  |  Q1 2026: 3~n'),
        format('  Reduction : ~w entries fewer  (~2f%% improvement)~n',
               [AJEReduction, AJEPct])
    ; true ),
    ( hours_saved(q1_2025, q1_2026, HS) ->
        format('  Reconciliation Hours - Q1 2025: 12.0h  |  Q1 2026: 2.5h~n'),
        format('  Hours Saved: ~2f hours~n', [HS])
    ; true ),

    % --------------------------------------------------
    format('~n[12] TAX STATEMENTS (2026 - All Active Members)~n'),
    format('------------------------------------------------------------~n'),
    generate_all_tax_statements(2026),

    format('============================================================~n'),
    format('                   END OF REPORT~n'),
    format('============================================================~n~n').
