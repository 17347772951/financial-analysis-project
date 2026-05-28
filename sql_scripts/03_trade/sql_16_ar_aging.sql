-- ============================================================
-- SQL-16：应收账款账龄分析
-- 学到的SQL概念：DATEDIFF / CASE WHEN 分段 / 账龄区间
-- 面试重点：能讲清楚账龄分析对现金流管理的重要性
-- ============================================================

SELECT
    po.supplier_name AS customer_name,
    SUM(po.amount)   AS total_ar,
    -- 账龄分段
    SUM(CASE WHEN DATEDIFF(CURDATE(), po.payment_due_date) <= 30
        THEN po.amount ELSE 0 END) AS aging_0_30,
    SUM(CASE WHEN DATEDIFF(CURDATE(), po.payment_due_date) BETWEEN 31 AND 60
        THEN po.amount ELSE 0 END) AS aging_31_60,
    SUM(CASE WHEN DATEDIFF(CURDATE(), po.payment_due_date) BETWEEN 61 AND 90
        THEN po.amount ELSE 0 END) AS aging_61_90,
    SUM(CASE WHEN DATEDIFF(CURDATE(), po.payment_due_date) > 90
        THEN po.amount ELSE 0 END) AS aging_90_plus
FROM purchase_order po
WHERE po.payment_status = 'Unpaid'
GROUP BY po.supplier_name
ORDER BY total_ar DESC;
