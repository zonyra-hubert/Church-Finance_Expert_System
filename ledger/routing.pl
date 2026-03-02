% ============================================================
%  MODULE: routing
%  Purpose: Financial routing – direct income to the correct ledger
%           and approve or escalate expense requests
%  Layer  : Ledger Management
%
%  Routing Rules (from flowchart):
%    Income + Restricted Fund  → Restricted Ledger
%    Income + Unrestricted Fund → General Ledger
%    Expense within budget      → Auto-approved; receipt issued
%    Expense over budget        → Escalated to Finance Committee
% ============================================================
:- module(routing, [
    route_to_restricted_ledger/3,
    route_to_general_ledger/3,
    approve_expense/4
]).

:- use_module('../facts/transactions').
:- use_module('../validation/validation').
:- use_module('../inference/expense_audit').

% ---- 4.1  Income Routing: Restricted Ledger ----
% route_to_restricted_ledger(-TxnID, -FundID, -Amount)
%   Matches income transactions posted to open restricted funds.
route_to_restricted_ledger(TxnID, FundID, Amount) :-
    transaction(TxnID, _, FundID, Amount, _, _, _, income),
    restricted_fund(FundID),
    fund_is_open(FundID).

% ---- 4.2  Income Routing: General Ledger ----
% route_to_general_ledger(-TxnID, -FundID, -Amount)
%   Matches income transactions posted to open unrestricted funds.
route_to_general_ledger(TxnID, FundID, Amount) :-
    transaction(TxnID, _, FundID, Amount, _, _, _, income),
    unrestricted_fund(FundID),
    fund_is_open(FundID).

% ---- 4.3  Expense Approval / Escalation ----
% approve_expense(+Category, +Amount, -Decision, -Message)
%
%   Decision: approved  – amount is within budget; receipt issued automatically
%             escalated – amount exceeds budget; routed to Finance Committee
approve_expense(Category, Amount, approved, Message) :-
    expense_within_budget(Category, Amount), !,
    format(atom(Message),
        'RECEIPT ISSUED | Category: ~w | Amount: GHS ~2f | STATUS: APPROVED',
        [Category, Amount]).

approve_expense(Category, Amount, escalated, Message) :-
    expense_exceeds_budget(Category, Amount, Overage),
    format(atom(Message),
        'FINANCE COMMITTEE REVIEW REQUIRED | Category: ~w | Requested: GHS ~2f | Exceeds budget by: GHS ~2f',
        [Category, Amount, Overage]).
