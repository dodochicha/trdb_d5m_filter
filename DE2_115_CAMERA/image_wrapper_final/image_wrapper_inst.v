	image_wrapper u0 (
		.clk_clk                                             (<connected-to-clk_clk>),                                             //                            clk.clk
		.reset_reset_n                                       (<connected-to-reset_reset_n>),                                       //                          reset.reset_n
		.uart_0_external_connection_rxd                      (<connected-to-uart_0_external_connection_rxd>),                      //     uart_0_external_connection.rxd
		.uart_0_external_connection_txd                      (<connected-to-uart_0_external_connection_txd>),                      //                               .txd
		.image_wrapper_0_avalon_slave_0_beginbursttransfer   (<connected-to-image_wrapper_0_avalon_slave_0_beginbursttransfer>),   // image_wrapper_0_avalon_slave_0.beginbursttransfer
		.image_wrapper_0_avalon_slave_0_writeresponsevalid_n (<connected-to-image_wrapper_0_avalon_slave_0_writeresponsevalid_n>), //                               .writeresponsevalid_n
		.image_wrapper_0_avalon_slave_0_readdata             (<connected-to-image_wrapper_0_avalon_slave_0_readdata>),             //                               .readdata
		.image_wrapper_0_i_writedata                         (<connected-to-image_wrapper_0_i_writedata>),                         //              image_wrapper_0_i.writedata
		.image_wrapper_0_o_readdata                          (<connected-to-image_wrapper_0_o_readdata>)                           //              image_wrapper_0_o.readdata
	);

