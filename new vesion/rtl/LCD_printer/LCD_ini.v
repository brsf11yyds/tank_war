module LCD_ini(input wire clk,rst_n,
               input wire init_mode,wfull,
               output reg init_end,
               output reg winc,
               output wire[16:0] wdata);

    parameter IDLE  = 2'b00;
    parameter Init  = 2'b01;
    parameter Fill  = 2'b10;
    parameter Fin   = 2'b11;
    reg[1:0] curr_state,next_state;

    reg[6:0] IP;
    reg      IP_enb;
    wire fill_st;

    reg[16:0] fill_count;
    reg fill_enb;
    wire fill_end;

    wire rstn;

    //FSM block

    always @(posedge clk) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            IDLE:begin
                if(init_mode)begin
                    next_state = Init;
                    init_end   = 1'b0;
                    winc       = 1'b0;
                    IP_enb     = 1'b0;
                    fill_enb   = 1'b0;
                end
                else begin
                    next_state = IDLE;
                    init_end   = 1'b0;
                    winc       = 1'b0;
                    IP_enb     = 1'b0;
                    fill_enb   = 1'b0;
                end
            end
            Init:begin
                if(fill_st)begin
                    next_state = Fill;
                    init_end   = 1'b0;
                    winc       = 1'b0;
                    IP_enb     = 1'b0;
                    fill_enb   = 1'b0;
                end
                else begin
                    if(wfull)begin
                        next_state = Init;
                        init_end   = 1'b0;
                        winc       = 1'b0;
                        IP_enb     = 1'b0;
                        fill_enb   = 1'b0;
                    end
                    else begin
                        next_state = Init;
                        init_end   = 1'b0;
                        winc       = 1'b1;
                        IP_enb     = 1'b1;
                        fill_enb   = 1'b0;
                    end
                end
            end
            Fill:begin
                if(fill_end)begin
                    next_state = Fin;
                    init_end   = 1'b0;
                    winc       = 1'b0;
                    IP_enb     = 1'b0;
                    fill_enb   = 1'b0;
                end
                else begin
                    if(wfull)begin
                        next_state = Fill;
                        init_end   = 1'b0;
                        winc       = 1'b0;
                        IP_enb     = 1'b0;
                        fill_enb   = 1'b0;
                    end
                    else begin
                        next_state = Fill;
                        init_end   = 1'b0;
                        winc       = 1'b1;
                        IP_enb     = 1'b0;
                        fill_enb   = 1'b1;
                    end
                end
            end
            Fin:begin
                next_state = IDLE;
                init_end   = 1'b1;
                winc       = 1'b0;
                IP_enb     = 1'b0;
                fill_enb   = 1'b0;
            end
            default:begin
                next_state = IDLE;
                init_end   = 1'b0;
                winc       = 1'b0;
                IP_enb     = 1'b0;
                fill_enb   = 1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        if(!rstn) IP <= 7'b0;
        else IP <= IP + (IP_enb?1'b1:1'b0);
    end

    always @(posedge clk) begin
        if(IP_enb) fill_count <= 17'b0;
        else if(fill_enb) fill_count <= fill_count + 1'b1;
    end

    assign fill_st = IP == 7'd106;
    assign rstn = ~(curr_state == IDLE);
    assign fill_end = fill_count == 17'd76800;

    Block_ROM_init_data Block_ROM_init_data(
        .addr(IP),
        .data(wdata[15:0])
    );

    Block_ROM_init_sign Block_ROM_init_sign(
        .addr(IP),
        .data(wdata[16])
    );

endmodule