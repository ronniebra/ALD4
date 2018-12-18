module simple_clock(
						input logic clk,
						input logic rstb,
						input logic up0_dn1,
						input logic clear,
						output logic done,
						output logic [7:0] count,
						input logic enable
			);
						



parameter 
		UP =1'b0,
		DOWN = 1'b1;

parameter
		ZERO = 1'b0,
		ONE = 1'b1;


logic [7:0] count_next;
logic [7:0] clear_count;
logic [7:0] compare_value; // value to compare to to decide whether to flag done
logic compare_result;
logic [7:0] enabled_count;




// Compare
assign compare_result = (compare_value == count_next); // 0 if we didnt reach it, 1 if we did


// Assigns the next value for count as well as the comparison value
always_comb
	case(up0_dn1)
		UP: 
			begin
				count_next = count + 1'b1;
				compare_value = 8'b11111111;
			end

		DOWN: 
			begin
				count_next = count - 1'b1;
				compare_value = 8'b0;
			end
	endcase




// Done Flip flop - inputs on a falling clock edge
always_ff @(posedge ~clk or negedge rstb) 
	if(~rstb)
		done <= 1'b0;
	else
		 done <= compare_result;


// Whether to clear value or to continue with next value
always_comb
	case(clear)
		ZERO: clear_count = count_next;
		ONE: clear_count = ZERO; 
		default: clear_count = count_next;
	endcase

// Enable Mux
always_comb
	case(enable)
		ONE: enabled_count = clear_count;
		ZERO: enabled_count = count;
		default: enabled_count = count;
	endcase



// Register flip-flop
always_ff @(posedge clk or negedge rstb)
	if(~rstb)
		 count <= 8'b0;
	else
		count <= enabled_count;
endmodule
