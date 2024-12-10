`include "defines.v"

module rom_program(
    input clk,
    input wire[`RegBus] rom_addr_i,
    input wire rom_ce_i,
    output wire[`RegBus] rom_data_o
);


blk_mem_gen_0 rom_inst0 (
  .clka(clk),    // input wire clka
  .ena(rom_ce_i),      // input wire ena
  .addra(rom_addr_i[`InstMemNumLog2+1:2]),  // input wire [9 : 0] addra
  .douta(rom_data_o)  // output wire [31 : 0] douta
);


endmodule