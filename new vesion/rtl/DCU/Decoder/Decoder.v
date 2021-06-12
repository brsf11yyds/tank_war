module Decoder(input wire       clk,rst_n,
               input wire       enb,rempty,wfull,
               input wire       bit,
               input wire[4:0]  litSymb,litCount,
               input wire[3:0]  distSymb,distCount,
               output reg       winc,
               output wire      fin,rinc_out,
               output wire[7:0] code,
               output wire[3:0] len_out,
               output reg[5:0]  symb_out);

    parameter IDLE     = 4'b0000;
    parameter lit      = 4'b0001;
    parameter WaitRL   = 4'b0010;
    parameter WaitWRL  = 4'b0011;
    parameter WaitWL   = 4'b0100;
    parameter dist     = 4'b0101;
    parameter WaitRT   = 4'b0110;
    parameter WaitWRT  = 4'b0111;
    parameter WaitWT   = 4'b1000;
    parameter WaitRTR  = 4'b1001;
    parameter WaitWRTR = 4'b1010;
    parameter WaitWTR  = 4'b1011;
    parameter WaitRD   = 4'b1100;
    parameter WaitF    = 4'b1101;
    parameter Finish   = 4'b1110;
    reg[4:0] curr_state,next_state;

    reg[3:0] len;
    reg[7:0] base,off;
    wire[7:0] next_base,next_off;
    reg match,ref;
    reg matched;
    reg rinc;
    wire next_matched;

    reg[4:0] symb,count;

    reg ext_ph,next_ph;
    reg[2:0] ext_bits;


    //FSM block

    always @(posedge clk) begin
        if(!rst_n)begin
            curr_state <= IDLE;
        end
        else begin
            curr_state <= next_state;
        end
    end

    //FSM state trans & comb logic

    always @(*) begin
        case(curr_state)
            IDLE:begin
                if(enb)begin
                    next_state = lit;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b1;
                end
                else begin
                    next_state = IDLE;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
            end
            lit:begin
                if(match)begin
                    if(litSymb >= 5'd16)begin
                        if(litSymb == 5'd16)begin
                            if(wfull)begin
                                next_state = WaitF;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                            else begin
                                next_state = Finish;
                                rinc       = 1'b0;
                                winc       = 1'b1;
                                ref        = 1'b0;
                            end
                        end
                        else begin
                            case({rempty,wfull})
                            2'b00:begin
                                next_state = dist;
                                rinc       = 1'b0;
                                winc       = 1'b1;
                                ref        = 1'b1;
                            end
                            2'b01:begin
                                next_state = WaitWT;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                            2'b10:begin
                                next_state = WaitRT;
                                rinc       = 1'b0;
                                winc       = 1'b1;
                                ref        = 1'b0;
                            end
                            2'b11:begin
                                next_state = WaitWRT;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                            default:begin
                                next_state = IDLE;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                        endcase 
                        end
                    end
                    else begin
                       case({rempty,wfull})
                            2'b00:begin
                                next_state = lit;
                                rinc       = 1'b0;
                                winc       = 1'b1;
                                ref        = 1'b1;
                            end
                            2'b01:begin
                                next_state = WaitWL;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                            2'b10:begin
                                next_state = WaitRL;
                                rinc       = 1'b0;
                                winc       = 1'b1;
                                ref        = 1'b0;
                            end
                            2'b11:begin
                                next_state = WaitWRL;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                            default:begin
                                next_state = IDLE;
                                rinc       = 1'b0;
                                winc       = 1'b0;
                                ref        = 1'b0;
                            end
                        endcase 
                    end
                end
                else begin
                    if(rempty)begin
                        next_state = WaitRL;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    else begin
                        next_state = lit;
                        rinc       = 1'b1;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                end
            end
            WaitRL:begin
                if(rempty)begin
                    next_state = WaitRL;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    if(matched)begin
                        next_state = lit;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b1;
                    end
                    else begin
                        next_state = lit;
                        rinc       = 1'b1;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                end
            end
            WaitWRL:begin
                case({rempty,wfull})
                    2'b00:begin
                        next_state = lit;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        ref        = 1'b1;
                    end
                    2'b01:begin
                        next_state = WaitWL;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    2'b10:begin
                        next_state = WaitRL;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        ref        = 1'b0;
                    end
                    2'b11:begin
                        next_state = WaitWRL;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    default:begin
                        next_state = IDLE;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                endcase
            end
            WaitWL:begin
                if(wfull)begin
                    next_state = WaitWL;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = lit;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    ref        = 1'b1;
                end
            end
            dist:begin
                if(match)begin
                    case({rempty,wfull})
                        2'b00:begin
                            next_state = lit;
                            rinc       = 1'b0;
                            winc       = 1'b1;
                            ref        = 1'b1;
                        end
                        2'b01:begin
                            next_state = WaitWTR;
                            rinc       = 1'b0;
                            winc       = 1'b0;
                            ref        = 1'b0;
                        end
                        2'b10:begin
                            next_state = WaitRTR;
                            rinc       = 1'b0;
                            winc       = 1'b1;
                            ref        = 1'b0;
                        end
                        2'b11:begin
                            next_state = WaitWRTR;
                            rinc       = 1'b0;
                            winc       = 1'b0;
                            ref        = 1'b0;
                        end
                        default:begin
                            next_state = IDLE;
                            rinc       = 1'b0;
                            winc       = 1'b0;
                            ref        = 1'b0;
                        end
                    endcase
                end
                else begin
                    if(rempty)begin
                        next_state = WaitRD;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    else begin
                        next_state = dist;
                        rinc       = 1'b1;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                end
            end
            WaitRT:begin
                if(rempty)begin
                    next_state = WaitRT;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = dist;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b1;
                end
            end
            WaitWRT:begin
                case({rempty,wfull})
                    2'b00:begin
                        next_state = dist;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        ref        = 1'b1;
                    end
                    2'b01:begin
                        next_state = WaitWT;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    2'b10:begin
                        next_state = WaitRT;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        ref        = 1'b0;
                    end
                    2'b11:begin
                        next_state = WaitWRT;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    default:begin
                        next_state = IDLE;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                endcase
            end
            WaitWT:begin
                if(wfull)begin
                    next_state = WaitWT;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = dist;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    ref        = 1'b1;
                end
            end
            WaitRTR:begin
                if(rempty)begin
                    next_state = WaitRTR;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = lit;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b1;
                end
            end
            WaitWRTR:begin
                case({rempty,wfull})
                    2'b00:begin
                        next_state = lit;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        ref        = 1'b1;
                    end
                    2'b01:begin
                        next_state = WaitWTR;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    2'b10:begin
                        next_state = WaitRTR;
                        rinc       = 1'b0;
                        winc       = 1'b1;
                        ref        = 1'b0;
                    end
                    2'b11:begin
                        next_state = WaitWRTR;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                    default:begin
                        next_state = IDLE;
                        rinc       = 1'b0;
                        winc       = 1'b0;
                        ref        = 1'b0;
                    end
                endcase
            end
            WaitWTR:begin
                if(wfull)begin
                    next_state = WaitWTR;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = lit;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    ref        = 1'b1;
                end
            end
            WaitRD:begin
                if(rempty)begin
                    next_state = WaitRD;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = dist;
                    rinc       = 1'b1;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
            end
            WaitF:begin
                if(wfull)begin
                    next_state = WaitF;
                    rinc       = 1'b0;
                    winc       = 1'b0;
                    ref        = 1'b0;
                end
                else begin
                    next_state = Finish;
                    rinc       = 1'b0;
                    winc       = 1'b1;
                    ref        = 1'b0;
                end
            end
            Finish:begin
                next_state = Finish;
                rinc       = 1'b0;
                winc       = 1'b0;
                ref        = 1'b0;
            end
            default:begin
                next_state = IDLE;
                rinc       = 1'b0;
                winc       = 1'b0;
                ref        = 1'b0;
            end
        endcase
    end
    

    //Other seq logic

    always @(posedge clk) begin
        if(!rst_n)begin
            len  <= 4'b0;
            off  <= 8'b0;
            base <= 8'b0;
        end
        else begin
            if(ref)begin
                len  <= 4'd1;
                off  <= bit?8'b0000_0001:8'b0;
                base <= 8'b0;
            end
            else if(rinc) begin
                len  <= len + 1'b1;
                off  <= next_off;
                base <= next_base;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n) matched <= 1'b0;
        else matched <= next_matched;
    end

    //Other comb logic

    always @(*) begin
        case(curr_state)
            lit:     match = off < count;
            dist:    match = off < count;
            default: match = 1'b0;
        endcase
    end

    always @(*) begin
        case(curr_state)
            lit:     symb  = litSymb;
            dist:    symb  = {1'b0,distSymb};
            default: symb  = 5'b0;
        endcase
    end

    always @(*) begin
        case(curr_state)
            lit:     count = litCount;
            WaitRL:  count = litCount;
            dist:    count = distCount;
            WaitRD:  count = distCount;
            default: count = 5'b0; 
        endcase
    end

    assign next_off     = ((off - count) << 1) + (bit?1'b1:1'b0);
    assign next_base    = (base + count) << 1;
    assign next_matched = winc|((curr_state == WaitRL)&matched);

    assign len_out      = len;
    assign fin          = curr_state == Finish;
    assign code         = off + base;
    assign rinc_out     = rinc|ref;
    
    always @(*) begin
        case(curr_state)
            lit:      symb_out = litSymb;
            WaitRL:   symb_out = litSymb;
            WaitWRL:  symb_out = litSymb;
            WaitWL:   symb_out = litSymb;
            WaitF:    symb_out = litSymb;
            WaitWRT:  symb_out = litSymb;
            WaitWT:   symb_out = litSymb;
            dist:     symb_out = distSymb + 6'd29;
            WaitWRTR: symb_out = distSymb + 6'd29;
            WaitWTR:  symb_out = distSymb + 6'd29;
            default:  symb_out = 6'b0;
        endcase
    end
    

endmodule