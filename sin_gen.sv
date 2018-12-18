//----------------------------------------------------------------------------------------------------
// Module name: sin_gen
// Author:      Ron Baruch
// Date:       	06.12.2018
// email:       ronabaruch@gmail.com
// Description: This module implements an FSM based design which detects '101' pattern on din data stream.
//----------------------------------------------------------------------------------------------------

module sin_gen
			(
				input logic clk,    // Clock
				input logic rst_n,  // Asynchronous reset active lo
				input logic en,
				input logic [7:0] period_sel,
				output logic [8:0] sin_out
			);



//-----------------------------------------------
// Variable Declaration
//-----------------------------------------------

//Variables for Counter Module
logic done; 
logic up0_dn1;
logic clear;
logic [7:0] count;
logic count_en;

// Top level variables
logic [7:0] sram_out;
logic positive; //whether we output SRAM or 0-SRAM

logic [7:0] new_period_sel;
logic new_en;


//-----------------------------------------------
// Parameter Declaration
//-----------------------------------------------
parameter ZERO = 8'b0,
		  TWOFIFTYFIVE = 8'b11111111,
		  ONE = 1'b1;

		
//-----------------------------------------------
// Instantiate Period Counter
//-----------------------------------------------  
period_counter period_counter(
						.period_sel(new_period_sel),
						.clk(clk),
						.rstb(rst_n),
						.en(count_en)
					);
//-----------------------------------------------
// Instantiate Counter
//-----------------------------------------------

simple_clock simple_clock (
				.clk(clk),
				.rstb(rst_n),
				.up0_dn1(up0_dn1),
				.count(count),
				.clear(clear),
				.done(done),
				.enable(count_en)
			    );

//-----------------------------------------------
// Instantiate sram
//-----------------------------------------------

static_mem static_mem (
			.address(count),
			.dout(sram_out)
	 	      );

//-----------------------------------------------
// Define states and assign binary values to each
//-----------------------------------------------

typedef enum 	    logic [2:0] {
					 IDLE  = 3'b000,
					 S1    = 3'b001,
					 S2    = 3'b010,
					 S3    = 3'b011,	
					 S4    = 3'b100
					 } state;
//-----------------------------------------------
// Defines next, current state
//-----------------------------------------------
state current_state;                                  
state next_state;  


//-----------------------------------------------
// FSM Block
//-----------------------------------------------

always_comb
	begin
	next_state = current_state;


	case(current_state)
		IDLE:
			begin
			clear = 1'b1;
			new_period_sel = period_sel; // We want to update the value for the next cycle
			if(en)
				next_state = S1;
			new_en = en;
			end
			
		S1:
			begin
			clear = 1'b0;
			up0_dn1 = 1'b0;
			positive = 1'b1;
			if(done)
				next_state = S2;
			end
		S2:
			begin
			up0_dn1 = 1'b1;
			positive = 1'b1;
			if(done)
				next_state = S3;
			end
		S3:
			begin
			up0_dn1 = 1'b0;
			positive = 1'b0;
			if(done)
				next_state = S4;
			end
		S4:
		begin
			up0_dn1 = 1'b1;
			positive = 1'b0;
			if(done)
				next_state = IDLE;
		end
	endcase // current_state
end


	


//-----------------------------------------------
// Initialize state machine 
//-----------------------------------------------
always_ff @(posedge clk or negedge rst_n) //fix negedge clear and fix clock
	if (~rst_n)
		current_state <= IDLE; //IDLE_STATE;
	else
		if (new_en)
			current_state <= next_state;
		
		


//-----------------------------------------------
// Output positive or negative values
//-----------------------------------------------

always_comb
	case (positive)
		1'b0: sin_out = 8'b0 - sram_out;
		1'b1: sin_out = sram_out;
		default: sin_out = sram_out;
	endcase

endmodule	

