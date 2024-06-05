	component image_wrapper is
		port (
			clk_clk                                             : in  std_logic                    := 'X';             -- clk
			reset_reset_n                                       : in  std_logic                    := 'X';             -- reset_n
			uart_0_external_connection_rxd                      : in  std_logic                    := 'X';             -- rxd
			uart_0_external_connection_txd                      : out std_logic;                                       -- txd
			image_wrapper_0_avalon_slave_0_beginbursttransfer   : in  std_logic                    := 'X';             -- beginbursttransfer
			image_wrapper_0_avalon_slave_0_writeresponsevalid_n : out std_logic;                                       -- writeresponsevalid_n
			image_wrapper_0_avalon_slave_0_readdata             : out std_logic_vector(7 downto 0);                    -- readdata
			image_wrapper_0_i_writedata                         : in  std_logic_vector(7 downto 0) := (others => 'X'); -- writedata
			image_wrapper_0_o_readdata                          : out std_logic                                        -- readdata
		);
	end component image_wrapper;

	u0 : component image_wrapper
		port map (
			clk_clk                                             => CONNECTED_TO_clk_clk,                                             --                            clk.clk
			reset_reset_n                                       => CONNECTED_TO_reset_reset_n,                                       --                          reset.reset_n
			uart_0_external_connection_rxd                      => CONNECTED_TO_uart_0_external_connection_rxd,                      --     uart_0_external_connection.rxd
			uart_0_external_connection_txd                      => CONNECTED_TO_uart_0_external_connection_txd,                      --                               .txd
			image_wrapper_0_avalon_slave_0_beginbursttransfer   => CONNECTED_TO_image_wrapper_0_avalon_slave_0_beginbursttransfer,   -- image_wrapper_0_avalon_slave_0.beginbursttransfer
			image_wrapper_0_avalon_slave_0_writeresponsevalid_n => CONNECTED_TO_image_wrapper_0_avalon_slave_0_writeresponsevalid_n, --                               .writeresponsevalid_n
			image_wrapper_0_avalon_slave_0_readdata             => CONNECTED_TO_image_wrapper_0_avalon_slave_0_readdata,             --                               .readdata
			image_wrapper_0_i_writedata                         => CONNECTED_TO_image_wrapper_0_i_writedata,                         --              image_wrapper_0_i.writedata
			image_wrapper_0_o_readdata                          => CONNECTED_TO_image_wrapper_0_o_readdata                           --              image_wrapper_0_o.readdata
		);

