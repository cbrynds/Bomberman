// Linear Feedback Shift Register
module LFSR_16(
    input clk, rst, w_en,
    input [15:0] w_in,
    output [15:0] out
);

reg [15:0] LFSR_reg;
wire feedback;

assign feedback = LFSR_reg[15] ^ LFSR_reg[13] ^ LFSR_reg[12] ^ LFSR_reg[10];

always @ (posedge clk, posedge rst) begin
    if (rst)
        LFSR_reg <= 1; // Reset reg to a value of 1; if 0, no random sequence would be generated
    else if (w_en)
        LFSR_reg <= w_in;
    else
        LFSR_reg <= {LFSR_reg[14:0], feedback};
end

assign out = LFSR_reg;

endmodule

