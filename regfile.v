
`include "defines.v"

module regfile(
    input clk,
    input rst,

    //д�˿�
    input we,                                       //дʹ���ź�
    input wire[`RegAddrBus] waddr,                  //дĿ��Ĵ�����ַ
    input wire[`RegBus] wdata,                      //д�������

    //�������˿�
    input re1,                                      //�˿�1��ʹ���ź�
    input re2,                                      //�˿�2��ʹ���ź�
    input wire[`RegAddrBus] raddr1,                 //�˿�1��Ŀ��Ĵ�����ַ
    input wire[`RegAddrBus] raddr2,                 //�˿�2��Ŀ��Ĵ�����ַ
    output reg[`RegBus] rdata1,                     //�˿�1�����ļĴ�������
    output reg[`RegBus] rdata2                      //�˿�2�����ļĴ�������
);

//����32��32λ�Ĵ���
reg[`RegBus] regs[0:`RegNum-1];


//д����
integer i = 0;
always@(posedge clk) begin
    if(rst == `RstEnable) begin
        for(i=0 ; i<`RegNum ; i = i+1) begin
            regs[i] <= `ZeroWord;                   //��λʱ��32���Ĵ���ȫ������
        end
    end
    else begin
        if((we == `WriteEnable) && (waddr != `RegNumLos2'h0)) begin                 //дʹ�ܣ����ǵ�һ���Ĵ�������һֱ���㣬�ų�д��ַΪ0�����
            regs[waddr] <= wdata;
        end
        else begin
            regs[waddr] <= regs[waddr];                                             //��������±��ֲ���
        end
    end
end


//�˿�1������
always@(*) begin
    if(rst == `RstEnable) begin
        rdata1 = `ZeroWord;
    end
    else if((raddr1 == waddr) && (we == `WriteEnable) && (re1 == `ReadEnable)) begin    //����ȡ�Ķ˿����ڱ�дʱ��ֱ�Ӷ�ȡд���ֵ
        rdata1 = wdata;
    end
    else if(re1 == `ReadEnable) begin
        rdata1 = regs[raddr1];
    end
    else begin
        rdata1 = `ZeroWord;
    end
end


//�˿�2������
always@(*) begin
    if(rst == `RstEnable) begin
        rdata2 = `ZeroWord;
    end
    else if((raddr2 == waddr) && (we == `WriteEnable) && (re2 == `ReadEnable)) begin    //����ȡ�Ķ˿����ڱ�дʱ��ֱ�Ӷ�ȡд���ֵ
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