module CL(input wire         clk,rst_n,
          input wire         enb,rempty,
          input wire[3:0]    rdata,
          output wire        rinc,fin,
          output wire[115:0] litTree,
          output wire[63:0]  distTree);

    parameter IDLE    = 3'b000;
    parameter Extract = 3'b001;
    parameter WaitR   = 3'b010;
    parameter Zero    = 3'b011;
    parameter Finish  = 3'b100;
    reg[2:0] curr_state,next_state;

    reg[3:0] ext_buf;
    reg[3:0] Tree_buf[44:0];
    reg[5:0] TP;
    reg[5:0] next_TP;

    reg buf_winc,tree_winc,TP_winc,zero_buf;

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
                if(enb&(~rempty))begin
                    next_state = Extract;
                    buf_winc   = 1'b1;
                    tree_winc  = 1'b0;
                    TP_winc    = 1'b0;
                end
                else begin
                    next_state = IDLE;
                    buf_winc   = 1'b0;
                    tree_winc  = 1'b0;
                    TP_winc    = 1'b0;
                end
            end
            Extract:begin
                if(rempty)begin
                    next_state = WaitR;
                    buf_winc   = 1'b0;
                    tree_winc  = ~(ext_buf == 4'd9);
                    TP_winc    = 1'b1;
                end
                else begin
                    if(zero_buf)begin
                        next_state = Zero;
                        buf_winc   = 1'b0;
                        tree_winc  = 1'b0;
                        TP_winc    = 1'b0;
                    end
                    else begin
                        if(next_TP == 6'd45)begin
                            next_state = Finish;
                            buf_winc   = 1'b0;
                            tree_winc  = 1'b1;
                            TP_winc    = 1'b1;
                        end
                        else begin
                            if(ext_buf == 4'd9)begin
                                next_state = Zero;
                                buf_winc   = 1'b1;
                                tree_winc  = 1'b0;
                                TP_winc    = 1'b0;
                            end
                            else if(ext_buf <= 4'd8)begin
                                next_state = Extract;
                                buf_winc   = 1'b1;
                                tree_winc  = 1'b1;
                                TP_winc    = 1'b1;
                            end
                            else begin
                                next_state = IDLE;
                                buf_winc   = 1'b0;
                                tree_winc  = 1'b0;
                                TP_winc    = 1'b0;
                            end
                        end
                    end
                end
            end
            WaitR:begin
                if(rempty)begin
                    next_state = WaitR;
                    buf_winc   = 1'b0;
                    tree_winc  = 1'b0;
                    TP_winc    = 1'b0;
                end
                else begin
                    next_state = Extract;
                    buf_winc   = 1'b1;
                    tree_winc  = 1'b0;
                    TP_winc    = 1'b0;
                end
            end
            Zero:begin
                if(next_TP == 6'd45)begin
                    next_state = Finish;
                    buf_winc   = 1'b0;
                    tree_winc  = 1'b0;
                    TP_winc    = 1'b1;
                end
                else begin
                    if(rempty)begin
                        next_state = Zero;
                        buf_winc   = 1'b0;
                        tree_winc  = 1'b0;
                        TP_winc    = 1'b0;
                    end
                    else begin
                        next_state = Extract;
                        buf_winc   = 1'b1;
                        tree_winc  = 1'b0;
                        TP_winc    = 1'b1;
                    end
                end
            end
            Finish:begin
                next_state = Finish;
                buf_winc   = 1'b0;
                tree_winc  = 1'b0;
                TP_winc    = 1'b0;
            end
            default:begin
                next_state = IDLE;
                buf_winc   = 1'b0;
                tree_winc  = 1'b0;
                TP_winc    = 1'b0;
            end
        endcase
    end

    //Other seq logic

    always @(posedge clk) begin
        if(buf_winc)begin
            ext_buf <= rdata;
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            TP <= 6'b0;
        end
        else if(TP_winc) begin
            TP <= next_TP;
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            Tree_buf[0]  <= 4'b0;
            Tree_buf[1]  <= 4'b0;
            Tree_buf[2]  <= 4'b0;
            Tree_buf[3]  <= 4'b0;
            Tree_buf[4]  <= 4'b0;
            Tree_buf[5]  <= 4'b0;
            Tree_buf[6]  <= 4'b0;
            Tree_buf[7]  <= 4'b0;
            Tree_buf[8]  <= 4'b0;
            Tree_buf[9]  <= 4'b0;
            Tree_buf[10] <= 4'b0;
            Tree_buf[11] <= 4'b0;
            Tree_buf[12] <= 4'b0;
            Tree_buf[13] <= 4'b0;
            Tree_buf[14] <= 4'b0;
            Tree_buf[15] <= 4'b0;
            Tree_buf[16] <= 4'b0;
            Tree_buf[17] <= 4'b0;
            Tree_buf[18] <= 4'b0;
            Tree_buf[19] <= 4'b0;
            Tree_buf[20] <= 4'b0;
            Tree_buf[21] <= 4'b0;
            Tree_buf[22] <= 4'b0;
            Tree_buf[23] <= 4'b0;
            Tree_buf[24] <= 4'b0;
            Tree_buf[25] <= 4'b0;
            Tree_buf[26] <= 4'b0;
            Tree_buf[27] <= 4'b0;
            Tree_buf[28] <= 4'b0;
            Tree_buf[29] <= 4'b0;
            Tree_buf[30] <= 4'b0;
            Tree_buf[31] <= 4'b0;
            Tree_buf[32] <= 4'b0;
            Tree_buf[33] <= 4'b0;
            Tree_buf[34] <= 4'b0;
            Tree_buf[35] <= 4'b0;
            Tree_buf[36] <= 4'b0;
            Tree_buf[37] <= 4'b0;
            Tree_buf[38] <= 4'b0;
            Tree_buf[39] <= 4'b0;
            Tree_buf[40] <= 4'b0;
            Tree_buf[41] <= 4'b0;
            Tree_buf[42] <= 4'b0;
            Tree_buf[43] <= 4'b0;
            Tree_buf[44] <= 4'b0;
        end
        else begin
            if(tree_winc)begin
                Tree_buf[TP] <= ext_buf;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            zero_buf <= 1'b0;
        end
        else begin
            if((curr_state == Extract)&(ext_buf == 4'd9)) zero_buf <= 1'b1;
            if(curr_state == Zero) zero_buf <= 1'b0;
        end
    end

    //Other comb logic

    always @(*) begin
        case(ext_buf)
            4'd0: next_TP = TP + ((curr_state == Zero)?4'd3 :4'd1);
            4'd1: next_TP = TP + ((curr_state == Zero)?4'd4 :4'd1);
            4'd2: next_TP = TP + ((curr_state == Zero)?4'd5 :4'd1);
            4'd3: next_TP = TP + ((curr_state == Zero)?4'd6 :4'd1);
            4'd4: next_TP = TP + ((curr_state == Zero)?4'd7 :4'd1);
            4'd5: next_TP = TP + ((curr_state == Zero)?4'd8 :4'd1);
            4'd6: next_TP = TP + ((curr_state == Zero)?4'd9 :4'd1);
            4'd7: next_TP = TP + ((curr_state == Zero)?4'd10:4'd1);
            4'd8: next_TP = TP + 4'd1;
            4'd9: next_TP = TP;
            default: next_TP = TP;
        endcase
    end

    assign rinc     = buf_winc;
    assign fin      = curr_state == Finish;
    assign litTree  = {Tree_buf[28],Tree_buf[27],Tree_buf[26],Tree_buf[25],
                      Tree_buf[24],Tree_buf[23],Tree_buf[22],Tree_buf[21],
                      Tree_buf[20],Tree_buf[19],Tree_buf[18],Tree_buf[17],
                      Tree_buf[16],Tree_buf[15],Tree_buf[14],Tree_buf[13],
                      Tree_buf[12],Tree_buf[11],Tree_buf[10],Tree_buf[9],
                      Tree_buf[8], Tree_buf[7], Tree_buf[6], Tree_buf[5],
                      Tree_buf[4], Tree_buf[3], Tree_buf[2], Tree_buf[1],
                      Tree_buf[0]};
    assign distTree = {Tree_buf[44],Tree_buf[43],Tree_buf[42],Tree_buf[41],
                       Tree_buf[40],Tree_buf[39],Tree_buf[38],Tree_buf[37],
                       Tree_buf[36],Tree_buf[35],Tree_buf[34],Tree_buf[33],
                       Tree_buf[32],Tree_buf[31],Tree_buf[30],Tree_buf[29]};

endmodule