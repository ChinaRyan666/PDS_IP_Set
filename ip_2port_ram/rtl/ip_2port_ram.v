//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ip_2port_ram
// Last modified Date:  2021/8/7 9:20:14
// Last Version:        V1.0
// Descriptions:        IP核之双端口RAM实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2022/6/29 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ip_2port_ram(
    input               sys_clk        ,  //系统时钟
    input               sys_rst_n      ,  //系统复位，低电平有效
    
    output              clk_50m        ,
    output              clk_25m        ,
    output              locked         ,
    output              ram_wr_en       ,
    output    [4:0]     ram_wr_addr     ,
    output    [7:0]     ram_wr_data     ,
    output              ram_rd_en       ,
    output    [4:0]     ram_rd_addr     ,
    output    [7:0]     ram_rd_data
    );
   
//*****************************************************
//**                    main code
//*****************************************************
//锁相环模块
pll_clk u_pll_clk(
    .pll_rst     (~sys_rst_n),   // input
    .clkin1      (sys_clk),      // input
    .pll_lock    (locked),       // output
    .clkout0     (clk_50m),      // output
    .clkout1     (clk_25m)       // output
    );

//RAM写模块
ram_wr u_ram_wr(
    .clk           (clk_50m),
    .rst_n         (sys_rst_n),
      
    .ram_wr_en     (ram_wr_en  ), //ram写使能 
    .ram_wr_addr   (ram_wr_addr),
    .ram_wr_data   (ram_wr_data)
    );

ram_2port ram_2port_inst (
  .wr_data    (ram_wr_data),    // input [7:0]  ram写数据
  .wr_addr    (ram_wr_addr),    // input [4:0]  ram写地址
  .wr_en      (ram_wr_en  ),    // input        
  .wr_clk     (clk_50m    ),    // input
  .wr_rst     (~sys_rst_n ),    // input
  .rd_addr    (ram_rd_addr),    // input [4:0]  ram读地址
  .rd_data    (ram_rd_data),    // output [7:0] ram读数据 
  .rd_clk     (clk_25m    ),    // input
  .rd_rst     (~sys_rst_n )     // input
);

//RAM读模块    
ram_rd u_ram_rd(
    .clk           (clk_25m),
    .rst_n         (sys_rst_n),
    .ram_rd_en     (ram_rd_en  ), //ram读使能
    .ram_rd_addr   (ram_rd_addr),
    .ram_rd_data   (ram_rd_data)
    );

endmodule
