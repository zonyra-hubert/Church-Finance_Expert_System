% ============================================================
%  MODULE: helpers
%  Purpose: Shared arithmetic utility predicates
%  Layer  : Utils
% ============================================================
:- module(helpers, [sum_list_amounts/2]).

% sum_list_amounts(+List, -Total)
%   Sums a list of numeric amounts.
sum_list_amounts([], 0).
sum_list_amounts([H|T], Total) :-
    sum_list_amounts(T, Rest),
    Total is H + Rest.
