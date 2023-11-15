// From https://nandland.com/lfsr-linear-feedback-shift-register/

// Linear Feedback Shift Register
module LFSR #(parameter N_BITS=16)(
    input clk, rst, w_en,
    // Seed value
    input seed_DV,
    input [N_BITS-1:0] seed_data,
    output [N_BITS-1:0] LFSR_out,
    output LFSR_done
);

reg [N_BITS:1] LFSR_reg = 0;
reg XNOR_reg;

// Load up LFSR with seed if data valid (DV) pulse is detected
always @ (posedge clk) begin
    if (rst)
        LFSR_reg <= 0;
    else if (w_en) begin
        if (seed_DV)
            LFSR_reg <= seed_data;
        else
            LFSR_reg <= {LFSR_reg[N_BITS-1:1], XNOR_reg};
    end
end

// Create feedback polynomials
always @ (*) begin
    case(N_BITS) 
        3: XNOR_reg = LFSR_reg[3] ^ ~LFSR_reg[2];
        4: XNOR_reg = LFSR_reg[4] ^ ~LFSR_reg[3];
        5: XNOR_reg = LFSR_reg[5] ^ ~LFSR_reg[2];
        6: XNOR_reg = LFSR_reg[6] ^ ~LFSR_reg[5];
        7: XNOR_reg = LFSR_reg[7] ^ ~LFSR_reg[6];
        8: XNOR_reg = LFSR_reg[8] ^ ~LFSR_reg[6] ^ ~LFSR_reg[5] ^ ~LFSR_reg[4];
        9: XNOR_reg = LFSR_reg[9] ^ ~LFSR_reg[5];
        10: XNOR_reg = LFSR_reg[10] ^ ~LFSR_reg[7];
        11: XNOR_reg = LFSR_reg[11] ^ ~LFSR_reg[9];
        12: XNOR_reg = LFSR_reg[12] ^ ~LFSR_reg[6] ^ ~LFSR_reg[4] ^ ~LFSR_reg[1];
        13: XNOR_reg = LFSR_reg[13] ^ ~LFSR_reg[4] ^ ~LFSR_reg[3] ^ ~LFSR_reg[1];
        14: XNOR_reg = LFSR_reg[14] ^ ~LFSR_reg[5] ^ ~LFSR_reg[3] ^ ~LFSR_reg[1];
        15: XNOR_reg = LFSR_reg[15] ^ ~LFSR_reg[14];
        // More cases for more bits
    endcase
end

assign LFSR_out = LFSR_reg[N_BITS:1];
assign LFSR_done = (LFSR_reg[N_BITS:1] == seed_data) ? 1 : 0;

endmodule

