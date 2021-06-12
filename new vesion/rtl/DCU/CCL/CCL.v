module CCL(input wire        clk,rst_n,
           input wire        winc,
           input wire[7:0]   byte,
           output wire       CCL_rdy,
           output wire[63:0] CCL_code_sq,
           output wire[15:0] CCL_count_sq);

    reg[3:0]   CCL_code[15:0],code,pos,CCL_count[4:1];
    wire[2:0]  CCL_sq_wap[9:0];
    wire[29:0] CCL_sq;
    wire[1:0]  buf_addr;
    wire[2:0]  len;
    wire       wenb,pos_enb,pos_end,match;

    CCL_ctr CCL_ctr(
        .clk       (clk),
        .rst_n     (rst_n),
        .winc      (winc),
        .pos       (pos),
        .buf_addr  (buf_addr),
        .len       (len),
        .wenb      (wenb),
        .pos_enb   (pos_enb),
        .pos_end   (pos_end),
        .rdy       (CCL_rdy)
    );

    Byte_buf Byte_buf(
        .clk       (clk),
        .rst_n     (rst_n),
        .enb       (wenb),
        .buf_addr  (buf_addr),
        .byte      (byte),
        .CCL_sq    (CCL_sq)
    );

    always @(posedge clk) begin
        if(!rst_n)begin
            pos <= 4'b0;
        end
        else if(pos_enb) begin
            if(pos == 4'b1001)begin
                pos <= 4'b0;
            end
            else begin
                pos <= pos +1'b1;
            end
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            code <= 4'b0;
        end
        else if(pos_enb)begin
            case({pos_end,match})
                2'b01: code <= code + 1'b1;
                2'b10: code <= code << 1;
                2'b11: code <= (code+1'b1) << 1;
                default: code <= code;
            endcase
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            CCL_code[0]  <= 4'hf;
            CCL_code[1]  <= 4'hf;
            CCL_code[2]  <= 4'hf;
            CCL_code[3]  <= 4'hf;
            CCL_code[4]  <= 4'hf;
            CCL_code[5]  <= 4'hf;
            CCL_code[6]  <= 4'hf;
            CCL_code[7]  <= 4'hf;
            CCL_code[8]  <= 4'hf;
            CCL_code[9]  <= 4'hf;
            CCL_code[10] <= 4'hf;
            CCL_code[11] <= 4'hf;
            CCL_code[12] <= 4'hf;
            CCL_code[13] <= 4'hf;
            CCL_code[14] <= 4'hf;
            CCL_code[15] <= 4'hf;
        end
        else if(pos_enb&match)begin
            CCL_code[code] <= pos;
        end
    end

    always @(posedge clk) begin
        if(!rst_n)begin
            CCL_count[1] <= 4'b0;
            CCL_count[2] <= 4'b0;
            CCL_count[3] <= 4'b0;
            CCL_count[4] <= 4'b0;
        end
        else if(pos_enb&match)begin
            CCL_count[len] <= CCL_count[len] + 1'b1;
        end
    end

    assign match = CCL_sq_wap[pos] == len;
    assign {CCL_sq_wap[9],CCL_sq_wap[8],CCL_sq_wap[7],CCL_sq_wap[6],CCL_sq_wap[5],
            CCL_sq_wap[4],CCL_sq_wap[3],CCL_sq_wap[2],CCL_sq_wap[1],CCL_sq_wap[0]} = CCL_sq;
    assign CCL_code_sq = {CCL_code[15],CCL_code[14],CCL_code[13],CCL_code[12],
                          CCL_code[11],CCL_code[10],CCL_code[9] ,CCL_code[8],
                          CCL_code[7] ,CCL_code[6] ,CCL_code[5] ,CCL_code[4],
                          CCL_code[3] ,CCL_code[2] ,CCL_code[1] ,CCL_code[0]};
    assign CCL_count_sq = {CCL_count[4],CCL_count[3],CCL_count[2],CCL_count[1]};

endmodule