
`include "defines.v"

module id(
    input rst,
    input wire[`InstAddrBus] pc_i,                      //输入的程序计数器值
    input wire[`InstBus] inst_i,                        //输入的指令

    //读到的寄存器值
    input wire[`RegBus] rdata1_i,                       //从寄存器读到的值1
    input wire[`RegBus] rdata2_i,                       //从寄存器读到的值2

    //执行阶段运算结果
    input wire ex_we_reg_i,                             //此时执行阶段写使能
    input wire[`RegBus] ex_wdata_i,                     //此时执行阶段写数据
    input wire[`RegAddrBus] ex_waddr_reg_i,             //此时执行阶段写地址

    //访存阶段结果
    input wire mem_we_reg_i,                            //此时访存阶段写使能
    input wire[`RegBus] mem_wdata_i,                    //此时访存阶段写数据
    input wire[`RegAddrBus] mem_waddr_reg_i,            //此时访存阶段写地址

    //给寄存器堆的控制信号
    output reg re1_o,                                   //读端口1的读使能信号
    output reg re2_o,                                   //读端口2的读使能信号
    output reg[`RegAddrBus] raddr1_o,                   //读端口1的目标寄存器地址
    output reg[`RegAddrBus] raddr2_o,                   //读端口2的目标寄存器地址

    //送给执行阶段的数据
    output reg[`AluOpBus] aluop_o,                      //给alu的子操作码
    output reg[`AluSelBus] alusel_o,                    //给alu的操作类型
    output reg[`RegBus] rdata1_o,                       //读到的操作数1的数据
    output reg[`RegBus] rdata2_o,                       //读到的操作数2的数据
    output reg[`RegAddrBus] waddr_reg_o,                //要写的寄存器的地址
    output reg we_reg_o                                 //写使能信号

);


//对指令进行分割
wire[5:0] op = inst_i[31:26];               //指令码
wire[5:0] op1 = inst_i[25:21];              //第一个操作数,当sll,srl,sra时为0
wire[4:0] op2 = inst_i[10:6];
wire[5:0] op_fun = inst_i[5:0];             //功能码
wire[4:0] op4 = inst_i[20:16];


//保存指令执行需要的立即数
reg[`RegBus] imm;

//指示指令是否有效
reg instvalid;


//****************************************************************//
//**************************指令译码部分***************************//
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

    //这部分赋默认值
    else begin                                      
        aluop_o = `EXE_NOP_OP;          
        alusel_o = `EXE_RES_NOP;
        waddr_reg_o = inst_i[15:11];                //默认第三个操作数为写入地址
        we_reg_o = `WriteDisable;
        instvalid = `InstInvalid;
        re1_o = `ReadDisable;
        re2_o = `ReadDisable;
        raddr1_o = inst_i[25:21];                   //默认第一个操作数为读取地址1
        raddr2_o = inst_i[20:16];                   //默认第二个操作数为读取地址2
        imm = `ZeroWord;
    end


    //根据指令的前六位译码不同的操作
    case(op) 
        `EXE_SPECIAL_INST: begin                    //special指令码
            if(op2 == 5'b00000) begin               //基本逻辑运算op2(inst_i[10:6])为0
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
        `EXE_ORI: begin                             //立即数或运算ori
            we_reg_o = `WriteEnable;                
            aluop_o = `EXE_OR_OP;                   //操作子类型为或运算
            alusel_o = `EXE_RES_LOGIC;              //操作类型为逻辑运算
            re1_o = `ReadEnable;                    //立即数运算时，把立即数给第一个操作数，第二个操作数默认0
            re2_o = `ReadDisable;
            imm = {16'h0000,inst_i[15:0]};          //立即数无符号扩展
            waddr_reg_o = inst_i[20:16];            //目标写寄存器地址
            instvalid = `InstValid;
        end
        `EXE_ANDI: begin                            //立即数与运算andi
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_AND_OP;
            alusel_o = `EXE_RES_LOGIC;
            re1_o = `ReadEnable;
            re2_o = `ReadDisable;
            imm = {16'h0000,inst_i[15:0]};
            waddr_reg_o = inst_i[20:16];
            instvalid = `InstValid;
        end
        `EXE_XORI: begin                            //立即数异或运算xori
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_XOR_OP;
            alusel_o = `EXE_RES_LOGIC;
            re1_o = `ReadEnable;
            re2_o = `ReadDisable;
            imm = {16'h0000,inst_i[15:0]};
            waddr_reg_o = inst_i[20:16];
            instvalid = `InstValid;
        end
        `EXE_LUT: begin                             //立即数保存lut
            we_reg_o = `WriteEnable;
            aluop_o = `EXE_OR_OP;                   //lut指令的操作和or指令一样
            alusel_o = `EXE_RES_LOGIC;              
            re1_o = `ReadEnable;
            re2_o = `ReadDisable;
            imm = {inst_i[15:0],16'h0000};
            waddr_reg_o = inst_i[20:16];
            instvalid = `InstValid;
        end
        `EXE_PREF: begin                            //预取指令,在本项目中无缓存，不做处理
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
//**************************确定操作数1****************************//
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
    else if(re1_o == `ReadEnable) begin             //如果读使能，说明需要操作数，则将寄存器的数据给到下一级
        rdata1_o = rdata1_i;                    
    end
    else if(re1_o == `ReadDisable) begin            //如果读禁止，可能不需要操作数，但也有可能需要立即数，不妨给立即数
        rdata1_o = imm;
    end
    else begin
        rdata1_o = `ZeroWord;
    end
end


//****************************************************************//
//**************************确定操作数2****************************//
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
    else if(re2_o == `ReadEnable) begin             //同操作数1的确定
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