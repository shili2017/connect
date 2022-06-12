`include "connect_parameters.v"

import axi4_pkg::*;

module FlitSerializer # (
    parameter DEBUG_ID = 0,
    parameter IN_FLIT_WIDTH = AXI4S_FLIT_DATA_WIDTH + 2 + `DEST_BITS + `VC_BITS,
    parameter OUT_FLIT_WIDTH = `FLIT_WIDTH
  ) (
    input CLK,
    input RST_N,

    // Input
    input  [IN_FLIT_WIDTH - 1 : 0]  in_flit,
    input                           in_flit_valid,
    output                          in_flit_ready,
  
    // Output
    output [OUT_FLIT_WIDTH - 1 : 0] out_flit,
    output                          out_flit_valid,
    input                           out_flit_ready
  );

  localparam FLIT_META_WIDTH = 2 + `DEST_BITS + `VC_BITS;
  localparam IN_FLIT_DATA_WIDTH = IN_FLIT_WIDTH - FLIT_META_WIDTH;
  localparam OUT_FLIT_DATA_WIDTH = OUT_FLIT_WIDTH - FLIT_META_WIDTH;
  localparam OUT_FLIT_EFF_DATA_WIDTH = OUT_FLIT_DATA_WIDTH - `SRC_BITS;

  // LEN = $ceil(IN_FLIT_DATA_WIDTH / OUT_FLIT_EFF_DATA_WIDTH)
  localparam LEN = (IN_FLIT_DATA_WIDTH + OUT_FLIT_EFF_DATA_WIDTH - 1) / OUT_FLIT_EFF_DATA_WIDTH;

  // In/Out fire signals
  logic in_fire, out_fire;
  assign in_fire = in_flit_valid && in_flit_ready;
  assign out_fire = out_flit_valid && out_flit_ready;

  // State definitions
  typedef enum logic [1 : 0] {IDLE, DATA} state_t;
  state_t state, next_state;

  always_ff @(posedge CLK) begin
    if (!RST_N)
      state <= IDLE;
    else
      state <= next_state;
  end

  logic [15 : 0] len_cnt;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      len_cnt <= 0;
    end else begin
      if (out_fire) begin
        len_cnt <= len_cnt + 1;
      end else if (state == IDLE) begin
        len_cnt <= 0;
      end
    end
  end

  // FSM
  always_comb begin
    case (state)
      IDLE: next_state = in_fire ? DATA : IDLE;
      DATA: next_state = ((len_cnt == LEN - 1) && out_fire) ? IDLE : DATA;
      default: next_state = state;
    endcase
  end

  logic [IN_FLIT_DATA_WIDTH - 1 : 0] flit_data_reg;
  logic [FLIT_META_WIDTH - 1 : 0] flit_meta_reg;
  logic [`SRC_BITS - 1 : 0] flit_src_reg;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      flit_data_reg <= 0;
      flit_meta_reg <= 0;
      flit_src_reg <= 0;
    end else begin
      if (in_fire) begin
        flit_data_reg <= in_flit[IN_FLIT_DATA_WIDTH - 1 : 0];
        flit_meta_reg <= in_flit[IN_FLIT_WIDTH - 1 : IN_FLIT_WIDTH - FLIT_META_WIDTH];
        flit_src_reg <= in_flit[`SRC_BITS - 1 : 0];
      end else begin
        if (out_fire) begin
          flit_data_reg <= flit_data_reg >> OUT_FLIT_EFF_DATA_WIDTH;
        end
      end
    end
  end

  logic [OUT_FLIT_WIDTH - 1 : 0] flit_out;

  /* Out flit structure
   * -----------------------------------------------------------------------------------
   * | <valid bit> | <is_tail> | <destination> | <virtual channel> | <source> | <data> |
   * -----------------------------------------------------------------------------------
   *        1            1        `DEST_BITS         `VC_BITS       `SRC_BITS OUT_FLIT_EFF_DATA_WIDTH
   */

  always_comb begin
    flit_out = {flit_meta_reg, flit_src_reg, flit_data_reg[OUT_FLIT_EFF_DATA_WIDTH - 1 : 0]};

    // update tail
    flit_out[OUT_FLIT_WIDTH - 2] = flit_meta_reg[FLIT_META_WIDTH - 2] && (len_cnt == LEN - 1);
  end

  // Input flit signals
  assign in_flit_ready = (state == IDLE);

  // Output flit signals
  assign out_flit = flit_out;
  assign out_flit_valid = (state == DATA);

`ifdef DEBUG_SERIALIZER
  reg [15 : 0] cycle = 0;
  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;
    if (in_fire)
      $display("%d: [Serializer  ] %d - in : meta=%x data=%x", cycle, DEBUG_ID,
        in_flit[IN_FLIT_WIDTH - 1 : IN_FLIT_DATA_WIDTH],
        in_flit[IN_FLIT_DATA_WIDTH - 1 : 0]
      );
    if (out_fire)
      $display("%d: [Serializer  ] %d - out: meta=%x src=%x data=%x", cycle, DEBUG_ID,
        out_flit[OUT_FLIT_WIDTH - 1 : OUT_FLIT_DATA_WIDTH],
        out_flit[OUT_FLIT_DATA_WIDTH - 1 : OUT_FLIT_EFF_DATA_WIDTH],
        out_flit[OUT_FLIT_EFF_DATA_WIDTH - 1 : 0]
      );
  end
`endif

endmodule

module FlitDeserializer # (
    parameter DEBUG_ID = 0,
    parameter IN_FLIT_WIDTH = `FLIT_WIDTH,
    parameter OUT_FLIT_WIDTH = AXI4S_FLIT_DATA_WIDTH + 2 + `DEST_BITS + `VC_BITS
  ) (
    input CLK,
    input RST_N,

    // Input
    input  [IN_FLIT_WIDTH - 1 : 0]  in_flit,
    input                           in_flit_valid,
    output                          in_flit_ready,
  
    // Output
    output [OUT_FLIT_WIDTH - 1 : 0] out_flit,
    output                          out_flit_valid,
    input                           out_flit_ready
  );

  localparam FLIT_META_WIDTH = 2 + `DEST_BITS + `VC_BITS;
  localparam IN_FLIT_DATA_WIDTH = IN_FLIT_WIDTH - FLIT_META_WIDTH;
  localparam IN_FLIT_EFF_DATA_WIDTH = IN_FLIT_DATA_WIDTH - `SRC_BITS;
  localparam OUT_FLIT_DATA_WIDTH = OUT_FLIT_WIDTH - FLIT_META_WIDTH;

  // LEN = $ceil(OUT_FLIT_DATA_WIDTH / IN_FLIT_EFF_DATA_WIDTH)
  localparam LEN = (OUT_FLIT_DATA_WIDTH + IN_FLIT_EFF_DATA_WIDTH - 1) / IN_FLIT_EFF_DATA_WIDTH;

  // State definitions
  typedef enum logic [1 : 0] {RECV, SEND} state_t;
  state_t state[`NUM_USER_SEND_PORTS];
  state_t next_state[`NUM_USER_SEND_PORTS];

  always_ff @(posedge CLK) begin
    for (int i = 0; i < `NUM_USER_SEND_PORTS; i++) begin
      if (!RST_N)
        state[i] <= RECV;
      else
        state[i] <= next_state[i];
    end
  end

  // In/Out valid, ready, fire signals
  logic [`NUM_USER_SEND_PORTS - 1 : 0] in_valid;
  logic [`NUM_USER_SEND_PORTS - 1 : 0] in_ready;
  logic [`NUM_USER_SEND_PORTS - 1 : 0] in_fire;
  logic [`NUM_USER_SEND_PORTS - 1 : 0] out_valid;
  logic [`NUM_USER_SEND_PORTS - 1 : 0] out_ready;
  logic [`NUM_USER_SEND_PORTS - 1 : 0] out_fire;

  logic [`SRC_BITS - 1 : 0] in_flit_src;
  assign in_flit_src = in_flit[IN_FLIT_DATA_WIDTH - 1 : IN_FLIT_EFF_DATA_WIDTH];

  always_comb begin
    for (int i = 0; i < `NUM_USER_SEND_PORTS; i++) begin
      in_valid[i]   = in_flit_valid && (in_flit_src == i);
      in_ready[i]   = (state[i] == RECV);
      in_fire[i]    = in_valid[i] && in_ready[i];
      out_valid[i]  = (state[i] == SEND);
      out_fire[i]   = out_valid[i] && out_ready[i];
    end
  end

  // Length counter
  logic [15 : 0] len_cnt[`NUM_USER_SEND_PORTS];

  always_ff @(posedge CLK) begin
    for (int i = 0; i < `NUM_USER_SEND_PORTS; i++) begin
      if (!RST_N) begin
        len_cnt[i] <= 0;
      end else begin
        if (in_fire[i]) begin
          len_cnt[i] <= len_cnt[i] + 1;
        end else if (state[i] == SEND) begin
          len_cnt[i] <= 0;
        end
      end
    end
  end

  // FSM
  always_comb begin
    for (int i = 0; i < `NUM_USER_SEND_PORTS; i++) begin
      case (state[i])
        RECV: next_state[i] = ((len_cnt[i] == LEN - 1) && in_fire[i]) ? SEND : RECV;
        SEND: next_state[i] = out_fire[i] ? RECV : SEND;
        default: next_state[i] = state[i];
      endcase
    end
  end

  logic [IN_FLIT_EFF_DATA_WIDTH * LEN - 1 : 0] flit_data_reg[`NUM_USER_SEND_PORTS];
  logic [FLIT_META_WIDTH - 1 : 0]              flit_meta_reg[`NUM_USER_SEND_PORTS];

  always_ff @(posedge CLK) begin
    for (int i = 0; i < `NUM_USER_SEND_PORTS; i++) begin
      if (!RST_N) begin
        flit_data_reg[i] <= 0;
        flit_meta_reg[i] <= 0;
      end else begin
        if (out_fire[i]) begin
          flit_data_reg[i] <= 0;
          flit_meta_reg[i] <= 0;
        end else if (in_fire[i]) begin
          flit_data_reg[i][len_cnt[i] * IN_FLIT_EFF_DATA_WIDTH +: IN_FLIT_EFF_DATA_WIDTH] <= in_flit[IN_FLIT_EFF_DATA_WIDTH - 1 : 0];

          // Only keep the metadata in the last flit
          if (len_cnt[i] == LEN - 1) begin
            flit_meta_reg[i] <= in_flit[IN_FLIT_WIDTH - 1 : IN_FLIT_WIDTH - FLIT_META_WIDTH];
          end
        end
      end
    end
  end

  // Input flit signals
  assign in_flit_ready = in_ready[in_flit_src];

  // Output flit signals
  logic [OUT_FLIT_WIDTH - 1 : 0] out_flit_;
  assign out_flit = out_flit_;
  assign out_flit_valid = |out_valid;

  // Use a priority encoder to decide which flit to send
  logic [`SRC_BITS - 1 : 0] _out_idx;
  always_comb begin
    _out_idx = 0;
    for (int i = `NUM_USER_SEND_PORTS - 1; i >= 0; i--) begin
      if (out_valid[i])
        _out_idx = i;
    end
  end
  always_comb begin
    for (int i = 0; i < `NUM_USER_SEND_PORTS; i++) begin
      out_ready[i] = 0;
      out_flit_ = 0;
    end
    out_ready[_out_idx] = out_flit_ready;
    out_flit_ = {flit_meta_reg[_out_idx], flit_data_reg[_out_idx][OUT_FLIT_DATA_WIDTH - 1 : 0]};
  end

`ifdef DEBUG_SERIALIZER
  reg [15 : 0] cycle = 0;
  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;
    if (in_flit_valid && in_flit_ready)
      $display("%d: [Deserializer] %d - in : meta=%x src=%x data=%x", cycle, DEBUG_ID,
        in_flit[IN_FLIT_WIDTH - 1 : IN_FLIT_DATA_WIDTH],
        in_flit[IN_FLIT_DATA_WIDTH - 1 : IN_FLIT_EFF_DATA_WIDTH],
        in_flit[IN_FLIT_EFF_DATA_WIDTH - 1 : 0]
      );
    if (out_flit_valid && out_flit_ready)
      $display("%d: [Deserializer] %d - out: meta=%x src=%x data=%x", cycle, DEBUG_ID,
        out_flit[OUT_FLIT_WIDTH - 1 : OUT_FLIT_DATA_WIDTH],
        _out_idx,
        out_flit[OUT_FLIT_DATA_WIDTH - 1 : 0]
      );
  end
`endif

endmodule
