% ============================================================
%  MODULE: members
%  Purpose: Congregant master data
%  Layer  : Facts (Knowledge Base)
%
%  member(Member_ID, FullName, Status, TwelveMonthSalary)
%    Member_ID uniquely identifies each congregant, preventing
%    confusion between members who share similar names.
%    Status             : active | guest
%    TwelveMonthSalary  : member's 12-month salary (GHS) for financial context
%
%  NOTE: No hardcoded facts.  All rows are loaded at startup
%        by db/loader.pl from the Neon (PostgreSQL) `members` table.
%        Maps to column "12_month_salary" (quoted because it starts with a digit).
% ============================================================
:- module(members, [member/4]).

:- dynamic member/4.
