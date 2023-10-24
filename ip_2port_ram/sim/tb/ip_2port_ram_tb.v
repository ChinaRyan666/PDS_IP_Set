`timescale 1ns / 1ps
module ip_2port_ram_tb;

reg  grs_n;
//GTP_GRS I_GTP_GRS(
    GTP_GRS GRS_INST(
    .GRS_N (grs_n)
    );
    
    initial begin
    grs_n = 1'b0;
    #5000 grs_n = 1'b1;
    end

    // Inputs
    reg sys_clk;
    reg sys_rst_n;

    // Outputs
    wire          clk_50m ;
    wire          clk_25m ;
    wire          locked  ;
    
    wire          wr_en_tb  ; //ram写使能
    wire [4:0]    wr_addr_tb; //ram写地址
    wire [7:0]    wr_data_tb; //ram写数据
    wire          rd_en_tb  ; //ram读使能
    wire [4:0]    rd_addr_tb; //ram读地址
    wire [7:0]    rd_data_tb; //ram读数据 

    // Instantiate the Unit Under Test (UUT)
    ip_2port_ram uut (
    .sys_clk      (sys_clk   ),
    .sys_rst_n    (sys_rst_n ),
    .clk_50m      (clk_50m   ),
    .clk_25m      (clk_25m   ),
    .locked       (locked    ),
    .ram_wr_en    (wr_en_tb  ),
    .ram_wr_addr  (wr_addr_tb),
    .ram_wr_data  (wr_data_tb),
    .ram_rd_en    (rd_en_tb  ),
    .ram_rd_addr  (rd_addr_tb),
    .ram_rd_data  (rd_data_tb)
    );
    
    initial begin
    // Initialize Inputs
    sys_clk = 0;
    sys_rst_n = 0;
    
    // Wait 100 ns for global reset to finish
    #100;
    sys_rst_n=1;
    // Add stimulus here
    end
    
    always #10 sys_clk=~sys_clk;
    
endmodule

