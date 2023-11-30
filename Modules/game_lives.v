module game_lives
(
    input clk, reset,
    input [9:0] x, y,                 // current pixel location on screen
    input bm_hb_on, enemy_on, exp_on, // input to determine when bomberman's hitbox overlaps enemy or explosion
    output gameover,                  // output asserted when lives == 0 and game is over, used to turn off bomberman moving and bomb
    output healthbar_on,                   // Added output to create the health bar
    output [11:0] healthbar_rgb,          // Added output to create the healthbar
    output [11:0] background_rgb      // output for background frame to arena color, going from red to black indicating bomberman's lives
);

// Added these parameters
localparam X_WALL_L = 48;             // end of left wall x coordinate
localparam X_WALL_R = 576;            // begin of right wall x coordinate
localparam Y_WALL_U = 32;             // bottom of top wall y coordinate
localparam Y_WALL_D = 448;            // top of bottom wall y coordinate

localparam INVISIBILITY_MAX = 150000000;  // max value for invisibility counter

// counter register to count a time period after bomberman is hit and cannot be hit immediately again
reg  [27:0] invisibility_reg;
wire [27:0] invisibility_next;

always @(posedge clk, posedge reset)
	if(reset)
		invisibility_reg <= 0;
   else 
	   invisibility_reg <= invisibility_next;

// if register is maxed out, reset to 0,
// if register > 0 and not maxed out, increment,
// if register == 0 and bomberman is hit, start counting up by making register > 0, else keep value of register
assign invisibility_next =                                   (invisibility_reg == INVISIBILITY_MAX) ?                    0 :
                           (invisibility_reg > 0) & (invisibility_reg < INVISIBILITY_MAX)           ? invisibility_reg + 1 :
								   invisibility_reg == 0  & ((exp_on & bm_hb_on) | (enemy_on & bm_hb_on))   ? 1 : invisibility_reg; 

// register to hold number of lives for bomberman, starting with 5
reg  [2:0] lives_reg;
wire [2:0] lives_next;

always @(posedge clk, posedge reset)
	if(reset)
		lives_reg <= 5;
   else 
	   lives_reg <= lives_next;
      
// when bomberman is hit, invisibility_reg is set to 1 and then increments to max, indicating a hit,
// if invisibility_reg == 1 and lives > 0, decrement lives.		
assign lives_next = invisibility_reg == 1 & lives_reg > 0 ? lives_reg - 1 : lives_reg;

// assert gameover output signal when lives == 0
assign gameover = lives_reg == 0;

// =========================================HEALTH BAR============================================================
// output the amount of lives the Bomberman has left
assign lives = lives_reg; 

// Assert healthbar_on when x,y coordinates of pixel are within the health bar rectangle
assign healthbar_on = ((x > X_WALL_R) & (x < X_WALL_R + lives_reg*4) & (y > 5) & (y < 13));
assign healthbar_rgb = 12'b111100000000;

// ===============================================================================================================
// set background rgb depending on # of lives, from bright red, moving down shades to finally being black when gameover
assign background_rgb = lives_reg == 5 ? 12'b101000000000 : 
                        lives_reg == 4 ? 12'b100000000000 : 
								lives_reg == 3 ? 12'b011000000000 : 
								lives_reg == 2 ? 12'b010000000000 : 
								lives_reg == 1 ? 12'b001000000000 : 12'd0;
						  
endmodule