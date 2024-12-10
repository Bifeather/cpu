//PC模块完成取指操作

`include "defines.v"

module pc_reg (
    input clk,
    input rst,
    output reg[`InstAddrBus] pc,
    output reg ce
);


//指令存储器ce
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        ce <= `ChipDisable;                     //复位的时候指令存储器禁用
    end
    else begin
        ce <= `ChipEnable;                      //复位结束使能
    end
end


//pc程序计数器
always@(posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= 32'h00000000;                     //复位时，pc归零
    end
    else begin
        pc <= pc + 4'h4;                        //正常工作时，时钟有效沿到来pc+4
    end
end

    
endmodule