-- ============================================================
-- SQL-15：销售费用率 & 管理费用率分析（按月+公司）
-- 学到的SQL概念：费用率 = 费用/营收 / 多表关联
-- ============================================================

WITH monthly_revenue AS (
    SELECT DATE_FORMAT(order_date, '%Y-%m') AS period, company_id,
           SUM(amount) AS revenue
    FROM sales_order GROUP BY DATE_FORMAT(order_date, '%Y-%m'), company_id
),
monthly_expense AS (
    SELECT DATE_FORMAT(expense_date, '%Y-%m') AS period, company_id,
           SUM(CASE WHEN expense_type = _utf8mb4'销售费用' THEN amount ELSE 0 END) AS selling_exp,
           SUM(CASE WHEN expense_type = _utf8mb4'管理费用' THEN amount ELSE 0 END) AS admin_exp,
           SUM(CASE WHEN expense_type = _utf8mb4'研发费用' THEN amount ELSE 0 END) AS rd_exp,
           SUM(CASE WHEN expense_type = _utf8mb4'财务费用' THEN amount ELSE 0 END) AS finance_exp
    FROM expense GROUP BY DATE_FORMAT(expense_date, '%Y-%m'), company_id
)
SELECT
    mr.period, ci.company_name, ci.company_type,
    ROUND(mr.revenue, 2) AS revenue,
    ROUND(me.selling_exp, 2) AS selling_exp,
    ROUND(me.selling_exp / mr.revenue * 100, 2) AS selling_ratio,
    ROUND(me.admin_exp, 2) AS admin_exp,
    ROUND(me.admin_exp / mr.revenue * 100, 2) AS admin_ratio,
    ROUND(me.rd_exp, 2) AS rd_exp,
    ROUND(me.rd_exp / NULLIF(mr.revenue, 0) * 100, 2) AS rd_ratio,
    ROUND(me.finance_exp, 2) AS finance_exp
FROM monthly_revenue mr
JOIN monthly_expense me ON mr.period = me.period AND mr.company_id = me.company_id
JOIN company_info ci ON mr.company_id = ci.company_id
ORDER BY mr.period DESC, ci.company_name;
