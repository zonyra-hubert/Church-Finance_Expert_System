-- ============================================================
--  CHURCH FINANCIAL MANAGEMENT EXPERT SYSTEM
--  Neon (PostgreSQL) Database Schema
--  Developed by IntelliGents  |  2026-03-02
--
--  Run once against your Neon database:
--    psql $DATABASE_URL -f schema.sql
-- ============================================================

-- ---- Members -----------------------------------------------
CREATE TABLE IF NOT EXISTS members (
    member_id          VARCHAR(10)  PRIMARY KEY,   -- e.g. m001
    full_name          VARCHAR(120) NOT NULL,
    status             VARCHAR(10)  NOT NULL        -- active | guest
        CHECK (status IN ('active', 'guest')),
    "12_month_salary"  NUMERIC(12,2) DEFAULT 0.00  -- member's annual salary used for context
        CHECK ("12_month_salary" >= 0)
);

-- ---- Funds -------------------------------------------------
CREATE TABLE IF NOT EXISTS funds (
    fund_id     VARCHAR(10)  PRIMARY KEY,   -- e.g. f001
    fund_name   VARCHAR(100) NOT NULL,
    fund_type   VARCHAR(20)  NOT NULL        -- restricted | unrestricted
        CHECK (fund_type IN ('restricted', 'unrestricted')),
    fund_status VARCHAR(10)  NOT NULL        -- open | closed
        CHECK (fund_status IN ('open', 'closed'))
);

-- ---- Budget Allocations ------------------------------------
CREATE TABLE IF NOT EXISTS budget (
    category         VARCHAR(50) PRIMARY KEY,
    allocated_amount NUMERIC(12,2) NOT NULL CHECK (allocated_amount >= 0)
);

-- ---- Year-to-Date Expense Spending -------------------------
CREATE TABLE IF NOT EXISTS expense_spent (
    category     VARCHAR(50) PRIMARY KEY
        REFERENCES budget(category) ON UPDATE CASCADE,
    amount_spent NUMERIC(12,2) NOT NULL DEFAULT 0
        CHECK (amount_spent >= 0)
);

-- ---- Transactions ------------------------------------------
-- Service_date = date of the church service
-- Entry_date   = date the record was physically keyed in
CREATE TABLE IF NOT EXISTS transactions (
    txn_id        VARCHAR(10)  PRIMARY KEY,
    member_id     VARCHAR(10)  REFERENCES members(member_id),  -- NULL = anonymous
    fund_id       VARCHAR(10)  NOT NULL REFERENCES funds(fund_id),
    amount        NUMERIC(12,2) NOT NULL CHECK (amount > 0),
    entry_method  VARCHAR(10)  NOT NULL
        CHECK (entry_method IN ('cash', 'check', 'digital')),
    service_date  DATE         NOT NULL,
    entry_date    DATE         NOT NULL,
    txn_type      VARCHAR(10)  NOT NULL
        CHECK (txn_type IN ('income', 'expense'))
);

-- ---- Historical Giving (12-month rolling) ------------------
CREATE TABLE IF NOT EXISTS historical_giving (
    member_id    VARCHAR(10)  NOT NULL REFERENCES members(member_id),
    giving_year  SMALLINT     NOT NULL,
    giving_month SMALLINT     NOT NULL CHECK (giving_month BETWEEN 1 AND 12),
    amount       NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    PRIMARY KEY (member_id, giving_year, giving_month)
);

-- ---- Bank Deposits -----------------------------------------
CREATE TABLE IF NOT EXISTS bank_deposits (
    deposit_date    DATE         PRIMARY KEY,
    total_deposited NUMERIC(12,2) NOT NULL CHECK (total_deposited >= 0)
);

-- ---- Audit Log ---------------------------------------------
CREATE TABLE IF NOT EXISTS audit_log (
    log_id        VARCHAR(20)  PRIMARY KEY,
    txn_id        VARCHAR(10)  NOT NULL REFERENCES transactions(txn_id),
    changed_by    VARCHAR(100) NOT NULL,
    change_date   DATE         NOT NULL,
    reason        TEXT         NOT NULL CHECK (reason <> ''),  -- reason is mandatory
    field_changed VARCHAR(50)  NOT NULL,
    old_value     TEXT         NOT NULL,
    new_value     TEXT         NOT NULL
);

-- ---- Adjusting Journal Entries (quarterly) -----------------
CREATE TABLE IF NOT EXISTS adjusting_journal_entries (
    period VARCHAR(20) PRIMARY KEY,   -- e.g. q1_2025
    count  SMALLINT    NOT NULL CHECK (count >= 0)
);

-- ---- Reconciliation Hours (quarterly) ----------------------
CREATE TABLE IF NOT EXISTS reconciliation_hours (
    period VARCHAR(20) PRIMARY KEY,
    hours  NUMERIC(6,2) NOT NULL CHECK (hours >= 0)
);

-- ---- Indexes for common query patterns ---------------------
CREATE INDEX IF NOT EXISTS idx_transactions_member   ON transactions(member_id);
CREATE INDEX IF NOT EXISTS idx_transactions_fund     ON transactions(fund_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type     ON transactions(txn_type);
CREATE INDEX IF NOT EXISTS idx_hist_giving_member    ON historical_giving(member_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_txn         ON audit_log(txn_id);
