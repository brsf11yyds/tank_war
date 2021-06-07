module fps_counter(
    input       wire            clk,
    input       wire            RSTn,
    output      reg             fps
);
reg [4:0] counter;
always@(posedge clk or negedge RSTn)
begin
    if(~RSTn)begin
        counter <= 0;
        fps <= 0;
    end
    if(counter < 5'h30)begin
        counter <= counter + 1'b1;
        fps <= 0;
    end
    else begin
        counter <= 0;
        fps <= 1;
    end
end