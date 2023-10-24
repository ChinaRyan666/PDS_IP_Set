//****************************************Copyright (c)**********************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved
//-----------------------------------------------------------------------------
// File name:           ip_fifo
// Last modified Date:  2019/05/10 11:31:26
// Last Version:        V1.0
// Descriptions:        FIFO实验顶层模块
//-----------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2019/05/10 11:31:51
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------
//***************************************************************************//

module ip_fifo(
    input    sys_clk ,  // 时钟信号
    input    sys_rst_n  // 复位信号
);

//wire define
wire         fifo_wr_en         /* synthesis syn_keep=1 */;// FIFO写使能信号
wire         fifo_rd_en         /* synthesis syn_keep=1 */;// FIFO读使能信号
wire  [7:0]  fifo_din           /* synthesis syn_keep=1 */;// 写入到FIFO的数据
wire  [7:0]  fifo_dout          /* synthesis syn_keep=1 */;// 从FIFO读出的数据
wire         almost_full        /* synthesis syn_keep=1 */;// FIFO将满信号
wire         almost_empty       /* synthesis syn_keep=1 */;// FIFO将空信号
wire         fifo_full          /* synthesis syn_keep=1 */;// FIFO满信号
wire         fifo_empty         /* synthesis syn_keep=1 */;// FIFO空信号
wire  [7:0]  fifo_wr_data_count /* synthesis syn_keep=1 */;// FIFO写时钟域的数据计数
wire  [7:0]  fifo_rd_data_count /* synthesis syn_keep=1 */;// FIFO读时钟域的数据计数

//*****************************************************
//**                    main code
//*****************************************************

reg  		almost_empty_d0  ;    //almost_empty 延迟一拍
reg  		almost_empty_d1  ;    //almost_empty 延迟两拍
reg  		almost_empty_syn ;    //almost_empty 延迟三拍
                                  
reg  		almost_full_d0   ;    //almost_full 延迟一拍
reg  		almost_full_d1   ;    //almost_full 延迟两拍
reg  		almost_full_syn  ;    //almost_full 延迟三拍

//因为 almost_empty 信号是属于FIFO读时钟域的
//所以要将其同步到写时钟域中
always@( posedge sys_clk ) begin
	if( !sys_rst_n ) begin
		almost_empty_d0  <= 1'b0 ;
		almost_empty_syn <= 1'b0 ;
		almost_empty_d1  <= 1'b0 ;
	end
	else begin
		almost_empty_d0  <= almost_empty ;
		almost_empty_d1  <= almost_empty_d0 ;
		almost_empty_syn  <= almost_empty_d1 ;
	end
end

//因为 almost_full 信号是属于FIFO读时钟域的
//所以要将其同步到写时钟域中
always@( posedge sys_clk ) begin
	if( !sys_rst_n ) begin
		almost_full_d0  <= 1'b0 ;
		almost_full_syn <= 1'b0 ;
		almost_full_d1  <= 1'b0 ;
	end
	else begin
		almost_full_d0  <= almost_full ;
		almost_full_d1  <= almost_full_d0 ;
        almost_full_syn  <= almost_full_d1 ;
	end
end

fifo_generator_0 u_fifo_generator_0 (
  .wr_clk            (sys_clk           ),    // input
  .wr_rst            (~sys_rst_n        ),    // input
  .wr_en             (fifo_wr_en        ),    // input
  .wr_data           (fifo_din          ),    // input [7:0]
  .wr_full           (fifo_full         ),    // output
  .wr_water_level    (fifo_wr_data_count),    // output [8:0]
  .almost_full       (almost_full       ),    // output
  .rd_clk            (sys_clk           ),    // input
  .rd_rst            (~sys_rst_n        ),    // input
  .rd_en             (fifo_rd_en        ),    // input
  .rd_data           (fifo_dout         ),    // output [7:0]
  .rd_empty          (fifo_empty        ),    // output
  .rd_water_level    (fifo_rd_data_count),    // output [8:0]
  .almost_empty      (almost_empty      )     // output
);

//例化写FIFO模块
fifo_wr  u_fifo_wr(
    .clk            ( sys_clk          ),    // 写时钟
    .rst_n          ( sys_rst_n        ),    // 复位信号

    .fifo_wr_en     ( fifo_wr_en       ),    // fifo写请求
    .fifo_wr_data   ( fifo_din         ),    // 写入FIFO的数据
    .almost_empty   ( almost_empty_syn ),    // fifo空信号
    .almost_full    ( almost_full_syn  )     // fifo满信号
);

//例化读FIFO模块
fifo_rd  u_fifo_rd(
    .clk            ( sys_clk          ),    // 读时钟
    .rst_n          ( sys_rst_n        ),    // 复位信号
                                             
    .fifo_rd_en     ( fifo_rd_en       ),    // fifo读请求
    .fifo_dout      ( fifo_dout        ),    // 从FIFO输出的数据
    .almost_empty   ( almost_empty_syn ),    // fifo空信号
    .almost_full    ( almost_full_syn  )     // fifo满信号
);

endmodule 