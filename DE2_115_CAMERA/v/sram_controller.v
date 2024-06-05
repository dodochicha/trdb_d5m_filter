module sram_controller (
	i_clk,
    i_vga_clk,
    i_rst,
    i_red,
    i_green,
    i_blue,
    i_horizon,
    i_verical,
    i_valid,
    i_start_process,
    SRAM_ADDR,
    SRAM_CE_N,
    SRAM_DQ,
    SRAM_LB_N,
    SRAM_OE_N,
    SRAM_UB_N,
    SRAM_WE_N,
    // image wrapper side
    i_wrapper_ready,
    o_wrapper_writedata,
    o_send,
    o_state,
    o_sram_data,
    o_test2,
    i_readdata,
    i_readdata_valid,
    // vga side
    o_fore,
    o_fore_valid
);

input i_clk;
input i_vga_clk;
input i_rst;
input [9:0] i_red;
input [9:0] i_green;
input [9:0] i_blue;
input [12:0] i_horizon;
input [12:0] i_verical;
input i_valid;
input i_start_process;
output [19:0] SRAM_ADDR;
output SRAM_CE_N;
inout [15:0] SRAM_DQ;
output SRAM_LB_N;
output SRAM_OE_N;
output SRAM_UB_N;
output SRAM_WE_N;
input i_wrapper_ready;
output [7:0] o_wrapper_writedata;
output o_send;
output [3:0] o_state;
output [8:0] o_sram_data;
output [3:0] o_test2;
input [7:0] i_readdata;
input i_readdata_valid;
output [7:0] o_fore;
output o_fore_valid;

localparam IDLE = 0;
localparam WAIT_SIGNAL1 = 1;
localparam STORE_STAGE1 = 2;
localparam WAIT_SIGNAL2 = 3;
localparam STORE_STAGE2 = 4;
localparam OUTPUT_IMAGE = 5;
localparam TEST = 6;
localparam TEST2 = 7;
localparam GET_FORES = 8;
localparam POSTPROCESS = 9;
localparam DISPLAY = 10;
localparam WAIT_SIGNAL3 = 11;

reg [3:0] state_r, state_w;
reg [19:0] addr_r, addr_w;
reg [7:0] blue_pre_r, blue_pre_w;
reg cnt_r, cnt_w;
wire [15:0] data;
wire [15:0] sram_data;
reg [1:0] stall_r, stall_w;
reg [7:0] writedata_r, writedata_w;
reg [15:0] fores_r [0:59]; //4*15
reg [15:0] fores_w [0:59];
reg [7:0] cnt_fore_r, cnt_fore_w;
wire [15:0] pixel1;
wire [15:0] pixel2;
wire [15:0] pixel3;
wire [15:0] pixel4;
reg [15:0] x_r, x_w;
reg [15:0] y_r, y_w;
reg [7:0] test_r, test_w;
reg [3:0] test2_r, test2_w;
wire [19:0] addr_postprocess;
wire [19:0] addr_x;
reg [23:0] new_rgb_r, new_rgb_w;
reg [19:0] addr_display_r, addr_display_w;
// reg [3:0] cnt_test_r, cnt_test_w;

integer i;

// assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign SRAM_WE_N = ~(state_r == TEST2 && i_valid || 
                     state_r == STORE_STAGE1 && i_valid || 
                     state_r == STORE_STAGE2 && i_valid && i_horizon[0] ||
                     state_r == POSTPROCESS
                     );
assign SRAM_CE_N = 1'b0;
assign SRAM_OE_N = 1'b0;
assign SRAM_LB_N = (state_r == POSTPROCESS) ? (x_r) ? (cnt_r) ? 1'b0 : 1'b0 : (cnt_r) ? 1'b1 : 1'b0 : 1'b0;
assign SRAM_UB_N = (state_r == POSTPROCESS) ? (x_r) ? (cnt_r) ? 1'b0 : 1'b1 : (cnt_r) ? 1'b0 : 1'b0 : 1'b0;
assign SRAM_ADDR = (state_r == TEST2 || state_r == TEST) ? 1234 :  addr_r;
assign data = (state_r == STORE_STAGE1) ? (i_horizon[0]) ? {i_blue[9:2], i_green[9:2]} : {i_red[9:2], blue_pre_r} :
              (state_r == STORE_STAGE2) ? (i_horizon[0]) ? {i_green[9:2], i_red[9:2]} : 16'dz :
              (state_r == POSTPROCESS) ? 16'hffff : 
              16'dz;
assign SRAM_DQ  = (state_r == STORE_STAGE1 && i_valid ||
                   state_r == STORE_STAGE2 && i_valid && i_horizon[0] ||
                   state_r == POSTPROCESS) ? data : 16'dz;
assign o_send = (state_r == OUTPUT_IMAGE);
assign sram_data = SRAM_DQ;
assign o_wrapper_writedata = (state_r == OUTPUT_IMAGE) ? writedata_r : 255;
assign pixel1 = fores_r[4*cnt_fore_r];
assign pixel2 = fores_r[4*cnt_fore_r+2];
assign pixel3 = fores_r[4*cnt_fore_r+1];
assign pixel4 = fores_r[4*cnt_fore_r+3];
assign addr_x = x_r*3;
assign addr_postprocess = 960*y_r+addr_x[19:1];
assign o_fore = i_readdata;
assign o_fore_valid = i_readdata_valid;
//test
assign o_state = state_r;
assign o_sram_data = test_r;

always @(*) begin
    test2_w = (o_send) ? 2 : 0;
end

always @(*) begin
    if (state_r == TEST) begin
        test_w = SRAM_DQ[7:0];
    end
    else begin
        test_w = test_r;
    end
end

always @(*) begin
    writedata_w = (cnt_r == 0) ? sram_data[15:8] : sram_data[7:0];
end

// write sram
always @(*) begin
    if (state_r == STORE_STAGE1 && !i_horizon[0]) blue_pre_w = i_blue[9:2];
    else blue_pre_w = blue_pre_r;
end

// write to wrapper
always @(*) begin
    case (state_r)
        OUTPUT_IMAGE: cnt_w = (i_wrapper_ready) ? ~cnt_r : cnt_r;
        GET_FORES: cnt_w = (i_readdata_valid) ? ~cnt_r : cnt_r;
        POSTPROCESS: cnt_w = ~cnt_r;
        // DISPLAY: cnt_w = (i_valid) ? ~cnt_r : cnt_r;
        default: cnt_w = 0;
    endcase
end


always @(*) begin
    stall_w = (state_r == OUTPUT_IMAGE && i_wrapper_ready) ? stall_r + 1 : 0;
end

// read from wrapper
always @(*) begin
    case (state_r)
        GET_FORES: cnt_fore_w = (i_readdata_valid) ? (cnt_r) ? (cnt_fore_r == 59) ? 0 : cnt_fore_r + 1 : cnt_fore_r : cnt_fore_r;
        POSTPROCESS: cnt_fore_w = (y_r == pixel4 && x_r == pixel2 && cnt_r) ? cnt_fore_r + 1 : cnt_fore_r;
        default: cnt_fore_w = 0;
    endcase
end

//save fores
always @(*) begin
    for (i=0;i<=59;i=i+1) begin
        fores_w[i] = fores_r[i];
    end
    if (state_r == GET_FORES && i_readdata_valid) begin
        fores_w[cnt_fore_r] = i_readdata;
    end
end

//postprocess
always @(*) begin
    x_w = (cnt_r) ? (x_r == 0) ? pixel1 : (y_r == pixel4 && x_r == pixel2) ? 0 : (x_r == pixel2) ? pixel1 : x_r + 1 : x_r;
    y_w = (cnt_r) ? (y_r == 0) ? pixel3 : (y_r == pixel4 && x_r == pixel2) ? 0 : (x_r == pixel2) ? y_r + 1 : y_r : y_r;
end

always @(*) begin
    case (state_r)
        WAIT_SIGNAL1: addr_w = 0;
        STORE_STAGE1: addr_w = (i_valid && !i_horizon[0]) ? addr_r + 2 : (i_valid && i_horizon[0]) ? addr_r + 1 : addr_r;
        WAIT_SIGNAL2: addr_w = 20'hfffff;
        STORE_STAGE2: addr_w = (i_valid && i_horizon == 639 && i_verical == 479) ? 0 : (i_valid && !i_horizon[0]) ? addr_r + 3 : addr_r;
        OUTPUT_IMAGE: addr_w = (i_wrapper_ready && cnt_r) ? addr_r + 1 : addr_r;
        POSTPROCESS: addr_w = addr_postprocess;
        default: addr_w = 0;
    endcase
end
//display
// always @(*) begin
//     if (state_r == DISPLAY) begin
//         addr_display_w = (i_horizon[0]) ? addr_display_r + 1 : (cnt_r) ? addr_display_r : addr_display_r + 1;
//     end
//     else addr_display_w = 0;
// end

// always @(*) begin
//     if (state_r == DISPLAY) begin
//         if (i_horizon) begin
//             if (cnt_r) new_rgb_w = {new_rgb_r[23:16], SRAM_DQ};
//             else new_rgb_w = {SRAM_DQ[7:0], 16'd0};
//         end
//         else begin
//             if (cnt_r) new_rgb_w = {16'd0, SRAM_DQ[15:8]};
//             else new_rgb_w = {SRAM_DQ, 16'd0};        
//         end
//     end
//     else begin
//         new_rgb_w = 0;
//     end
// end

always @(*) begin
    case (state_r)
        // IDLE: state_w = (i_start_process) ? WAIT_SIGNAL1 : IDLE;
        IDLE: state_w = (i_start_process) ? WAIT_SIGNAL1 : IDLE;
        WAIT_SIGNAL1: state_w = (i_valid && i_horizon == 0 && i_verical == 0) ? STORE_STAGE1 : WAIT_SIGNAL1;
        STORE_STAGE1: state_w = (i_valid && i_horizon == 639 && i_verical == 479) ? WAIT_SIGNAL2 : STORE_STAGE1;
        // STORE_STAGE1: state_w = (i_valid && addr_r == 1) ? TEST : STORE_STAGE1;
        WAIT_SIGNAL2: state_w = (i_valid && i_horizon == 0 && i_verical == 0) ? STORE_STAGE2 : WAIT_SIGNAL2;
        STORE_STAGE2: state_w = (i_valid && i_horizon == 639 && i_verical == 479) ? OUTPUT_IMAGE : STORE_STAGE2;
        // STORE_STAGE2: state_w = (i_valid && addr_r == 640*480*3/2-1) ? OUTPUT_IMAGE : STORE_STAGE2;
        OUTPUT_IMAGE: state_w = (addr_r == 640*480*3/2-1) ? GET_FORES: OUTPUT_IMAGE;
        GET_FORES: state_w = (cnt_fore_r == 59) ? DISPLAY : GET_FORES;
        // POSTPROCESS: state_w = (cnt_fore_r == 14) ? WAIT_SIGNAL3 : POSTPROCESS;
        // WAIT_SIGNAL3: state_w = (i_horizon == 13'h1fff && i_verical == 0) ? DISPLAY : WAIT_SIGNAL3;
        DISPLAY: state_w = DISPLAY;
        // TEST: state_w = TEST;
        // TEST2: state_w = (i_valid) ? TEST : TEST2;
        default: state_w = IDLE;
    endcase
end

always @(posedge i_vga_clk or posedge i_rst) begin
    if (i_rst) begin
        state_r <= IDLE;
        addr_r <= 0;
        blue_pre_r <= 0;
        cnt_r <= 0;
        test_r <= 0;
        test2_r <= 0;
        stall_r <= 0;
        cnt_fore_r <= 0;
        writedata_r <= 0;
        // for (i=0;i<=59;i=i+1) begin
        //     fores_r[i] <= 0;
        // end
        x_r <= 0;
        y_r <= 0;
    end
    else begin
        state_r <= state_w;
        addr_r <= addr_w;
        blue_pre_r <= blue_pre_w;
        cnt_r <= cnt_w;
        test_r <= test_w;
        test2_r <= test2_w;
        stall_r <= stall_w;
        cnt_fore_r <= cnt_fore_w;
        writedata_r <= writedata_w;
        for (i=0;i<=59;i=i+1) begin
            fores_r[i] <= fores_w[i];
        end
        x_r <= x_w;
        y_r <= y_w;
    end
end

always @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        addr_display_r <= 0;
        new_rgb_r <= 0;
    end
    else begin
        addr_display_r <= addr_display_w;
        new_rgb_r <= new_rgb_w;
    end
end
    
endmodule