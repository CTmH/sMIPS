`timescale 1ns / 1ps
`include "consts.vh"

module cpu(
           input wire         clk,
           input wire         clk_bus,
           input wire         rst,

           //SRAM IO
           output wire [18:0] sram_addr,
           inout wire [15:0]  sram_data,
           output wire        sram_oe_n,
           output wire        sram_ce_n,
           output wire        sram_we_n,
           output wire        sram_ub,
           output wire        sram_lb,
           output wire [7:0]  led,
           output wire [7:0]   seg_sel,
           output wire [7:0]   seg_code,
           output wire [3:0] r,
           output wire [3:0] g,
           output wire [3:0] b,
           output wire hs,
           output wire vs
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
wire[`InstBus] ex_inst;
//??????��??EX?????????EX/MEM????????
wire ex_wreg_enable_o;
wire[`RegAddrBus] ex_wreg_addr_o;
wire[`RegDataBus] ex_wreg_data_o;
wire[`AluOpBus] ex_aluop_o;
wire[`DataAddrBus] ex_mem_addr_o;
wire[`DataBus] ex_reg2_o;

//????EX/MEM?????????????MEM????????
wire mem_wreg_enable_i;
wire[`RegAddrBus] mem_wreg_addr_i;
wire[`RegDataBus] mem_wreg_data_i;
wire[`AluOpBus] mem_aluop_o;
wire[`DataAddrBus] mem_mem_addr_o;
wire[`DataBus] mem_reg2_o;

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

// Bus
wire            bus_en;
wire            bus_rw;
wire [31:0]     mem_addr;
wire [31:0]     mem_wdata;
wire [31:0]     mem_rdata;
wire [3:0]      mem_sel;

// branch prediction
wire flush_from_id;
wire flush_to_id;
wire branch_predict_to_id;
wire branch_predict_from_if;
wire[31:0] special_pc;
wire[31:0] if_branch_predict_addr;


pc if_pc0(
     .clk(clk),
     .rst(rst),
     .stall(stall),
     .npc(npc),
     .pc(pc)
   );

npc if_npc0(
      .pc(pc),
      .special_pc(special_pc),
      .imm16(fore_inst_o[15:0]),
      .imm26(fore_inst_o[25:0]),
      .reg1_data(reg1_data),
      .cu_npc_op(cu_npc_op),
      .branch_predict(branch_predict_from_if),
      .branch_predict_addr(if_branch_predict_addr),
      .npc(npc)
    );

imem imem0(
       .rst(rst),
       .addr(pc),
       .inst(if_inst_o)
     );

branch_predict branch_predict0(
  .clk(clk),
  .rst(rst),
  .pc(pc),
  .flush(flush_from_id),
  .inst(if_inst_o),
  .branch_predict(branch_predict_from_if),
  .branch_predict_addr(if_branch_predict_addr)
);


if_id if_id0(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .if_pc(pc),
        .if_inst(if_inst_o),
        .branch_predict_i(branch_predict_from_if),
        .id_pc(id_pc_i),
        .id_inst(id_inst_i),
        .branch_predict_o(branch_predict_to_id)
      );

//??????ID???
id id0(
     .rst(rst),
     .pc_i(id_pc_i),
     .inst_i(id_inst_i),

     .reg1_data_i(reg1_data),
     .reg2_data_i(reg2_data),

     .is_in_delayslot_i(is_in_delayslot_o),
     .branch_predict_i(branch_predict_to_id),
     .flush_i(flush_to_id),

     .ex_aluop_i(ex_aluop_o),

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
     .fore_inst(fore_inst_o),

     .special_pc(special_pc),
     .flush_o(flush_from_id)
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
        .id_inst(fore_inst_o),
        .id_link_address(link_addr_o),
        .id_is_in_delayslot(id_is_in_delayslot),
        .next_inst_in_delayslot_i(next_inst_in_delayslot_o),
        .flush_i(flush_from_id),

        //???????��??EX???????
        .ex_aluop(ex_aluop_i),
        .ex_alusel(ex_alusel_i),
        .ex_reg1(ex_reg1_i),
        .ex_reg2(ex_reg2_i),
        .ex_wreg_addr(ex_wreg_addr_i),
        .ex_wreg_enable(ex_wreg_enable_i),
        .ex_link_address(link_address_i),
        .ex_is_in_delayslot(is_in_delayslot_i),
        .is_in_delayslot_o(is_in_delayslot_o),
        .ex_inst(ex_inst),
        .flush_o(flush_to_id)
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
     .inst_i(ex_inst),
     .link_address_i(link_address_i),
     .is_in_delayslot_i(is_in_delayslot_i),

     //EX?????????EX/MEM??????
     .wreg_addr_o(ex_wreg_addr_o),
     .wreg_enable_o(ex_wreg_enable_o),
     .wdata_o(ex_wreg_data_o),
     .aluop_o(ex_aluop_o),
     .mem_addr_o(ex_mem_addr_o),
     .reg2_o(ex_reg2_o),
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

         .ex_aluop(ex_aluop_o),
         .ex_mem_addr(ex_mem_addr_o),
         .ex_reg2(ex_reg2_o),

         //????????MEM???????
         .mem_wreg_addr(mem_wreg_addr_i),
         .mem_wreg_enable(mem_wreg_enable_i),
         .mem_wdata(mem_wreg_data_i),

         .mem_aluop(mem_aluop_o),
         .mem_mem_addr(mem_mem_addr_o),
         .mem_reg2(mem_reg2_o)

       );


//MEM???????
mem mem0(
      .rst(rst),

      //????EX/MEM???????
      .wreg_addr_i(mem_wreg_addr_i),
      .wreg_enable_i(mem_wreg_enable_i),
      .wdata_i(mem_wreg_data_i),

      .aluop_i(mem_aluop_o),
      .mem_addr_i(mem_mem_addr_o),
      .reg2_i(mem_reg2_o),
      .mem_data_i(mem_rdata),

      //???MEM/WB???????
      .wreg_addr_o(mem_wreg_addr_o),
      .wreg_enable_o(mem_wreg_enable_o),
      .wdata_o(mem_wreg_data_o),
      .mem_addr_o(mem_addr),
      .mem_we_o(bus_rw),
      .mem_sel_o(mem_sel),
      .mem_data_o(mem_wdata),
      .mem_ce_o(bus_en)
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

bus bus0(
         .sck(clk_bus),
         .rst(rst),
         .en(bus_en),
         .rw(bus_rw),
         .sel(mem_sel),
         .addr(mem_addr),
         .wdata(mem_wdata),
         .rdata(mem_rdata),
         .sram_addr(sram_addr),
         .sram_data(sram_data),
         .sram_oe_n(sram_oe_n),
         .sram_ce_n(sram_ce_n),
         .sram_we_n(sram_we_n),
         .sram_ub(sram_ub),
         .sram_lb(sram_lb),
         .led(led),
         .seg_sel(seg_sel),
         .seg_code(seg_code),
         .hs(hs),
         .vs(vs),
         .r(r),
         .g(g),
         .b(b)
         );

endmodule
