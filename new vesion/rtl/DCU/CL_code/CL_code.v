module CL_code(input wire clk,rst_n,
               input wire enb,
               input wire[115:0] litTree,
               input wire[63:0] distTree,
               input wire[7:0] code,
               input wire[3:0] len,
               output wire fin,
               output wire[4:0] litSymb,
               output wire[3:0] distSymb,
               output wire[4:0] litCount,
               output wire[3:0] distCount);

    wire fin_lit,fin_dist;

    CL_code_lit CL_code_lit(
        .clk       (clk),
        .rst_n     (rst_n),
        .enb       (enb),
        .litTree   (litTree),
        .litCode   (code),
        .len_in    (len),
        .fin_lit   (fin_lit),
        .litSymb   (litSymb),
        .litCount  (litCount)
    );

    CL_code_dist CL_code_dist(
        .clk       (clk),
        .rst_n     (rst_n),
        .enb       (enb),
        .distTree  (distTree),
        .distCode  (code),
        .len_in    (len),
        .fin_dist  (fin_dist),
        .distSymb  (distSymb),
        .distCount (distCount)
    );

    assign fin = fin_lit&fin_dist;

endmodule