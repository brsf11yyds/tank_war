module CL_code_lit(input wire clk,rst_n,
                   input wire enb,
                   input wire[115:0] litTree,
                   input wire[7:0] litCode,
                   input wire[3:0] len_in,
                   output wire fin_lit,
                   output wire[4:0] litSymb,
                   output wire[4:0] litCount);

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

    reg[4:0] litCode_reg[255:0],litCode_count[8:1];
    reg[7:0] code,next_code;
    reg[3:0] len;
    reg[4:0] pos;
    reg pos_enb;

    wire[3:0] litTree_wap[28:0];
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
            pos <= 5'b0;
        end
        else if(pos_enb) begin
            if(pos_end) pos <= 5'b0;
            else pos <= pos + 1'b1;
        end
    end

    always @(posedge clk) begin
        if(pos_enb&match) litCode_reg[code] <= pos;
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            litCode_count[1] <= 5'b0;
            litCode_count[2] <= 5'b0;
            litCode_count[3] <= 5'b0;
            litCode_count[4] <= 5'b0;
            litCode_count[5] <= 5'b0;
            litCode_count[6] <= 5'b0;
            litCode_count[7] <= 5'b0;
            litCode_count[8] <= 5'b0;
        end
        else begin
            litCode_count[len] <= litCode_count[len] + ((pos_enb&match)?1'b1:1'b0);
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


    assign litSymb = litCode_reg[litCode];
    assign fin_lit = curr_state == Fin;
    assign litCount = ((len_in>=4'd1)&(len_in<=4'd8))?litCode_count[len_in]:5'b0;

    assign match = litTree_wap[pos] == len;
    assign pos_end = pos == 5'd28;

    assign {litTree_wap[28],litTree_wap[27],litTree_wap[26],litTree_wap[25],
            litTree_wap[24],litTree_wap[23],litTree_wap[22],litTree_wap[21],
            litTree_wap[20],litTree_wap[19],litTree_wap[18],litTree_wap[17],
            litTree_wap[16],litTree_wap[15],litTree_wap[14],litTree_wap[13],
            litTree_wap[12],litTree_wap[11],litTree_wap[10],litTree_wap[9],
            litTree_wap[8], litTree_wap[7], litTree_wap[6], litTree_wap[5],
            litTree_wap[4], litTree_wap[3], litTree_wap[2], litTree_wap[1],
            litTree_wap[0]}  = litTree;

endmodule