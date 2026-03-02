% ============================================================
%  MODULE: bank_records
%  Purpose: Bank deposits, audit log, and performance metrics
%  Layer  : Facts (Knowledge Base)
%
%  bank_deposit(DepositDate, Total_Deposited_GHS)
%  audit_log(Log_ID, Txn_ID, Changed_By, Change_Date,
%            Reason_For_Change, Field_Changed, Old_Value, New_Value)
%  adjusting_journal_entries(Period, Count)
%  reconciliation_hours(Period, Hours)
%
%  NOTE: No hardcoded facts.  All rows are loaded at startup
%        by db/loader.pl from Neon (PostgreSQL).
%        audit_log/8 stays dynamic so the audit_trail module can
%        assertz new change records at runtime; those new entries
%        are also persisted back to the database by audit_trail.
% ============================================================
:- module(bank_records, [
    bank_deposit/2,
    audit_log/8,
    adjusting_journal_entries/2,
    reconciliation_hours/2
]).

:- dynamic bank_deposit/2.
:- dynamic audit_log/8.
:- dynamic adjusting_journal_entries/2.
:- dynamic reconciliation_hours/2.
