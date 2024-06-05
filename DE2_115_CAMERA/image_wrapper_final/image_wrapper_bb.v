
module image_wrapper (
	clk_clk,
	reset_reset_n,
	uart_0_external_connection_rxd,
	uart_0_external_connection_txd,
	image_wrapper_0_avalon_slave_0_beginbursttransfer,
	image_wrapper_0_avalon_slave_0_writeresponsevalid_n,
	image_wrapper_0_avalon_slave_0_readdata,
	image_wrapper_0_i_writedata,
	image_wrapper_0_o_readdata);	

	input		clk_clk;
	input		reset_reset_n;
	input		uart_0_external_connection_rxd;
	output		uart_0_external_connection_txd;
	input		image_wrapper_0_avalon_slave_0_beginbursttransfer;
	output		image_wrapper_0_avalon_slave_0_writeresponsevalid_n;
	output	[7:0]	image_wrapper_0_avalon_slave_0_readdata;
	input	[7:0]	image_wrapper_0_i_writedata;
	output		image_wrapper_0_o_readdata;
endmodule
