`include "connect_parameters.v"

import axi4_pkg::*;

`define AXI4_FLIT_WIDTH (AXI4_FLIT_DATA_WIDTH + 2 + `DEST_BITS + `VC_BITS)

module AXI4MasterBridge (
    input CLK,
    input RST_N,

    // AXI4 interface
    axi_interface.slave axi,

    // InPortSimple send port
    output [`AXI4_FLIT_WIDTH - 1 : 0] put_flit,
    output                            put_flit_valid,
    input                             put_flit_ready,

    // OutPortSimple recv port
    input  [`AXI4_FLIT_WIDTH - 1 : 0] get_flit,
    input                             get_flit_valid,
    output                            get_flit_ready
  );

  // State definitions
  typedef enum logic [2 : 0] {IDLE, WDATA, WRESP1, WRESP2, RDATA1, RDATA2} state_t;
  state_t state, next_state;

  always_ff @(posedge CLK) begin
    if (!RST_N)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Fire signals
  wire aw_fire = axi.awvalid && axi.awready;
  wire w_fire  = axi.wvalid  && axi.wready;
  wire b_fire  = axi.bvalid  && axi.bready;
  wire ar_fire = axi.arvalid && axi.arready;
  wire r_fire  = axi.rvalid  && axi.rready;

  // FSM to handle AXI master device request
  always_comb begin
    case (state)
      IDLE: begin
        if (aw_fire)
          next_state = WDATA;
        else if (ar_fire)
          next_state = RDATA1;
        else
          next_state = state;
      end
      WDATA: begin
        if (w_fire && axi.wlast)
          next_state = WRESP1;
        else
          next_state = state;
      end
      WRESP1: begin
        if (get_flit_valid)
          next_state = WRESP2;
        else
          next_state = state;
      end
      WRESP2: begin
        if (b_fire)
          next_state = IDLE;
        else
          next_state = state;
      end
      RDATA1: begin
        if (get_flit_valid)
          next_state = RDATA2;
        else
          next_state = state;
      end
      RDATA2: begin
        if (r_fire) begin
          if (axi.rlast)
            next_state = IDLE;
          else
            next_state = RDATA1;
        end else
          next_state = state;
      end
      default: next_state = state;
    endcase
  end

  // put_flit data for aw/w/ar
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data;
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data_aw;
  assign put_flit_data_aw =
    {CHANNEL_AW, axi.awuser, axi.awid, 12'b0, axi.awlen, axi.awsize, axi.awburst,
     axi.awlock, axi.awcache, axi.awprot, axi.awqos, axi.awregion, axi.awaddr};
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data_w;
  assign put_flit_data_w =
    {CHANNEL_W, axi.wuser, axi.wid, axi.wlast, axi.wstrb, axi.wdata};
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data_ar;
  assign put_flit_data_ar =
    {CHANNEL_AR, axi.aruser, axi.arid, 12'b0, axi.arlen, axi.arsize, axi.arburst,
     axi.arlock, axi.arcache, axi.arprot, axi.arqos, axi.arregion, axi.araddr};

  always_comb begin
    case ({aw_fire, w_fire, ar_fire})
      3'b100: put_flit_data = put_flit_data_aw;
      3'b010: put_flit_data = put_flit_data_w;
      3'b001: put_flit_data = put_flit_data_ar;
      default: put_flit_data = 0;
    endcase
  end

  // Flit register
  reg  [`AXI4_FLIT_WIDTH - 1 : 0] get_flit_reg;
  wire                                get_flit_reg_valid   = get_flit_reg[`AXI4_FLIT_WIDTH - 1];
  wire                                get_flit_reg_is_tail = get_flit_reg[`AXI4_FLIT_WIDTH - 2];
  wire [`DEST_BITS - 1 : 0]           get_flit_reg_dst     = get_flit_reg[`AXI4_FLIT_WIDTH - 3 : `AXI4_FLIT_WIDTH - `DEST_BITS - 2];
  wire [`VC_BITS - 1 : 0]             get_flit_reg_vc      = get_flit_reg[`AXI4_FLIT_WIDTH - `DEST_BITS - 3: `AXI4_FLIT_WIDTH - `DEST_BITS - `VC_BITS - 2];
  wire [AXI4_FLIT_DATA_WIDTH - 1 : 0] get_flit_reg_data    = get_flit_reg[AXI4_FLIT_DATA_WIDTH - 1 : 0];

  always @(posedge CLK) begin
    if (!RST_N) begin
      get_flit_reg <= 0;
    end else if (get_flit_ready) begin
      get_flit_reg <= get_flit;
    end
  end

  // Flit destination
  logic [`DEST_BITS - 1 : 0] put_flit_dst;
  logic [`DEST_BITS - 1 : 0] put_flit_dst_reg;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      put_flit_dst_reg <= 0;
    end else if (aw_fire) begin
      put_flit_dst_reg <= axi.awaddr[`DEST_BITS - 1 : 0];
    end else if (ar_fire) begin
      put_flit_dst_reg <= axi.araddr[`DEST_BITS - 1 : 0];
    end
  end

  always_comb begin
    if (aw_fire)
      put_flit_dst = axi.awaddr[`DEST_BITS - 1 : 0];
    else if (ar_fire)
      put_flit_dst = axi.araddr[`DEST_BITS - 1 : 0];
    else
      put_flit_dst = put_flit_dst_reg;
  end

  // Flit tail
  logic put_flit_tail;

  // Flit vc
  logic [`VC_BITS - 1 : 0] put_flit_vc;

  // aw channel output signal
  assign axi.awready  = (state == IDLE);

  // w channel output signal
  assign axi.wready   = (state == WDATA);

  // b channel output signal
  assign axi.buser    = get_flit_reg_data[88 : 81];
  assign axi.bid      = get_flit_reg_data[80 : 73];
  assign axi.bresp    = get_flit_reg_data[65 : 64];
  assign axi.bvalid   = (state == WRESP2);

  // ar channel output signal
  assign axi.arready  = (state == IDLE);

  // r channel output signal
  assign axi.ruser    = get_flit_reg_data[88 : 81];
  assign axi.rid      = get_flit_reg_data[80 : 73];
  assign axi.rlast    = get_flit_reg_data[72];
  assign axi.rresp    = get_flit_reg_data[65 : 64];
  assign axi.rdata    = get_flit_reg_data[63 : 0];
  assign axi.rvalid   = (state == RDATA2);

  // InPortSimple output signal, use VC 1
  assign put_flit       = {put_flit_valid, put_flit_tail, put_flit_dst, put_flit_vc, put_flit_data};
  assign put_flit_vc    = 1;
  assign put_flit_tail  = ar_fire || (w_fire && axi.wlast);
  assign put_flit_valid = aw_fire || ar_fire || w_fire;

  // OutPortSimple output signal
  assign get_flit_ready = (state == WRESP1) || (state == RDATA1);

  // Debug
  axi_id_t     axi_awid;
  assign       axi_awid = axi.awid;
  axi_addr_t   axi_awaddr;
  assign       axi_awaddr = axi.awaddr;
  axi_len_t    axi_awlen;
  assign       axi_awlen = axi.awlen;
  axi_size_t   axi_awsize;
  assign       axi_awsize = axi.awsize;
  axi_burst_t  axi_awburst;
  assign       axi_awburst = axi.awburst;
  logic        axi_awlock;
  assign       axi_awlock = axi.awlock;
  axi_cache_t  axi_awcache;
  assign       axi_awcache = axi.awcache;
  axi_prot_t   axi_awprot;
  assign       axi_awprot = axi.awprot;
  axi_qos_t    axi_awqos;
  assign       axi_awqos = axi.awqos;
  axi_region_t axi_awregion;
  assign       axi_awregion = axi.awregion;
  axi_user_t   axi_awuser;
  assign       axi_awuser = axi.awuser;
  logic        axi_awvalid;
  assign       axi_awvalid = axi.awvalid;
  logic        axi_awready;
  assign       axi_awready = axi.awready;
  axi_id_t     axi_wid;
  assign       axi_wid = axi.wid;
  axi_data_t   axi_wdata;
  assign       axi_wdata = axi.wdata;
  axi_strb_t   axi_wstrb;
  assign       axi_wstrb = axi.wstrb;
  logic        axi_wlast;
  assign       axi_wlast = axi.wlast;
  axi_user_t   axi_wuser;
  assign       axi_wuser = axi.wuser;
  logic        axi_wvalid;
  assign       axi_wvalid = axi.wvalid;
  logic        axi_wready;
  assign       axi_wready = axi.wready;
  axi_id_t     axi_bid;
  assign       axi_bid = axi.bid;
  axi_resp_t   axi_bresp;
  assign       axi_bresp = axi.bresp;
  axi_user_t   axi_buser;
  assign       axi_buser = axi.buser;
  logic        axi_bvalid;
  assign       axi_bvalid = axi.bvalid;
  logic        axi_bready;
  assign       axi_bready = axi.bready;
  axi_id_t     axi_arid;
  assign       axi_arid = axi.arid;
  axi_addr_t   axi_araddr;
  assign       axi_araddr = axi.araddr;
  axi_len_t    axi_arlen;
  assign       axi_arlen = axi.arlen;
  axi_size_t   axi_arsize;
  assign       axi_arsize = axi.arsize;
  axi_burst_t  axi_arburst;
  assign       axi_arburst = axi.arburst;
  logic        axi_arlock;
  assign       axi_arlock = axi.arlock;
  axi_cache_t  axi_arcache;
  assign       axi_arcache = axi.arcache;
  axi_prot_t   axi_arprot;
  assign       axi_arprot = axi.arprot;
  axi_qos_t    axi_arqos;
  assign       axi_arqos = axi.arqos;
  axi_region_t axi_arregion;
  assign       axi_arregion = axi.arregion;
  axi_user_t   axi_aruser;
  assign       axi_aruser = axi.aruser;
  logic        axi_arvalid;
  assign       axi_arvalid = axi.arvalid;
  logic        axi_arready;
  assign       axi_arready = axi.arready;
  axi_id_t     axi_rid;
  assign       axi_rid = axi.rid;
  axi_data_t   axi_rdata;
  assign       axi_rdata = axi.rdata;
  axi_resp_t   axi_rresp;
  assign       axi_rresp = axi.rresp;
  logic        axi_rlast;
  assign       axi_rlast = axi.rlast;
  axi_user_t   axi_ruser;
  assign       axi_ruser = axi.ruser;
  logic        axi_rvalid;
  assign       axi_rvalid = axi.rvalid;
  logic        axi_rready;
  assign       axi_rready = axi.rready;

endmodule

module AXI4SlaveBridge (
    input CLK,
    input RST_N,

    // AXI4 interface
    axi_interface.master axi,

    // InPortSimple send port
    output [`AXI4_FLIT_WIDTH - 1 : 0] put_flit,
    output                            put_flit_valid,
    input                             put_flit_ready,

    // OutPortSimple recv port
    input  [`AXI4_FLIT_WIDTH - 1 : 0] get_flit,
    input                             get_flit_valid,
    output                            get_flit_ready
  );

  // State definitions
  typedef enum logic [2 : 0] {IDLE, WADDR, WDATA1, WDATA2, WRESP, RADDR, RDATA} state_t;
  state_t state, next_state;

  always @(posedge CLK) begin
    if (!RST_N)
      state <= IDLE;
    else
      state <= next_state;
  end

  // Fire signals
  wire aw_fire = axi.awvalid && axi.awready;
  wire w_fire  = axi.wvalid  && axi.wready;
  wire b_fire  = axi.bvalid  && axi.bready;
  wire ar_fire = axi.arvalid && axi.arready;
  wire r_fire  = axi.rvalid  && axi.rready;

  // Flit register
  reg  [`AXI4_FLIT_WIDTH - 1 : 0] get_flit_reg;
  wire                                get_flit_reg_valid   = get_flit_reg[`AXI4_FLIT_WIDTH - 1];
  wire                                get_flit_reg_is_tail = get_flit_reg[`AXI4_FLIT_WIDTH - 2];
  wire [`DEST_BITS - 1 : 0]           get_flit_reg_dst     = get_flit_reg[`AXI4_FLIT_WIDTH - 3 : `AXI4_FLIT_WIDTH - `DEST_BITS - 2];
  wire [`VC_BITS - 1 : 0]             get_flit_reg_vc      = get_flit_reg[`AXI4_FLIT_WIDTH - `DEST_BITS - 3: `AXI4_FLIT_WIDTH - `DEST_BITS - `VC_BITS - 2];
  wire [AXI4_FLIT_DATA_WIDTH - 1 : 0] get_flit_reg_data    = get_flit_reg[AXI4_FLIT_DATA_WIDTH - 1 : 0];

  always @(posedge CLK) begin
    if (!RST_N) begin
      get_flit_reg <= 0;
    end else if (get_flit_ready) begin
      get_flit_reg <= get_flit;
    end
  end

  // Flit destination
  logic [`DEST_BITS - 1 : 0] put_flit_dst;
  logic [`DEST_BITS - 1 : 0] put_flit_dst_reg;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      put_flit_dst_reg <= 0;
    end else if (aw_fire) begin
      put_flit_dst_reg <= axi.awid[`DEST_BITS - 1 : 0];
    end else if (ar_fire) begin
      put_flit_dst_reg <= axi.arid[`DEST_BITS - 1 : 0];
    end
  end

  always_comb begin
    if (aw_fire)
      put_flit_dst = axi.awid[`DEST_BITS - 1 : 0];
    else if (ar_fire)
      put_flit_dst = axi.arid[`DEST_BITS - 1 : 0];
    else
      put_flit_dst = put_flit_dst_reg;
  end

  // Flit tail
  logic put_flit_tail;

  // Flit VC
  logic [`VC_BITS - 1 : 0] put_flit_vc;

  // FSM to handle AXI slave device status
  always_comb begin
    case (state)
      IDLE: begin
        if (get_flit_valid) begin
          if (get_flit[AXI4_FLIT_DATA_WIDTH - 1 : AXI4_FLIT_DATA_WIDTH - 3] == CHANNEL_AW)
            next_state = WADDR;
          else if (get_flit[AXI4_FLIT_DATA_WIDTH - 1 : AXI4_FLIT_DATA_WIDTH - 3] == CHANNEL_AR)
            next_state = RADDR;
          else
            next_state = state;
        end else
          next_state = state;
      end
      WADDR: begin
        if (aw_fire)
          next_state = WDATA1;
        else
          next_state = state;
      end
      WDATA1: begin
        if (get_flit_valid)
          next_state = WDATA2;
        else
          next_state = state;
      end
      WDATA2: begin
        if (w_fire) begin
          if (axi.wlast)
            next_state = WRESP;
          else
            next_state = WDATA1;
        end else
          next_state = state;
      end
      WRESP: begin
        if (b_fire)
          next_state = IDLE;
        else
          next_state = state;
      end
      RADDR: begin
        if (ar_fire)
          next_state = RDATA;
        else
          next_state = state;
      end
      RDATA: begin
        if (r_fire) begin
          if (axi.rlast)
            next_state = IDLE;
          else
            next_state = RDATA;
        end else
          next_state = state;
      end
      default: next_state = state;
    endcase
  end

  // put_flit data for b/r
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data;
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data_b;
  assign put_flit_data_b =
    {CHANNEL_B, axi.buser, axi.bid, 7'b0, axi.bresp, 64'b0};
  logic [AXI4_FLIT_DATA_WIDTH - 1 : 0] put_flit_data_r;
  assign put_flit_data_r =
    {CHANNEL_R, axi.ruser, axi.rid, axi.rlast, 6'b0, axi.rresp, axi.rdata};

  always_comb begin
    case ({b_fire, r_fire})
      2'b10: put_flit_data = put_flit_data_b;
      2'b01: put_flit_data = put_flit_data_r;
      default: put_flit_data = 0;
    endcase
  end

  // aw channel output signal
  assign axi.awid     = get_flit_reg_data[80 : 73];
  assign axi.awaddr   = get_flit_reg_data[31 : 0];
  assign axi.awlen    = get_flit_reg_data[60 : 53];
  assign axi.awsize   = get_flit_reg_data[52 : 50];
  assign axi.awburst  = get_flit_reg_data[49 : 48];
  assign axi.awlock   = get_flit_reg_data[47];
  assign axi.awcache  = get_flit_reg_data[46 : 43];
  assign axi.awprot   = get_flit_reg_data[42 : 40];
  assign axi.awqos    = get_flit_reg_data[39 : 36];
  assign axi.awregion = get_flit_reg_data[35 : 32];
  assign axi.awuser   = get_flit_reg_data[88 : 81];
  assign axi.awvalid  = (state == WADDR);

  // w channel output signal
  assign axi.wid      = get_flit_reg_data[80 : 73];
  assign axi.wdata    = get_flit_reg_data[63 : 0];
  assign axi.wstrb    = get_flit_reg_data[71 : 64];
  assign axi.wlast    = get_flit_reg_data[72];
  assign axi.wuser    = get_flit_reg_data[88 : 81];
  assign axi.wvalid   = (state == WDATA2);

  // b channel output signal
  assign axi.bready   = (state == WRESP);

  // ar channel output signal
  assign axi.arid     = get_flit_reg_data[80 : 73];
  assign axi.araddr   = get_flit_reg_data[31 : 0];
  assign axi.arlen    = get_flit_reg_data[60 : 53];
  assign axi.arsize   = get_flit_reg_data[52 : 50];
  assign axi.arburst  = get_flit_reg_data[49 : 48];
  assign axi.arlock   = get_flit_reg_data[47];
  assign axi.arcache  = get_flit_reg_data[46 : 43];
  assign axi.arprot   = get_flit_reg_data[42 : 40];
  assign axi.arqos    = get_flit_reg_data[39 : 36];
  assign axi.arregion = get_flit_reg_data[35 : 32];
  assign axi.aruser   = get_flit_reg_data[88 : 81];
  assign axi.arvalid  = (state == RADDR);

  // r channel output signal
  assign axi.rready   = (state == RDATA);

  // InPortSimple output signal, use VC 0
  assign put_flit       = {put_flit_valid, put_flit_tail, put_flit_dst, put_flit_vc, put_flit_data};
  assign put_flit_vc    = 0;
  assign put_flit_tail  = b_fire || (r_fire && axi.rlast);
  assign put_flit_valid = b_fire || r_fire;

  // OutPortSimple output signal
  assign get_flit_ready = (state == IDLE) || (state == WDATA1);

  // Debug
  axi_id_t     axi_awid;
  assign       axi_awid = axi.awid;
  axi_addr_t   axi_awaddr;
  assign       axi_awaddr = axi.awaddr;
  axi_len_t    axi_awlen;
  assign       axi_awlen = axi.awlen;
  axi_size_t   axi_awsize;
  assign       axi_awsize = axi.awsize;
  axi_burst_t  axi_awburst;
  assign       axi_awburst = axi.awburst;
  logic        axi_awlock;
  assign       axi_awlock = axi.awlock;
  axi_cache_t  axi_awcache;
  assign       axi_awcache = axi.awcache;
  axi_prot_t   axi_awprot;
  assign       axi_awprot = axi.awprot;
  axi_qos_t    axi_awqos;
  assign       axi_awqos = axi.awqos;
  axi_region_t axi_awregion;
  assign       axi_awregion = axi.awregion;
  axi_user_t   axi_awuser;
  assign       axi_awuser = axi.awuser;
  logic        axi_awvalid;
  assign       axi_awvalid = axi.awvalid;
  logic        axi_awready;
  assign       axi_awready = axi.awready;
  axi_id_t     axi_wid;
  assign       axi_wid = axi.wid;
  axi_data_t   axi_wdata;
  assign       axi_wdata = axi.wdata;
  axi_strb_t   axi_wstrb;
  assign       axi_wstrb = axi.wstrb;
  logic        axi_wlast;
  assign       axi_wlast = axi.wlast;
  axi_user_t   axi_wuser;
  assign       axi_wuser = axi.wuser;
  logic        axi_wvalid;
  assign       axi_wvalid = axi.wvalid;
  logic        axi_wready;
  assign       axi_wready = axi.wready;
  axi_id_t     axi_bid;
  assign       axi_bid = axi.bid;
  axi_resp_t   axi_bresp;
  assign       axi_bresp = axi.bresp;
  axi_user_t   axi_buser;
  assign       axi_buser = axi.buser;
  logic        axi_bvalid;
  assign       axi_bvalid = axi.bvalid;
  logic        axi_bready;
  assign       axi_bready = axi.bready;
  axi_id_t     axi_arid;
  assign       axi_arid = axi.arid;
  axi_addr_t   axi_araddr;
  assign       axi_araddr = axi.araddr;
  axi_len_t    axi_arlen;
  assign       axi_arlen = axi.arlen;
  axi_size_t   axi_arsize;
  assign       axi_arsize = axi.arsize;
  axi_burst_t  axi_arburst;
  assign       axi_arburst = axi.arburst;
  logic        axi_arlock;
  assign       axi_arlock = axi.arlock;
  axi_cache_t  axi_arcache;
  assign       axi_arcache = axi.arcache;
  axi_prot_t   axi_arprot;
  assign       axi_arprot = axi.arprot;
  axi_qos_t    axi_arqos;
  assign       axi_arqos = axi.arqos;
  axi_region_t axi_arregion;
  assign       axi_arregion = axi.arregion;
  axi_user_t   axi_aruser;
  assign       axi_aruser = axi.aruser;
  logic        axi_arvalid;
  assign       axi_arvalid = axi.arvalid;
  logic        axi_arready;
  assign       axi_arready = axi.arready;
  axi_id_t     axi_rid;
  assign       axi_rid = axi.rid;
  axi_data_t   axi_rdata;
  assign       axi_rdata = axi.rdata;
  axi_resp_t   axi_rresp;
  assign       axi_rresp = axi.rresp;
  logic        axi_rlast;
  assign       axi_rlast = axi.rlast;
  axi_user_t   axi_ruser;
  assign       axi_ruser = axi.ruser;
  logic        axi_rvalid;
  assign       axi_rvalid = axi.rvalid;
  logic        axi_rready;
  assign       axi_rready = axi.rready;

endmodule
