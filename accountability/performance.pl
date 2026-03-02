% ============================================================
%  MODULE: performance
%  Purpose: Track reduction in Adjusting Journal Entries (AJE)
%           and hours saved on reconciliation to prove system
%           efficacy over time.
%  Layer  : Accountability
% ============================================================
:- module(performance, [
    aje_reduction/4,
    hours_saved/3
]).

:- use_module('../facts/bank_records').

% ---- 5.5  Adjusting Journal Entry Reduction ----
% aje_reduction(+PeriodA, +PeriodB, -Reduction, -PctImprovement)
%   Compares AJE counts between two periods.
%   A falling count signals that the expert system is preventing
%   the manual errors that necessitate adjusting entries.
aje_reduction(PeriodA, PeriodB, Reduction, PctImprovement) :-
    adjusting_journal_entries(PeriodA, CountA),
    adjusting_journal_entries(PeriodB, CountB),
    Reduction is CountA - CountB,
    ( CountA > 0
    ->  PctImprovement is (Reduction / CountA) * 100
    ;   PctImprovement = 0.0
    ).

% ---- 5.6  Reconciliation Hours Saved ----
% hours_saved(+PeriodA, +PeriodB, -HoursSaved)
%   Measures the reduction in manual reconciliation time between
%   two periods as direct evidence of system efficiency gains.
hours_saved(PeriodA, PeriodB, HoursSaved) :-
    reconciliation_hours(PeriodA, HoursA),
    reconciliation_hours(PeriodB, HoursB),
    HoursSaved is HoursA - HoursB.
