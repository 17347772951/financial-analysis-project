# -*- coding: utf-8 -*-
"""将 CSV 文件批量导入 MySQL"""
import pymysql
import csv
import os

conn = pymysql.connect(
    host='127.0.0.1', user='root', password='123456',
    database='financial_analysis_db', charset='utf8mb4'
)
cursor = conn.cursor()
cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")

csv_dir = "d:/xiangm/caiwuxiagnmu/data_generator/output"

files = [
    ("company_info.csv",        "company_info"),
    ("product.csv",             "product"),
    ("customer.csv",            "customer"),
    ("bom.csv",                 "bom"),
    ("production_order.csv",    "production_order"),
    ("sales_order.csv",         "sales_order"),
    ("purchase_order.csv",      "purchase_order"),
    ("expense.csv",             "expense"),
    ("income_statement.csv",    "income_statement"),
    ("cross_border_project.csv","cross_border_project"),
    ("fx_transaction.csv",      "fx_transaction"),
]

for filename, table in files:
    filepath = os.path.join(csv_dir, filename)
    if not os.path.exists(filepath):
        print(f"  [SKIP] {filename} not found")
        continue

    cursor.execute(f"TRUNCATE {table};")

    with open(filepath, "r", encoding="utf-8-sig") as f:
        reader = csv.reader(f)
        headers = next(reader)
        placeholders = ",".join(["%s"] * len(headers))
        cols = ",".join(headers)
        sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders})"

        count = 0
        for row in reader:
            # Convert empty strings to None for NULL values
            clean_row = [v.strip() if v and v.strip() != '' else None for v in row]
            cursor.execute(sql, clean_row)
            count += 1

        conn.commit()
        print(f"  [OK] {table}: {count} rows imported")

cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
cursor.close()
conn.close()

print("\nAll done!")
