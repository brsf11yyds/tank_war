`timescale 1ps/1ps
module Printer_testbench();

    reg clk,rst_n;
    wire rempty;
    reg wfull;
    wire[31:0] rdata;
    reg HREADY;
    wire[31:0] HRDATA;

    wire winc,rinc;
    wire[16:0] wdata;
    wire[31:0] HADDR;
    wire[1:0] HTRANS;
    wire HWRITE;

    reg[2:0] rdata_sp;

    wire[31:0] rdata_reg[3:0];
    wire[31:0] Pixel_data_reg[7:0];

    Printer Printer(
        .clk(clk),
        .rst_n(rst_n),
        .rempty(rempty),
        .wfull(wfull),
        .rdata(rdata),
        .HREADY(HREADY),
        .HRDATA(HRDATA),
        .winc(winc),
        .rinc(rinc),
        .wdata(wdata),
        .HADDR(HADDR),
        .HTRANS(HTRANS),
        .HWRITE(HWRITE)
    );

    initial begin
        rst_n = 0;
        wfull = 0;
        HREADY = 1;
        #10;
        rst_n = 1;
    end

    always @(posedge clk) begin
        if(!rst_n) rdata_sp <= 3'b0;
        else if(rinc) rdata_sp <= rdata_sp + 1'b1;
    end

    assign rdata = rdata_reg[rdata_sp];
    assign HRDATA = Pixel_data_reg[HADDR[4:2]];

    assign rdata_reg[0] = 32'hffff_ffff;
    assign rdata_reg[1] = 32'h000f_000F;
    assign rdata_reg[2] = 32'h0000_0003;
    assign rdata_reg[3] = 32'h0000_0000;

    assign Pixel_data_reg[0] = 32'h0601_0601;
    assign Pixel_data_reg[1] = 32'h1611_1611;
    assign Pixel_data_reg[2] = 32'h2621_2621;
    assign Pixel_data_reg[3] = 32'h3631_3631;
    assign Pixel_data_reg[4] = 32'h4641_4641;
    assign Pixel_data_reg[5] = 32'h5651_5651;
    assign Pixel_data_reg[6] = 32'h6661_6661;
    assign Pixel_data_reg[7] = 32'h7671_7671;

    assign rempty = rdata_sp >= 5'd4;

    always begin
        clk = 0;
        #5;
        clk = 1;
        #5;
    end
endmodule