// --------------------------------------------------------------------
// Copyright (c) 2010 by Terasic Technologies Inc. 
// --------------------------------------------------------------------
//
// Permission:
//
//   Terasic grants permission to use and modify this code for use
//   in synthesis for all Terasic Development Boards and Altera Development 
//   Kits made by Terasic.  Other use of this code, including the selling 
//   ,duplication, or modification of any portion is strictly prohibited.
//
// Disclaimer:
//
//   This VHDL/Verilog or C/C++ source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  Terasic provides no warranty regarding the use 
//   or functionality of this code.
//
// --------------------------------------------------------------------
//           
//                     Terasic Technologies Inc
//                     356 Fu-Shin E. Rd Sec. 1. JhuBei City,
//                     HsinChu County, Taiwan
//                     302
//
//                     web: http://www.terasic.com/
//                     email: support@terasic.com
//
// --------------------------------------------------------------------
//
// Major Functions:	VGA_Controller
//
// --------------------------------------------------------------------
//
// Revision History :
// --------------------------------------------------------------------
//   Ver  :| Author            :| Mod. Date :| Changes Made:
//   V1.0 :| Johnny FAN Peli Li:| 22/07/2010:| Initial Revision
// --------------------------------------------------------------------

module	VGA_Controller(	//	Host Side
						iRed,
						iGreen,
						iBlue,
						oRequest,
						//	VGA Side
						oVGA_R,
						oVGA_G,
						oVGA_B,
						oVGA_H_SYNC,
						oVGA_V_SYNC,
						oVGA_SYNC,
						oVGA_BLANK,
						//	Control Signal
						clk_50m,
						iCLK,
						iRST_N,
						iZOOM_MODE_SW,
						// sram controller side
						o_horizon,
						o_vertical,
						o_valid,
						i_fore,
						i_fore_valid,
						i_filter,
						// test
						i_test_cnt,
						o_test
							);
`include "VGA_Param.h"

`ifdef VGA_640x480p60
//	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	96;
parameter	H_SYNC_BACK	=	48;
parameter	H_SYNC_ACT	=	640;	
parameter	H_SYNC_FRONT=	16;
parameter	H_SYNC_TOTAL=	800;

//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	2;
parameter	V_SYNC_BACK	=	33;
parameter	V_SYNC_ACT	=	480;	
parameter	V_SYNC_FRONT=	10;
parameter	V_SYNC_TOTAL=	525; 

`else
 // SVGA_800x600p60
////	Horizontal Parameter	( Pixel )
parameter	H_SYNC_CYC	=	128;         //Peli
parameter	H_SYNC_BACK	=	88;
parameter	H_SYNC_ACT	=	800;	
parameter	H_SYNC_FRONT=	40;
parameter	H_SYNC_TOTAL=	1056;
//	Virtical Parameter		( Line )
parameter	V_SYNC_CYC	=	4;
parameter	V_SYNC_BACK	=	23;
parameter	V_SYNC_ACT	=	600;	
parameter	V_SYNC_FRONT=	1;
parameter	V_SYNC_TOTAL=	628;

`endif
//	Start Offset
parameter	X_START		=	H_SYNC_CYC+H_SYNC_BACK;
parameter	Y_START		=	V_SYNC_CYC+V_SYNC_BACK;
//	Host Side
input		[9:0]	iRed;
input		[9:0]	iGreen;
input		[9:0]	iBlue;
output	reg			oRequest;
//	VGA Side
output	reg	[9:0]	oVGA_R;
output	reg	[9:0]	oVGA_G;
output	reg	[9:0]	oVGA_B;
output	reg			oVGA_H_SYNC;
output	reg			oVGA_V_SYNC;
output	reg			oVGA_SYNC;
output	reg			oVGA_BLANK;
// sram controller side
output		[12:0]	o_horizon;
output		[12:0]	o_vertical;
output				o_valid;
input       [7:0]   i_fore;
input				i_fore_valid;
input				i_filter;
// test
input			[4:0] i_test_cnt;
output		[7:0]	o_test;

wire		[9:0]	mVGA_R;
wire		[9:0]	mVGA_G;
wire		[9:0]	mVGA_B;
reg					mVGA_H_SYNC;
reg					mVGA_V_SYNC;
wire				mVGA_SYNC;
wire				mVGA_BLANK;

//	Control Signal
input				clk_50m;
input				iCLK;
input				iRST_N;
input 				iZOOM_MODE_SW;

//	Internal Registers and Wires
reg		[12:0]		H_Cont;
reg		[12:0]		V_Cont;

wire	[12:0]		v_mask;

//	sram side
integer i;
reg		[15:0]		fores_r [0:59];
reg		[15:0]		fores_w [0:59];
reg					cnt_r, cnt_w;
reg		[7:0]		cnt_fore_r, cnt_fore_w;
reg		[7:0]		cnt_test_r, cnt_test_w;
//	fore
reg		[29:0]		fore_color_r, fore_color_w;
wire				fore1;
wire				fore2;
wire				fore3;
wire				fore4;
wire				fore5;
wire				fore6;
wire				fore7;
wire				fore8;
wire				fore9;
wire				fore10;
wire				fore11;
wire				fore12;
wire				fore13;
wire				fore14;
wire				fore15;
wire				meet_fore;

assign fore1 = (o_horizon >= fores_r[0] && o_horizon <= fores_r[2] && o_vertical >= fores_r[1] && o_vertical <= fores_r[3]);
assign fore2 = (o_horizon >= fores_r[4] && o_horizon <= fores_r[6] && o_vertical >= fores_r[5] && o_vertical <= fores_r[7]);
assign fore3 = (o_horizon >= fores_r[8] && o_horizon <= fores_r[10] && o_vertical >= fores_r[9] && o_vertical <= fores_r[11]);
assign fore4 = (o_horizon >= fores_r[12] && o_horizon <= fores_r[14] && o_vertical >= fores_r[13] && o_vertical <= fores_r[15]);
assign fore5 = (o_horizon >= fores_r[16] && o_horizon <= fores_r[18] && o_vertical >= fores_r[17] && o_vertical <= fores_r[19]);
assign fore6 = (o_horizon >= fores_r[20] && o_horizon <= fores_r[22] && o_vertical >= fores_r[21] && o_vertical <= fores_r[23]);
assign fore7 = (o_horizon >= fores_r[24] && o_horizon <= fores_r[26] && o_vertical >= fores_r[25] && o_vertical <= fores_r[27]);
assign fore8 = (o_horizon >= fores_r[28] && o_horizon <= fores_r[30] && o_vertical >= fores_r[29] && o_vertical <= fores_r[31]);
assign fore9 = (o_horizon >= fores_r[32] && o_horizon <= fores_r[34] && o_vertical >= fores_r[33] && o_vertical <= fores_r[35]);
assign fore10 = (o_horizon >= fores_r[36] && o_horizon <= fores_r[38] && o_vertical >= fores_r[37] && o_vertical <= fores_r[39]);
assign fore11 = (o_horizon >= fores_r[40] && o_horizon <= fores_r[42] && o_vertical >= fores_r[41] && o_vertical <= fores_r[43]);
assign fore12 = (o_horizon >= fores_r[44] && o_horizon <= fores_r[46] && o_vertical >= fores_r[45] && o_vertical <= fores_r[47]);
assign fore13 = (o_horizon >= fores_r[48] && o_horizon <= fores_r[50] && o_vertical >= fores_r[49] && o_vertical <= fores_r[51]);
assign fore14 = (o_horizon >= fores_r[52] && o_horizon <= fores_r[54] && o_vertical >= fores_r[53] && o_vertical <= fores_r[55]);
assign fore15 = (o_horizon >= fores_r[56] && o_horizon <= fores_r[58] && o_vertical >= fores_r[57] && o_vertical <= fores_r[59]);
assign meet_fore = (fore1 || fore2 || fore3 || fore4 || fore5 || fore6 || fore7 || fore8 || fore9 || fore10 || fore11 || fore12 || fore13 || fore14 || fore15);

assign v_mask = 13'd0 ;//iZOOM_MODE_SW ? 13'd0 : 13'd26;

////////////////////////////////////////////////////////

assign	mVGA_BLANK	=	mVGA_H_SYNC & mVGA_V_SYNC;
assign	mVGA_SYNC	=	1'b0;

assign	mVGA_R	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	(i_filter) ? (meet_fore) ? fore_color_r[29:20] : iRed : iRed	:	0;
assign	mVGA_G	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	(i_filter) ? (meet_fore) ? fore_color_r[19:10] : iGreen : iGreen	:	0;
assign	mVGA_B	=	(	H_Cont>=X_START 	&& H_Cont<X_START+H_SYNC_ACT &&
						V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT )
						?	(i_filter) ? (meet_fore) ? fore_color_r[9:0] : iBlue : iBlue	:	0;

assign o_valid = (H_Cont>=X_START+1 	&& H_Cont<X_START+H_SYNC_ACT+1 &&
				V_Cont>=Y_START+v_mask 	&& V_Cont<Y_START+V_SYNC_ACT);
assign o_horizon = H_Cont - X_START-1;
assign o_vertical = V_Cont - (Y_START+v_mask);

assign o_test = fores_r[i_test_cnt][7:0];
// assign o_test = cnt_test_r;

always @(*) begin
	if (o_horizon == fores_r[0]-1 && o_vertical >= fores_r[1] && o_vertical <= fores_r[3]|| o_horizon == fores_r[4]-1 && o_vertical >= fores_r[5] && o_vertical <= fores_r[7]||
		o_horizon == fores_r[8]-1 && o_vertical >= fores_r[9] && o_vertical <= fores_r[11]|| o_horizon == fores_r[12]-1 && o_vertical >= fores_r[13] && o_vertical <= fores_r[15]||
		o_horizon == fores_r[16]-1 && o_vertical >= fores_r[17] && o_vertical <= fores_r[19]|| o_horizon == fores_r[20]-1 && o_vertical >= fores_r[21] && o_vertical <= fores_r[23]|| 
		o_horizon == fores_r[24]-1 && o_vertical >= fores_r[25] && o_vertical <= fores_r[27]|| o_horizon == fores_r[28]-1 && o_vertical >= fores_r[29] && o_vertical <= fores_r[31]|| 
		o_horizon == fores_r[32]-1 && o_vertical >= fores_r[33] && o_vertical <= fores_r[35]|| o_horizon == fores_r[36]-1 && o_vertical >= fores_r[37] && o_vertical <= fores_r[39]|| 
		o_horizon == fores_r[40]-1 && o_vertical >= fores_r[41] && o_vertical <= fores_r[43]|| o_horizon == fores_r[44]-1 && o_vertical >= fores_r[45] && o_vertical <= fores_r[47]|| 
		o_horizon == fores_r[48]-1 && o_vertical >= fores_r[49] && o_vertical <= fores_r[51]|| o_horizon == fores_r[52]-1 && o_vertical >= fores_r[53] && o_vertical <= fores_r[55]|| 
		o_horizon == fores_r[56]-1 && o_vertical >= fores_r[57] && o_vertical <= fores_r[59]) begin
			fore_color_w = {iRed, iGreen, iBlue};
		end
	else fore_color_w = fore_color_r;
end

always @(*) begin
	cnt_w = (i_fore_valid) ? ~cnt_r : cnt_r;
end

always @(*) begin
	cnt_fore_w = (i_fore_valid) ? (cnt_r) ? (cnt_fore_r == 59) ? 0 : cnt_fore_r + 1 : cnt_fore_r : cnt_fore_r;
end

always @(*) begin
	cnt_test_w = (i_fore_valid) ? cnt_test_r + 1 : cnt_test_r;
end

//save fores
always @(*) begin
    for (i=0;i<=59;i=i+1) begin
        fores_w[i] = fores_r[i];
    end
    if (i_fore_valid) begin
        // fores_w[cnt_fore_r] = i_fore;
		fores_w[cnt_fore_r] = (cnt_r) ? {fores_r[cnt_fore_r][15:8], i_fore} : {i_fore, fores_r[cnt_fore_r][7:0]};
    end
end

always@(posedge iCLK or negedge iRST_N)
	begin
		if (!iRST_N)
			begin
				oVGA_R <= 0;
				oVGA_G <= 0;
                oVGA_B <= 0;
				oVGA_BLANK <= 0;
				oVGA_SYNC <= 0;
				oVGA_H_SYNC <= 0;
				oVGA_V_SYNC <= 0; 
			end
		else
			begin
				oVGA_R <= mVGA_R;
				oVGA_G <= mVGA_G;
                oVGA_B <= mVGA_B;
				oVGA_BLANK <= mVGA_BLANK;
				oVGA_SYNC <= mVGA_SYNC;
				oVGA_H_SYNC <= mVGA_H_SYNC;
				oVGA_V_SYNC <= mVGA_V_SYNC;				
			end               
	end



//	Pixel LUT Address Generator
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	oRequest	<=	0;
	else
	begin
		if(	H_Cont>=X_START-2 && H_Cont<X_START+H_SYNC_ACT-2 &&
			V_Cont>=Y_START && V_Cont<Y_START+V_SYNC_ACT )
		oRequest	<=	1;
		else
		oRequest	<=	0;
	end
end

//	H_Sync Generator, Ref. 40 MHz Clock
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		H_Cont		<=	0;
		mVGA_H_SYNC	<=	0;
	end
	else
	begin
		//	H_Sync Counter
		if( H_Cont < H_SYNC_TOTAL )
		H_Cont	<=	H_Cont+1;
		else
		H_Cont	<=	0;
		//	H_Sync Generator
		if( H_Cont < H_SYNC_CYC )
		mVGA_H_SYNC	<=	0;
		else
		mVGA_H_SYNC	<=	1;
	end
end

//	V_Sync Generator, Ref. H_Sync
always@(posedge iCLK or negedge iRST_N)
begin
	if(!iRST_N)
	begin
		V_Cont		<=	0;
		mVGA_V_SYNC	<=	0;
		for (i=0;i<=59;i=i+1) begin
            fores_r[i] <= 16'hffff;
        end
		cnt_r <= 0;
		cnt_fore_r <= 0;
		cnt_test_r <= 0;
		fore_color_r <= 0;
	end
	else
	begin
		for (i=0;i<=59;i=i+1) begin
			fores_r[i] <= fores_w[i];
		end
		cnt_r <= cnt_w;
		cnt_fore_r <= cnt_fore_w;
		cnt_test_r <= cnt_test_w;
		fore_color_r <= fore_color_w;
		//	When H_Sync Re-start
		if(H_Cont==0) begin
			//	V_Sync Counter
			if( V_Cont < V_SYNC_TOTAL )
			V_Cont	<=	V_Cont+1;
			else
			V_Cont	<=	0;
			//	V_Sync Generator
			if(	V_Cont < V_SYNC_CYC )
			mVGA_V_SYNC	<=	0;
			else
			mVGA_V_SYNC	<=	1;
		end
	end
end

endmodule
