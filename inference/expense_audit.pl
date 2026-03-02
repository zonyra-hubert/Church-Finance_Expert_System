% ============================================================
%  MODULE: expense_audit
%  Purpose: Budget constraint checking for every expense
%  Layer  : Inference Engine
%
%  For every expense, the system checks whether it exceeds the
%  allocated budget category.  Results feed into the ledger
%  routing module to auto-approve or escalate to the Finance
%  Committee.
% ============================================================
:- module(expense_audit, [
    budget_remaining/2,
    expense_within_budget/2,
    expense_exceeds_budget/3
]).

:- use_module('../facts/budget').

% ---- 3.7  Budget Remaining ----
% budget_remaining(+Category, -Remaining)
%   Computes how much of the allocated budget is still available.
budget_remaining(Category, Remaining) :-
    budget(Category, Allocated),
    expense_spent(Category, Spent),
    Remaining is Allocated - Spent.

% ---- 3.8  Within-Budget Check ----
% Succeeds when the new expense fits entirely within remaining budget.
expense_within_budget(Category, NewAmount) :-
    budget_remaining(Category, Remaining),
    NewAmount =< Remaining.

% ---- 3.9  Over-Budget Detection ----
% expense_exceeds_budget(+Category, +NewAmount, -Overage)
%   Succeeds and returns the exact overage when a new expense
%   would breach the budget ceiling for this category.
expense_exceeds_budget(Category, NewAmount, Overage) :-
    budget_remaining(Category, Remaining),
    NewAmount > Remaining,
    Overage is NewAmount - Remaining.
