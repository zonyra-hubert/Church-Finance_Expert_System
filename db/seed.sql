-- ============================================================
--  CHURCH FINANCIAL MANAGEMENT EXPERT SYSTEM
--  Neon (PostgreSQL) Seed Data
--  Developed by IntelliGents  |  2026-03-02
--
--  Migrated from hard-coded Prolog facts.
--  Run after schema.sql:
--    psql $DATABASE_URL -f seed.sql
-- ============================================================

-- ---- Members -----------------------------------------------
INSERT INTO members (member_id, full_name, status, "12_month_salary") VALUES
    ('m001', 'Kofi Mensah',     'active',  36000.00),
    ('m002', 'Ama Owusu',       'active',  48000.00),
    ('m003', 'Kwame Boateng',   'active',  30000.00),
    ('m004', 'Esi Asante',      'active',  42000.00),
    ('m005', 'Yaw Darko',       'active',  60000.00),
    ('m006', 'John Guest',      'guest',       0.00),
    ('m007', 'Abena Frimpong',  'active',  27000.00),
    ('m008', 'Nana Adjei',      'active',  33000.00)
ON CONFLICT (member_id) DO NOTHING;

-- ---- Funds -------------------------------------------------
INSERT INTO funds (fund_id, fund_name, fund_type, fund_status) VALUES
    ('f001', 'General Tithe',  'unrestricted', 'open'),
    ('f002', 'Building Fund',  'restricted',   'open'),
    ('f003', 'Missions Fund',  'restricted',   'open'),
    ('f004', 'Youth Program',  'restricted',   'open'),
    ('f005', 'Old Roof Fund',  'restricted',   'closed'),
    ('f006', 'Emergency Fund', 'restricted',   'open')
ON CONFLICT (fund_id) DO NOTHING;

-- ---- Budget ------------------------------------------------
INSERT INTO budget (category, allocated_amount) VALUES
    ('utilities',        5000.00),
    ('salaries',        30000.00),
    ('maintenance',      8000.00),
    ('outreach',         4000.00),
    ('office_supplies',  1500.00),
    ('events',           3000.00)
ON CONFLICT (category) DO NOTHING;

-- ---- Expense Spent -----------------------------------------
INSERT INTO expense_spent (category, amount_spent) VALUES
    ('utilities',        3200.00),
    ('salaries',        29500.00),
    ('maintenance',      7800.00),
    ('outreach',         3900.00),
    ('office_supplies',  1450.00),
    ('events',           3100.00)
ON CONFLICT (category) DO NOTHING;

-- ---- Transactions ------------------------------------------
INSERT INTO transactions
    (txn_id, member_id, fund_id, amount, entry_method, service_date, entry_date, txn_type)
VALUES
    ('t001', 'm001', 'f001',  500.00, 'cash',    '2026-02-01', '2026-02-02', 'income'),
    ('t002', 'm002', 'f002', 1000.00, 'check',   '2026-02-01', '2026-02-02', 'income'),
    ('t003', 'm003', 'f001',  250.00, 'digital', '2026-02-08', '2026-02-08', 'income'),
    ('t004', 'm004', 'f003',  300.00, 'cash',    '2026-02-08', '2026-02-09', 'income'),
    ('t005', 'm006', 'f001',  150.00, 'cash',    '2026-02-08', '2026-02-09', 'income'),  -- Guest → General Tithe
    ('t006', 'm005', 'f001', 4500.00, 'digital', '2026-02-15', '2026-02-15', 'income'),  -- ANOMALY
    ('t007', 'm001', 'f005',  200.00, 'cash',    '2026-02-15', '2026-02-15', 'income'),  -- CLOSED fund
    ('t008', NULL,   'f001',  100.00, 'cash',    '2026-02-22', '2026-02-22', 'income'),  -- anonymous
    ('t009', 'm007', 'f001',  400.00, 'check',   '2026-02-22', '2026-02-23', 'income'),
    ('t010', 'm008', 'f004',  600.00, 'digital', '2026-03-01', '2026-03-01', 'income')
ON CONFLICT (txn_id) DO NOTHING;

-- ---- Historical Giving -------------------------------------
INSERT INTO historical_giving (member_id, giving_year, giving_month, amount) VALUES
    -- Kofi Mensah (m001)
    ('m001', 2025,  3,  480.00), ('m001', 2025,  4,  500.00),
    ('m001', 2025,  5,  520.00), ('m001', 2025,  6,  490.00),
    ('m001', 2025,  7,  510.00), ('m001', 2025,  8,  500.00),
    ('m001', 2025,  9,  480.00), ('m001', 2025, 10,  520.00),
    ('m001', 2025, 11,  530.00), ('m001', 2025, 12,  500.00),
    ('m001', 2026,  1,  510.00), ('m001', 2026,  2,  490.00),
    -- Yaw Darko (m005)
    ('m005', 2025,  3,  700.00), ('m005', 2025,  4,  750.00),
    ('m005', 2025,  5,  720.00), ('m005', 2025,  6,  680.00),
    ('m005', 2025,  7,  710.00), ('m005', 2025,  8,  730.00),
    ('m005', 2025,  9,  740.00), ('m005', 2025, 10,  760.00),
    ('m005', 2025, 11,  700.00), ('m005', 2025, 12,  720.00),
    ('m005', 2026,  1,  810.00), ('m005', 2026,  2,  750.00),
    -- Ama Owusu (m002)
    ('m002', 2025,  3,  900.00), ('m002', 2025,  4,  950.00),
    ('m002', 2025,  5,  920.00), ('m002', 2025,  6,  880.00),
    ('m002', 2025,  7,  910.00), ('m002', 2025,  8,  930.00),
    ('m002', 2025,  9,  940.00), ('m002', 2025, 10,  960.00),
    ('m002', 2025, 11,  900.00), ('m002', 2025, 12,  920.00),
    ('m002', 2026,  1,  910.00), ('m002', 2026,  2,  950.00)
ON CONFLICT (member_id, giving_year, giving_month) DO NOTHING;

-- ---- Bank Deposits -----------------------------------------
INSERT INTO bank_deposits (deposit_date, total_deposited) VALUES
    ('2026-02-28', 7800.00)
ON CONFLICT (deposit_date) DO NOTHING;

-- ---- Audit Log (seed entries) ------------------------------
INSERT INTO audit_log
    (log_id, txn_id, changed_by, change_date, reason, field_changed, old_value, new_value)
VALUES
    ('log001', 't002', 'Admin Clerk',  '2026-02-03',
     'Corrected check amount entered in error', 'amount',  '900.0',  '1000.0'),
    ('log002', 't004', 'Finance Lead', '2026-02-10',
     'Donor confirmed correct fund verbally',   'fund_id', 'f001',   'f003')
ON CONFLICT (log_id) DO NOTHING;

-- ---- Adjusting Journal Entries -----------------------------
INSERT INTO adjusting_journal_entries (period, count) VALUES
    ('q1_2025', 18), ('q2_2025', 15), ('q3_2025', 11),
    ('q4_2025',  8), ('q1_2026',  3)
ON CONFLICT (period) DO NOTHING;

-- ---- Reconciliation Hours ----------------------------------
INSERT INTO reconciliation_hours (period, hours) VALUES
    ('q1_2025', 12.0), ('q2_2025', 10.5), ('q3_2025', 9.0),
    ('q4_2025',  6.5), ('q1_2026',  2.5)
ON CONFLICT (period) DO NOTHING;
