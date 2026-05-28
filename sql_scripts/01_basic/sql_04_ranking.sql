-- ============================================================
-- SQL-04：子公司营收贡献度排名
-- 学到的SQL概念：ROW_NUMBER() / 窗口函数计算占比 / 累计占比
-- ============================================================

WITH company_total AS (
    -- ① 汇总每个子公司的总营收
    SELECT
        so.company_id,
        ci.company_name,
        ci.company_type,
        SUM(so.amount) AS total_revenue
    FROM sales_order so
    JOIN company_info ci ON so.company_id = ci.company_id
    GROUP BY so.company_id, ci.company_name, ci.company_type
),
grand_total AS (
    -- ② 集团总营收
    SELECT SUM(total_revenue) AS group_revenue FROM company_total
)
SELECT
    ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS ranking,   -- ★ 排名
    company_name,
    company_type,
    total_revenue,
    ROUND(total_revenue / group_revenue * 100, 2) AS pct,          -- ★ 占比
    ROUND(SUM(total_revenue) OVER (ORDER BY total_revenue DESC)
          / group_revenue * 100, 2) AS cumulative_pct              -- ★ 累计占比
FROM company_total, grand_total
ORDER BY total_revenue DESC;
