module ImageWrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest,
    // sram controller side
    input  [7:0]  i_writedata,
    input         i_start_send,
    output        o_ready,
    output [7:0]  o_readdata,
    output        o_readdata_valid,
    //test
    output [3:0] o_state,
    output [7:0] o_test
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam IDLE = 0;
localparam SEND_IMAGE = 1;
localparam GET_PREDICT = 2;

reg [1:0] state_r, state_w;
reg cnt_r, cnt_w;
reg [4:0] avm_address_r, avm_address_w;
reg avm_read_r, avm_read_w, avm_write_r, avm_write_w;
reg [7:0] writedata_r, writedata_w;

reg [1:0] color_r, color_w;
reg [1:0] point_r, point_w;
reg [9:0] h_r, h_w;
reg [9:0] v_r, v_w;
reg [4:0] box_r, box_w;
reg [7:0] test_cnt_r, test_cnt_w;
reg [7:0] readdata_r, readdata_w;
reg readdata_valid_r, readdata_valid_w;

wire [7:0] hv;

assign hv = v_r[7:0];

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = writedata_r;
assign o_ready = (state_r == SEND_IMAGE && avm_readdata[TX_OK_BIT] && cnt_r == 0 && ~avm_waitrequest);
assign o_state = state_r;
assign o_readdata = readdata_r;
assign o_readdata_valid = readdata_valid_r;

assign o_test = readdata_r;
// assign o_test = 20;

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

always @(*) begin
    test_cnt_w = (readdata_valid_r) ? test_cnt_r + 1 : test_cnt_r;
end

always @(*) begin
    readdata_valid_w = (state_r == GET_PREDICT && ~avm_waitrequest && cnt_r == 1) ? 1 : 0;
    // readdata_valid_w = (state_r == SEND_IMAGE && ~avm_waitrequest && cnt_r == 1) ? 1 : 0;
end

always @(*) begin
    readdata_w = (state_r == GET_PREDICT && ~avm_waitrequest && cnt_r == 1) ? avm_readdata[7:0] : readdata_r;
end

always @(*) begin
    case (state_r)
        SEND_IMAGE: begin
            if (~avm_waitrequest) begin
                cnt_w = ((cnt_r == 0 && avm_readdata[TX_OK_BIT]) || cnt_r == 1) ? ~cnt_r : cnt_r;
                color_w = (cnt_r == 1) ? (color_r == 2) ? 0 : color_r + 1 : color_r;
                h_w = (cnt_r == 1 && color_r == 2) ? (h_r == 639) ? 0 : h_r + 1 : h_r;
                v_w = (cnt_r == 1 && color_r == 2 && h_r == 639) ? (v_r == 479) ? 0 : v_r + 1 : v_r;
                box_w = box_r;
                point_w = point_r;
            end
            else begin
                cnt_w = cnt_r;
                color_w = color_r;
                h_w = h_r;
                v_w = v_r;
                box_w = box_r;
                point_w = point_r;
            end
        end
        GET_PREDICT: begin
            if (~avm_waitrequest) begin
                cnt_w = ((cnt_r == 0 && avm_readdata[RX_OK_BIT]) || cnt_r == 1) ? ~cnt_r : cnt_r;
                point_w = (cnt_r == 1) ? (point_r == 7) ? 0 : point_r + 1 : point_r;
                box_w = (cnt_r == 1 && point_r == 7) ? (box_r == 15) ? 0 : box_r + 1 : box_r;
                color_w = color_r;
                h_w = h_r;
                v_w = v_r;            
            end
            else begin
                cnt_w = cnt_r;
                color_w = color_r;
                h_w = h_r;
                v_w = v_r;
                box_w = box_r;
                point_w = point_r;
            end
        end
        default: begin
            cnt_w = cnt_r;
            color_w = color_r;
            h_w = h_r;
            v_w = v_r;
            box_w = box_r;
            point_w = point_r;
        end
    endcase
end

always @(*) begin
    // TODO
    avm_address_w = avm_address_r;
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    writedata_w = writedata_r;
    case (state_r)
        SEND_IMAGE: begin
            if (~avm_waitrequest) begin
                if (cnt_r == 0 && avm_readdata[TX_OK_BIT]) begin
                    StartWrite(TX_BASE);
                    writedata_w = writedata_r;
                end
                else begin
                    StartRead(STATUS_BASE);
                    writedata_w = i_writedata;
                end
            end
            else begin
                avm_address_w = avm_address_r;
                avm_read_w = avm_read_r;
                avm_write_w = avm_write_r;
            end
        end
        GET_PREDICT: begin
            if (~avm_waitrequest) begin
                if (cnt_r == 0 && avm_readdata[RX_OK_BIT]) begin
                    StartRead(RX_BASE);
                end
                else begin
                    StartRead(STATUS_BASE);
                end
            end
            else begin
                avm_address_w = avm_address_r;
                avm_read_w = avm_read_r;
                avm_write_w = avm_write_r;
            end
        end
    endcase
end

always@ (*) begin
    case (state_r)
        IDLE: state_w = (i_start_send) ? SEND_IMAGE : IDLE;
        SEND_IMAGE: state_w = (~avm_waitrequest && cnt_r == 1 && color_r == 2 && h_r == 639 && v_r == 479) ? GET_PREDICT : SEND_IMAGE;
        GET_PREDICT: state_w = (~avm_waitrequest && box_r == 14 && point_r == 7 && cnt_r == 1) ? IDLE : GET_PREDICT;
        default: state_w = IDLE;
    endcase
end

always @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= IDLE;
        cnt_r <= 0;
        color_r <= 0;
        h_r <= 0;
        v_r <= 0;
        box_r <= 0;
        point_r <= 0;
        writedata_r <= 0;
        test_cnt_r <= 0;
        readdata_r <= 0;
        readdata_valid_r <= 0;
    end 
    else begin
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        cnt_r <= cnt_w;
        color_r <= color_w;
        h_r <= h_w;
        v_r <= v_w;
        box_r <= box_w;
        point_r <= point_w;
        writedata_r <= writedata_w;
        test_cnt_r <= test_cnt_w;
        readdata_r <= readdata_w;
        readdata_valid_r <= readdata_valid_w;
    end
end

endmodule
