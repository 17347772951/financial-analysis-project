-- ============================================================
-- SQL-01：按月份+子公司汇总 营收/成本/毛利/毛利率
-- 学到的SQL概念：SELECT / JOIN / GROUP BY / SUM / 四则运算
-- ============================================================

SELECT
    -- ① 分组维度：按月份 + 公司
    DATE_FORMAT(so.order_date, '%Y-%m') AS period,   -- 日期→年月格式
    ci.company_name,                                   -- 公司名称
    ci.company_type,                                   -- 公司类型

    -- ② 聚合计算：SUM就是"加起来"
    SUM(so.amount)                       AS revenue,             -- 营收 = 所有销售金额求和
    SUM(so.cost_amount)                  AS cost_total,          -- 成本 = 所有销售成本求和
    SUM(so.amount) - SUM(so.cost_amount) AS gross_profit,       -- 毛利 = 营收 - 成本

    -- ③ 毛利率 = 毛利 / 营收 → ROUND(..., 4) 保留4位小数
    ROUND(
        (SUM(so.amount) - SUM(so.cost_amount)) / SUM(so.amount),
        4
    ) AS gross_margin,                                        -- 毛利率

    -- ④ 订单数统计
    COUNT(*) AS order_count                                    -- COUNT(*) = 数行数

FROM sales_order so
JOIN company_info ci ON so.company_id = ci.company_id         -- JOIN = 把两张表关联起来

GROUP BY
    DATE_FORMAT(so.order_date, '%Y-%m'),                      -- 按月份分组
    ci.company_name,
    ci.company_type

ORDER BY
    period DESC,                                              -- 最新月份在上
    ci.company_name;
