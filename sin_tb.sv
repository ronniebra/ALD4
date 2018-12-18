module sin_tb();


	logic en;
	logic clk;
	logic rst_n;
	logic [8:0] sin_out;
	logic[7:0] period_sel;

sin_gen sin_gen(.clk(clk), .en(en), .rst_n(rst_n), .sin_out(sin_out), .period_sel(period_sel));


always
	#5ns clk = ~clk;

initial
	begin
	clk = 1'b0;
	period_sel = 8'h6;
	en = 1'b1;
	rst_n = 1'b0;
	#10ns
	rst_n = 1'b1;
	#2560ns
	period_sel = 8'b0;
	end
endmodule
