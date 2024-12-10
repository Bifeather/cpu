
`include "defines.v"

module mem_wb(
    input clk,
    input rst,

    //ȡ�ô���
    input wire[`RegAddrBus] mem_waddr_reg_i,
    input wire mem_we_reg_i,
    input wire[`RegBus] mem_wdata_i,

    //����д�׶�
    output reg[`RegAddrBus] wb_waddr_reg_o,
    output reg wb_we_reg_o,
    output reg[`RegBus] wb_wdata_o

);

always@(posedge clk) begin
    if(rst == `RstEnable) begin
        wb_waddr_reg_o <= `NOPRegAddr;
        wb_we_reg_o <= `WriteDisable;
        wb_wdata_o <= `ZeroWord;
    end
    else begin
        wb_waddr_reg_o <= mem_waddr_reg_i;
        wb_we_reg_o <= mem_we_reg_i;
        wb_wdata_o <= mem_wdata_i;
    end
end


endmodule