module fps_counter(
    input       wire            clk,
    input       wire            RSTn,
    output      reg             zhen
);
reg [4:0] counter;
always@(posedge clk or negedge RSTn)
begin
    if(~RSTn)begin
        counter <= 0;
        zhen <= 0;
    end
    if(counter < 5'h30)begin
        counter <= counter + 1'b1;
        zhen <= 0;
    end
    else begin
        counter <= 0;
        zhen <= 1;
    end
end