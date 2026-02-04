module tb_pipeline_reg;
    parameter DATA_WIDTH = 8;
    parameter CLK_PERIOD = 10;

    logic             clk;
    logic             rst_n;
    
    // Input interface
    logic             in_valid;
    wire              in_ready;
    logic [DATA_WIDTH-1:0] in_data;
    
    // Output interface
    wire              out_valid;
    logic             out_ready;
    wire [DATA_WIDTH-1:0] out_data;

    // DUT
    pipeline_reg #(DATA_WIDTH) dut (
        .clk, .rst_n,
        .in_valid, .in_ready, .in_data,
        .out_valid, .out_ready, .out_data
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // Test sequence
    initial begin
        rst_n = 0;
        in_valid = 0;
        in_data = 0;
        out_ready = 0;
        
        $display("=== Pipeline Register Testbench ===");
        $display("Time\tin_valid\tin_ready\tin_data\tout_valid\tout_ready\tout_data");
        $monitor("%0t\t%b\t\t%b\t\t%h\t%b\t\t%b\t\t%h", 
                 $time, in_valid, in_ready, in_data, out_valid, out_ready, out_data);
        
        // Reset
        repeat(2) @(posedge clk);
        rst_n = 1;
        repeat(2) @(posedge clk);
        
        test_normal_flow();
        test_backpressure();
        test_concurrent_handshakes();
        test_empty_to_full();
        
        repeat(5) @(posedge clk);
        $display("=== Test completed successfully! ===");
        $finish;
    end

    task test_normal_flow();
        $display("\n--- Test 1: Normal flow ---");
        // Send data 0xAA
        in_data = 8'hAA; in_valid = 1; out_ready = 1;
        @(posedge clk);
        assert(in_ready) else $error("Failed: in_ready low when empty");
        
        // Data should transfer through
        in_valid = 0;
        @(posedge clk);
        assert(out_valid) else $error("Failed: out_valid not asserted");
        assert(out_data == 8'hAA) else $error("Failed: out_data mismatch");
        
        out_ready = 0;
        @(posedge clk);
    endtask

    task test_backpressure();
        $display("\n--- Test 2: Output backpressure ---");
        // Send data 0xBB, but hold output
        in_data = 8'hBB; in_valid = 1; out_ready = 0;
        repeat(3) @(posedge clk);
        assert(in_ready == 0) else $error("Failed: in_ready high under backpressure");
        assert(out_valid) else $error("Failed: data not stored");
        
        // Release backpressure
        out_ready = 1;
        @(posedge clk);
        out_ready = 0;
    endtask

    task test_concurrent_handshakes();
        $display("\n--- Test 3: Concurrent input/output handshakes ---");
        // Send new data while forwarding old data
        in_data = 8'hCC; in_valid = 1; out_ready = 1;
        repeat(2) @(posedge clk);
        assert(out_data == 8'hCC) else $error("Failed: concurrent data mismatch");
    endtask

    task test_empty_to_full();
        $display("\n--- Test 4: Empty -> Full -> Empty -> Full ---");
        out_ready = 0;
        repeat(2) @(posedge clk);
        assert(!out_valid) else $error("Failed: not empty after drain");
        
        // Fill again
        in_data = 8'hDD; in_valid = 1; out_ready = 1;
        @(posedge clk);
        in_valid = 0;
    endtask

endmodule
  
