//---------------------------------------------------------------------------
//--	文件名		:	Vga_Module.v
//--	作者		:	ZIRCON
//--	描述		:	VGA显示彩条
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//-- VGA 800*600@60 
//-- VGA_DATA[7:0] red2,red1,red0,green2,green1,green0,blue1,blue0
//-- VGA CLOCK 40MHz.
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//-- Horizonal timing information
//-- Sync pluse   128  a
//-- back porch   88   b
//-- active       800  c
//-- front porch  40   d
//-- All line     1056 e
//-- Vertical timing information
//-- sync pluse   4    o
//-- back porch   23   p
//-- active time  600  q
//-- front porch  1    r
//-- All lines    628  s
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
//-- Horizonal timing information
`define HSYNC_A   16'd128  // 128
`define HSYNC_B   16'd216  // 128 + 88
`define HSYNC_C   16'd1016 // 128 + 88 + 800
`define HSYNC_D   16'd1056 // 128 + 88 + 800 + 40
//-- Vertical  timing information
`define VSYNC_O   16'd4    // 4 
`define VSYNC_P   16'd27   // 4 + 23
`define VSYNC_Q   16'd627  // 4 + 23 + 600
`define VSYNC_R   16'd628  // 4 + 23 + 600 + 1
//---------------------------------------------------------------------------

module Vga_Module
(
	//输入端口
	CLK_50M,RST_N,
	//输出端口
	VSYNC,HSYNC,VGA_DATA
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input 				CLK_50M;					//时钟的端口,开发板用的50M晶振
input 				RST_N;					//复位的端口,低电平复位
output 				VSYNC;					//VGA垂直同步端口
output 				HSYNC;					//VGA水平同步端口
output  	[ 7:0]	VGA_DATA;				//VGA数据端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg 		[15:0] 	hsync_cnt;				//水平扫描计数器
reg 		[15:0]	hsync_cnt_n;			//hsync_cnt的下一个状态
reg 		[15:0] 	vsync_cnt;				//垂直扫描计数器
reg 		[15:0] 	vsync_cnt_n;			//vsync_cnt的下一个状态
reg 		[ 7:0] 	VGA_DATA;				//RGB端口总线
reg 		[ 7:0] 	VGA_DATA_N;				//VGA_DATA的下一个状态
reg 					VSYNC;					//垂直同步端口	
reg					VSYNC_N;					//VSYNC的下一个状态
reg 					HSYNC;					//水平同步端口
reg					HSYNC_N;					//HSYNC的下一个状态
reg 					vga_data_en;			//RGB传输使能信号		
reg 					vga_data_en_n;			//vga_data_en的下一个状态
	
//时序电路,用来给hsync_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		hsync_cnt <= 16'b0;					//初始化hsync_cnt值
	else
		hsync_cnt <= hsync_cnt_n;			//用来给hsync_cnt赋值
end

//组合电路,水平扫描
always @ (*)
begin
	if(hsync_cnt == `HSYNC_D)				//判断水平扫描时序
		hsync_cnt_n = 16'b0;					//如果水平扫描完毕,计数器将会被清零
	else
		hsync_cnt_n = hsync_cnt + 1'b1;	//如果水平没有扫描完毕,计数器继续累加
end

//时序电路,用来给vsync_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		vsync_cnt <= 16'b0;					//给行扫描赋值
	else
		vsync_cnt <= vsync_cnt_n;			//给行扫描赋值
end

//组合电路,垂直扫描
always @ (*)
begin
	if((vsync_cnt == `VSYNC_R) && (hsync_cnt == `HSYNC_D))//判断垂直扫描时序
		vsync_cnt_n = 16'b0;					//如果垂直扫描完毕,计数器将会被清零
	else if(hsync_cnt == `HSYNC_D)		//判断水平扫描时序
		vsync_cnt_n = vsync_cnt + 1'b1;	//如果水平扫描完毕,计数器继续累加
	else
		vsync_cnt_n = vsync_cnt;			//否则,计数器将保持不变
end

//时序电路,用来给HSYNC寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		HSYNC <= 1'b0;							//初始化HSYNC值
	else
		HSYNC <= HSYNC_N;						//用来给HSYNC赋值
end

//组合电路，将HSYNC_A区域置0,HSYNC_B+HSYNC_C+HSYNC_D置1
always @ (*)
begin	
	if(hsync_cnt < `HSYNC_A)				//判断水平扫描时序
		HSYNC_N = 1'b0;						//如果在HSYNC_A区域,那么置0
	else
		HSYNC_N = 1'b1;						//如果不在HSYNC_A区域,那么置1
end

//时序电路,用来给VSYNC寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		VSYNC <= 1'b0;							//初始化VSYNC值
	else
		VSYNC <= VSYNC_N;						//用来给VSYNC赋值
end

//组合电路，将VSYNC_A区域置0,VSYNC_P+VSYNC_Q+VSYNC_R置1
always @ (*)
begin	
	if(vsync_cnt < `VSYNC_O)				//判断水平扫描时序
		VSYNC_N = 1'b0;						//如果在VSYNC_O区域,那么置0
	else
		VSYNC_N = 1'b1;						//如果不在VSYNC_O区域,那么置1
end

//时序电路,用来给vga_data_en寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		vga_data_en <= 1'b0;					//初始化vga_data_en值
	else
		vga_data_en <= vga_data_en_n;		//用来给vga_data_en赋值
end

//组合电路，判断显示有效区（列像素>216&&列像素<1017&&行像素>27&&行像素<627）
always @ (*)
begin
	if((hsync_cnt > `HSYNC_B && hsync_cnt <`HSYNC_C) && 
		(vsync_cnt > `VSYNC_P && vsync_cnt < `VSYNC_Q))
		vga_data_en_n = 1'b1;				//如果在显示区域就给使能数据信号置1
	else
		vga_data_en_n = 1'b0;				//如果不在显示区域就给使能数据信号置0
end


//时序电路,用来给VGA_DATA寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		VGA_DATA <= 8'h0;						//初始化VGA_DATA值
	else
		VGA_DATA <= VGA_DATA_N;				//用来给VGA_DATA赋值
end

//组合电路，显示彩条,判断区域并根据数据填充颜色
always @ (*)
begin
	if(vga_data_en)							//判断数据使能
	begin
		if( vsync_cnt >= `VSYNC_P )		//判断屏幕位置
		begin
			if((hsync_cnt > `HSYNC_B) && (hsync_cnt <= `HSYNC_B + 10'd300))						//判断屏幕位置
				VGA_DATA_N = 8'hE0;			//红色
			else if((hsync_cnt > `HSYNC_B + 10'd300) && (hsync_cnt <= `HSYNC_B + 10'd400))	//判断屏幕位置
				VGA_DATA_N = 8'h03;			//黄色
			else if((hsync_cnt > `HSYNC_B + 10'd400) && (hsync_cnt <= `HSYNC_B + 10'd500))	//判断屏幕位置
				VGA_DATA_N = 8'hFC;			//蓝色
			else if((hsync_cnt > `HSYNC_B + 10'd500) && (hsync_cnt <= `HSYNC_B + 10'd800))	//判断屏幕位置
				VGA_DATA_N = 8'h1C;			//绿色
			else
				VGA_DATA_N = 8'h0;			//黑色	
		end
		else
			VGA_DATA_N = 8'h0;				//黑色	
	end
	else
		VGA_DATA_N = 8'h0;					//黑色	
end
endmodule
