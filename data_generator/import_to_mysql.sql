-- ============================================================
-- 批量导入 CSV 数据到 MySQL
-- 在命令行执行：mysql -u root -p123456 --local-infile=1 < import_to_mysql.sql
-- 或在 DBeaver 中逐段执行
-- ============================================================

USE financial_analysis_db;

SET FOREIGN_KEY_CHECKS = 0;

-- 先清空所有表
TRUNCATE fx_transaction;
TRUNCATE cross_border_project;
TRUNCATE income_statement;
TRUNCATE expense;
TRUNCATE purchase_order;
TRUNCATE sales_order;
TRUNCATE bom;
TRUNCATE production_order;
TRUNCATE customer;
TRUNCATE product;
TRUNCATE company_info;

-- 基础信息表
LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/company_info.csv'
INTO TABLE company_info
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/product.csv'
INTO TABLE product
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/customer.csv'
INTO TABLE customer
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 业务表
LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/bom.csv'
INTO TABLE bom
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/production_order.csv'
INTO TABLE production_order
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/sales_order.csv'
INTO TABLE sales_order
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/purchase_order.csv'
INTO TABLE purchase_order
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/expense.csv'
INTO TABLE expense
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 财务表
LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/income_statement.csv'
INTO TABLE income_statement
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/cross_border_project.csv'
INTO TABLE cross_border_project
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE 'd:/xiangm/caiwuxiagnmu/data_generator/output/fx_transaction.csv'
INTO TABLE fx_transaction
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SET FOREIGN_KEY_CHECKS = 1;

-- 验证
SELECT 'company_info' AS tbl, COUNT(*) AS cnt FROM company_info
UNION ALL SELECT 'product', COUNT(*) FROM product
UNION ALL SELECT 'customer', COUNT(*) FROM customer
UNION ALL SELECT 'bom', COUNT(*) FROM bom
UNION ALL SELECT 'production_order', COUNT(*) FROM production_order
UNION ALL SELECT 'sales_order', COUNT(*) FROM sales_order
UNION ALL SELECT 'purchase_order', COUNT(*) FROM purchase_order
UNION ALL SELECT 'expense', COUNT(*) FROM expense
UNION ALL SELECT 'income_statement', COUNT(*) FROM income_statement
UNION ALL SELECT 'cross_border_project', COUNT(*) FROM cross_border_project
UNION ALL SELECT 'fx_transaction', COUNT(*) FROM fx_transaction;
