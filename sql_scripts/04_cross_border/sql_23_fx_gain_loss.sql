-- ============================================================
-- SQL-23：汇兑损益计算 ★★★★★ 面试王牌中的王牌
-- 核心公式：汇兑损益 = 外币金额 × 合同汇率 - 实际结算RMB
--   正数 = 汇兑收益（合同汇率 > 实际汇率，人民币拿得多）
--   负数 = 汇兑损失（合同汇率 < 实际汇率，人民币拿得少）
-- 学到的SQL概念：关联计算 / 外汇风险分析 / GROUP BY聚合
-- ============================================================

SELECT
    cbp.project_name,
    cbp.currency,
    cbp.contract_exchange_rate,

    -- 按月度汇兑损益
    fxt.transaction_date,
    fxt.amount_foreign,
    fxt.exchange_rate          AS actual_exchange_rate,
    fxt.amount_rmb             AS actual_rmb_received,

    -- ★ 汇兑损益核心计算
    -- 按合同汇率应得RMB = 外币金额 × 合同汇率
    ROUND(fxt.amount_foreign * cbp.contract_exchange_rate, 2) AS expected_rmb,
    -- 汇兑损益 = 应得RMB - 实际RMB
    ROUND(
        fxt.amount_foreign * cbp.contract_exchange_rate - fxt.amount_rmb, 2
    ) AS exchange_gain_loss,
    -- 损益方向
    CASE
        WHEN fxt.amount_foreign * cbp.contract_exchange_rate > fxt.amount_rmb
            THEN 'GAIN - 汇兑收益'
        WHEN fxt.amount_foreign * cbp.contract_exchange_rate < fxt.amount_rmb
            THEN 'LOSS - 汇兑损失'
        ELSE 'EVEN'
    END AS fx_direction,

    -- 汇兑损益占交易金额的比例
    ROUND(
        ABS(fxt.amount_foreign * cbp.contract_exchange_rate - fxt.amount_rmb)
        / NULLIF(fxt.amount_rmb, 0) * 100, 4
    ) AS fx_impact_pct

FROM cross_border_project cbp
JOIN fx_transaction fxt ON cbp.project_id = fxt.project_id

ORDER BY cbp.project_id, fxt.transaction_date;
