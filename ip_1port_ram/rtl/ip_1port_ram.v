//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                               
//----------------------------------------------------------------------------------------
// File name:           ip_ram
// Last modified Date:  2019/05/08 8:41:06
// Last Version:        V1.0
// Descriptions:        IP核之单端口RAM实验
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2022/06/28 8:41:06
// Version:             V1.0
// Descriptions:        顶层文件
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//
module ip_1port_ram(
    input          sys_clk   ,
    input          sys_rst_n ,
    
//冗余逻辑，仅仅是为了将端口拉出去，方便观察信号
    output         ena  ,
    output         wea  ,
    output [4 : 0] addra,
    output [7 : 0] dina ,
    output [7 : 0] douta
    );

//*****************************************************
//**                    main code
//*****************************************************

ram_1port u_ram_1port (
  .wr_data    (dina      ),    // input [7:0]
  .addr       (addra     ),    // input [4:0]
  .wr_en      (wea       ),    // input
  .clk        (sys_clk   ),    // input
  .rst        (~sys_rst_n),    // input
  .rd_data    (douta     )     // output [7:0]
);

ram_rw u_ram_rw (
    .clk            (sys_clk  ),
    .rst_n          (sys_rst_n),
    .ram_en         (ena      ),
    .ram_wea        (wea      ),
    .ram_addr       (addra    ),
    .ram_wr_data    (dina     )
    );
    
endmodule
