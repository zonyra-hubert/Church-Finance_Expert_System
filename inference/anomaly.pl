% ============================================================
%  MODULE: anomaly
%  Purpose: Pattern recognition – flag statistically unusual donations
%  Layer  : Inference Engine
%
%  Rule: An income transaction is flagged for "Verification Needed"
%        if its amount exceeds 500% (5×) of the member's 12-month
%        rolling average giving.
% ============================================================
:- module(anomaly, [
    twelve_month_average/2,
    anomalous_transaction/4
]).

:- use_module('../utils/helpers').
:- use_module('../facts/historical_giving').
:- use_module('../facts/transactions').
:- use_module('../validation/validation').

% ---- 3.1  12-Month Average Giving ----
% Collects all historical amounts for a member and computes their mean.
member_giving_amounts(MemberID, Amounts) :-
    findall(A, historical_giving(MemberID, _, A), Amounts).

twelve_month_average(MemberID, Average) :-
    member_giving_amounts(MemberID, Amounts),
    Amounts \= [],
    length(Amounts, Count),
    sum_list_amounts(Amounts, Total),
    Average is Total / Count.

% ---- 3.2  Anomaly Detection ----
% anomalous_transaction(+TxnID, -MemberID, -Amount, -Average)
%   Succeeds when the transaction amount is more than 5× the member's
%   12-month giving average.  Triggers a "Verification Needed" alert.
anomalous_transaction(TxnID, MemberID, Amount, Average) :-
    transaction(TxnID, MemberID, _, Amount, _, _, _, income),
    valid_member(MemberID),
    twelve_month_average(MemberID, Average),
    Amount > 5 * Average.
