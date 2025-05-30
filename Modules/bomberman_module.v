module bomberman_module(
    input clk, reset,
    input [9:0] x, y,
    input L, R, U, D,       // Controller direction from buttons
    input [1:0] current_dir,          // Bomberman current direction
    input bm_blocked, gameover, // asserted when bomberman is blocked by a pillar/he has 0 lives left
    output bomberman_on,        // Signal asserted when pixel location is within sprite location on screen
    output bm_hb_on,            // Signal asserted when pixel location is within sprite hitbox location on screen
    output [9:0] x_b, y_b,      // Top left corner of sprite arena coordinates; bomberman's current pos on screen
    output [11:0] rgb_out
);

//******************************************************************** CONSTANTS ********************************************************************

localparam TIMER_MAX = 1200000;                 // max value of motion_timer_reg; arbitrary and controls the speed of bomberman

localparam CD_U = 2'b00;                        // current direction register vals
localparam CD_R = 2'b01;
localparam CD_D = 2'b10;
localparam CD_L = 2'b11;

localparam FRAME_CNT_1 = 12500000;              // sprite frame animation count ranges 
localparam FRAME_CNT_2 = 2*FRAME_CNT_1;
localparam FRAME_CNT_3 = 3*FRAME_CNT_1;
localparam FRAME_CNT_4 = 4*FRAME_CNT_1;
localparam FRAME_REG_MAX = 50000000;

localparam BM_HB_OFFSET_9 = 9;                  // offset from top of sprite down to top of 16x16 hit box              
localparam BM_WIDTH       = 16;                 // sprite width
localparam BM_HEIGHT      = 25;                 // sprite height

localparam UP_LEFT_X   = 48;                    // constraints of Bomberman sprite location (upper left corner) within arena.
localparam UP_LEFT_Y   = 32;
localparam LOW_RIGHT_X = 576 - BM_WIDTH + 1;
localparam LOW_RIGHT_Y = 448 - BM_HB_OFFSET_9;

// y indexing constants into bomberman sprite ROM. 3 frames for UP, RIGHT, DOWN, LEFT, 1 frame for gameover.
localparam U_1 = 0;
localparam U_2 = 25;
localparam U_3 = 50;
localparam R_1 = 75;
localparam R_2 = 100;
localparam R_3 = 125;
localparam D_1 = 150;
localparam D_2 = 175;
localparam D_3 = 200;
localparam G_O = 225;

//******************************************************************** WIRES & REGS ******************************************************************

// Delay timer reg, next_state, and tick for setting speed of bomberman motion
reg[20:0] motion_timer_reg;
wire[20:0] motion_timer_next;
wire motion_timer_tick;

// Bomberman x/y location reg, next_state
reg [9:0] x_b_reg, y_b_reg;
wire [9:0] x_b_next, y_b_next;

// Register to count time between walking frames
reg[25:0] frame_timer_reg;
wire[25:0] frame_timer_next;

// Register to hold y index offset into the bomberman sprite ROM
reg [8:0] rom_offset_reg, rom_offset_next;

//************************************************************** MOTION TIMER REGISTER ****************************************************************

// Infer register for motion_timer
always @ (posedge clk, posedge reset)
    if (reset)
        motion_timer_reg <= 0;
    else 
        motion_timer_reg <= motion_timer_next;

// next state logic for motion timer: increment when bomberman to move and timer less than max, else reset.
assign motion_timer_next = ((L | R | U | D) & (motion_timer_reg < TIMER_MAX)) ? motion_timer_reg + 1 : 0;

// tick every time timer rolls over, used to signal when to actually move bomberman.
assign motion_timer_tick = motion_timer_reg == TIMER_MAX;

//************************************************************** PILLAR COLLISION SIGNALS *************************************************************

// Pillar collision signals
wire p_c_up, p_c_down, p_c_left, p_c_right;

wire [9:0] x_b_hit_l, x_b_hit_r, y_b_bottom, y_b_top;
assign x_b_hit_l  = x_b_reg - UP_LEFT_X;                        // x coordinate of left  edge of hitbox
assign x_b_hit_r  = x_b_reg - UP_LEFT_X + BM_WIDTH - 1;         // x coordinate of right edge of hitbox
assign y_b_bottom = y_b_reg - UP_LEFT_Y + BM_HEIGHT + 1;        // y coordiante of bottom of hitbox if sprite were going to move down (y + 1)
assign y_b_top    = y_b_reg - UP_LEFT_Y + BM_HB_OFFSET_9 - 1;   // y coordinate of top of hitbox if sprite were going to move up (y - 1)

// sprite will collide if going down if the bottom of the hitbox would be within a pillar (5th bit == 1), 
// and either the left or right edges of the hit box are within the x coordinates of a pillar (5th bit == 1)
assign p_c_down = ((y_b_bottom[4] == 1) & (x_b_hit_l[4] == 1 | x_b_hit_r[4] == 1));   

// sprite will collide if going up if the top of the hitbox would be within a pillar (5th bit == 1), 
// and either the left or right edges of the hit box are within the x coordinates of a pillar (5th bit == 1)
assign p_c_up   = ((   y_b_top[4] == 1) & (x_b_hit_l[4] == 1 | x_b_hit_r[4] == 1));

// determine p_c_left & p_c_right signals:

wire [9:0] y_b_hit_t, y_b_hit_b, x_b_left, x_b_right;
assign y_b_hit_t = y_b_reg - UP_LEFT_Y + BM_HB_OFFSET_9; // y coordinate of the top edge of the hitbox
assign y_b_hit_b = y_b_reg - UP_LEFT_Y + BM_HEIGHT -1;   // y coordiate of the bottom edge of the hitbox
assign x_b_left  = x_b_reg - UP_LEFT_X - 1;              // x coordinate of the left edge of the hitbox if the sprite were going to move left (x - 1)
assign x_b_right = x_b_reg - UP_LEFT_X + BM_WIDTH + 1;   // x coordinate of the right edge of the hitbox if the sprite were going to move right (x + 1)


// sprite will collide if going left if the left edge of the hitbox would be within a pillar (5th bit == 1), 
// and either the top or bottom edges of the hit box are within the x coordinates of a pillar (5th bit == 1)
assign p_c_left  = ( (x_b_left[4] == 1) & (y_b_hit_t[4] == 1 | y_b_hit_b[4] == 1)) ? 1 : 0;

// sprite will collide if going right if the right edge of the hitbox would be within a pillar (5th bit == 1), 
// and either the top or bottom edges of the hit box are within the x coordinates of a pillar (5th bit == 1)
assign p_c_right = ((x_b_right[4] == 1) & (y_b_hit_t[4] == 1 | y_b_hit_b[4] == 1)) ? 1 : 0;

//******************************************************  SPRITE X/Y COORDINATE REGISTERS ********************************************************

// Infer registers for bomberman sprite x/y location
always @ (posedge clk, posedge reset) begin
    if (reset) begin
        x_b_reg     <= UP_LEFT_X + 16;  // initial location                
        y_b_reg     <= UP_LEFT_Y - BM_HB_OFFSET_9;  
    end
    else begin
        x_b_reg     <= x_b_next;
        y_b_reg     <= y_b_next;
    end
end

// offset values used to avoid corner case where bomberman walks into block when going around a pillar
// to witness corner cases, use original values in two assignments below.
wire [9:0] x_b_hit_l_m1 = x_b_hit_l - 1;   
wire [9:0] x_b_hit_r_p1 = x_b_hit_r + 1;
wire [9:0] y_b_hit_t_m1 = y_b_hit_t - 1;
wire [9:0] y_b_hit_b_p1 = y_b_hit_b + 1;

// next state logic for bomberman location
assign x_b_next = (!gameover & !bm_blocked & motion_timer_tick) ?
                  (current_dir == CD_R & ~p_c_right & x_b < LOW_RIGHT_X) |                  // can move right into a clear row
                  (current_dir == CD_U & p_c_up     & x_b_hit_l_m1[4] == 1) |               // moving up into top right of pillar, go right and around
                  (current_dir == CD_D & p_c_down   & x_b_hit_l_m1[4] == 1)? x_b_reg + 1:   // moving down into bottom right of pillar, go right and around
                          
                  (current_dir == CD_L & ~p_c_left  & x_b > UP_LEFT_X) |                    // can move left into a clear row
                  (current_dir == CD_U & p_c_up     & x_b_hit_r_p1[4] == 1) |               // moving up into top left of pillar, go left and around
                  (current_dir == CD_D & p_c_down   & x_b_hit_r_p1[4] == 1)                 // moving up into botom left of pillar, go left and around
                  ? x_b_reg - 1 : x_b_reg : x_b_reg;
                  
assign y_b_next = (!gameover & !bm_blocked & motion_timer_tick) ?
                  (current_dir == CD_D & ~p_c_down  & y_b < LOW_RIGHT_Y) |                  // can move down a clear column
                  (current_dir == CD_R & p_c_right  & y_b_hit_t_m1[4] == 1) |               // moving right into bottom side of pillar, go down and around 
                  (current_dir == CD_L & p_c_left   & y_b_hit_t_m1[4]  == 1)? y_b_reg + 1:  // moving left into bottom side of pillar, go down and around
                  
                  (current_dir == CD_U & ~p_c_up    & y_b > (UP_LEFT_Y - BM_HB_OFFSET_9)) | // can move up a clear column 
                  (current_dir == CD_R & p_c_right  & y_b_hit_b_p1[4] == 1) |               // moving right into top side of pillar, go up and around
                  (current_dir == CD_L & p_c_left   & y_b_hit_b_p1[4] == 1)                 // moving left into top side of pillar, go up and around
                  ? y_b_reg - 1 : y_b_reg : y_b_reg;

      
//************************************************************ ANIMATION FRAME TIMER **************************************************************
always @ (posedge clk, posedge reset) begin
    if (reset)
        frame_timer_reg <= 0;
    else begin
        frame_timer_reg <= frame_timer_next;
    end
end

// next state logic for motion timer: increment when bomberman to move and timer less than max, else reset.
assign frame_timer_next = ((L | R | U | D) & (frame_timer_reg < FRAME_REG_MAX)) ? frame_timer_reg + 1 : 0;

//********************************************************* REGISTER TO INDEX INTO SPRITE ROM *****************************************************

always @ (posedge clk, posedge reset) begin
    if (reset)
        rom_offset_reg <= 0;
    else
        rom_offset_reg <= rom_offset_next;
end

always @ (*) begin
    if (gameover)
        rom_offset_next = G_O;
    else
        case(current_dir)
            CD_U: begin
                case(frame_timer_reg)
                    0: rom_offset_next = U_1;
                    FRAME_CNT_1: rom_offset_next = U_2;
                    FRAME_CNT_2: rom_offset_next = U_1;
                    FRAME_CNT_3: rom_offset_next = U_3;
                endcase
            end
            CD_D: begin
                case(frame_timer_reg)
                    0: rom_offset_next = D_1;
                    FRAME_CNT_1: rom_offset_next = D_2;
                    FRAME_CNT_2: rom_offset_next = D_1;
                    FRAME_CNT_3: rom_offset_next = D_3;
                endcase
            end
            CD_L: begin
                case(frame_timer_reg)
                    0: rom_offset_next = R_1;
                    FRAME_CNT_1: rom_offset_next = R_2;
                    FRAME_CNT_2: rom_offset_next = R_1;
                    FRAME_CNT_3: rom_offset_next = R_3;
                endcase
            end
            CD_R: begin
                case(frame_timer_reg)
                    0: rom_offset_next = R_1;
                    FRAME_CNT_1: rom_offset_next = R_2;
                    FRAME_CNT_2: rom_offset_next = R_1;
                    FRAME_CNT_3: rom_offset_next = R_3;
                endcase
            end
        endcase
end
//********************************************************** INSTANTIATE ROM & ASSIGN OUTPUTS *****************************************************

// index into the rom using x/y, sprite location, and rom_offset, mirroring x for current direction being left
wire [11:0] br_addr = (current_dir == CD_L) ? 15 - (x - x_b_reg) + {(y-y_b_reg+rom_offset_reg), 4'd0} 
                                   :      (x - x_b_reg) + {(y-y_b_reg+rom_offset_reg), 4'd0};

// instantiate bomberman sprite ROM
bm_sprite_br bm_s_unit(.clka(clk), .ena(1'b1), .addra(br_addr), .douta(rgb_out));

// assign output for bomberman sprite location        
assign x_b = x_b_reg;
assign y_b = y_b_reg;
                  
// assign output telling top_module when to display bomberman's sprite on screen
assign bomberman_on = (x >= x_b_reg) & (x <= x_b_reg + BM_WIDTH - 1) & (y >= y_b_reg) & (y <= y_b_reg + BM_HEIGHT - 1);

// assign output, asserted when x/y vga pixel coordinates are within bomberman hitbox - used in game_lives
assign bm_hb_on = (x >= x_b_reg) & (x <= x_b_reg + BM_WIDTH - 1) & 
                  (y >= y_b_reg + BM_HB_OFFSET_9) & (y <= y_b_reg + BM_HEIGHT - 1);

endmodule