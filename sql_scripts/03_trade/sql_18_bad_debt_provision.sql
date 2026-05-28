-- ============================================================
-- SQL-18：坏账准备计提计算（按账龄分段 × 不同计提比例）
-- 学到的SQL概念：分段计提 / 业务规则转化为SQL逻辑
-- 计提规则：0-30天=1%, 31-60=5%, 61-90=20%, 90+=50%
-- ============================================================

WITH aging_data AS (
    SELECT
        po.supplier_name,
        po.amount,
        DATEDIFF(CURDATE(), po.payment_due_date) AS overdue_days
    FROM purchase_order po
    WHERE po.payment_status = 'Unpaid'
),
categorized AS (
    SELECT
        supplier_name,
        amount,
        overdue_days,
        CASE
            WHEN overdue_days <= 0   THEN 0.01
            WHEN overdue_days <= 30  THEN 0.01
            WHEN overdue_days <= 60  THEN 0.05
            WHEN overdue_days <= 90  THEN 0.20
            ELSE 0.50
        END AS provision_rate
    FROM aging_data
)
SELECT
    supplier_name,
    COUNT(*)                        AS unpaid_count,
    ROUND(SUM(amount), 2)           AS total_unpaid,
    ROUND(SUM(amount * provision_rate), 2) AS bad_debt_provision,
    ROUND(AVG(provision_rate) * 100, 2)    AS avg_provision_rate_pct
FROM categorized
GROUP BY supplier_name
ORDER BY bad_debt_provision DESC;
