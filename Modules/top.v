module top(
    input clk, rst, PS2clk, key_data,
    input PB_ENTER, PB_UP, PB_DOWN, PB_LEFT, PB_RIGHT,
    output hsync, vsync,
    output [11:0] VGA_RGB
);

// Synchronous reset
reg reset;
always @ (posedge clk) 
    reset <= rst;

// Debounce pushbutton inputs to debounced signals U - A
wire U, D, L, R, A;
debounce_button db_u(.clk(clk), .reset(reset), .button(PB_UP), .db_out(U));
debounce_button db_d(.clk(clk), .reset(reset), .button(PB_DOWN), .db_out(D));
debounce_button db_l(.clk(clk), .reset(reset), .button(PB_LEFT), .db_out(L));
debounce_button db_r(.clk(clk), .reset(reset), .button(PB_RIGHT), .db_out(R));
debounce_button db_a(.clk(clk), .reset(reset), .button(PB_ENTER), .db_out(A));

// Constants
localparam X_WALL_L = 48;      // end of left wall x coordinate
localparam Y_WALL_U = 32;      // bottom of top wall y coordinate

localparam LEFT_WALL = 49;     // coordinate positions of arena walls
localparam RIGHT_WALL = 575;
localparam TOP_WALL = 33;
localparam BOTTOM_WALL = 463;

localparam CD_U = 2'b00;       // current direction register vals
localparam CD_R = 2'b01;
localparam CD_D = 2'b10;
localparam CD_L = 2'b11;

// Signals 
wire display_on, p_tick;
wire [9:0] x_pos, y_pos; // VGA x, y pixel locations
wire [7:0] c_data;
reg [11:0] rgb_reg;
wire [11:0] rgb_next;
wire [11:0] bomberman_rgb, pillar_rgb, block_rgb,   // Routing vectors for rgb signals out of object modules
            bomb_rgb, exp_rgb, enemy_rgb, 
            background_rgb;
wire bomberman_on, pillar_on, block_on,             // Signals asserted when x,y located within objects
    bomb_on, exp_on, enemy_on, 
    bm_hb_on, score_on;
wire [9:0] x_b, y_b;
reg [1:0] current_dir_reg; // Reg to hold current direction of bomberman and next state logic
wire [1:0] current_dir_next;
wire wall_on, bomberman_blocked, block_we;
wire [9:0] block_w_adder;
wire gameover, enemy_hit, post_exp_active;

// x, y pixel coords translated to arena coords
wire [9:0] x_a, y_a;
assign x_a = x_pos - X_WALL_L;
assign y_a = y_pos - Y_WALL_U;

// Infer current direction register
always @ (posedge clk, posedge reset)
    if (reset)
        current_dir_reg <= CD_D;
    else
        current_dir_reg <= current_dir_next;

// Current direction register next-state logic
assign current_dir_next = U ? CD_U :
                            R ? CD_R :
                            D ? CD_D :
                            L ? CD_L : current_dir_reg;

// Assert wall_on when x/y pixel coords are outside arena
assign wall_on = ((x_pos < LEFT_WALL) | (x_pos > RIGHT_WALL) | (y_pos < TOP_WALL) | (y_pos > BOTTOM_WALL)) ? 1 : 0;

pillar_display pillar_disp_unit(.x(x_pos), .y(y_pos),
    .x_a(x_a), .y_a(y_a),
    .pillar_on(pillar_on),
    .rgb_out(pillar_rgb)
);

bomberman_module bm_module_unit(.clk(clk), .reset(reset),
    .x(x_pos), .y(y_pos),
    .L(L), .R(R), .U(U), .D(D),
    .current_dir(current_dir_reg),
    .bm_blocked(bm_blocked),
    .gameover(gameover),
    .bomberman_on(bomberman_on),
    .bm_hb_on(bm_hb_on),
    .x_b(x_b), .y_b(y_b),
    .rgb_out(bomberman_rgb)
);

block_module block_module_unit(.clk(clk), .reset(reset), .display_on(display_on), 
    .x(x_pos), .y(y_pos), .x_a(x_a), .y_a(y_a), .x_b(x_b), .y_b(y_b),
    .cd(current_dir_reg),
    .waddr(block_w_addr),
    .we(block_we),
    .rgb_out(block_rgb),
    .block_on(block_on),
    .bm_blocked(bm_blocked)
);

bomb_module bomb_module_unit(.clk(clk), .reset(reset),
    .x_a(x_a), .y_a(y_a), .x_b(x_b), .y_b(y_b),
    .cd(current_dir_reg),
    .A(A),
    .gameover(gameover), .bomb_rgb(bomb_rgb),
    .exp_rgb(exp_rgb), .bomb_on(bomb_on), .exp_on(exp_on),
    .block_w_addr(block_w_addr), .block_we(block_we),
    .post_exp_active(post_exp_active)
);

/*
enemy_module enemy_module_unit(.clk(clk), .reset(reset), .display_on(display_on),
    .x(x_pos), .y(y_pos), .x_b(x_b), .y_b(y_b),
    .exp_on(exp_on), .post_exp_active(post_exp_active),
    .rgb_out(enemy_rgb), .enemy_on(enemy_on), .enemy_hit(enemy_hit)
);

game_lives game_lives_unit(.clk(clk), .reset(reset), .x(x_pos), .y(y_pos), .bm_hb_on(bm_hb_on),
    .enemy_on(enemy_on), .exp_on(exp_on), .gameover(gameover),
    .background_rgb(background_rgb)
);

score_display score_display_unit(.clk(clk), .reset(reset), 
    .x(x_pos), .y(y_pos),
    .enemy_hit(enemy_hit), .score_on(score_on)
);
*/

vga_sync vga_driver(.clk(clk), .reset(reset),
    .hsync(hsync), .vsync(vsync),
    .display_on(display_on),
    .p_tick(p_tick),
    .x_pos(x_pos), .y_pos(y_pos)
);

//PS2_receiver receiver(
//    .clk(clk),
//    .PS2clk(PS2clk),
//    .key_data(key_data),
//    .c_data(c_data)
//);

// Infer register for RGB color data signal
always @(posedge clk, posedge reset)
   if(reset)
      rgb_reg <= 0;
   else 
      rgb_reg <= rgb_next;

// RGB register next-state logic
assign rgb_next = p_tick ? 
                    (bomberman_on & bomberman_rgb != 2049) ? bomberman_rgb :
                    (enemy_on     & enemy_rgb     != 2049) ? enemy_rgb :
                    (pillar_on)                            ? pillar_rgb :
                    (block_on)                             ? block_rgb :
                    (bomb_on      & bomb_rgb      != 2049) ? bomb_rgb :
                    (exp_on       & exp_rgb       != 2048) ? exp_rgb :
                    (score_on)                             ? 12'b111111111111:
                    (wall_on)                              ? background_rgb :
                    12'b001000100000 : rgb_reg;

// Assign rgb output of top module
assign VGA_RGB = (display_on) ? rgb_reg : 8'h00;
 
endmodule