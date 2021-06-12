module CL_code_dist(input wire clk,rst_n,
                    input wire enb,
                    input wire[63:0] distTree,
                    input wire[7:0] distCode,
                    input wire[3:0] len_in,
                    output wire fin_dist,
                    output wire[3:0] distSymb,
                    output wire[3:0] distCount);

    parameter IDLE = 4'b0000;
    parameter Len1 = 4'b0001;
    parameter Len2 = 4'b0010;
    parameter Len3 = 4'b0011;
    parameter Len4 = 4'b0100;
    parameter Len5 = 4'b0101;
    parameter Len6 = 4'b0110;
    parameter Len7 = 4'b0111;
    parameter Len8 = 4'b1000;
    parameter Fin  = 4'b1001;
    reg[3:0] curr_state,next_state;

    reg[3:0] distCode_reg[255:0],distCode_count[8:1];
    reg[7:0] code,next_code;
    reg[3:0] len;
    reg[3:0] pos;
    reg pos_enb;

    wire[3:0] distTree_wap[15:0];
    wire match,pos_end;

    //FSM block

    always @(posedge clk) begin
        if(!rst_n)begin
            curr_state <= IDLE;
        end
        else begin
            curr_state <= next_state;
        end
    end

    always @(*) begin
        case(curr_state)
            IDLE:begin
                if(enb)begin
                    next_state = Len1;
                    len        = 4'd0;
                    pos_enb    = 1'b0;
                end
                else begin
                    next_state = IDLE;
                    len        = 4'd0;
                    pos_enb    = 1'b0;
                end
            end
            Len1:begin
                if(pos_end)begin
                    next_state = Len2;
                    len        = 4'd1;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len1;
                    len        = 4'd1;
                    pos_enb    = 1'b1;
                end
            end
            Len2:begin
                if(pos_end)begin
                    next_state = Len3;
                    len        = 4'd2;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len2;
                    len        = 4'd2;
                    pos_enb    = 1'b1;
                end
            end
            Len3:begin
                if(pos_end)begin
                    next_state = Len4;
                    len        = 4'd3;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len3;
                    len        = 4'd3;
                    pos_enb    = 1'b1;
                end
            end
            Len4:begin
                if(pos_end)begin
                    next_state = Len5;
                    len        = 4'd4;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len4;
                    len        = 4'd4;
                    pos_enb    = 1'b1;
                end
            end
            Len5:begin
                if(pos_end)begin
                    next_state = Len6;
                    len        = 4'd5;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len5;
                    len        = 4'd5;
                    pos_enb    = 1'b1;
                end
            end
            Len6:begin
                if(pos_end)begin
                    next_state = Len7;
                    len        = 4'd6;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len6;
                    len        = 4'd6;
                    pos_enb    = 1'b1;
                end
            end
            Len7:begin
                if(pos_end)begin
                    next_state = Len8;
                    len        = 4'd7;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len7;
                    len        = 4'd7;
                    pos_enb    = 1'b1;
                end
            end
            Len8:begin
                if(pos_end)begin
                    next_state = Fin;
                    len        = 4'd8;
                    pos_enb    = 1'b1;
                end
                else begin
                    next_state = Len8;
                    len        = 4'd8;
                    pos_enb    = 1'b1;
                end
            end
            Fin:begin
                next_state = Fin;
                len        = 4'd0;
                pos_enb    = 1'b0;
            end
            default:begin
                next_state = IDLE;
                len        = 4'd0;
                pos_enb    = 1'b0;
            end
        endcase
    end
    
    //Other seq logic

    always @(posedge clk) begin
        if(!rst_n)begin
            pos <= 4'b0;
        end
        else if(pos_enb) begin
            if(pos_end) pos <= 4'b0;
            else pos <= pos + 1'b1;
        end
    end

    always @(posedge clk) begin
        if(pos_enb&match) distCode_reg[code] <= pos;
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            distCode_count[1] <= 4'b0;
            distCode_count[2] <= 4'b0;
            distCode_count[3] <= 4'b0;
            distCode_count[4] <= 4'b0;
            distCode_count[5] <= 4'b0;
            distCode_count[6] <= 4'b0;
            distCode_count[7] <= 4'b0;
            distCode_count[8] <= 4'b0;
        end
        else begin
            distCode_count[len] <= distCode_count[len] + ((pos_enb&match)?1'b1:1'b0);
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            code <= 8'b0;
        end
        else if(pos_enb)begin
            code <= next_code;
        end
    end

    //Other comb logic

    always @(*) begin
        case({pos_end,match})
            2'b00: next_code = code;
            2'b01: next_code = code + 1'b1;
            2'b10: next_code = code << 1;
            2'b11: next_code = (code + 1'b1) << 1;
            default: next_code = code;
        endcase
    end


    assign distSymb = distCode_reg[distCode];
    assign fin_dist = curr_state == Fin;
    assign distCount = ((len_in>=4'd1)&(len_in<=4'd8))?distCode_count[len_in]:4'b0;

    assign match = distTree_wap[pos] == len;
    assign pos_end = pos == 4'd15;

    assign {distTree_wap[15],distTree_wap[14],distTree_wap[13],distTree_wap[12],
            distTree_wap[11],distTree_wap[10],distTree_wap[9], distTree_wap[8],
            distTree_wap[7], distTree_wap[6], distTree_wap[5], distTree_wap[4],
            distTree_wap[3], distTree_wap[2], distTree_wap[1], distTree_wap[0]} = distTree;

endmodule