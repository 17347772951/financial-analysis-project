-- ============================================================
-- SQL-24：不同支付方式成本对比（信用证 vs 电汇 vs 托收）
-- 学到的SQL概念：成本结构对比 / CASE WHEN分类
-- 面试能讲：信用证成本高但风险低，电汇成本低但对买方不利
-- ============================================================

SELECT
    cbp.payment_method,
    COUNT(DISTINCT cbp.project_id)                    AS project_count,
    ROUND(SUM(fxt.amount_rmb), 2)                     AS total_settlement_rmb,
    COUNT(fxt.fx_id)                                   AS transaction_count,
    ROUND(AVG(fxt.amount_rmb), 2)                      AS avg_transaction_size,

    -- 按经验费率估算支付成本
    ROUND(SUM(fxt.amount_rmb) *
        CASE
            WHEN cbp.payment_method = '信用证' THEN 0.003     -- 信用证约0.3%
            WHEN cbp.payment_method = '电汇'   THEN 0.001     -- 电汇约0.1%
            WHEN cbp.payment_method = '托收'   THEN 0.002     -- 托收约0.2%
            ELSE 0.0015
        END, 2
    ) AS estimated_payment_cost,

    -- 总汇兑损益
    ROUND(SUM(
        fxt.amount_foreign * cbp.contract_exchange_rate - fxt.amount_rmb
    ), 2) AS total_fx_gain_loss

FROM cross_border_project cbp
JOIN fx_transaction fxt ON cbp.project_id = fxt.project_id

GROUP BY cbp.payment_method
ORDER BY total_settlement_rmb DESC;
