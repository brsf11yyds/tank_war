module Bitstream(input wire clk,rst_n,
                 input wire enb,
                 input wire rempty_in,rinc_in,
                 input wire[7:0] byte,
                 output wire bit,
                 output reg rempty_out,rinc_out);
    
    parameter IDLE  = 2'b00;
    parameter WaitR = 2'b01;
    parameter Ready = 2'b10;
    reg[1:0] curr_state,next_state;

    reg[7:0] byte_buf;
    reg[3:0] bp;
    wire rde;

    //FSM block

    always @(posedge clk) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            IDLE:begin
                if(enb)begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = IDLE;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
            end
            WaitR:begin
                if(rempty_in)begin
                    next_state = WaitR;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b0;
                end
                else begin
                    next_state = Ready;
                    rempty_out = 1'b1;
                    rinc_out   = 1'b1;
                end
            end
            Ready:begin
                if(rde)begin
                    if(rempty_in)begin
                        next_state = WaitR;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b0;
                    end
                    else begin
                        next_state = Ready;
                        rempty_out = 1'b1;
                        rinc_out   = 1'b1;
                    end
                end
                else begin
                    next_state = Ready;
                    rempty_out = 1'b0;
                    rinc_out   = 1'b0;
                end
            end
            default:begin
                next_state = IDLE;
                rempty_out = 1'b1;
                rinc_out   = 1'b0;
            end
        endcase
    end

    //Other seq logic

    always @(posedge clk) begin
        if(rinc_out) byte_buf <= byte;
    end

    always @(posedge clk) begin
        if(rinc_out) bp <= 4'b0;
        else if(rinc_in&(~rempty_out)) bp <= bp + 1'b1;
    end

    //Other comb logic

    assign rde = bp[3];
    assign bit = byte_buf[bp[2:0]];

endmodule