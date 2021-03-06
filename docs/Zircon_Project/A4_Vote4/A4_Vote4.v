//---------------------------------------------------------------------------
//--	文件名		:	A4_Vote4.v
//--	作者		:	ZIRCON
//--	描述		:	用外设来实现三人表决器
//--	修订历史	:	2014-1-1
//---------------------------------------------------------------------------
module A4_Vote4							//模块名A4_Vote4,即模块的开始
(
	//输入端口
	KEY1,KEY2,KEY3,
	//输出端口
	LED1,LED2,LED3,SEG_DATA,SEG_EN                 
);

//---------------------------------------------------------------------------
//--	外部端口声明
//---------------------------------------------------------------------------
input       		KEY1,KEY2,KEY3;	//按键
output      		LED1,LED2,LED3;	//LED
output      [5:0] SEG_EN;           //数码管使能管脚
output reg  [6:0] SEG_DATA;         //数码管数据管脚
 
//---------------------------------------------------------------------------
//--	内部端口声明
//---------------------------------------------------------------------------
parameter	SEG_NUM0 = 7'h3f,       //数字0
				SEG_NUM1 = 7'h06,       //数字1
				SEG_NUM2 = 7'h5b,       //数字2
				SEG_NUM3 = 7'h4f;       //数字3

//---------------------------------------------------------------------------
//--	逻辑功能实现	
//---------------------------------------------------------------------------
always @ (*)                        //组合电路，实现三人表决器电路（行为描述）
begin                   
	case({KEY3,KEY2,KEY1})				//检测按键KEY3，KEY2，KEY1是否按下，按下为1，悬空为0
		3'b000 : SEG_DATA = SEG_NUM0;	//当有0个按键按下时，数码管就显示数字0
		3'b001 : SEG_DATA = SEG_NUM1;	//当有1个按键按下时，数码管就显示数字1
		3'b010 : SEG_DATA = SEG_NUM1;	//当有1个按键按下时，数码管就显示数字1
		3'b011 : SEG_DATA = SEG_NUM2;	//当有2个按键按下时，数码管就显示数字2
		3'b100 : SEG_DATA = SEG_NUM1;	//当有1个按键按下时，数码管就显示数字1
		3'b101 : SEG_DATA = SEG_NUM2;	//当有2个按键按下时，数码管就显示数字2
		3'b110 : SEG_DATA = SEG_NUM2;	//当有2个按键按下时，数码管就显示数字2
		3'b111 : SEG_DATA = SEG_NUM3;	//当有3个按键按下时，数码管就显示数字3
		default: SEG_DATA = SEG_NUM0;
	endcase									//case语句的结束
end											//begin语句的结束

assign LED1 = !KEY1;                //当触摸按键1按下其对应的D1将会亮起
assign LED2 = !KEY2;                //当触摸按键2按下其对应的D2将会亮起
assign LED3 = !KEY3;                //当触摸按键3按下其对应的D3将会亮起
assign SEG_EN = 6'b011111;          //SEG1-SEG5熄灭，SEG6点亮
  
endmodule									//模块的结束
