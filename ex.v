
`include "defines.v"

module ex(
    input rst,
    
    //译码的输入
    input wire[`AluOpBus] aluop_i,                  //操作子类型
    input wire[`AluSelBus] alusel_i,                //操作类型
    input wire[`RegBus] rdata1_i,                   //操作数1
    input wire[`RegBus] rdata2_i,                   //操作数2
    input wire[`RegAddrBus] waddr_reg_i,            //写目标寄存器地址
    input wire we_reg_i,                            //写使能信号

    //执行后结果
    output reg[`RegAddrBus] waddr_reg_o,            //写目标寄存器地址
    output reg we_reg_o,                            //写使能信号
    output reg[`RegBus] wdata_o                     //处理后的数据

);

//保存逻辑运算的结果
reg[`RegBus] logicout;

//保存移位运算结果
reg[`RegBus] shiftres;

//***************************************************************************************************//
//*******************************根据运算子类型aluop_i进行计算*****************************************//
//***************************************************************************************************//

always@(*) begin
    if(rst == `RstEnable) begin
        logicout = `ZeroWord;
    end
    else begin
        case(aluop_i) 
            `EXE_OR_OP: begin                                   //或运算
                logicout = rdata1_i | rdata2_i;
            end
            `EXE_AND_OP: begin
                logicout = rdata1_i & rdata2_i;
            end
            `EXE_NOR_OP: begin
                logicout = ~(rdata1_i | rdata2_i);
            end
            `EXE_XOR_OP: begin
                logicout = rdata1_i ^ rdata2_i;
            end
            default: begin
                logicout = `ZeroWord;
            end
        endcase
    end
end

//*************************************************************************//
//移位运算
always@(*) begin
    if(rst == `RstEnable) begin
        shiftres = `ZeroWord;
    end
    else begin
        case(aluop_i)
            `EXE_SLL_OP: begin
                shiftres = (rdata2_i << rdata1_i[4:0]);
            end
            `EXE_SRL_OP: begin
                shiftres = (rdata2_i >> rdata1_i[4:0]);
            end
            `EXE_SRA_OP: begin
                shiftres = ({32{rdata2_i[31]}}<<(6'd32-{1'b0,rdata1_i[4:0]})) | rdata2_i >> rdata1_i[4:0]; 
            end
        endcase
    end
end


//***************************************************************************************************//
//*******************************根据运算类型alusel_i选择运算结果**************************************//
//***************************************************************************************************//

always@(*) begin
    waddr_reg_o = waddr_reg_i;
    we_reg_o = we_reg_i;                                //写目标地址与写使能信号直接通过
    case(alusel_i) 
        `EXE_RES_LOGIC: begin           //逻辑运算类型
            wdata_o = logicout;
        end
        `EXE_RES_SHIFT: begin
            wdata_o = shiftres;
        end
        default: begin
            wdata_o = `ZeroWord;
        end
    endcase
end



endmodule