 run -all
# === Pipeline Register Testbench ===
# Time	in_valid	in_ready	in_data	out_valid	out_ready	out_data
# 0	0		1		00	0		0		00
# 
# --- Test 1: Normal flow ---
# 35	1		1		aa	0		1		00
# 45	0		1		aa	1		1		aa
# 55	0		1		aa	0		0		aa
# 
# --- Test 2: Output backpressure ---
# 65	1		1		bb	0		0		aa
# 75	1		0		bb	1		0		bb
# 95	1		1		bb	1		1		bb
# 
# --- Test 3: Concurrent input/output handshakes ---
# 105	1		1		cc	1		1		bb
# 115	1		1		cc	1		1		cc
# 
# --- Test 4: Empty -> Full -> Empty -> Full ---
# 125	1		0		cc	1		0		cc
# ** Error: Failed: not empty after drain
#    Time: 145 ns  Scope: tb_pipeline_reg.test_empty_to_full File: testbench.sv Line: 101
# 145	1		1		dd	1		1		cc
# 155	0		1		dd	1		1		dd
# 165	0		1		dd	0		1		dd
# === Test completed successfully! === 
