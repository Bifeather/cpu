`include "defines.v"
`timescale 1ns/1ns
module sopc_tb;

reg clk;
reg rst;

always#5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    #1010
    rst = 0;
end

//ʵ����sopc
sopc sopc_inst(
    .clk(clk),
    .rst(rst)
);

endmodule