module Printer(input wire        clk,rst_n,
               input wire        rempty,wfull,
               input wire[31:0]  rdata,
               input wire        HREADY,
               input wire[31:0]  HRDATA,
               output wire       winc,rinc,
               output wire[16:0] wdata,
               output wire[31:0] HADDR,
               output wire[1:0]  HTRANS,
               output wire       HWRITE);

    assign HWRITE = 1'b0;

    reg[31:0] XYReg,SizeReg,AddrReg;
    wire[15:0] XH,XL,YH,YL;

    wire row_end,img_end;
    wire init_sign,init_end,init_mode;
    wire XY,SizePh,AddrPh;
    wire PT_winc;
    wire[3:0] data_sel;
    wire[16:0] PT_wdata;
    reg[15:0] temp_wdata;

    wire[31:0] wfull_HRDATA_buf;

    reg[4:0] row_count,col_count;

    Printer_ctr Printer_ctr(
        .clk        (clk),
        .rst_n      (rst_n),
        .rempty     (rempty),
        .wfull      (wfull),
        .HREADY     (HREADY),
        .row_end    (row_end),
        .img_end    (img_end),
        .init_sign  (init_sign),
        .init_end   (init_end),
        .HRDATA     (HRDATA),
        .XY         (XY),
        .SizePh     (SizePh),
        .AddrPh     (AddrPh),
        .init_mode  (init_mode),
        .rinc       (rinc),
        .winc       (PT_winc),
        .data_sel   (data_sel),
        .ID         (PT_wdata[16]),
        .HTRANS     (HTRANS),
        .wfull_HRDATA_buf (wfull_HRDATA_buf)
    );

    wire       init_winc;
    wire[16:0] init_wdata;

    LCD_ini LCD_ini(
        .clk        (clk),
        .rst_n      (rst_n),
        .init_mode  (init_mode),
        .wfull      (wfull),
        .init_end   (init_end),
        .winc       (init_winc),
        .wdata      (init_wdata)
    );

    always @(posedge clk) begin
        if(XY) XYReg <= rdata;
        else if(row_end&PT_winc&((data_sel == 4'b0111)|(data_sel == 4'b1000))) XYReg <= XYReg + 1'b1;
    end

    always @(posedge clk) begin
        if(SizePh) SizeReg <= rdata;
    end

    always @(posedge clk) begin
        if(AddrPh) AddrReg <= rdata;
        else begin
            if(((data_sel == 4'b0111)|(data_sel == 4'b1000))&PT_winc) AddrReg <= AddrReg + 2'b10;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) row_count <= 5'b0;
        else begin
            if(row_end&PT_winc&((data_sel == 4'b0111)|(data_sel == 4'b1000))) row_count <= 5'b0;
            else if(PT_winc&((data_sel == 4'b0111)|(data_sel == 4'b1000))) row_count <= row_count + 1'b1;
        end
    end

    always @(posedge clk) begin
        if(!rst_n) col_count <= 5'b0;
        else begin
            if(img_end&PT_winc&((data_sel == 4'b0111)|(data_sel == 4'b1000))) col_count <= 5'b0;
            else if(row_end&PT_winc&((data_sel == 4'b0111)|(data_sel == 4'b1000))) col_count <= col_count + 1'b1;
        end
    end

    assign row_end = row_count == SizeReg[4:0];
    assign img_end = (col_count == SizeReg[4:0])&row_end;
    assign init_sign = (~rempty)&(&rdata);

    assign XH = {8'b0,XYReg[31:24]};
    assign XL = {8'b0,XYReg[23:16]};
    assign YH = {8'b0,XYReg[15:8]};
    assign YL = {8'b0,XYReg[7:0]};

    always @(*) begin
        case(data_sel)
            4'b0000: temp_wdata = 16'h002a;  //XIns
            4'b0001: temp_wdata = XH;        //XAix1
            4'b0010: temp_wdata = XL;        //XAix2
            4'b0011: temp_wdata = 16'h002b;  //YIns
            4'b0100: temp_wdata = YH;        //YAix1
            4'b0101: temp_wdata = YL;        //YAix2
            4'b0110: temp_wdata = 16'h002c;  //RamPre
            4'b0111:begin                    //Pixel
                if(AddrReg[1]) temp_wdata = HRDATA[31:16]; 
                else           temp_wdata = HRDATA[15:0]; 
            end
            4'b1000:begin                    //Pixel
                if(AddrReg[1]) temp_wdata = wfull_HRDATA_buf[31:16]; 
                else           temp_wdata = wfull_HRDATA_buf[15:0]; 
            end
            default: temp_wdata = 16'h0;
        endcase
    end

    assign PT_wdata[15:0] = temp_wdata;
    

    assign HADDR = AddrReg;
    assign wdata = init_mode?init_wdata:PT_wdata;
    assign winc  = init_mode?init_winc:PT_winc;

endmodule