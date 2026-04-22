# ⛪ Church Financial Management Expert System

### Developed by IntelliGents

### Version 1.0 | March 2026

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [Architecture](#2-architecture)
3. [Prerequisites & Installation](#3-prerequisites--installation)
4. [Database Setup (Neon PostgreSQL)](#4-database-setup-neon-postgresql)
5. [Configuration](#5-configuration)
6. [Starting the System](#6-starting-the-system)
7. [User Guide — All Commands](#7-user-guide--all-commands)
8. [Inference Engine Rules](#8-inference-engine-rules)
9. [Financial Routing Logic](#9-financial-routing-logic)
10. [Reconciliation & Accountability](#10-reconciliation--accountability)
11. [Error Reference](#11-error-reference)
12. [Module Reference](#12-module-reference)
13. [Security & Best Practices](#13-security--best-practices)
14. [Glossary](#14-glossary)

---

## 1. System Overview

The **Church Financial Management Expert System** is a rule-based
expert system built in **SWI-Prolog** with a live **Neon PostgreSQL**
cloud database backend. It automates the financial operations of a
church by:

- Validating all income and expense entries at the point of capture
- Detecting anomalous transactions using historical giving patterns
- Routing funds to the correct accounting ledger automatically
- Enforcing budget constraints and escalating overspending
- Reconciling manual entries against actual bank deposits
- Generating end-of-year tax contribution statements
- Maintaining a tamper-evident audit trail for every record change

### Key Facts

| Property     | Value                   |
| ------------ | ----------------------- |
| Language     | SWI-Prolog 9.x          |
| Database     | Neon PostgreSQL (cloud) |
| Architecture | 18 modular components   |
| Entry Point  | `church_finance.pl`     |
| Developer    | IntelliGents            |
| System Date  | 2026-03-02              |

---

## 2. Architecture

```
church_finance.pl          ← Entry point (loader only)
│
├── db/                    ← Database layer
│   ├── env_loader.pl      ← Reads .env file at startup
│   ├── connection.pl      ← ODBC connection to Neon Postgres
│   ├── loader.pl          ← Loads DB rows into Prolog facts
│   ├── schema.sql         ← Table definitions
│   └── seed.sql           ← Sample data
│
├── utils/
│   └── helpers.pl         ← Shared arithmetic utilities
│
├── facts/                 ← Knowledge Base (pure data, no rules)
│   ├── members.pl         ← member/4 dynamic facts
│   ├── funds.pl           ← fund/4 dynamic facts
│   ├── transactions.pl    ← transaction/8 dynamic facts
│   ├── budget.pl          ← budget/2, expense_spent/2
│   ├── historical_giving.pl  ← historical_giving/3
│   └── bank_records.pl    ← bank_deposit/2, audit_log/8
│
├── validation/
│   └── validation.pl      ← Input guards (member, fund, method)
│
├── inference/             ← Expert decision logic
│   ├── anomaly.pl         ← 500% threshold detection
│   ├── constraints.pl     ← Fund/guest/attribution rules
│   ├── expense_audit.pl   ← Budget constraint checking
│   └── metrics.pl         ← Error-prone channel analysis
│
├── ledger/
│   └── routing.pl         ← Restricted/General ledger routing
│
├── accountability/
│   ├── reconciliation.pl  ← Bank vs manual totals
│   ├── audit_trail.pl     ← Change logging with reason guard
│   ├── performance.pl     ← AJE reduction, hours saved
│   └── tax_statements.pl  ← Year-end contribution statements
│
└── reporting/
    └── reports.pl         ← run_full_audit/0 aggregator
```

### Data Flow

```
User Input
    │
    ▼
[Validation Layer] ──FAIL──► Error Message to User
    │
   PASS
    │
    ▼
[Inference Engine]
    ├── Anomaly Check   ──FLAG──► "Verification Needed"
    ├── Constraint Check──FAIL──► Reject + Reason
    └── Budget Check    ──OVER──► Escalate to Finance Committee
    │
   PASS
    │
    ▼
[Financial Router]
    ├── Income + Restricted Fund  ──► Restricted Ledger
    ├── Income + Unrestricted Fund──► General Ledger
    └── Expense within budget     ──► Approve + Receipt
    │
    ▼
[Accountability Layer]
    ├── Reconciliation (manual vs bank)
    ├── Audit Trail (every change logged)
    ├── Performance Metrics
    └── Tax Statement Generation
```

---

## 3. Prerequisites & Installation

### 3.1 Required Software

| Software        | Version      | Download                                                   |
| --------------- | ------------ | ---------------------------------------------------------- |
| SWI-Prolog      | 9.x (64-bit) | https://www.swi-prolog.org/download                        |
| psqlODBC Driver | Latest x64   | https://github.com/postgresql-interfaces/psqlodbc/releases |

### 3.2 Install SWI-Prolog

1. Download the **Windows 64-bit installer** from the link above
2. Run the installer — accept all defaults
3. Verify in PowerShell:

```powershell
swipl --version
```

Expected output: `SWI-Prolog version 9.x.x`

### 3.3 Install psqlODBC Driver

1. Go to the releases page above
2. Download `psqlodbc_##_##_####-x64.msi`
3. Run the MSI — accept all defaults
4. Verify in PowerShell:

```powershell
Get-OdbcDriver -Name "PostgreSQL*"
```

Expected output: `PostgreSQL Unicode(x64)`

### 3.4 Install the pgsql SWI-Prolog Pack

Open SWI-Prolog and run:

```prolog
?- pack_install(pgsql).
```

---

## 4. Database Setup (Neon PostgreSQL)

### 4.1 Create a Neon Account

1. Go to https://console.neon.tech
2. Sign up / log in
3. Create a new **Project** named `church_finance`
4. Copy the **connection string** from the dashboard

### 4.2 Apply the Schema

Paste the contents of `db/schema.sql` into the **Neon SQL Editor**
and click **Run**. This creates all required tables:

| Table               | Purpose                                           |
| ------------------- | ------------------------------------------------- |
| `members`           | Congregant records including 12-month salary      |
| `funds`             | Church fund definitions (restricted/unrestricted) |
| `transactions`      | All income and expense entries                    |
| `budget`            | Per-category budget allocations                   |
| `expense_spent`     | Year-to-date spending per category                |
| `historical_giving` | 12-month rolling giving averages                  |
| `bank_deposits`     | Actual bank deposit records                       |
| `audit_log`         | Immutable record of all changes                   |

### 4.3 Load Sample Data (Optional)

Paste the contents of `db/seed.sql` into the Neon SQL Editor
and click **Run**.

---

## 5. Configuration

### 5.1 The `.env` File

The file `d:\prolog\.env` holds your database credentials.
It is **never committed to version control** (protected by `.gitignore`).

Your `.env` should contain exactly:

```dotenv
PGHOST='ep-your-neon-host.neon.tech'
PGDATABASE='neondb'
PGUSER='neondb_owner'
PGPASSWORD='your_password_here'
PGSSLMODE='require'
PGCHANNELBINDING='require'
```

### 5.2 Environment Variable Reference

| Variable           | Required    | Description                      |
| ------------------ | ----------- | -------------------------------- |
| `PGHOST`           | ✅ Yes      | Neon PostgreSQL host URL         |
| `PGDATABASE`       | ✅ Yes      | Database name (usually `neondb`) |
| `PGUSER`           | ✅ Yes      | Database username                |
| `PGPASSWORD`       | ✅ Yes      | Database password                |
| `PGSSLMODE`        | ✅ Yes      | Must be `require` for Neon       |
| `PGCHANNELBINDING` | ✅ Yes      | Must be `require` for Neon       |
| `PGPORT`           | ❌ Optional | Defaults to `5432`               |

### 5.3 The `.env.example` File

A safe template is provided in `d:\prolog\.env.example`.
Copy it to `.env` and fill in your real values:

```powershell
Copy-Item .env.example .env
notepad .env
```

---

## 6. Starting the System

### 6.1 Normal Start

```powershell
cd d:\prolog
swipl -l church_finance.pl
```

### 6.2 Expected Startup Output

```
[DB] .env loaded.
[DB] Connecting to Neon Postgres...
[DB]   members loaded:          8 rows
[DB]   funds loaded:             6 rows
[DB]   transactions loaded:     10 rows
[DB]   budget loaded:            5 rows
[DB]   expense_spent loaded:     5 rows
[DB]   historical_giving loaded: 8 rows
[DB]   bank_deposits loaded:     3 rows
[DB]   audit_log loaded:         4 rows
[DB] All facts loaded successfully.
?-
```

The `?-` prompt means the system is **ready for queries**.

### 6.3 Run a Full Audit Immediately

```powershell
swipl -l church_finance.pl -g "run_full_audit, halt"
```

### 6.4 Exit the System

```prolog
?- halt.
```

---

## 7. User Guide — All Commands

---

### 7.1 Run the Full Audit Report

**What it does:** Executes all 12 audit sections in sequence —
anomalies, constraints, budget, routing, reconciliation,
performance, and tax statements.

```prolog
?- run_full_audit.
```

---

### 7.2 Member Management

#### View all members

```prolog
?- member(MemberID, Name, Status, Salary).
```

#### Find a specific member by ID

```prolog
?- member(m001, Name, Status, Salary).
```

#### Check if a member is valid

```prolog
?- valid_member(m001).
```

Returns `true` or `false`.

#### Add a new member

```prolog
?- assert(member(m009, 'John Doe', active, 24000.00)).
```

| Argument        | Type  | Values               |
| --------------- | ----- | -------------------- |
| Member_ID       | Atom  | Unique e.g. `m009`   |
| Full Name       | Atom  | Quoted string        |
| Status          | Atom  | `active` or `guest`  |
| 12-Month Salary | Float | Annual salary in GHS |

---

### 7.3 Fund Management

#### View all funds

```prolog
?- fund(FundID, Name, Type, Status).
```

#### Check if a fund is valid

```prolog
?- validate_fund(f001, Status).
```

Returns `valid`, `closed_fund`, or `nonexistent_fund`.

#### View only open funds

```prolog
?- fund(FundID, Name, Type, open).
```

#### View only restricted funds

```prolog
?- fund(FundID, Name, restricted, open).
```

---

### 7.4 Transaction Management

#### View all transactions

```prolog
?- transaction(TxnID, MemberID, FundID, Amount,
               Method, ServiceDate, EntryDate, Type).
```

#### Record a new income transaction

```prolog
?- assert(transaction(
    t011,              % Transaction ID (unique)
    m001,              % Member ID
    f001,              % Fund ID
    500.00,            % Amount (GHS)
    digital,           % Entry method: cash / check / digital
    date(2026,3,2),    % Service date
    date(2026,3,2),    % Entry date
    income             % Type: income / expense
)).
```

#### Record a new expense

```prolog
?- assert(transaction(
    t012,
    m001,
    f003,
    200.00,
    check,
    date(2026,3,2),
    date(2026,3,2),
    expense
)).
```

#### View transactions for a specific member

```prolog
?- transaction(TxnID, m001, FundID, Amount, _, _, _, _).
```

#### View all income transactions

```prolog
?- transaction(TxnID, _, _, Amount, _, _, _, income).
```

---

### 7.5 Anomaly Detection

#### Check all anomalous transactions

```prolog
?- anomalous_transaction(TxnID, MemberID, Amount, AvgGiving).
```

Flags any transaction exceeding **500% (5×)** of the
member's 12-month average giving.

#### Check a specific member's average giving

```prolog
?- twelve_month_average(m001, Average).
```

---

### 7.6 Constraint Checks

#### Check for invalid fund transactions

```prolog
?- invalid_fund_transaction(TxnID, FundID, Reason).
```

Returns `closed_fund` or `nonexistent_fund` as the reason.

#### Check for guest tithe alerts

```prolog
?- guest_tithe_alert(TxnID, MemberID).
```

Fires when a guest member submits a tithe — prompts
creation of a new member profile.

---

### 7.7 Expense & Budget Management

#### Check budget remaining for a category

```prolog
?- budget_remaining(operations, Remaining).
```

Available categories:

- `operations`
- `missions`
- `building`
- `events`
- `welfare`

#### Check if an expense is within budget

```prolog
?- within_budget(operations, 500.00).
```

#### Check if an expense exceeds budget

```prolog
?- expense_exceeds_budget(operations, 5000.00, Overage).
```

#### Approve or escalate an expense

```prolog
?- approve_expense(operations, 800.00, Decision, Message).
```

| Result                 | Meaning                                |
| ---------------------- | -------------------------------------- |
| `Decision = approved`  | Within budget — receipt generated      |
| `Decision = escalated` | Over budget — Finance Committee review |

---

### 7.8 Financial Ledger Routing

#### Route income to restricted ledger

```prolog
?- route_to_restricted_ledger(t011, f002, 500.00).
```

#### Route income to general ledger

```prolog
?- route_to_general_ledger(t011, f001, 500.00).
```

#### Auto-route based on fund type

```prolog
?- transaction(TxnID, _, FundID, Amount, _, _, _, income),
   fund(FundID, _, restricted, open),
   route_to_restricted_ledger(TxnID, FundID, Amount).
```

---

### 7.9 Bank Reconciliation

#### Reconcile against a bank deposit

```prolog
?- reconcile(date(2026,2,28), 7800.00, Status, Discrepancy).
```

Replace `7800.00` with the **actual bank deposit total**.

| Status              | Meaning                           |
| ------------------- | --------------------------------- |
| `matched`           | System total equals bank total    |
| `discrepancy_found` | Difference shown in `Discrepancy` |

#### View total manual income

```prolog
?- total_manual_income(Total).
```

---

### 7.10 Audit Trail

#### Log a change to a record

```prolog
?- log_change(
    t001,              % Transaction ID
    'Admin',           % Changed by
    date(2026,3,2),    % Date of change
    'Corrected fund',  % Reason (CANNOT be empty)
    fund_id,           % Field changed
    f001,              % Old value
    f002               % New value
).
```

⚠️ **The system blocks the save if Reason is empty (`''`).**

#### View full audit history for a transaction

```prolog
?- audit_history(t001, History).
```

#### View all audit log entries

```prolog
?- audit_log(TxnID, ChangedBy, Date, Reason,
             Field, OldVal, NewVal, _).
```

---

### 7.11 Performance Metrics

#### Check AJE (Adjusting Journal Entry) reduction

```prolog
?- aje_reduction(Before, After, Reduction, Percentage).
```

#### Check reconciliation hours saved

```prolog
?- hours_saved(Before, After, Saved).
```

#### Check error-prone entry channels

```prolog
?- error_prone_channel(Method, ErrorCount).
```

---

### 7.12 Tax Statements

#### Generate statement for one member

```prolog
?- tax_statement(m001, 2026).
```

#### Generate statements for all members

```prolog
?- generate_all_tax_statements(2026).
```

Sample output:

```
====================================================
  OFFICIAL CONTRIBUTION STATEMENT — 2026
  Member : Kwame Asante (m001)
  Status : active
  Total Contributions: GHS 3,450.00
  This statement is issued for tax purposes.
====================================================
```

---

## 8. Inference Engine Rules

| Rule                     | Trigger                          | Action                          |
| ------------------------ | -------------------------------- | ------------------------------- |
| Anomaly Detection        | Amount > 5× 12-month average     | Flag "Verification Needed"      |
| Invalid Fund             | Fund is closed or does not exist | Reject transaction              |
| Guest Tithe              | Guest submits a tithe            | Prompt to create member profile |
| Expense Over Budget      | Expense > budget allocation      | Escalate to Finance Committee   |
| Unattributed Transaction | No valid Member_ID               | Flag for manual review          |

---

## 9. Financial Routing Logic

```
New Transaction
      │
      ├─── Type = income ─┬─ Fund = restricted  ──► Restricted Ledger
      │                   └─ Fund = unrestricted ──► General Ledger
      │
      └─── Type = expense ─┬─ Within budget  ──► Approve + Receipt
                           └─ Over budget    ──► Finance Committee
```

---

## 10. Reconciliation & Accountability

### Bank Reconciliation Process

1. System sums all `income` transactions for the period
2. Compares against the provided bank deposit total
3. Returns `matched` or `discrepancy_found` with exact GHS difference
4. Finance team investigates any discrepancy

### Audit Trail Rules

- **Every** field change requires a written reason
- Empty reason strings are **blocked** by the system
- All audit entries are **permanent** (`assertz` — never retracted)
- Each entry records: who changed it, when, what field,
  old value, new value, and reason

### Tax Statement Compliance

- Generated per member per year
- Includes total contributions across all funds
- Formatted for submission to tax authorities
- Covers both restricted and unrestricted giving

---

## 11. Error Reference

| Error Message                   | Cause                             | Fix                                             |
| ------------------------------- | --------------------------------- | ----------------------------------------------- |
| `[DB] ERROR: PGHOST not set`    | `.env` not loaded or missing      | Check `.env` file exists and has correct values |
| `[DB] ERROR: Connection failed` | Wrong credentials or Neon offline | Verify `.env` values match Neon dashboard       |
| `ERROR: Driver not found`       | psqlODBC not installed            | Install psqlODBC x64 MSI                        |
| `false` on `valid_member`       | Member ID not in database         | Check member exists; add if new                 |
| `false` on `validate_fund`      | Fund ID not in database           | Check fund ID spelling                          |
| Audit log blocked               | Reason field is empty             | Provide a non-empty reason string               |
| `anomalous_transaction` fires   | Amount > 5× average               | Verify the entry; confirm if legitimate         |

---

## 12. Module Reference

| Module            | File                               | Exports                                                     |
| ----------------- | ---------------------------------- | ----------------------------------------------------------- |
| DB Loader         | `db/env_loader.pl`                 | `load_dotenv/0`                                             |
| DB Connection     | `db/connection.pl`                 | `db_connect/1`, `db_disconnect/1`                           |
| DB Facts Loader   | `db/loader.pl`                     | `db_load_all/0`                                             |
| Helpers           | `utils/helpers.pl`                 | `sum_list_amounts/2`                                        |
| Members           | `facts/members.pl`                 | `member/4`                                                  |
| Funds             | `facts/funds.pl`                   | `fund/4`                                                    |
| Transactions      | `facts/transactions.pl`            | `transaction/8`                                             |
| Budget            | `facts/budget.pl`                  | `budget/2`, `expense_spent/2`                               |
| Historical Giving | `facts/historical_giving.pl`       | `historical_giving/3`                                       |
| Bank Records      | `facts/bank_records.pl`            | `bank_deposit/2`, `audit_log/8`                             |
| Validation        | `validation/validation.pl`         | `valid_member/1`, `validate_fund/2`                         |
| Anomaly           | `inference/anomaly.pl`             | `anomalous_transaction/4`                                   |
| Constraints       | `inference/constraints.pl`         | `invalid_fund_transaction/3`, `guest_tithe_alert/2`         |
| Expense Audit     | `inference/expense_audit.pl`       | `approve_expense/4`, `budget_remaining/2`                   |
| Metrics           | `inference/metrics.pl`             | `error_prone_channel/2`                                     |
| Routing           | `ledger/routing.pl`                | `route_to_restricted_ledger/3`, `route_to_general_ledger/3` |
| Reconciliation    | `accountability/reconciliation.pl` | `reconcile/4`, `total_manual_income/1`                      |
| Audit Trail       | `accountability/audit_trail.pl`    | `log_change/7`, `audit_history/2`                           |
| Performance       | `accountability/performance.pl`    | `aje_reduction/4`, `hours_saved/3`                          |
| Tax Statements    | `accountability/tax_statements.pl` | `tax_statement/2`, `generate_all_tax_statements/1`          |
| Reports           | `reporting/reports.pl`             | `run_full_audit/0`                                          |

---

## 13. Security & Best Practices

### Credential Security

- ✅ `.env` is listed in `.gitignore` — never committed
- ✅ Use `.env.example` as the committed template
- ✅ Rotate `PGPASSWORD` every 90 days via Neon dashboard
- ✅ Never hardcode credentials in any `.pl` file
- ❌ Never share `.env` over email or chat

### Data Integrity

- Always use unique Transaction IDs (`t001`, `t002`, etc.)
- Never retract audit log entries
- Always provide a reason when calling `log_change/7`
- Run `run_full_audit` at least once per week

### Backups

- Neon provides automatic daily backups
- Export data monthly via Neon dashboard → **Backup** tab
- Keep a local copy of `schema.sql` and `seed.sql`

---

## 14. Glossary

| Term                  | Definition                                                              |
| --------------------- | ----------------------------------------------------------------------- |
| **AJE**               | Adjusting Journal Entry — a correction made after initial recording     |
| **Restricted Fund**   | Donations designated for a specific purpose (e.g. Building Fund)        |
| **Unrestricted Fund** | General donations used at the church's discretion                       |
| **Member_ID**         | Unique identifier for each congregant (e.g. `m001`)                     |
| **Entry Method**      | How payment was received: `cash`, `check`, or `digital`                 |
| **Anomaly Threshold** | 500% (5×) of a member's 12-month giving average                         |
| **Inference Engine**  | The rule-based logic that makes automated decisions                     |
| **ODBC**              | Open Database Connectivity — the driver connecting Prolog to PostgreSQL |
| **Neon**              | Cloud-hosted serverless PostgreSQL provider                             |
| **Audit Trail**       | Immutable log of every change made to financial records                 |
| **Reconciliation**    | Comparing system totals against actual bank deposit amounts             |

---

_Document generated by IntelliGents | Church Financial Management Expert System v1.0_
_
