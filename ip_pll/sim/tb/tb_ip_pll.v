`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////
// Module Name: tb_ip_pll
//////////////////////////////////////////////////////////////

module tb_ip_pll;

    // Inputs
    reg sys_clk;
    reg sys_rst_n;
    
    // Outputs
    wire clk_100m;
    wire clk_100m_180deg;
    wire clk_50m;
    wire clk_25m;
    wire clk_25m_75;
    wire locked;
    // Instantiate the Unit Under Test (UUT)
    ip_pll uut(
    .sys_clk            (sys_clk        ),  //系统时钟
    .sys_rst_n          (sys_rst_n      ),  //系统复位，低电平有效
    //输出时钟          
    .clk_100m           (clk_100m       ),  //100Mhz时钟频率
    .clk_100m_180deg    (clk_100m_180deg),  //100Mhz时钟频率,相位偏移180度
    .clk_50m            (clk_50m        ),  //50Mhz时钟频率
    .clk_25m            (clk_25m        ),  //25Mhz时钟频率
    .clk_25m_75         (clk_25m_75     ),  //25Mhz时钟频率,占空比75.0%
    .locked             (locked         )
    );

    initial begin
    // Initialize Inputs
    sys_clk   = 0;
    sys_rst_n = 0;
    
    // Wait 100 ns for global reset to finish
    #100;
    sys_rst_n = 1;
    // Add stimulus here
    end
    
    always #10 sys_clk=~sys_clk;  //20ns

endmodule