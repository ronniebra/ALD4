module period_counter(
						input logic [7:0] period_sel,
						input logic clk,
						input logic rstb,
						output logic en
						);

logic [7:0] count;
logic [7:0] count_next;
logic clear;
logic [7:0] mux_clear; 
logic compare_result;

// DFF
always_ff @(posedge clk or negedge rstb)
	if(~rstb)
		count <= 1'b0;
	else
		count <= mux_clear;

// Clear Mux
always_comb
	if(clear)
		mux_clear = 8'b0;
	else
		mux_clear = count_next;

// Count Next
assign count_next = count + 1'b1;

// enable value
assign compare_result = (count_next == period_sel);

always_ff @(posedge ~clk or negedge rstb)
	if(~rstb)
		en <= 1'b0;
	else
		en <= compare_result;



// Assign clear to en
assign clear = compare_result;




endmodule // period_counter


