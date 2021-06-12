module Printer_ctr(input wire       clk,rst_n,
                   input wire       rempty,wfull,
                   input wire       HREADY,row_end,img_end,init_sign,init_end,
                   input wire[31:0] HRDATA,
                   output wire      XY,SizePh,AddrPh,init_mode,
                   output reg       rinc,winc,
                   output reg[3:0]  data_sel,
                   output reg       ID,       //0: Ins  1: Data
                   output reg[1:0]  HTRANS,
                   output reg[31:0] wfull_HRDATA_buf);

    parameter IDLE     = 4'b0000;
    parameter Addr     = 4'b0001;
    parameter XIns     = 4'b0010;
    parameter XAix1    = 4'b0011;
    parameter XAix2    = 4'b0100;
    parameter YIns     = 4'b0101;
    parameter YAix1    = 4'b0110;
    parameter YAix2    = 4'b0111;
    parameter RamPre   = 4'b1000;
    parameter Pixel_Ad = 4'b1001;
    parameter Pixel_Da = 4'b1010;
    parameter Init     = 4'b1011;
    parameter Size     = 4'b1100;
    parameter WaitDa   = 4'b1101;
    reg[3:0] curr_state,next_state;

    wire HRDATA_buf_enb;

    //FSM block

    always @(posedge clk) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            IDLE:begin
                if(rempty)begin
                    next_state = IDLE;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    if(init_sign)begin
                        next_state = Init;
                        rinc       = 1'b1;
                        winc       = 1'b0;
                        data_sel   = 4'b0000;
                        ID         = 1'b0;
                        HTRANS     = 2'b00;
                    end
                    else begin
                        next_state = Size;
                        rinc       = 1'b1;
                        winc       = 1'b0;
                        data_sel   = 4'b0000;
                        ID         = 1'b0;
                        HTRANS     = 2'b00;
                    end
                end
            end
            Size:begin
                if(rempty)begin
                    next_state = Size;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = Addr;
                    rinc       = 1'b1;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
            end
            Addr:begin
                if(rempty)begin
                    next_state = Addr;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = XIns;
                    rinc       = 1'b1;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
            end
            XIns:begin
                if(wfull)begin
                    next_state = XIns;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = XAix1;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
            end
            XAix1:begin
                if(wfull)begin
                    next_state = XAix1;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = XAix2;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0001;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
            end
            XAix2:begin
                if(wfull)begin
                    next_state = XAix2;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = YIns;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0010;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
            end
            YIns:begin
                if(wfull)begin
                    next_state = YIns;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = YAix1;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0011;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
            end
            YAix1:begin
                if(wfull)begin
                    next_state = YAix1;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = YAix2;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0100;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
            end
            YAix2:begin
                if(wfull)begin
                    next_state = YAix2;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = RamPre;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0101;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
            end
            RamPre:begin
                if(wfull)begin
                    next_state = RamPre;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = Pixel_Ad;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    data_sel   = 4'b0110;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
            end
            Pixel_Ad:begin
                if(HREADY)begin
                    next_state = Pixel_Da;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b10;
                end
                else begin
                    next_state = Pixel_Ad;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b10;
                end
            end
            Pixel_Da:begin
                if(HREADY)begin
                    if(wfull)begin
                        next_state = WaitDa;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        data_sel   = 4'b0000;
                        ID         = 1'b1;
                        HTRANS     = 2'b00;
                    end
                    else begin
                        if(img_end)begin
                            next_state = IDLE;
                            rinc       = 1'b0;
                            winc       = 1'b1;
                            data_sel   = 4'b0111;
                            ID         = 1'b1;
                            HTRANS     = 2'b00;
                        end
                        else if(row_end)begin
                            next_state = XIns;
                            rinc       = 1'b0;
                            winc       = 1'b1;
                            data_sel   = 4'b0111;
                            ID         = 1'b1;
                            HTRANS     = 2'b00;
                        end
                        else begin
                            next_state = Pixel_Ad;
                            rinc       = 1'b0;
                            winc       = 1'b1;
                            data_sel   = 4'b0111;
                            ID         = 1'b1;
                            HTRANS     = 2'b00;
                        end
                    end
                end
                else begin
                    next_state = Pixel_Da;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
            end
            WaitDa:begin
                if(wfull)begin
                    next_state = WaitDa;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b1;
                    HTRANS     = 2'b00;
                end
                else begin
                    if(img_end)begin
                        next_state = IDLE;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        data_sel   = 4'b1000;
                        ID         = 1'b1;
                        HTRANS     = 2'b00;
                    end
                    else if(row_end)begin
                        next_state = XIns;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        data_sel   = 4'b1000;
                        ID         = 1'b1;
                        HTRANS     = 2'b00;
                    end
                    else begin
                        next_state = Pixel_Ad;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        data_sel   = 4'b1000;
                        ID         = 1'b1;
                        HTRANS     = 2'b00;
                    end
                end
            end
            Init:begin
                if(init_end)begin
                    next_state = IDLE;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
                else begin
                    next_state = Init;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    data_sel   = 4'b0000;
                    ID         = 1'b0;
                    HTRANS     = 2'b00;
                end
            end
            default:begin
                next_state = IDLE;
                rinc       = 1'b0;
                winc       = 1'b0;
                data_sel   = 4'b0000;
                ID         = 1'b0;
                HTRANS     = 2'b00;
            end
        endcase
    end

    always @(posedge clk) begin
        if(HRDATA_buf_enb) wfull_HRDATA_buf <= HRDATA;
    end


    assign XY        = curr_state == IDLE;
    assign SizePh    = curr_state == Size;
    assign AddrPh    = curr_state == Addr;
    assign init_mode = curr_state == Init;

    assign HRDATA_buf_enb = (curr_state == Pixel_Da)&HREADY&wfull;

endmodule