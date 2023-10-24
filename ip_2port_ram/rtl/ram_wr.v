//****************************************Copyright (c)***********************************//
//原子哥在线教学平台：www.yuanzige.com
//技术支持：www.openedv.com
//淘宝店铺：http://openedv.taobao.com 
//关注微信公众平台微信号："正点原子"，免费获取ZYNQ & FPGA & STM32 & LINUX资料。
//版权所有，盗版必究。
//Copyright(C) 正点原子 2018-2028
//All rights reserved                                  
//----------------------------------------------------------------------------------------
// File name:           ram_wr
// Last modified Date:  2022/6/29 9:20:14
// Last Version:        V1.0
// Descriptions:        RAM写数据
//----------------------------------------------------------------------------------------
// Created by:          正点原子
// Created date:        2021/8/7 9:20:14
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module ram_wr(
    input            clk,           //时钟信号
    input            rst_n,         //复位信号，低电平有效
                                    
    //RAM写端口操作                 
    output           ram_wr_en,     //ram写使能
    output reg [4:0] ram_wr_addr,   //ram写地址        
    output reg [7:0] ram_wr_data    //ram写数据
);

//reg define
reg  [5:0]  wr_cnt;                 //写计数器

//*****************************************************
//**                    main code
//*****************************************************

//wr_cnt计数范围在0~31,ram_wr_en为高电平
assign ram_wr_en = ((wr_cnt>=6'd0) && (wr_cnt<=6'd31) && rst_n) ? 1'b1 : 1'b0;

//写计数器,计数器范围0~63
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        wr_cnt <= 6'd0;
    else if(wr_cnt == 6'd63)
        wr_cnt <= wr_cnt;
    else    
        wr_cnt <= wr_cnt + 1'b1;
end

//写计数器范围：0~31,产生ram写数据信号
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        ram_wr_data <= 8'd0;
    else if(wr_cnt >= 6'd0 && wr_cnt <= 6'd31)  
        ram_wr_data <= ram_wr_data + 1'b1;
    else
        ram_wr_data <= 8'd0;
end        

//写地址信号 范围:0~31        
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)        
        ram_wr_addr <= 5'd0;
    else if(wr_cnt >= 6'd0 && wr_cnt <= 6'd31)
        ram_wr_addr <= ram_wr_addr + 1'b1;
    else
        ram_wr_addr <= 5'd0;
end        

endmodule