set W_ROWS=%1
set W_COLS=%2
set X_COLS=%3

rd /s /q .\vivado_project
del /q *.log *.jou *.str

python scripts/generate_mem.py %X_COLS% %W_COLS% %W_ROWS%

CALL vivado -mode batch -source scripts\run_simulation.tcl -notrace

python scripts/evaluate.py %X_COLS% %W_COLS% %W_ROWS%

