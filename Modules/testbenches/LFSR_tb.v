`timescale 1ns/1ps

module LFSR_TB();

reg clk = 0, rst = 0, write_enable_t;
reg[15:0] w_in_t;
wire[15:0] w_LFSR_Data_t;

LFSR_16 DUT(
    .clk(clk),
    .w_en(write_enable_t),
    .rst(rst),
    .w_in(w_in_t)
    .LFSR_out(w_LFSR_Data_t)
);

initial begin
    clk = 1'b0;
    rst = 1;
    #10 rst = 0;
    write_enable_t = 1;

    w_in_t = 16'h684C;

    #10 write_enable_t = 0;
end

always @ (*)
    #10 clk <= ~clk;

endmodule