`timescale 1ns / 1ps
module ip_1port_ram_tb;

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
    wire ena_tb;
    wire wea_tb;
    wire [4:0] addra_tb;
    wire [7:0] dina_tb;
    wire [7:0] douta_tb;
    // Instantiate the Unit Under Test (UUT)
    ip_1port_ram uut (
    .sys_clk      (sys_clk  ),
    .sys_rst_n    (sys_rst_n),
    .ena          (ena_tb   ),
    .wea          (wea_tb   ),
    .addra        (addra_tb ),
    .dina         (dina_tb  ),
    .douta        (douta_tb )
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

