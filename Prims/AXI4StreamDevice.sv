import axi4_pkg::*;

module AXI4StreamMasterDevice #(parameter ID = 0) (
  input CLK,
  input RST_N,
  axi_stream_interface.master axis,
  input logic start,
  input axi_dest_t dest
);

  typedef enum logic [1 : 0] {IDLE, TDATA} state_type;
  state_type state, next_state;

  localparam LEN = 24;

  axi_data_t data = 64'hdeadbeef00000000;
  axi_len_t len_cnt;
  logic start_delay;

  assign axis.tdata = data + len_cnt;
  assign axis.tstrb = 8'hff;
  assign axis.tkeep = 8'hff;
  assign axis.tlast = (state == TDATA && len_cnt == LEN - 1);
  assign axis.tid   = ID;
  assign axis.tdest = dest;
  assign axis.tuser = 0;
  assign axis.tvalid = (state == TDATA);

  always_ff @(posedge CLK) begin
    if (~RST_N) begin
      len_cnt <= 0;
    end else begin
      if (state == TDATA && axis.tvalid && axis.tready)
        len_cnt <= len_cnt + 1;
    end
  end

  always_ff @(posedge CLK) begin
    if (~RST_N) begin
      start_delay <= 0;
    end else begin
      start_delay <= start;
    end
  end

  always_comb begin
    case (state)
      IDLE : next_state = (start_delay) ? TDATA : IDLE;
      TDATA: next_state = (axis.tvalid && axis.tready && axis.tlast) ? IDLE : TDATA;
      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

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

module AXI4StreamSlaveDevice #(parameter ONLY_ACCEPT = 0) (
  input CLK,
  input RST_N,
  axi_stream_interface.slave axis
);

  typedef enum logic [2 : 0] {IDLE, TDATA} state_type;
  state_type state, next_state;

  axi_dest_t dest;
  axi_len_t len_cnt;

  axi_data_t buffer[0 : 32];

  assign axis.tready = 1;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      len_cnt <= 0;
      for (int i = 0; i < 32; i++) begin
        buffer[i] = 0;
      end
    end else begin
      if (axis.tvalid && axis.tready && axis.tid == ONLY_ACCEPT) begin
        len_cnt <= len_cnt + 1;
        buffer[len_cnt] <= axis.tdata;
      end
    end
  end

  always_comb begin
    case (state)
      IDLE : next_state = (axis.tvalid) ? TDATA : IDLE;
      TDATA: next_state = (axis.tvalid && axis.tready && axis.tlast) ? IDLE : TDATA;
      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

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
