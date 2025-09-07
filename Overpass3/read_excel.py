import openpyxl

# Load file
wb = openpyxl.load_workbook("CustomerDetails.xlsx")

# Pilih sheet pertama
sheet = wb.active

# Loop semua baris dan print
for row in sheet.iter_rows(values_only=True):
    print(row)
