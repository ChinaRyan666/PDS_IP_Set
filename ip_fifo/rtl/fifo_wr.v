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
// Descriptions:        写FIFO模块
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/10 13:38:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module fifo_wr(
    //mudule clock
    input                  clk         ,    // 时钟信号
    input                  rst_n       ,    // 复位信号
    //FIFO interface       
    input                  almost_empty,    // FIFO将空信号
    input                  almost_full ,    // FIFO将满信号
	output    reg          fifo_wr_en  ,    // FIFO写使能
    output    reg  [7:0]   fifo_wr_data     // 写入FIFO的数据
);

//reg define
reg  [1:0]  state      ; //动作状态
reg  [3:0]  dly_cnt    ; //延迟计数器
//*****************************************************
//**                    main code
//*****************************************************
//向FIFO中写入数据
always @(posedge clk ) begin
    if(!rst_n) begin
        fifo_wr_en   <= 1'b0;
        fifo_wr_data <= 8'd0;
        state        <= 2'd0;
        dly_cnt      <= 4'd0;
    end
    else begin
        case(state)
            2'd0: begin 
                if(almost_empty) begin  //如果检测到FIFO将被读空
                    state <= 2'd1;        //就进入延时状态
                end 
                else
                    state <= state;
            end 
			2'd1: begin
				if(dly_cnt == 10) begin  //延时10拍
											//原因是FIFO IP核内部状态信号的更新存在延时
											//延迟10拍以等待状态信号更新完毕                   
                    dly_cnt    <= 4'd0;
					state      <= 2'd2;     //开始写操作
					fifo_wr_en <= 1'b1;     //打开写使能				
				end
				else begin
					dly_cnt <= dly_cnt + 4'd1;				
				end	
            end             
			2'd2: begin
                if(almost_full) begin        //等待FIFO将被写满
                    fifo_wr_en   <= 1'b0;  //关闭写使能
                    fifo_wr_data <= 8'd0;
                    state        <= 2'd0;  //回到第一个状态
                end
                else begin                 //如果FIFO没有被写满
                    fifo_wr_en   <= 1'b1;  //则持续打开写使能
                    fifo_wr_data <= fifo_wr_data + 1'd1;  //且写数据值持续累加
                end
            end 
			default : state <= 2'd0;
        endcase
    end
end

endmodule