% ============================================================
%  MODULE: reconciliation
%  Purpose: Bank reconciliation – compare manual entry totals
%           against actual bank deposit and surface discrepancies
%  Layer  : Accountability
% ============================================================
:- module(reconciliation, [
    total_manual_income/1,
    reconcile/4
]).

:- use_module('../utils/helpers').
:- use_module('../facts/transactions').
:- use_module('../facts/bank_records').
:- use_module('../validation/validation').

% ---- 5.1  Total Manual Income ----
% Sums all income transactions recorded against open funds.
% This is the figure that should match the bank deposit.
total_manual_income(Total) :-
    findall(A,
        ( transaction(_, _, FundID, A, _, _, _, income),
          fund_is_open(FundID) ),
        Amounts),
    sum_list_amounts(Amounts, Total).

% ---- 5.2  Bank Reconciliation ----
% reconcile(+DepositDate, +DepositAmount, -Status, -Discrepancy)
%
%   Status: matched          – manual total equals bank deposit
%           discrepancy_found – totals do not match; Discrepancy = Bank - Manual
%
%   A floating-point tolerance of GHS 0.005 is applied.
reconcile(DepositDate, DepositAmount, Status, Discrepancy) :-
    bank_deposit(DepositDate, DepositAmount),
    total_manual_income(ManualTotal),
    ( abs(ManualTotal - DepositAmount) < 0.005
    ->  Status      = matched,
        Discrepancy = 0.00
    ;   Status      = discrepancy_found,
        Discrepancy is DepositAmount - ManualTotal
    ).
