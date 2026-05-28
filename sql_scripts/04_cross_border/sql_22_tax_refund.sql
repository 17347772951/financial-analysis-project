-- ============================================================
-- SQL-22：出口退税测算（按项目汇总）
-- 学到的SQL概念：税务计算逻辑 / 退税公式
-- 出口退税额 = 出口金额(人民币) × 退税率
-- ============================================================

WITH export_sales AS (
    SELECT
        so.order_id,
        so.order_date,
        so.amount,
        cbp.project_id,
        cbp.project_name,
        cbp.tax_refund_rate,
        cbp.currency,
        cbp.contract_exchange_rate,
        -- 如果是非CNY结算，折算为人民币金额
        so.amount AS amount_rmb
    FROM sales_order so
    JOIN cross_border_project cbp ON so.customer_id = cbp.customer_id
    WHERE so.sale_type = 'Export'
)
SELECT
    project_name,
    currency,
    tax_refund_rate,
    COUNT(*)                                  AS transaction_count,
    ROUND(SUM(amount_rmb), 2)                  AS total_export_amount_rmb,
    -- 退税金额 = 出口金额 × 退税率
    ROUND(SUM(amount_rmb) * MAX(tax_refund_rate) / 100, 2) AS estimated_tax_refund,
    ROUND(AVG(amount_rmb), 2)                  AS avg_transaction_size
FROM export_sales
GROUP BY project_id, project_name, currency, tax_refund_rate
ORDER BY total_export_amount_rmb DESC;
