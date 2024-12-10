//PCģ�����ȡָ����

`include "defines.v"

module pc_reg (
    input clk,
    input rst,
    output reg[`InstAddrBus] pc,
    output reg ce
);


//ָ��洢��ce
always @(posedge clk) begin
    if(rst == `RstEnable) begin
        ce <= `ChipDisable;                     //��λ��ʱ��ָ��洢������
    end
    else begin
        ce <= `ChipEnable;                      //��λ����ʹ��
    end
end


//pc���������
always@(posedge clk) begin
    if(ce == `ChipDisable) begin
        pc <= 32'h00000000;                     //��λʱ��pc����
    end
    else begin
        pc <= pc + 4'h4;                        //��������ʱ��ʱ����Ч�ص���pc+4
    end
end

    
endmodule