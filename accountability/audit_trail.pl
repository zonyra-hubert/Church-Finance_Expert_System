% ============================================================
%  MODULE: audit_trail
%  Purpose: Complete change-history log for every transaction edit.
%           Enforces a mandatory "Reason for Change" to maintain
%           a transparent, tamper-evident record of all amendments.
%  Layer  : Accountability
% ============================================================
:- module(audit_trail, [
    audit_history/2,
    log_change/7
]).

:- use_module('../facts/bank_records').  % audit_log/8 dynamic predicate lives here

% ---- 5.3  Audit History Retrieval ----
% audit_history(+TxnID, -Logs)
%   Returns the full change history for a given transaction
%   as a list of log/7 terms.
audit_history(TxnID, Logs) :-
    findall(
        log(LogID, ChangedBy, ChangeDate, Reason, Field, OldVal, NewVal),
        audit_log(LogID, TxnID, ChangedBy, ChangeDate, Reason, Field, OldVal, NewVal),
        Logs
    ).

% ---- 5.4  Log a Change (Reason Mandatory) ----
% log_change(+TxnID, +ChangedBy, +ChangeDate, +Reason,
%            +Field, +OldVal, +NewVal)
%
%   GUARD: If Reason is an empty string the record is BLOCKED.
%          A non-empty reason is required before any change persists.
%          New log entries are asserted into bank_records:audit_log/8.
log_change(_TxnID, _ChangedBy, _ChangeDate, '', _Field, _OldVal, _NewVal) :-
    !,
    format('ERROR: A reason for change is REQUIRED. Record not saved.~n').

log_change(TxnID, ChangedBy, ChangeDate, Reason, Field, OldVal, NewVal) :-
    gensym(log, LogID),
    assertz(bank_records:audit_log(
        LogID, TxnID, ChangedBy, ChangeDate, Reason, Field, OldVal, NewVal)),
    format('AUDIT LOG ~w | TXN ~w | Changed by: ~w | Field: ~w | ~w -> ~w | Reason: ~w~n',
           [LogID, TxnID, ChangedBy, Field, OldVal, NewVal, Reason]).
