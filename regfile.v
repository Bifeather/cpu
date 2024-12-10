
`include "defines.v"

module regfile(
    input clk,
    input rst,

    //写端口
    input we,                                       //写使能信号
    input wire[`RegAddrBus] waddr,                  //写目标寄存器地址
    input wire[`RegBus] wdata,                      //写入的数据

    //两个读端口
    input re1,                                      //端口1读使能信号
    input re2,                                      //端口2读使能信号
    input wire[`RegAddrBus] raddr1,                 //端口1读目标寄存器地址
    input wire[`RegAddrBus] raddr2,                 //端口2读目标寄存器地址
    output reg[`RegBus] rdata1,                     //端口1读到的寄存器数据
    output reg[`RegBus] rdata2                      //端口2读到的寄存器数据
);

//定义32个32位寄存器
reg[`RegBus] regs[0:`RegNum-1];


//写操作
integer i = 0;
always@(posedge clk) begin
    if(rst == `RstEnable) begin
        for(i=0 ; i<`RegNum ; i = i+1) begin
            regs[i] <= `ZeroWord;                   //复位时把32个寄存器全部清零
        end
    end
    else begin
        if((we == `WriteEnable) && (waddr != `RegNumLos2'h0)) begin                 //写使能，但是第一个寄存器必须一直是零，排除写地址为0的情况
            regs[waddr] <= wdata;
        end
        else begin
            regs[waddr] <= regs[waddr];                                             //其他情况下保持不变
        end
    end
end


//端口1读操作
always@(*) begin
    if(rst == `RstEnable) begin
        rdata1 = `ZeroWord;
    end
    else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //当读取的端口正在被写时，直接读取写入的值
        rdata1 = wdata;
    end
    else if(re1 == `ReadEnable) begin
        rdata1 = regs[raddr1];
    end
    else begin
        rdata1 = `ZeroWord;
    end
end


//端口2读操作
always@(*) begin
    if(rst == `RstEnable) begin
        rdata2 = `ZeroWord;
    end
    else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin    //当读取的端口正在被写时，直接读取写入的值
        rdata2 = wdata;
    end
    else if(re2 == `ReadEnable) begin
        rdata2 = regs[raddr2];
    end
    else begin
        rdata2 = `ZeroWord;
    end
end


endmodule