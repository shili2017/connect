`include "connect_parameters.v"

import axi4_pkg::*;

`define AXI4S_FLIT_WIDTH (AXI4S_FLIT_DATA_WIDTH + 2 + `DEST_BITS + `VC_BITS)

module AXI4StreamMasterBridge (
    input CLK,
    input RST_N,

    // AXI4-Stream interface
    axi_stream_interface.slave axis,

    // InPortSimple send port
    output [`AXI4S_FLIT_WIDTH - 1 : 0]  put_flit,
    output                              put_flit_valid,
    input                               put_flit_ready
  );

  // State definitions
  typedef enum logic [1 : 0] {IDLE, TDATA} state_t;
  state_t state, next_state;

  always_ff @(posedge CLK) begin
    if (!RST_N)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Fire signals
  wire t_fire = axis.tvalid && axis.tready;

  assign axis.tready = put_flit_ready;

  // FSM to handle AXI4-Stream master device request
  always_comb begin
    case (state)
      IDLE: next_state = t_fire ? TDATA : IDLE;
      TDATA: next_state = (t_fire && axis.tlast) ? IDLE : TDATA;
      default: next_state = state;
    endcase
  end

  // put_flit
  logic [AXI4S_FLIT_DATA_WIDTH - 1 : 0] put_flit_data;
  logic [`DEST_BITS - 1 : 0] put_flit_dst;
  logic [`VC_BITS - 1 : 0] put_flit_vc;
  logic put_flit_tail;

  // InPortSimple output signal, use VC 1
  assign put_flit       = {put_flit_valid, put_flit_tail, put_flit_dst, put_flit_vc, put_flit_data};
  assign put_flit_data  = {axis.tuser, axis.tdest, axis.tid, axis.tlast, axis.tkeep, axis.tstrb, axis.tdata};
  assign put_flit_vc    = 1;
  assign put_flit_dst   = axis.tdest[`DEST_BITS - 1 : 0];
  assign put_flit_tail  = t_fire && axis.tlast;
  assign put_flit_valid = t_fire;

  // Debug
  axi_data_t axis_tdata;
  assign     axis_tdata = axis.tdata;
  axi_strb_t axis_tstrb;
  assign     axis_tstrb = axis.tstrb;
  axi_keep_t axis_tkeep;
  assign     axis_tkeep = axis.tkeep;
  logic      axis_tlast;
  assign     axis_tlast = axis.tlast;
  axi_id_t   axis_tid;
  assign     axis_tid = axis.tid;
  axi_dest_t axis_tdest;
  assign     axis_tdest = axis.tdest;
  axi_user_t axis_tuser;
  assign     axis_tuser = axis.tuser;
  logic      axis_tvalid;
  assign     axis_tvalid = axis.tvalid;
  logic      axis_tready;
  assign     axis_tready = axis.tready;

endmodule

module AXI4StreamSlaveBridge (
    input CLK,
    input RST_N,

    // AXI4 interface
    axi_stream_interface.master axis,

    // OutPortSimple recv port
    input  [`AXI4S_FLIT_WIDTH - 1 : 0]  get_flit,
    input                               get_flit_valid,
    output                              get_flit_ready
  );

  // State definitions
  typedef enum logic [1 : 0] {IDLE, TDATA} state_t;
  state_t state, next_state;

  always @(posedge CLK) begin
    if (!RST_N)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Fire signals
  wire t_fire = axis.tvalid && axis.tready;

  // Flit register
  reg  [`AXI4S_FLIT_WIDTH - 1 : 0] get_flit_reg;
  wire                                 get_flit_reg_valid   = get_flit_reg[`AXI4S_FLIT_WIDTH - 1];
  wire                                 get_flit_reg_is_tail = get_flit_reg[`AXI4S_FLIT_WIDTH - 2];
  wire [`DEST_BITS - 1 : 0]            get_flit_reg_dst     = get_flit_reg[`AXI4S_FLIT_WIDTH - 3 : `AXI4S_FLIT_WIDTH - `DEST_BITS - 2];
  wire [`VC_BITS - 1 : 0]              get_flit_reg_vc      = get_flit_reg[`AXI4S_FLIT_WIDTH - `DEST_BITS - 3: `AXI4S_FLIT_WIDTH - `DEST_BITS - `VC_BITS - 2];
  wire [AXI4S_FLIT_DATA_WIDTH - 1 : 0] get_flit_reg_data    = get_flit_reg[AXI4S_FLIT_DATA_WIDTH - 1 : 0];

  always @(posedge CLK) begin
    if (!RST_N) begin
      get_flit_reg <= 0;
    end else if (get_flit_ready) begin
      get_flit_reg <= get_flit;
    end
  end

  // FSM to handle AXI4-Stream slave device status
  always_comb begin
    case (state)
      IDLE: next_state = get_flit_valid ? TDATA : IDLE;
      TDATA: next_state = t_fire ? IDLE : TDATA;
      default: next_state = state;
    endcase
  end

  assign axis.tuser  = get_flit_reg_data[100 : 93];
  assign axis.tdest  = get_flit_reg_data[92 : 89];
  assign axis.tid    = get_flit_reg_data[88 : 81];
  assign axis.tlast  = get_flit_reg_data[80];
  assign axis.tkeep  = get_flit_reg_data[79 : 72];
  assign axis.tstrb  = get_flit_reg_data[71 : 64];
  assign axis.tdata  = get_flit_reg_data[63 : 0];
  assign axis.tvalid = (state == TDATA);

  // OutPortSimple output signal
  assign get_flit_ready = (state == IDLE);

  // Debug
  axi_data_t axis_tdata;
  assign     axis_tdata = axis.tdata;
  axi_strb_t axis_tstrb;
  assign     axis_tstrb = axis.tstrb;
  axi_keep_t axis_tkeep;
  assign     axis_tkeep = axis.tkeep;
  logic      axis_tlast;
  assign     axis_tlast = axis.tlast;
  axi_id_t   axis_tid;
  assign     axis_tid = axis.tid;
  axi_dest_t axis_tdest;
  assign     axis_tdest = axis.tdest;
  axi_user_t axis_tuser;
  assign     axis_tuser = axis.tuser;
  logic      axis_tvalid;
  assign     axis_tvalid = axis.tvalid;
  logic      axis_tready;
  assign     axis_tready = axis.tready;

endmodule
