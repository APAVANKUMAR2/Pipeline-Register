module pipeline_reg #(
    parameter DATA_WIDTH = 8
)(
    input  logic             clk,
    input  logic             rst_n,
    
    // Input interface
    input  logic             in_valid,
    output logic             in_ready,
    input  logic [DATA_WIDTH-1:0] in_data,
    
    // Output interface
    output logic             out_valid,
    input  logic             out_ready,
    output logic [DATA_WIDTH-1:0] out_data
);

    logic stored_valid;
    logic [DATA_WIDTH-1:0] stored_data;

    // Combinational logic for input ready
    assign in_ready = ~stored_valid | out_ready;

    // Sequential logic
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            stored_valid <= 1'b0;
            stored_data  <= '0;
        end else begin
            // Accept new data when input handshake completes
            if (in_valid && in_ready) begin
                stored_data  <= in_data;
                stored_valid <= 1'b1;
            end
            // Forward stored data when output handshake completes
            else if (stored_valid && out_ready) begin
                stored_valid <= 1'b0;
            end
        end
    end

    // Output assignments
    assign out_valid = stored_valid;
    assign out_data  = stored_data;

endmodule

