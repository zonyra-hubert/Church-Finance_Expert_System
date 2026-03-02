% ============================================================
%  MODULE: tax_statements
%  Purpose: Generate accurate end-of-year contribution statements
%           for each member to ensure legal compliance and
%           congregational trust.
%  Layer  : Accountability
% ============================================================
:- module(tax_statements, [
    member_annual_total/3,
    tax_statement/2,
    generate_all_tax_statements/1
]).

:- use_module('../utils/helpers').
:- use_module('../facts/members').
:- use_module('../facts/transactions').
:- use_module('../validation/validation').

% ---- 5.7  Member Annual Contribution Total ----
% member_annual_total(+MemberID, +Year, -Total)
%   Computes a member's total verified income contributions
%   for the given calendar year.
member_annual_total(MemberID, Year, Total) :-
    findall(A,
        ( transaction(_, MemberID, _, A, _, date(Year, _, _), _, income) ),
        Amounts),
    sum_list_amounts(Amounts, Total).

% ---- 5.8  Individual Tax Statement ----
% tax_statement(+MemberID, +Year)
%   Prints a formatted contribution statement for one active member.
tax_statement(MemberID, Year) :-
    valid_member(MemberID), !,
    member(MemberID, Name, _, _),
    member_annual_total(MemberID, Year, Total),
    format('~n+--------------------------------------------------+~n'),
    format('|   END-OF-YEAR CONTRIBUTION STATEMENT             |~n'),
    format('+--------------------------------------------------+~n'),
    format('  Member ID  : ~w~n',      [MemberID]),
    format('  Full Name  : ~w~n',      [Name]),
    format('  Tax Year   : ~w~n',      [Year]),
    format('  Total Cont.: GHS ~2f~n', [Total]),
    format('  Statement generated for legal/tax compliance.~n'),
    format('+--------------------------------------------------+~n~n').

tax_statement(MemberID, _Year) :-
    \+ valid_member(MemberID),
    format('ERROR: Member_ID ~w not found in the system.~n', [MemberID]).

% ---- 5.9  Batch Tax Statement Generation ----
% generate_all_tax_statements(+Year)
%   Iterates over all active members and prints a statement for each.
generate_all_tax_statements(Year) :-
    forall(
        member(MemberID, _, active, _),
        tax_statement(MemberID, Year)
    ).
