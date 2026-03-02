% ============================================================
%  MODULE: validation
%  Purpose: Input validation rules – first line of defense
%           against manual data-entry errors
%  Layer  : Validation
%
%  Responsibilities:
%    - Member identification (ID existence check)
%    - Fund status and type classification helpers
%    - 3-way fund validation (valid / closed / nonexistent)
%    - Entry method (channel) enumeration
% ============================================================
:- module(validation, [
    valid_member/1,
    valid_entry_method/1,
    fund_exists/1,
    fund_is_open/1,
    restricted_fund/1,
    unrestricted_fund/1,
    validate_fund/2
]).

:- use_module('../facts/members').
:- use_module('../facts/funds').

% ---- 2.1  Member Identification ----
% Succeeds only when the Member_ID is registered in the KB.
% Prevents duplicate entries or confusion between similarly named members.
valid_member(MemberID) :-
    member(MemberID, _, _, _).

% ---- 2.2  Fund Type Classifiers ----
restricted_fund(FundID) :-
    fund(FundID, _, restricted, _).

unrestricted_fund(FundID) :-
    fund(FundID, _, unrestricted, _).

% ---- 2.3  Fund Status Helpers ----
fund_is_open(FundID) :-
    fund(FundID, _, _, open).

fund_exists(FundID) :-
    fund(FundID, _, _, _).

% ---- 2.4  Fund Validation (3-way result) ----
% validate_fund(+FundID, -Status)
%   Status: valid | closed_fund | nonexistent_fund
%
% Used by the constraint checker to reject entries immediately.
validate_fund(FundID, valid) :-
    fund_exists(FundID),
    fund_is_open(FundID), !.
validate_fund(FundID, closed_fund) :-
    fund_exists(FundID),
    \+ fund_is_open(FundID), !.
validate_fund(_FundID, nonexistent_fund).

% ---- 2.5  Entry Method Validation ----
% Records which channel was used (cash / check / digital).
% Used downstream by the metrics module to identify error-prone channels.
valid_entry_method(cash).
valid_entry_method(check).
valid_entry_method(digital).
