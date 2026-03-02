% ============================================================
%  MODULE: metrics
%  Purpose: Transaction Attribution analysis – identify which
%           entry channels (Cash / Check / Digital) are most
%           prone to errors and irregularities
%  Layer  : Inference Engine
%
%  An "irregular" transaction is any transaction that:
%    - Is anomalous (amount > 500% of 12-month avg)
%    - Targets a closed or nonexistent fund
%    - Has no Member_ID (unattributed)
%    - References an unknown Member_ID
% ============================================================
:- module(metrics, [
    irregular_transaction/1,
    error_prone_channel/2
]).

:- use_module(library(lists)).
:- use_module('../inference/anomaly').
:- use_module('../inference/constraints').
:- use_module('../validation/validation').
:- use_module('../facts/transactions').

% ---- Irregular Transaction Classifier ----
% A transaction is irregular if it meets ANY of the four criteria.
irregular_transaction(TxnID) :- anomalous_transaction(TxnID, _, _, _).
irregular_transaction(TxnID) :- invalid_fund_transaction(TxnID, _, _).
irregular_transaction(TxnID) :- unattributed_transaction(TxnID).
irregular_transaction(TxnID) :- unknown_member_transaction(TxnID).

% ---- Entry Method Error-Proneness ----
% error_prone_channel(-Method, -Count)
%   For each entry method, counts the number of unique irregular
%   transactions made through that channel.  Highlights which
%   input channels are most susceptible to human error.
error_prone_channel(Method, Count) :-
    valid_entry_method(Method),
    findall(TxnID,
        ( irregular_transaction(TxnID),
          transaction(TxnID, _, _, _, Method, _, _, _) ),
        Bag),
    list_to_set(Bag, Unique),
    length(Unique, Count).
