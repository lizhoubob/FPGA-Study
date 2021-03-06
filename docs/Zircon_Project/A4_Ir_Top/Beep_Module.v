//---------------------------------------------------------------------------
//--	文件名		:	Beep_Module.v
//--	作者		:	ZIRCON
//--	描述		:	蜂鸣器发声模块
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module Beep_Module
(
	//输入端口
	CLK_50M,RST_N,KEY,
	//输出端口
	BEEP
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input					CLK_50M;					//时钟的端口,开发板用的50MHz晶振
input					RST_N;					//复位的端口,低电平复位
input 	[ 7:0]	KEY;						//按键端口
output				BEEP;						//蜂鸣器端口

//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
reg		[15:0]	time_cnt;				//用来控制蜂鸣器发声频率的定时计数器
reg		[15:0]	time_cnt_n;				//time_cnt的下一个状态
reg		[15:0]	freq;						//各种音调的分频值
reg		[15:0]	freq_n;					//各种音调的分频值
reg					beep_reg;				//用来控制蜂鸣器发声的寄存器
reg					beep_reg_n;				//beep_reg的下一个状态

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
//时序电路，用来给time_cnt寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		time_cnt <= 16'b0;						//初始化time_cnt值
	else
		time_cnt <= time_cnt_n;				//用来给time_cnt赋值
end

//组合电路,判断频率,让定时器累加 
always @ (*)
begin
	if(time_cnt == freq)						//判断分频值
		time_cnt_n = 16'b0;					//定时器清零操作
	else
		time_cnt_n = time_cnt + 1'b1;		//定时器累加操作

end

//时序电路，用来给beep_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		beep_reg <= 1'b0;						//初始化beep_reg值
	else
		beep_reg <= beep_reg_n;				//用来给beep_reg赋值
end

//组合电路,判断频率,使蜂鸣器发声
always @ (*)
begin
	if(time_cnt == freq)						//判断分频值
		beep_reg_n = ~beep_reg;				//改变蜂鸣器的状态
	else
		beep_reg_n = beep_reg;				//蜂鸣器的状态保持不变
end

//时序电路，用来给beep_reg寄存器赋值
always @ (posedge CLK_50M or negedge RST_N)
begin
	if(!RST_N)									//判断复位
		freq <= 16'b0;							//初始化beep_reg值
	else
		freq <= freq_n;						//用来给beep_reg赋值
end

//组合电路，按键选择分频值来实现蜂鸣器发出不同声音
//中音do的频率为523.3hz，freq = 50 * 10^6 / (523 * 2) = 47774
always @ (*)
begin
	case(KEY)
		8'h16: freq_n = 16'd0;			//没有声音
		8'h0C: freq_n = 16'd47774; 	//中音1的频率值262Hz
		8'h18: freq_n = 16'd42568; 	//中音2的频率值587.3Hz
		8'h5E: freq_n = 16'd37919; 	//中音3的频率值659.3Hz
		8'h08: freq_n = 16'd35791; 	//中音4的频率值698.5Hz
		8'h1C: freq_n = 16'd31888; 	//中音5的频率值784Hz
		8'h5A: freq_n = 16'd28409; 	//中音6的频率值880Hz
		8'h42: freq_n = 16'd25309; 	//中音7的频率值987.8Hz
		8'h52: freq_n = 16'd23889; 	//高音1的频率值1046.5Hz
		8'h4A: freq_n = 16'd21276; 	//高音2的频率值1175Hz
		default	  : freq_n = freq;
	endcase
end

assign BEEP = beep_reg;		//最后,将寄存器的值赋值给端口BEEP

endmodule



