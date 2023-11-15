module top(
    input clk, PS2clk, key_data,
    output hsync, vsync,
    output [11:0] VGA_RGB
);

// Synchronous reset
reg reset;
always @ (posedge clk) 
    reset <= rst;

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
reg [11:0] rgb_reg, rgb_next;
wire [11:0] bomberman_rgb, pillar_rgb, block_rgb,   // Routing vectors for rgb signals out of object modules
            bomb_rgb, exp_rgb, enemy_rgb, 
            background_rgb;
wire bomberman_on, pillar_on, block_on,             // Signals asserted when x,y located within objects
    bomb_on, exp_on, enemy_on, 
    bm_hb_on, score_on;
wire [9:0] x_bomberman, y_bomberman;
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
                            L ? CDL : current_dir_reg;

// Assert wall_on when x/y pixel coords are outside arena
assign wall_on = ((x < LEFT_WALL) | (x > RIGHT_WALL) | (y < TOP_WALL) | (y > BOTTOM_WALL)) ? 1 : 0;

pillar_display pillar_disp_unit(

);

bomberman_module bm_module_unit(

);

block_module block_module_unit(

);

bomb_module bomb_module_unit(

);

enemy_module enemy_module_unit(

);

game_lives game_lives_unit(

);

score_display score_display_unit(

);

// Module instantiation
vga_sync vga_driver(
    .clk(clk),
    .rst(rst),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(display_on),
    .p_tick(p_tick),
    .x_pos(x_pos),
    .y_pos(y_pos)
);

PS2_receiver receiver(
    .clk(clk),
    .PS2clk(PS2clk),
    .key_data(key_data),
    .c_data(c_data)
);

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
                    (score_on)                             ? 12'b111111111111;
                    (wall_on)                              ? background_rgb :
                    12'b001000100000 : rgb_reg;

// Assign rgb output of top module
assign VGA_RGB = (display_on) ? rgb_reg : 8'h00;
 
endmodule