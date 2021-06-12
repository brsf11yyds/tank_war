module Byte_buf(input wire        clk,rst_n,
                input wire        enb,
                input wire[1:0]   buf_addr,
                input wire[7:0]   byte,
                output wire[29:0] CCL_sq);

    reg[7:0] Bbuf[3:0];

    always @(posedge clk) begin
        if(!rst_n)begin
            Bbuf[0] <= 8'b0;
            Bbuf[1] <= 8'b0;
            Bbuf[2] <= 8'b0;
            Bbuf[3] <= 8'b0;
        end
        else if(enb)begin
            Bbuf[buf_addr] <= byte;
        end
    end

    assign CCL_sq = {Bbuf[3][5],Bbuf[3][6],Bbuf[3][7],
                     Bbuf[3][2],Bbuf[3][3],Bbuf[3][4],
                     Bbuf[2][7],Bbuf[3][0],Bbuf[3][1],
                     Bbuf[2][4],Bbuf[2][5],Bbuf[2][6],
                     Bbuf[2][1],Bbuf[2][2],Bbuf[2][3],
                     Bbuf[1][6],Bbuf[1][7],Bbuf[2][0],
                     Bbuf[1][3],Bbuf[1][4],Bbuf[1][5],
                     Bbuf[1][0],Bbuf[1][1],Bbuf[1][2],
                     Bbuf[0][5],Bbuf[0][6],Bbuf[0][7],
                     Bbuf[0][2],Bbuf[0][3],Bbuf[0][4]};
endmodule