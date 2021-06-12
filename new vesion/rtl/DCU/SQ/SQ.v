module SQ(input wire       clk,rst_n,
          input wire       fetch,wfull,
          input wire       bit,
          input wire[63:0] CCL_code_sq,
          input wire[15:0] CCL_count_sq,
          output reg       fin,bit_req,
          output wire[3:0] wdata,
          output reg       winc);

    parameter IDLE   = 3'b000;
    parameter Decode = 3'b001;
    parameter WaitW  = 3'b010;
    parameter WaitR  = 3'b011;
    parameter WaitWR = 3'b100;
    parameter WaitF  = 3'b101;
    parameter Finish = 3'b110;
    reg[2:0]  curr_state,next_state;

    wire[3:0] CCL_code_wap[15:0];
    wire[3:0] CCL_count_wap[4:1];
    wire      match,decode_end;

    reg       decode_mode;
    reg       decode_buf;
    reg       ref;
    reg[5:0]  num_count;
    reg[5:0]  next_num_count;
    reg[2:0]  len;
    wire[2:0] next_len;
    reg[3:0]  off,base;
    wire[3:0] temp_off,next_base;
    reg[3:0]  reg_wdata;
    reg       ext;

    //FSM always code block

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
                if(fetch)begin
                    next_state  = Decode;
                    fin         = 1'b0; 
                    bit_req     = 1'b0;
                    winc        = 1'b0;
                    decode_mode = 1'b0;
                    ref         = 1'b1;
                end
                else begin
                    next_state  = IDLE;
                    fin         = 1'b0; 
                    bit_req     = 1'b0;
                    winc        = 1'b0;
                    decode_mode = 1'b0;
                    ref         = 1'b1;
                end
            end
            Decode:begin
                case({fetch,match})
                    2'b00:begin
                        next_state  = WaitR;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b0;
                        decode_mode = 1'b1;
                        ref         = 1'b0;
                    end
                    2'b10:begin
                        next_state  = Decode;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b0;
                        decode_mode = 1'b1;
                        ref         = 1'b0;
                    end
                    2'b01:begin
                        case({wfull,decode_end})
                            2'b00:begin
                                next_state  = WaitR;
                                fin         = 1'b0; 
                                bit_req     = 1'b1;
                                winc        = 1'b1;
                                decode_mode = 1'b0;
                                ref         = 1'b1;
                            end
                            2'b01:begin
                                next_state  = Finish;
                                fin         = 1'b0; 
                                bit_req     = 1'b0;
                                winc        = 1'b1;
                                decode_mode = 1'b1;
                                ref         = 1'b1;
                            end
                            2'b10:begin
                                next_state  = WaitWR;
                                fin         = 1'b0; 
                                bit_req     = 1'b1;
                                winc        = 1'b0;
                                decode_mode = 1'b0;
                                ref         = 1'b0;
                            end
                            2'b11:begin
                                next_state  = WaitF;
                                fin         = 1'b0; 
                                bit_req     = 1'b0;
                                winc        = 1'b0;
                                decode_mode = 1'b0;
                                ref         = 1'b0;
                            end
                            default:begin
                                next_state  = IDLE;
                                fin         = 1'b0; 
                                bit_req     = 1'b0;
                                winc        = 1'b0;
                                decode_mode = 1'b0;
                                ref         = 1'b1;
                            end
                        endcase
                    end
                    2'b11:begin
                        case({wfull,decode_end})
                            2'b00:begin
                                next_state  = Decode;
                                fin         = 1'b0; 
                                bit_req     = 1'b1;
                                winc        = 1'b1;
                                decode_mode = 1'b1;
                                ref         = 1'b1;
                            end
                            2'b01:begin
                                next_state  = Finish;
                                fin         = 1'b0; 
                                bit_req     = 1'b0;
                                winc        = 1'b1;
                                decode_mode = 1'b1;
                                ref         = 1'b1;
                            end
                            2'b10:begin
                                next_state  = WaitW;
                                fin         = 1'b0; 
                                bit_req     = 1'b1;
                                winc        = 1'b0;
                                decode_mode = 1'b0;
                                ref         = 1'b0;
                            end
                            2'b11:begin
                                next_state  = WaitF;
                                fin         = 1'b0; 
                                bit_req     = 1'b0;
                                winc        = 1'b0;
                                decode_mode = 1'b0;
                                ref         = 1'b0;
                            end
                            default:begin
                                next_state  = IDLE;
                                fin         = 1'b0; 
                                bit_req     = 1'b0;
                                winc        = 1'b0;
                                decode_mode = 1'b0;
                                ref         = 1'b1;
                            end
                        endcase
                    end
                    default:begin
                        next_state  = IDLE;
                        fin         = 1'b0; 
                        bit_req     = 1'b0;
                        winc        = 1'b0;
                        decode_mode = 1'b0;
                        ref         = 1'b1;
                    end
                endcase
            end
            WaitR:begin
                if(fetch)begin
                    next_state  = Decode;
                    fin         = 1'b0; 
                    bit_req     = 1'b1;
                    winc        = 1'b0;
                    decode_mode = 1'b0;
                    ref         = 1'b0;
                end
                else begin
                    next_state  = WaitR;
                    fin         = 1'b0; 
                    bit_req     = 1'b1;
                    winc        = 1'b0;
                    decode_mode = 1'b0;
                    ref         = 1'b0;
                end
            end
            WaitW:begin
                if(wfull)begin
                    next_state  = WaitW;
                    fin         = 1'b0; 
                    bit_req     = 1'b0;
                    winc        = 1'b0;
                    decode_mode = 1'b0;
                    ref         = 1'b0;
                end
                else begin
                    next_state  = Decode;
                    fin         = 1'b0; 
                    bit_req     = 1'b0;
                    winc        = 1'b1;
                    decode_mode = 1'b0;
                    ref         = 1'b1;
                end
            end
            WaitWR:begin
                case({fetch,wfull})
                    2'b00:begin
                        next_state  = WaitR;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b1;
                        decode_mode = 1'b0;
                        ref         = 1'b1;
                    end
                    2'b01:begin
                        next_state  = WaitWR;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b0;
                        decode_mode = 1'b0;
                        ref         = 1'b0;
                    end
                    2'b10:begin
                        next_state  = Decode;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b1;
                        decode_mode = 1'b0;
                        ref         = 1'b1;
                    end
                    2'b11:begin
                        next_state  = WaitW;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b0;
                        decode_mode = 1'b0;
                        ref         = 1'b0;
                    end
                    default:begin
                        next_state  = WaitWR;
                        fin         = 1'b0; 
                        bit_req     = 1'b1;
                        winc        = 1'b0;
                        decode_mode = 1'b0;
                        ref         = 1'b0;
                    end
                endcase
            end
            WaitF:begin
                if(wfull)begin
                    next_state  = WaitF;
                    fin         = 1'b0; 
                    bit_req     = 1'b0;
                    winc        = 1'b0;
                    decode_mode = 1'b0;
                    ref         = 1'b0;
                end
                else begin
                    next_state  = Finish;
                    fin         = 1'b0; 
                    bit_req     = 1'b0;
                    winc        = 1'b1;
                    decode_mode = 1'b0;
                    ref         = 1'b1;
                end
            end
            Finish:begin
                next_state  = Finish;
                fin         = 1'b1; 
                bit_req     = 1'b0;
                winc        = 1'b0;
                decode_mode = 1'b0;
                ref         = 1'b0;
            end
            default:begin
                next_state  = IDLE;
                fin         = 1'b0; 
                bit_req     = 1'b0;
                winc        = 1'b0;
                decode_mode = 1'b0;
                ref         = 1'b0;
            end
        endcase
    end

    //other seq logic

    always @(posedge clk) begin
        if(fetch)begin
            decode_buf <= bit;
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            num_count <= 6'b0;
        end
        else if(winc) begin
            num_count <= next_num_count;
        end
    end

    always @(posedge clk) begin
        if(ref) begin
            off  <= 4'b0;
            base <= 4'b0;
            len  <= 3'b001;
        end
        else if(decode_mode) begin
            off  <= temp_off - CCL_count_wap[len];
            base <= next_base;
            len  <= next_len;
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            ext <= 1'b0;
        end
        else if(winc)begin
            ext <= (wdata == 4'h9)?1'b1:1'b0;
        end
    end

    always @(posedge clk) begin
        if((next_state == WaitW)&(curr_state != WaitW)) reg_wdata <= CCL_code_wap[base + temp_off]; 
    end

    //Comb logic

    always @(*) begin
        case(wdata)
            4'h0: next_num_count = num_count + (ext?6'd3 :6'd1);
            4'h1: next_num_count = num_count + (ext?6'd4 :6'd1);
            4'h2: next_num_count = num_count + (ext?6'd5 :6'd1);
            4'h3: next_num_count = num_count + (ext?6'd6 :6'd1);
            4'h4: next_num_count = num_count + (ext?6'd7 :6'd1);
            4'h5: next_num_count = num_count + (ext?6'd8 :6'd1);
            4'h6: next_num_count = num_count + (ext?6'd9 :6'd1);
            4'h7: next_num_count = num_count + (ext?6'd10:6'd1);
            4'h8: next_num_count = num_count + 6'd1;
            4'h9: next_num_count = num_count;
            default: next_num_count = num_count;
        endcase
    end


    assign temp_off   = (off << 1) + (decode_buf?1'b1:1'b0);
    assign next_base  = (base + CCL_count_wap[len]) << 1;
    assign next_len   = len + 1'b1;

    assign match      = temp_off < CCL_count_wap[len];
    assign wdata      = (curr_state == WaitW)?reg_wdata:CCL_code_wap[base + temp_off];
    assign decode_end = next_num_count >= 6'd45;


    assign {CCL_code_wap[15],CCL_code_wap[14],CCL_code_wap[13],CCL_code_wap[12],
            CCL_code_wap[11],CCL_code_wap[10],CCL_code_wap[9], CCL_code_wap[8],
            CCL_code_wap[7], CCL_code_wap[6], CCL_code_wap[5], CCL_code_wap[4],
            CCL_code_wap[3], CCL_code_wap[2], CCL_code_wap[1], CCL_code_wap[0]}  = CCL_code_sq;

    assign {CCL_count_wap[4],CCL_count_wap[3],CCL_count_wap[2],CCL_count_wap[1]} = CCL_count_sq;

endmodule