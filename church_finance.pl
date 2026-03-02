% ============================================================
%  CHURCH FINANCIAL MANAGEMENT EXPERT SYSTEM
%  Developed by IntelliGents
%  System Date: 2026-03-02
%
%  ENTRY POINT – loads all modular components.
%  Each layer is isolated in its own file; this file only
%  wires them together so any module can be replaced or
%  extended independently.
%
%  Module Tree
%  ───────────
%  church_finance.pl          ← you are here (loader / entry point)
%  │
%  ├── utils/
%  │   └── helpers.pl         ← shared arithmetic utilities
%  │
%  ├── facts/                 ← Knowledge Base (pure data, no rules)
%  │   ├── members.pl
%  │   ├── funds.pl
%  │   ├── transactions.pl
%  │   ├── budget.pl
%  │   ├── historical_giving.pl
%  │   └── bank_records.pl
%  │
%  ├── validation/            ← Input validation (1st line of defense)
%  │   └── validation.pl
%  │
%  ├── inference/             ← Expert / decision logic
%  │   ├── anomaly.pl         ← Pattern recognition (anomaly detection)
%  │   ├── constraints.pl     ← Constraint satisfaction rules
%  │   ├── expense_audit.pl   ← Budget constraint checking
%  │   └── metrics.pl         ← Entry method error-proneness analysis
%  │
%  ├── ledger/                ← Financial routing & approval
%  │   └── routing.pl
%  │
%  ├── accountability/        ← Reconciliation, audit trail, reporting
%  │   ├── reconciliation.pl
%  │   ├── audit_trail.pl
%  │   ├── performance.pl
%  │   └── tax_statements.pl
%  │
%  └── reporting/             ← Diagnostic report aggregator
%      └── reports.pl
%
% ============================================================
%  QUICK-START
%    Load  : ?- [church_finance].
%    Report: ?- run_full_audit.
% ============================================================

:- use_module(db/env_loader).
:- use_module(db/connection).
:- use_module(db/loader).
:- use_module(utils/helpers).
:- use_module(facts/members).
:- use_module(facts/funds).
:- use_module(facts/transactions).
:- use_module(facts/budget).
:- use_module(facts/historical_giving).
:- use_module(facts/bank_records).
:- use_module(validation/validation).
:- use_module(inference/anomaly).
:- use_module(inference/constraints).
:- use_module(inference/expense_audit).
:- use_module(inference/metrics).
:- use_module(ledger/routing).
:- use_module(accountability/reconciliation).
:- use_module(accountability/audit_trail).
:- use_module(accountability/performance).
:- use_module(accountability/tax_statements).
:- use_module(reporting/reports).
