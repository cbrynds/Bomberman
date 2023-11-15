module LFSR_TB();

parameter c_N_BITS = 16;

reg clk = 0;

wire[c_N_BITS-1:0] w_LFSR_Data;
wire w_LFSR_Done;

LFSR #(.N_BITS(c_N_BITS)) LFSR_16bit(
    .clk(clk),
    .w_en(1.b1),
    .seed_DV(1'b0),
    .seed_data({c_N_BITS{1'b0}}),
    .LFSR_out(w_LFSR_Data),
    .LFSR_done(w_LFSR_Done)
);

always @ (*)
    #10 clk <= ~clk;

endmodule