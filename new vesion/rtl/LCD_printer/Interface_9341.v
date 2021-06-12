module Interface_9341(input wire        clk,rst_n,
                      input wire        rempty,
                      input wire[16:0]  rdata,
                      output reg        rinc,
                      output wire[15:0] LCD_DATA,
                      output reg        LCD_CS,
                      output reg        LCD_WR,
                      output wire       LCD_RS,
                      output wire       LCD_RD,
                      output wire       LCD_RST,
                      output wire       LCD_BL_CTR);

    assign LCD_RST    = rst_n;
    assign LCD_RD     = 1'b1;
    assign LCD_BL_CTR = 1'b1;

    parameter IDLE  = 3'b000;
    parameter WaitS = 3'b001;
    parameter Pre   = 3'b010;
    parameter Wri   = 3'b011;
    parameter WaitH = 3'b100;
    reg[2:0] curr_state,next_state;

    reg[16:0] data_buf;

    //FSM block

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            IDLE:begin
                if(rempty)begin
                    next_state = IDLE;
                    rinc       = 1'b0;
                    LCD_CS     = 1'b1;
                    LCD_WR     = 1'b1;
                end
                else begin
                    next_state = WaitS;
                    rinc       = 1'b1;
                    LCD_CS     = 1'b1;
                    LCD_WR     = 1'b1;
                end
            end
            WaitS:begin
                next_state = Pre;
                rinc       = 1'b0;
                LCD_CS     = 1'b0;
                LCD_WR     = 1'b1;
            end
            Pre:begin
                next_state = Wri;
                rinc       = 1'b0;
                LCD_CS     = 1'b0;
                LCD_WR     = 1'b0;
            end
            Wri:begin
                next_state = WaitH;
                rinc       = 1'b0;
                LCD_CS     = 1'b0;
                LCD_WR     = 1'b1;
            end
            WaitH:begin
                next_state = IDLE;
                rinc       = 1'b0;
                LCD_CS     = 1'b0;
                LCD_WR     = 1'b1;
            end
            default:begin
                next_state = IDLE;
                rinc       = 1'b0;
                LCD_CS     = 1'b1;
                LCD_WR     = 1'b1;
            end
        endcase
    end


    always @(posedge clk) begin
        if(rinc)begin
            data_buf <= rdata;
        end
    end


    assign LCD_DATA = data_buf[15:0];
    assign LCD_RS   = data_buf[16];
    

endmodule