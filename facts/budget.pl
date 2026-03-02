% ============================================================
%  MODULE: budget_facts
%  Purpose: Budget allocations and year-to-date expense spending
%  Layer  : Facts (Knowledge Base)
%
%  budget(Category, Allocated_Amount_GHS)
%  expense_spent(Category, Amount_Already_Spent_GHS)
%
%  NOTE: No hardcoded facts.  All rows are loaded at startup
%        by db/loader.pl from the Neon (PostgreSQL)
%        `budget` and `expense_spent` tables.
% ============================================================
:- module(budget_facts, [budget/2, expense_spent/2]).

:- dynamic budget/2.
:- dynamic expense_spent/2.
