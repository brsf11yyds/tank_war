module CCL_ctr(input wire      clk,rst_n,
               input wire      winc,
               input wire[3:0] pos,
               output reg[1:0] buf_addr,
               output reg[2:0] len,
               output reg      wenb,
               output reg      pos_enb,
               output wire     pos_end,
               output reg      rdy);

    parameter Byte0 = 4'b0000;
    parameter Byte1 = 4'b0001;
    parameter Byte2 = 4'b0010;
    parameter Byte3 = 4'b0011;
    parameter Len1  = 4'b0100;
    parameter Len2  = 4'b0101;
    parameter Len3  = 4'b0110;
    parameter Len4  = 4'b0111;
    parameter Fin   = 4'b1000;
    reg[3:0] curr_state,next_state;

    always @(posedge clk) begin
        if(!rst_n)begin
            curr_state <= Byte0;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case(curr_state)
            Byte0:begin
                if(winc)begin
                    next_state = Byte1;
                    buf_addr   = 2'b00;
                    len        = 3'b000;
                    wenb       = 1'b1;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Byte0;
                    buf_addr   = 2'b00;
                    len        = 3'b000;
                    wenb       = 1'b0;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
            end
            Byte1:begin
                if(winc)begin
                    next_state = Byte2;
                    buf_addr   = 2'b01;
                    len        = 3'b000;
                    wenb       = 1'b1;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Byte1;
                    buf_addr   = 2'b01;
                    len        = 3'b000;
                    wenb       = 1'b0;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
            end
            Byte2:begin
                if(winc)begin
                    next_state = Byte3;
                    buf_addr   = 2'b10;
                    len        = 3'b000;
                    wenb       = 1'b1;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Byte2;
                    buf_addr   = 2'b10;
                    len        = 3'b000;
                    wenb       = 1'b0;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
            end
            Byte3:begin
                if(winc)begin
                    next_state = Len1;
                    buf_addr   = 2'b11;
                    len        = 3'b000;
                    wenb       = 1'b1;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Byte3;
                    buf_addr   = 2'b11;
                    len        = 3'b000;
                    wenb       = 1'b0;
                    pos_enb    = 1'b0;
                    rdy        = 1'b0;
                end
            end
            Len1:begin
                if(pos_end)begin
                    next_state = Len2;
                    buf_addr   = 2'b00;
                    len        = 3'b001;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Len1;
                    buf_addr   = 2'b00;
                    len        = 3'b001;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
            end
            Len2:begin
                if(pos_end)begin
                    next_state = Len3;
                    buf_addr   = 2'b00;
                    len        = 3'b010;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Len2;
                    buf_addr   = 2'b00;
                    len        = 3'b010;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
            end
            Len3:begin
                if(pos_end)begin
                    next_state = Len4;
                    buf_addr   = 2'b00;
                    len        = 3'b011;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Len3;
                    buf_addr   = 2'b00;
                    len        = 3'b011;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
            end
            Len4:begin
                if(pos_end)begin
                    next_state = Fin;
                    buf_addr   = 2'b00;
                    len        = 3'b100;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
                else begin
                    next_state = Len4;
                    buf_addr   = 2'b00;
                    len        = 3'b100;
                    wenb       = 1'b0;
                    pos_enb    = 1'b1;
                    rdy        = 1'b0;
                end
            end
            Fin:begin
                next_state = Fin;
                buf_addr   = 2'b00;
                len        = 3'b000;
                wenb       = 1'b0;
                pos_enb    = 1'b0;
                rdy        = 1'b1;
            end
            default:begin
                next_state = Byte0;
                buf_addr   = 2'b00;
                len        = 3'b000;
                wenb       = 1'b0;
                pos_enb    = 1'b0;
                rdy        = 1'b0;
            end
        endcase
    end

    assign pos_end = (pos == 4'b1001);

endmodule