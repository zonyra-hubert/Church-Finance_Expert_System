% ============================================================
%  MODULE: transactions
%  Purpose: All financial transaction records
%  Layer  : Facts (Knowledge Base)
%
%  transaction(Txn_ID, Member_ID, Fund_ID, Amount,
%              Entry_Method, Service_Date, Entry_Date, Txn_Type)
%
%    Entry_Method : cash | check | digital
%    Txn_Type     : income | expense
%    Member_ID    : none  – anonymous donor; no registered profile
%
%    Service_Date = actual date of the church service
%    Entry_Date   = date the record was physically keyed in
%
%  NOTE: No hardcoded facts.  All rows are loaded at startup
%        by db/loader.pl from the Neon (PostgreSQL) `transactions` table.
%        PostgreSQL NULL member_id values are mapped to the atom `none`.
% ============================================================
:- module(transactions, [transaction/8]).

:- dynamic transaction/8.
