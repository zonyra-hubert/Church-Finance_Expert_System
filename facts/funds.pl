% ============================================================
%  MODULE: funds
%  Purpose: Church fund definitions and classification
%  Layer  : Facts (Knowledge Base)
%
%  fund(Fund_ID, Fund_Name, Fund_Type, Fund_Status)
%    Fund_Type  : restricted | unrestricted
%    Fund_Status: open | closed
%
%  Restricted   – money confined to a specific purpose
%                 (Building, Missions, Youth, etc.)
%  Unrestricted – General Tithe; freely allocatable
%
%  NOTE: No hardcoded facts.  All rows are loaded at startup
%        by db/loader.pl from the Neon (PostgreSQL) `funds` table.
% ============================================================
:- module(funds, [fund/4]).

:- dynamic fund/4.
