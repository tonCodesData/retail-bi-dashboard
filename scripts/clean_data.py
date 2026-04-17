import pandas as pd

# ── 1. LOAD ──────────────────────────────────────────────────────────────
# Read the raw Excel file from the data folder
# We tell pandas the engine to use for .xlsx files
raw = pd.read_excel('../data/Online Retail.xlsx', engine='openpyxl')

print(f"Raw data shape: {raw.shape}")  # shows rows x columns before cleaning
print(f"Columns: {list(raw.columns)}")

# ── 2. CLEAN ─────────────────────────────────────────────────────────────

# Drop rows where CustomerID is missing
# Reason: we need customer info for segmentation analysis in Power BI
df = raw.dropna(subset=['CustomerID'])
print(f"After dropping missing CustomerID: {df.shape}")

# Remove cancelled transactions (InvoiceNo starting with 'C')
# Reason: cancellations are returns, not sales — we track them separately
df = df[~df['Invoice'].astype(str).str.startswith('C')]
print(f"After removing cancellations: {df.shape}")

# Remove rows with zero or negative quantity or price
# Reason: these are data errors or samples — not real sales
df = df[df['Quantity'] > 0]
df = df[df['Price'] > 0]
print(f"After removing zero/negative values: {df.shape}")

# Clean up Description column — strip whitespace, uppercase for consistency
df['Description'] = df['Description'].str.strip().str.upper()

# Convert InvoiceDate to proper datetime format
# Reason: SQL Server and Power BI need this as a date type, not plain text
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

# Add a calculated column: TotalAmount = Quantity x UnitPrice
# Reason: this is the core revenue metric we'll use in every dashboard visual
df['TotalAmount'] = df['Quantity'] * df['Price']

# Rename columns to remove spaces — SQL Server doesn't like spaces in column names
df = df.rename(columns={
    'Invoice': 'InvoiceNo',
    'StockCode': 'StockCode',
    'Description': 'Description',
    'Quantity': 'Quantity',
    'InvoiceDate': 'InvoiceDate',
    'Price': 'UnitPrice',
    'CustomerID': 'CustomerID',
    'Country': 'Country',
    'TotalAmount': 'TotalAmount'
})

# ── 3. SAVE ───────────────────────────────────────────────────────────────
# Save the cleaned data as a CSV into the data folder
output_path = '../data/online_retail_clean.csv'
df.to_csv(output_path, index=False)

print(f"\nCleaning complete.")
print(f"Clean data shape: {df.shape}")
print(f"Saved to: {output_path}")
print(f"\nSample of clean data:")
print(df.head())