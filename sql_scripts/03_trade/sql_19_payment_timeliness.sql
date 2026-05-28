-- ============================================================
-- SQL-19：客户/供应商回款及时率排名
-- 学到的SQL概念：AVG(日期差) / 排名聚合
-- ============================================================

SELECT
    po.supplier_name,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN po.actual_pay_date <= po.payment_due_date THEN 1 ELSE 0 END) AS on_time_count,
    ROUND(
        SUM(CASE WHEN po.actual_pay_date <= po.payment_due_date THEN 1 ELSE 0 END)
        / COUNT(*) * 100, 2
    ) AS on_time_pct,
    ROUND(AVG(DATEDIFF(po.actual_pay_date, po.payment_due_date)), 1) AS avg_delay_days,
    ROUND(SUM(po.amount), 2) AS total_amount
FROM purchase_order po
WHERE po.payment_status = 'Paid'
  AND po.actual_pay_date IS NOT NULL
GROUP BY po.supplier_name
ORDER BY on_time_pct DESC;
