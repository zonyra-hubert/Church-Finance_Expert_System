% ============================================================
%  MODULE: constraints
%  Purpose: Constraint satisfaction – enforce all business rules
%           that must hold for a transaction to be accepted
%  Layer  : Inference Engine
%
%  Responsibilities:
%    - Reject entries to closed / nonexistent funds
%    - Alert when a Guest tries to tithe (prompt for new profile)
%    - Flag transactions with unknown or missing Member IDs
% ============================================================
:- module(constraints, [
    invalid_fund_transaction/3,
    guest_tithe_alert/2,
    unknown_member_transaction/1,
    unattributed_transaction/1
]).

:- use_module('../facts/transactions').
:- use_module('../facts/members').
:- use_module('../validation/validation').

% ---- 3.3  Constraint Satisfaction: Invalid Fund Entries ----
% invalid_fund_transaction(+TxnID, -FundID, -Reason)
%   Automatically rejects entries targeting closed or nonexistent funds.
%   Reason: closed_fund | nonexistent_fund
invalid_fund_transaction(TxnID, FundID, Reason) :-
    transaction(TxnID, _, FundID, _, _, _, _, _),
    validate_fund(FundID, Reason),
    Reason \= valid.

% ---- 3.4  Member Status Logic: Guest + Tithe ----
% guest_tithe_alert(+TxnID, -MemberID)
%   When a "guest" member submits income to the General Tithe fund (f001),
%   the system must prompt the operator to create a full member profile.
guest_tithe_alert(TxnID, MemberID) :-
    transaction(TxnID, MemberID, f001, _, _, _, _, income),
    member(MemberID, _, guest, _).

% ---- 3.5  Unknown Member Transactions ----
% Transactions whose Member_ID is set but not found in the knowledge base.
unknown_member_transaction(TxnID) :-
    transaction(TxnID, MemberID, _, _, _, _, _, _),
    MemberID \= none,
    \+ valid_member(MemberID).

% ---- 3.6  Unattributed Transactions ----
% Transactions deliberately recorded with no member (anonymous cash donors).
unattributed_transaction(TxnID) :-
    transaction(TxnID, none, _, _, _, _, _, _).
