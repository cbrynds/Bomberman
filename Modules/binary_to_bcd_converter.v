module binary2bcd (
    input clk, reset, start,
    input [13:0] in,
    output [3:0] bcd3, bcd2, bcd1, bcd0, count,
    output [1:0] state
); 
    localparam  IDLE = 2'b00,
                SHIFT = 2'b01,
                DONE = 2'b10,
                COUNT_MAX = 14;

    reg [1:0] state_reg, state_next;
    reg[13:0] binary_reg, binary_next;
    reg [3:0] shift_count_reg, shift_count_next;
    reg [15:0] bcd_out_reg, bcd_out_next;

    always @ (posedge clk or posedge reset) begin
        if (reset) begin
            state_reg <= IDLE;
            bcd_out_reg <= 0;
            binary_reg <= in;
            shift_count_reg <= 0;
        end
        else begin
            bcd_out_reg <= bcd_out_next;
            shift_count_reg <= shift_count_next;
            state_reg <= state_next;
            binary_reg <= binary_next;
        end
    end
    
    always @ (*) begin
        case(state_reg)
            IDLE: begin 
                if (start) begin
                    binary_next = in;
                    bcd_out_next = 0;
                    shift_count_next = 0;
                    state_next = SHIFT;
                end
                else 
                    state_next = IDLE;
            end
            SHIFT: begin
                if (shift_count_reg == COUNT_MAX) 
                    state_next = state_reg + 1;
                else begin
                    bcd_out_next = bcd_out_reg << 1;
                    bcd_out_next[0] = binary_reg[13]; // MSB from binary input
                    binary_next = binary_reg << 1;
                    
                    if (shift_count_reg < COUNT_MAX - 1) begin
                        if (bcd_out_next[3:0] > 4) 
                            bcd_out_next[3:0] = bcd_out_next[3:0] + 3;
                        if (bcd_out_next[7:4] > 4) 
                            bcd_out_next[7:4] = bcd_out_next[7:4] + 3;
                        if (bcd_out_next[11:8] > 4) 
                            bcd_out_next[11:8] = bcd_out_next[11:8] + 3;
                        if (bcd_out_next[15:12] > 4) 
                            bcd_out_next[15:12] = bcd_out_next[15:12] + 3;
                    end
                    
                    shift_count_next = shift_count_reg + 1;
                end
            end
            DONE: begin
                   state_next = IDLE;
            end
        endcase
    end
        
    assign state = state_reg;
    assign count = shift_count_reg;
    assign {bcd3, bcd2, bcd1, bcd0} = bcd_out_reg;

endmodule