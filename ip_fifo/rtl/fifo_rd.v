//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           fifo_wr
// Last modified Date:  2019/05/10 13:38:04
// Last Version:        V1.0
// Descriptions:        读FIFO模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/10 13:38:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_rd(
    //system clock
    input               clk         ,    // 时钟信号
    input               rst_n       ,    // 复位信号
    //FIFO interface
    input        [7:0]  fifo_dout   ,    // 从FIFO读出的数据
    input               almost_full ,    // FIFO将满信号
    input               almost_empty,    // FIFO将空信号
    output  reg         fifo_rd_en       // FIFO读使能
);

//reg define
reg  [1:0]  state           ;    // 动作状态
reg         almost_full_d0  ;    // fifo_full 延迟一拍
reg         almost_full_syn ;    // fifo_full 延迟两拍
reg  [3:0]  dly_cnt         ;    //延迟计数器

//*****************************************************
//**                    main code
//*****************************************************

//因为 fifo_full 信号是属于FIFO写时钟域的
//所以要将其同步到读时钟域中
always@( posedge clk ) begin
	if( !rst_n ) begin
		almost_full_d0  <= 1'b0 ;
		almost_full_syn <= 1'b0 ;
	end
	else begin
		almost_full_d0  <= almost_full ;
		almost_full_syn <= almost_full_d0 ;
	end
end

//读出FIFO的数据
always @(posedge clk ) begin
    if(!rst_n) begin
        fifo_rd_en <= 1'b0;
		state      <= 2'd0;
		dly_cnt    <= 4'd0;
    end
    else begin
        case(state)
            2'd0: begin
                if(almost_full_syn)      //如果检测到FIFO将被写满
                    state <= 2'd1;       //就进入延时状态
                else
                    state <= state;
            end 
			2'd1: begin
                if(dly_cnt == 4'd10) begin  //延时10拍
											//原因是FIFO IP核内部状态信号的更新存在延时
											//延迟10拍以等待状态信号更新完毕
                    dly_cnt <= 4'd0;
					state   <= 2'd2;        //开始读操作
				end
				else
					dly_cnt <= dly_cnt + 4'd1;
            end
		    2'd2: begin
                if(almost_empty) begin     //等待FIFO将被读空
                    fifo_rd_en <= 1'b0;    //关闭读使能
                    state      <= 2'd0;    //回到第一个状态
                end
                else                       //如果FIFO没有被读空
                    fifo_rd_en <= 1'b1;    //则持续打开读使能
            end 
			default : state <= 2'd0;
        endcase
    end
end

endmodule