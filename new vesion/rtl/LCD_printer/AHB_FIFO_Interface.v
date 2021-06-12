module AHB_FIFO_Interface(input wire        clk,rst_n,
                          input wire        wfull,
                          input wire        HSEL,HWRITE,HREADY,
                          input wire[1:0]   HTRANS,
                          input wire[31:0]  HWDATA,
                          output reg        HREADYOUT,
                          output wire[31:0] HRDATA,
                          output wire       HRESP,
                          output reg        winc,
                          output wire[31:0] wdata);

    assign HRDATA = 32'b0;
    assign HRESP  = 1'b0;

    parameter AddrPh = 1'b0;
    parameter DataPh = 1'b1;
    reg curr_state,next_state;

    always @(posedge clk) begin
        if(!rst_n) curr_state <= AddrPh;
        else curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            AddrPh:begin
                if(HTRANS[1]&HWRITE&HSEL&HREADY) begin
                    next_state = DataPh;
                    HREADYOUT  = 1'b1;
                    winc       = 1'b0;
                end
                else begin
                    next_state = AddrPh;
                    HREADYOUT  = 1'b1;
                    winc       = 1'b0;
                end
            end
            DataPh:begin
                if(wfull)begin
                    next_state = DataPh;
                    HREADYOUT  = 1'b0;
                    winc       = 1'b0;
                end
                else begin
                    next_state = AddrPh;
                    HREADYOUT  = 1'b1;
                    winc       = 1'b1;
                end
            end
            default:begin
                next_state = AddrPh;
                HREADYOUT  = 1'b1;
                winc       = 1'b0;
            end
        endcase
    end


    assign wdata = HWDATA[31:0];

endmodule