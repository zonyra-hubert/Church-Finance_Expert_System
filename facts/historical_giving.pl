% ============================================================
%  MODULE: historical_giving
%  Purpose: 12-month rolling giving history per member
%  Layer  : Facts (Knowledge Base)
%
%  historical_giving(Member_ID, ym(Year, Month), Amount_GHS)
%
%  Used by the anomaly detection engine to compute a member's
%  12-month average giving and flag statistically large outliers.
%
%  NOTE: No hardcoded facts.  All rows are loaded at startup
%        by db/loader.pl from the Neon (PostgreSQL)
%        `historical_giving` table.
% ============================================================
:- module(historical_giving, [historical_giving/3]).

:- dynamic historical_giving/3.
