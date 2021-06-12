module Text_pool(input wire clk,rst_n,
                 input wire rempty,wfull,
                 input wire[5:0] symb,
                 output wire winc,rinc,
                 output wire[3:0] symb_out);

    parameter IDLE = 3'b000;
    parameter lit  = 3'b001;
    parameter extL = 3'b010;
    parameter dist = 3'b011;
    parameter extD = 3'b100;
    parameter Pour = 3'b101;
    reg[2:0] curr_state,next_state;

    reg[3:0] pool[255:0];
    wire[3:0] next_pool[255:0];
    reg[7:0] pool_pointer;

    //FSM block

    always @(posedge clk) begin
        if(!rst_n) curr_state <= IDLE;
        else curr_state <= next_state;
    end

    always @(*) begin
        case(curr_state)
            IDLE:begin
                
            end
            lit:begin
                
            end
            extL:begin
                
            end
            dist:begin
                
            end
            extD:begin
                
            end
            Pour:begin
                
            end
            default:begin
                
            end
        endcase
    end

    //Other seq logic

    //Other comb logic


endmodule