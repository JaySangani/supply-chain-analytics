"""
Supply Chain Analytics — Data Cleaning
Author: Jay Sangani
Project: Supply Chain Operations Analytics Dashboard
Dataset: Supply Chain Analysis (Kaggle)
"""

import pandas as pd
import numpy as np

# ── 1. Load raw data ──────────────────────────────────────────────────
print("Loading raw data...")
df = pd.read_csv("data/raw_supply_chain.csv")

print(f"Raw shape: {df.shape}")
print(f"\nColumn names:\n{df.columns.tolist()}")
print(f"\nData types:\n{df.dtypes}")
print(f"\nMissing values:\n{df.isnull().sum()}")

# ── 2. Standardise column names ───────────────────────────────────────
# Strip whitespace and lowercase all column names for consistency
df.columns = df.columns.str.strip().str.lower().str.replace(" ", "_")
print(f"\nStandardised columns:\n{df.columns.tolist()}")

# ── 3. Handle missing values ──────────────────────────────────────────
print("\n--- Handling missing values ---")

# Drop rows where key business fields are null
key_fields = ["product_type", "sku", "price", "revenue_generated"]
before = len(df)
df = df.dropna(subset=key_fields)
print(f"Dropped {before - len(df)} rows with nulls in key fields")

# Fill numeric nulls with median (safer than mean for skewed data)
numeric_cols = df.select_dtypes(include=[np.number]).columns
for col in numeric_cols:
    if df[col].isnull().sum() > 0:
        median_val = df[col].median()
        df[col] = df[col].fillna(median_val)
        print(f"  Filled '{col}' nulls with median: {median_val:.2f}")

# Fill categorical nulls with 'Unknown'
cat_cols = df.select_dtypes(include=["object"]).columns
for col in cat_cols:
    if df[col].isnull().sum() > 0:
        df[col] = df[col].fillna("Unknown")
        print(f"  Filled '{col}' nulls with 'Unknown'")

# ── 4. Remove duplicates ──────────────────────────────────────────────
before = len(df)
df = df.drop_duplicates()
print(f"\nRemoved {before - len(df)} duplicate rows")

# ── 5. Fix data types ─────────────────────────────────────────────────
print("\n--- Fixing data types ---")

# Convert percentage columns (remove % signs if present)
pct_cols = [c for c in df.columns if "rate" in c or "defect" in c]
for col in pct_cols:
    if df[col].dtype == object:
        df[col] = df[col].str.replace("%", "").astype(float)
        print(f"  Converted '{col}' to float")

# Ensure price and revenue are positive
for col in ["price", "revenue_generated"]:
    if col in df.columns:
        neg_count = (df[col] < 0).sum()
        df = df[df[col] >= 0]
        print(f"  Removed {neg_count} rows with negative {col}")

# ── 6. Derived columns for KPI analysis ──────────────────────────────
print("\n--- Creating derived columns ---")

# On-time delivery flag (1 = on time, 0 = late)
if "shipping_times" in df.columns and "lead_times" in df.columns:
    df["on_time_flag"] = (df["shipping_times"] <= df["lead_times"]).astype(int)
    on_time_rate = df["on_time_flag"].mean() * 100
    print(f"  On-time delivery rate: {on_time_rate:.1f}%")

# Profit margin estimate
if "price" in df.columns and "manufacturing_costs" in df.columns:
    df["profit_margin"] = ((df["price"] - df["manufacturing_costs"]) / df["price"] * 100).round(2)
    print(f"  Average profit margin: {df['profit_margin'].mean():.1f}%")

# Cost efficiency ratio (manufacturing cost per unit revenue)
if "manufacturing_costs" in df.columns and "revenue_generated" in df.columns:
    df["cost_efficiency"] = (df["manufacturing_costs"] / df["revenue_generated"]).round(4)
    print(f"  Average cost efficiency ratio: {df['cost_efficiency'].mean():.4f}")

# ── 7. Outlier detection (IQR method) ────────────────────────────────
print("\n--- Outlier check on key numeric columns ---")
check_cols = ["price", "revenue_generated", "shipping_costs"]
for col in [c for c in check_cols if c in df.columns]:
    Q1 = df[col].quantile(0.25)
    Q3 = df[col].quantile(0.75)
    IQR = Q3 - Q1
    outliers = ((df[col] < Q1 - 1.5 * IQR) | (df[col] > Q3 + 1.5 * IQR)).sum()
    print(f"  '{col}': {outliers} outliers detected (flagged, not removed)")

# ── 8. Summary statistics ─────────────────────────────────────────────
print("\n--- Cleaned dataset summary ---")
print(f"Final shape: {df.shape}")
print(f"\nDescriptive statistics:")
print(df.describe().round(2))

# ── 9. Export cleaned data ────────────────────────────────────────────
output_path = "data/cleaned_supply_chain.csv"
df.to_csv(output_path, index=False)
print(f"\nCleaned data saved to: {output_path}")
print("Data cleaning complete.")
