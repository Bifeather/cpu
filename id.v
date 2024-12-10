
`include "defines.v"

module id(
    input rst,
    input wire[`InstAddrBus] pc_i,                      //����ĳ��������ֵ
    input wire[`InstBus] inst_i,                        //�����ָ��

    //�����ļĴ���ֵ
    input wire[`RegBus] rdata1_i,                       //�ӼĴ���������ֵ1
    input wire[`RegBus] rdata2_i,                       //�ӼĴ���������ֵ2

    //ִ�н׶�������
    input wire ex_we_reg_i,                             //��ʱִ�н׶�дʹ��
    input wire[`RegBus] ex_wdata_i,                     //��ʱִ�н׶�д����
    input wire[`RegAddrBus] ex_waddr_reg_i,             //��ʱִ�н׶�д��ַ

    //�ô�׶ν��
    input wire mem_we_reg_i,                            //��ʱ�ô�׶�дʹ��
    input wire[`RegBus] mem_wdata_i,                    //��ʱ�ô�׶�д����
    input wire[`RegAddrBus] mem_waddr_reg_i,            //��ʱ�ô�׶�д��ַ

    //���Ĵ����ѵĿ����ź�
    output reg re1_o,                                   //���˿�1�Ķ�ʹ���ź�
    output reg re2_o,                                   //���˿�2�Ķ�ʹ���ź�
    output reg[`RegAddrBus] raddr1_o,                   //���˿�1��Ŀ��Ĵ�����ַ
    output reg[`RegAddrBus] raddr2_o,                   //���˿�2��Ŀ��Ĵ�����ַ

    //�͸�ִ�н׶ε�����
    output reg[`AluOpBus] aluop_o,                      //��alu���Ӳ�����
    output reg[`AluSelBus] alusel_o,                    //��alu�Ĳ�������
    output reg[`RegBus] rdata1_o,                       //�����Ĳ�����1������
    output reg[`RegBus] rdata2_o,                       //�����Ĳ�����2������
    output reg[`RegAddrBus] waddr_reg_o,                //Ҫд�ļĴ����ĵ�ַ
    output reg we_reg_o                                 //дʹ���ź�

);


//��ָ����зָ�
wire[5:0] op = inst_i[31:26];               //ָ����
wire[5:0] op1 = inst_i[25:21];              //��һ��������,��sll,srl,sraʱΪ0
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op_fun = inst_i[5:0];             //������
wire[4:0] op4 = inst_i[20:16];


//����ָ��ִ����Ҫ��������
reg[`RegBus] imm;

//ָʾָ���Ƿ���Ч
reg instvalid;


//****************************************************************//
//**************************ָ�����벿��***************************//
//****************************************************************//

always@(*) begin

    if(rst == `RstEnable) begin
        aluop_o = `EXE_NOP_OP;
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = `NOPRegAddr;
        we_reg_o = `WriteDisable;
        instvalid = `InstValid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = `NOPRegAddr;
        raddr2_o = `NOPRegAddr;
        imm = `ZeroWord;
    end

    //�ⲿ�ָ�Ĭ��ֵ
    else begin                                      
        aluop_o = `EXE_NOP_OP;          
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = inst_i[15:11];                //Ĭ�ϵ�����������Ϊд���ַ
        we_reg_o = `WriteDisable;
        instvalid = `InstInvalid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = inst_i[25:21];                   //Ĭ�ϵ�һ��������Ϊ��ȡ��ַ1
        raddr2_o = inst_i[20:16];                   //Ĭ�ϵڶ���������Ϊ��ȡ��ַ2
        imm = `ZeroWord;
    end


    //����ָ���ǰ��λ���벻ͬ�Ĳ���
    case(op) 
        `EXE_SPECIAL_INST: begin                    //specialָ����
            if(op2 == 5'b00000) begin               //�����߼�����op2(inst_i[10:6])Ϊ0
                case(op_fun) 
                    `EXE_FUN_OR: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_OR_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_AND: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_AND_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_XOR: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_XOR_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_NOR: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_NOR_OP;
                        alusel_o = `EXE_RES_LOGIC;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_SLLV: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SLL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_SRLV: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SRL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_SRAV: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SRA_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        re1_o = `ReadEnable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_SYNC: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_NOP_OP;
                        alusel_o = `EXE_RES_NOP;
                        re1_o = `ReadDisable;
                        re2_o = `ReadEnable;
                        instvalid = `InstValid;
                    end
                    default: begin

                    end
                endcase
            end
            else if(op1 == 5'b00000) begin
                case(op_fun)
                    `EXE_FUN_SLL: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SLL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        re1_o = `ReadDisable;
                        re2_o = `ReadEnable;
                        imm[4:0] = inst_i[10:6];
                        waddr_reg_o = inst_i[15:11];
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_SRL: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SRL_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        re1_o = `ReadDisable;
                        re2_o = `ReadEnable;
                        imm[4:0] = inst_i[10:6];
                        waddr_reg_o = inst_i[15:11];
                        instvalid = `InstValid;
                    end
                    `EXE_FUN_SRA: begin
                        we_reg_o = `WriteEnable;
                        aluop_o = `EXE_SRA_OP;
                        alusel_o = `EXE_RES_SHIFT;
                        re1_o = `ReadDisable;
                        re2_o = `ReadEnable;
                        imm[4:0] = inst_i[10:6];
                        waddr_reg_o = inst_i[15:11];
                        instvalid = `InstValid;
                    end
                    default: begin

                    end
                endcase
            end
        end
        `EXE_ORI: begin                             //������������ori
            we_reg_o = `WriteEnable;                
            aluop_o = `EXE_OR_OP;                   //����������Ϊ������
            alusel_o = `EXE_RES_LOGIC;              //��������Ϊ�߼�����
            re1_o = `ReadEnable;                    //����������ʱ��������������һ�����������ڶ���������Ĭ��0
            re2_o = `ReadDisable;
            imm = {16'h0000,inst_i[15:0]};          //�������޷�����չ
            waddr_reg_o = inst_i[20:16];            //Ŀ��д�Ĵ�����ַ
            instvalid = `InstValid;
        end
        `EXE_ANDI: begin                            //������������andi
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_AND_OP;
            alusel_o = `EXE_RES_LOGIC;
            re1_o = `ReadEnable;
            re2_o = `ReadDisable;
            imm = {16'h0000,inst_i[15:0]};
            waddr_reg_o = inst_i[20:16];
            instvalid = `InstValid;
        end
        `EXE_XORI: begin                            //�������������xori
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_XOR_OP;
            alusel_o = `EXE_RES_LOGIC;
            re1_o = `ReadEnable;
            re2_o = `ReadDisable;
            imm = {16'h0000,inst_i[15:0]};
            waddr_reg_o = inst_i[20:16];
            instvalid = `InstValid;
        end
        `EXE_LUT: begin                             //����������lut
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_OR_OP;                   //lutָ��Ĳ�����orָ��һ��
            alusel_o = `EXE_RES_LOGIC;              
            re1_o = `ReadEnable;
            re2_o = `ReadDisable;
            imm = {inst_i[15:0],16'h0000};
            waddr_reg_o = inst_i[20:16];
            instvalid = `InstValid;
        end
        `EXE_PREF: begin                            //Ԥȡָ��,�ڱ���Ŀ���޻��棬��������
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_NOP_OP;
            alusel_o = `EXE_RES_NOP;
            re1_o = `ReadDisable;
            re2_o = `ReadDisable;
            waddr_reg_o = `NOPRegAddr;
            instvalid = `InstValid;
        end
        default: begin

        end

    endcase


end

//****************************************************************//
//**************************ȷ��������1****************************//
//****************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        rdata1_o = `ZeroWord;
    end
    else if(re1_o == `ReadEnable && ex_we_reg_i == `WriteEnable && ex_waddr_reg_i == raddr1_o) begin
        rdata1_o = ex_wdata_i;
    end
    else if(re1_o == `ReadEnable && mem_we_reg_i == `WriteEnable && mem_waddr_reg_i == raddr1_o) begin
        rdata1_o = mem_wdata_i;
    end
    else if(re1_o == `ReadEnable) begin             //�����ʹ�ܣ�˵����Ҫ���������򽫼Ĵ��������ݸ�����һ��
        rdata1_o = rdata1_i;                    
    end
    else if(re1_o == `ReadDisable) begin            //�������ֹ�����ܲ���Ҫ����������Ҳ�п�����Ҫ��������������������
        rdata1_o = imm;
    end
    else begin
        rdata1_o = `ZeroWord;
    end
end


//****************************************************************//
//**************************ȷ��������2****************************//
//****************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        rdata2_o = `ZeroWord;
    end
    else if(re2_o == `ReadEnable && ex_we_reg_i == `WriteEnable && ex_waddr_reg_i == raddr2_o) begin
        rdata2_o = ex_wdata_i;
    end
    else if(re2_o == `ReadEnable && mem_we_reg_i == `WriteEnable && mem_waddr_reg_i == raddr2_o) begin
        rdata2_o = mem_wdata_i;
    end
    else if(re2_o == `ReadEnable) begin             //ͬ������1��ȷ��
        rdata2_o = rdata2_i;
    end
    else if(re2_o == `ReadDisable) begin
        rdata2_o = imm;
    end
    else begin
        rdata2_o = `ZeroWord;
    end
end


endmodule