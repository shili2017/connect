`include "connect_parameters.v"

import axi4_pkg::*;

module FlitSerializer # (
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

  initial begin
    assert(IN_FLIT_WIDTH > OUT_FLIT_WIDTH);
  end

  localparam FLIT_META_WIDTH = 2 + `DEST_BITS + `VC_BITS;
  localparam IN_FLIT_DATA_WIDTH = IN_FLIT_WIDTH - FLIT_META_WIDTH;
  localparam OUT_FLIT_DATA_WIDTH = OUT_FLIT_WIDTH - FLIT_META_WIDTH;

  // LEN = $ceil(IN_FLIT_DATA_WIDTH / OUT_FLIT_DATA_WIDTH)
  localparam LEN = (IN_FLIT_DATA_WIDTH + OUT_FLIT_DATA_WIDTH - 1) / OUT_FLIT_DATA_WIDTH;

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

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      flit_data_reg <= 0;
      flit_meta_reg <= 0;
    end else begin
      if (in_fire) begin
        flit_data_reg <= in_flit[IN_FLIT_DATA_WIDTH - 1 : 0];
        flit_meta_reg <= in_flit[IN_FLIT_WIDTH - 1 : IN_FLIT_WIDTH - FLIT_META_WIDTH];
      end else begin
        if (out_fire) begin
          flit_data_reg <= flit_data_reg >> OUT_FLIT_DATA_WIDTH;
        end
      end
    end
  end

  logic [OUT_FLIT_WIDTH - 1 : 0] flit_out;

  always_comb begin
    flit_out = {flit_meta_reg, flit_data_reg[OUT_FLIT_DATA_WIDTH - 1 : 0]};

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
      $display("%d: [Serializer  ] in =%b", cycle, in_flit);
    if (out_fire)
      $display("%d: [Serializer  ] out=%b", cycle, out_flit);
  end
`endif

endmodule

module FlitDeserializer # (
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

  initial begin
    assert(IN_FLIT_WIDTH < OUT_FLIT_WIDTH);
  end

  localparam FLIT_META_WIDTH = 2 + `DEST_BITS + `VC_BITS;
  localparam IN_FLIT_DATA_WIDTH = IN_FLIT_WIDTH - FLIT_META_WIDTH;
  localparam OUT_FLIT_DATA_WIDTH = OUT_FLIT_WIDTH - FLIT_META_WIDTH;

  // LEN = $ceil(OUT_FLIT_DATA_WIDTH / IN_FLIT_DATA_WIDTH)
  localparam LEN = (OUT_FLIT_DATA_WIDTH + IN_FLIT_DATA_WIDTH - 1) / IN_FLIT_DATA_WIDTH;

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
      if (in_fire) begin
        len_cnt <= len_cnt + 1;
      end else if (state == DATA) begin
        len_cnt <= 0;
      end
    end
  end

  // FSM
  always_comb begin
    case (state)
      IDLE: next_state = ((len_cnt == LEN - 1) && in_fire) ? DATA : IDLE;
      DATA: next_state = out_fire ? IDLE : DATA;
      default: next_state = state;
    endcase
  end

  logic [IN_FLIT_DATA_WIDTH * LEN - 1 : 0] flit_data_reg;
  logic [FLIT_META_WIDTH - 1 : 0] flit_meta_reg;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      flit_data_reg <= 0;
      flit_meta_reg <= 0;
    end else begin
      if (out_fire) begin
        flit_data_reg <= 0;
        flit_meta_reg <= 0;
      end else if (in_fire) begin
        flit_data_reg[len_cnt * IN_FLIT_DATA_WIDTH +: IN_FLIT_DATA_WIDTH] <= in_flit;

        // Only keep the metadata in the last flit
        // We can ensure that LEN - 2 >= 0 because of the assertion in the initial block
        if (len_cnt == LEN - 2) begin
          flit_meta_reg <= in_flit[IN_FLIT_WIDTH - 1 : IN_FLIT_WIDTH - FLIT_META_WIDTH];
        end
      end
    end
  end

  // Input flit signals
  assign in_flit_ready = (state == IDLE);

  // Output flit signals
  assign out_flit = {flit_meta_reg, flit_data_reg[OUT_FLIT_DATA_WIDTH - 1 : 0]};
  assign out_flit_valid = (state == DATA);

`ifdef DEBUG_SERIALIZER
  reg [15 : 0] cycle = 0;
  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;
    if (in_fire)
      $display("%d: [Deserializer] in =%b", cycle, in_flit);
    if (out_fire)
      $display("%d: [Deserializer] out=%b", cycle, out_flit);
  end
`endif

endmodule
