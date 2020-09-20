`timescale 1ns / 1ps
`include "consts.vh"

module cpu(
         input wire clk,
         input wire rst
       );

wire[`InstAddrBus] pc;
wire[`InstAddrBus] npc;
wire[`InstBus]  if_inst_o;
wire[`NPC_OP_LENGTH  - 1:0] cu_npc_op;
wire[`InstAddrBus] id_pc_i;
wire[`InstBus] id_inst_i;

//??????????ID?????????ID/EX????????
wire[`AluOpBus] id_aluop_o;
wire[`AluSelBus] id_alusel_o;
wire[`RegDataBus] id_reg1_o;
wire[`RegDataBus] id_reg2_o;
wire id_wreg_enable_o;
wire[`RegAddrBus] id_wreg_addr_o;
wire next_inst_in_delayslot_o;
wire[`RegDataBus] link_addr_o;
wire id_is_in_delayslot;

//????ID/EX???????????????ID????????
wire is_in_delayslot_o;

//????ID/EX???????????��??EX????????
wire[`AluOpBus] ex_aluop_i;
wire[`AluSelBus] ex_alusel_i;
wire[`RegDataBus] ex_reg1_i;
wire[`RegDataBus] ex_reg2_i;
wire ex_wreg_enable_i;
wire[`RegAddrBus] ex_wreg_addr_i;
wire [`RegDataBus] link_address_i;
wire is_in_delayslot_i;
//??????��??EX?????????EX/MEM????????
wire ex_wreg_enable_o;
wire[`RegAddrBus] ex_wreg_addr_o;
wire[`RegDataBus] ex_wreg_data_o;

//????EX/MEM?????????????MEM????????
wire mem_wreg_enable_i;
wire[`RegAddrBus] mem_wreg_addr_i;
wire[`RegDataBus] mem_wreg_data_i;

//????????MEM?????????MEM/WB????????
wire mem_wreg_enable_o;
wire[`RegAddrBus] mem_wreg_addr_o;
wire[`RegDataBus] mem_wreg_data_o;

//????MEM/WB??????????��??��?????
wire wb_wreg_enable_i;
wire[`RegAddrBus] wb_wreg_addr_i;
wire[`RegDataBus] wb_wreg_data_i;

//??????????ID???????��????Regfile???
wire reg1_read;
wire reg2_read;
wire[`RegDataBus] reg1_data;
wire[`RegDataBus] reg2_data;
wire[`RegAddrBus] reg1_addr;
wire[`RegAddrBus] reg2_addr;

//???????????
wire[5:0] stall;
wire stallreq_from_id;
wire stallreq_from_ex;
wire[`InstAddrBus] fore_inst_o;

pc if_pc0(
     .clk(clk),
     .rst(rst),
     .stall(stall),
     .npc(npc),
     .pc(pc)
   );

npc if_npc0(
      .pc(pc),
      .imm16(fore_inst_o[15:0]),
      .imm26(fore_inst_o[25:0]),
      .reg1_data(reg1_data),
      .cu_npc_op(cu_npc_op),
      .npc(npc)
    );

imem imem0(
       .addr(pc),
       .inst(if_inst_o)
     );

if_id if_id0(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .if_pc(pc),
        .if_inst(if_inst_o),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i)
      );

//??????ID???
id id0(
     .rst(rst),
     .pc_i(id_pc_i),
     .inst_i(id_inst_i),

     .reg1_data_i(reg1_data),
     .reg2_data_i(reg2_data),

     .is_in_delayslot_i(is_in_delayslot_o),

     //??????��?��?????��?????????????
     .ex_wreg_i(ex_wreg_enable_o),
     .ex_wdata_i(ex_wreg_data_o),
     .ex_wd_i(ex_wreg_addr_o),

     //???????��?????��?????????????
     .mem_wreg_i(mem_wreg_enable_o),
     .mem_wdata_i(mem_wreg_data_o),
     .mem_wd_i(mem_wreg_addr_o),

     //???regfile?????
     .reg1_read_o(reg1_read),
     .reg2_read_o(reg2_read),

     .reg1_addr_o(reg1_addr),
     .reg2_addr_o(reg2_addr),

     //???ID/EX???????
     .aluop_o(id_aluop_o),
     .alusel_o(id_alusel_o),
     .reg1_data_o(id_reg1_o),
     .reg2_data_o(id_reg2_o),
     .wreg_addr_o(id_wreg_addr_o),
     .wreg_enable_o(id_wreg_enable_o),

     .next_inst_in_delayslot_o(next_inst_in_delayslot_o),
     .cu_npc_op_o(cu_npc_op),
     .link_addr_o(link_addr_o),
     .is_in_delayslot_o(id_is_in_delayslot),

     .stallreq(stallreq_from_id),
     .fore_inst(fore_inst_o)
   );

//??��????Regfile????
regfile regfile1(
          .clk (clk),
          .rst (rst),
          .we	(wb_wreg_enable_i),
          .waddr (wb_wreg_addr_i),
          .wdata (wb_wreg_data_i),
          .re1 (reg1_read),
          .raddr1 (reg1_addr),
          .rdata1 (reg1_data),
          .re2 (reg2_read),
          .raddr2 (reg2_addr),
          .rdata2 (reg2_data)
        );

//ID/EX???
id_ex id_ex0(
        .clk(clk),
        .rst(rst),
        .stall(stall),

        //????????ID??��??????
        .id_aluop(id_aluop_o),
        .id_alusel(id_alusel_o),
        .id_reg1(id_reg1_o),
        .id_reg2(id_reg2_o),
        .id_wreg_addr(id_wreg_addr_o),
        .id_wreg_enable(id_wreg_enable_o),

        .id_link_address(link_addr_o),
        .id_is_in_delayslot(id_is_in_delayslot),
        .next_inst_in_delayslot_i(next_inst_in_delayslot_o),

        //???????��??EX???????
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wreg_addr(ex_wreg_addr_i),
        .ex_wreg_enable(ex_wreg_enable_i),
        .ex_link_address(link_address_i),
        .ex_is_in_delayslot(is_in_delayslot_i),
        .is_in_delayslot_o(is_in_delayslot_o)
      );

//EX???
ex ex0(
     .rst(rst),

     //?????��??EX???????
     .aluop_i(ex_aluop_i),
     .alusel_i(ex_alusel_i),
     .reg1_i(ex_reg1_i),
     .reg2_i(ex_reg2_i),
     .wreg_addr_i(ex_wreg_addr_i),
     .wreg_enable_i(ex_wreg_enable_i),
     .link_address_i(link_address_i),
     .is_in_delayslot_i(is_in_delayslot_i),

     //EX?????????EX/MEM??????
     .wreg_addr_o(ex_wreg_addr_o),
     .wreg_enable_o(ex_wreg_enable_o),
     .wdata_o(ex_wreg_data_o),

     .stallreq(stallreq_from_ex)
   );

//EX/MEM???
ex_mem ex_mem0(
         .clk(clk),
         .rst(rst),
         .stall(stall),

         //??????��??EX???????
         .ex_wreg_addr(ex_wreg_addr_o),
         .ex_wreg_enable(ex_wreg_enable_o),
         .ex_wdata(ex_wreg_data_o),


         //????????MEM???????
         .mem_wreg_addr(mem_wreg_addr_i),
         .mem_wreg_enable(mem_wreg_enable_i),
         .mem_wdata(mem_wreg_data_i)


       );

//MEM???????
mem mem0(
      .rst(rst),

      //????EX/MEM???????
      .wreg_addr_i(mem_wreg_addr_i),
      .wreg_enable_i(mem_wreg_enable_i),
      .wdata_i(mem_wreg_data_i),

      //???MEM/WB???????
      .wreg_addr_o(mem_wreg_addr_o),
      .wreg_enable_o(mem_wreg_enable_o),
      .wdata_o(mem_wreg_data_o)
    );

//MEM/WB???
mem_wb mem_wb0(
         .clk(clk),
         .rst(rst),
         .stall(stall),

         //????????MEM???????
         .mem_wreg_addr(mem_wreg_addr_o),
         .mem_wreg_enable(mem_wreg_enable_o),
         .mem_wdata(mem_wreg_data_o),

         //?????��??��????
         .wb_wreg_addr(wb_wreg_addr_i),
         .wb_wreg_enable(wb_wreg_enable_i),
         .wb_wdata(wb_wreg_data_i)

       );

stall_control stall_ctrl0(
             .rst(rst),

             .stallreq_from_id(stallreq_from_id),
             //??????��?��????????
             .stallreq_from_ex(stallreq_from_ex),
             .stall(stall)
           );
endmodule
