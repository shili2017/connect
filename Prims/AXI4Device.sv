// source: https://github.com/mmxsrup/axi4-interface/tree/master/axi4

import axi4_pkg::*;

module AXI4MasterDevice #(parameter ID = 0) (
  input CLK,
  input RST_N,
  axi_interface.master axi,
  input logic start_read,
  input logic start_write,
  input axi_addr_t addr
);

  typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
  state_type state, next_state;

  localparam LEN = 8;

  axi_data_t data = 64'hdeadbeefdeadbeef;
  axi_len_t len_cnt;
  axi_data_t rdata [0 : 15];
  logic [3 : 0] rdata_cnt;
  logic start_read_delay, start_write_delay;

  // AR
  assign axi.arid = ID;
  assign axi.araddr  = (state == RADDR) ? addr : 32'h0;
  assign axi.arlen = LEN - 1;
  assign axi.arsize = AXSIZE_8;
  assign axi.arburst = BURST_INCR;
  assign axi.arlock = 0;
  assign axi.arcache = 0;
  assign axi.arprot = 0;
  assign axi.arqos = 0;
  assign axi.arregion = 0;
  assign axi.aruser = 0;
  assign axi.arvalid = (state == RADDR);

  // R
  assign axi.rready = (state == RDATA);

  // AW
  assign axi.awid = ID;
  assign axi.awaddr  = (state == WADDR) ? addr : 32'h0;
  assign axi.awlen = LEN - 1;
  assign axi.awsize = AXSIZE_8;
  assign axi.awburst = BURST_INCR;
  assign axi.awlock = 0;
  assign axi.awcache = 0;
  assign axi.awprot = 0;
  assign axi.awqos = 0;
  assign axi.awregion = 0;
  assign axi.awuser = 0;
  assign axi.awvalid = (state == WADDR);

  // W
  assign axi.wid = ID;
  assign axi.wdata = (state == WDATA) ? data + len_cnt : 32'h0;
  assign axi.wstrb = 8'hff;
  assign axi.wlast = (state == WDATA && len_cnt == LEN - 1);
  assign axi.wuser = 0;
  assign axi.wvalid = (state == WDATA);

  // B
  assign axi.bready = (state == WRESP);

  always_ff @(posedge CLK) begin
    if (~RST_N) begin
      for (int i = 0; i < 16; i++) begin
        rdata[i] <= 0;
      end
      rdata_cnt <= 0;
      len_cnt <= 0;
    end else begin
      if (state == RDATA && axi.rvalid && axi.rready) begin
        rdata[addr + rdata_cnt] <= axi.rdata;
        rdata_cnt <= rdata_cnt + 1;
      end
      if (state == WDATA && axi.wvalid && axi.wready)
        len_cnt <= len_cnt + 1;
    end
  end

  always_ff @(posedge CLK) begin
    if (~RST_N) begin
      start_read_delay  <= 0;
      start_write_delay <= 0;
    end else begin
      start_read_delay  <= start_read;
      start_write_delay <= start_write;
    end
  end

  always_comb begin
    case (state)
      IDLE : next_state = (start_read_delay) ? RADDR : ((start_write_delay) ? WADDR : IDLE);
      RADDR : if (axi.arvalid && axi.arready) next_state = RDATA;
      RDATA : if (axi.rvalid  && axi.rready && axi.rlast) next_state = IDLE;
      WADDR : if (axi.awvalid && axi.awready) next_state = WDATA;
      WDATA : if (axi.wvalid  && axi.wready && axi.wlast) next_state = WRESP;
      WRESP : if (axi.bvalid  && axi.bready) next_state = IDLE;
      default : next_state = IDLE;
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

module AXI4SlaveDevice #(parameter ID = 0) (
  input CLK,
  input RST_N,
  axi_interface.slave axi
);

  typedef enum logic [2 : 0] {IDLE, RADDR, RDATA, WADDR, WDATA, WRESP} state_type;
  state_type state, next_state;

  axi_addr_t addr;
  axi_len_t len;
  axi_size_t size;
  axi_burst_t burst;
  axi_data_t data;

  axi_size_t len_cnt;
  axi_data_t buffer[0 : 15];

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      for (int i = 0; i < 16; i++) begin
        buffer[i] = 64'hdeadbeefdeadbeec + i;
      end
    end
  end

  // AR
  assign axi.arready = (state == RADDR);

  // R
  assign axi.rid = ID;
  assign axi.rdata = (state == RDATA) ? buffer[addr + len_cnt] : 0;
  assign axi.rresp = 0;
  assign axi.rlast = (state == RDATA && len_cnt == len && axi.rvalid  && axi.rready);
  assign axi.ruser = 0;
  assign axi.rvalid = (state == RDATA);

  // AW
  assign axi.awready = (state == WADDR);

  // W
  assign axi.wready = (state == WDATA);

  // B
  assign axi.bid = ID;
  assign axi.bresp = 0;
  assign axi.buser = 0;
  assign axi.bvalid = (state == WRESP);

  always_ff @(posedge CLK) begin
    if (~RST_N) begin
      addr  <= 0;
      len   <= 0;
      size  <= 0;
      burst <= 0;
    end else begin
      case (state)
        RADDR : begin
          addr  <= axi.araddr;
          len   <= axi.arlen;
          size  <= axi.arsize;
          burst <= axi.arburst;
        end
        WADDR : begin
          addr  <= axi.awaddr;
          len   <= axi.awlen;
          size  <= axi.awsize;
          burst <= axi.awburst;
        end
      endcase
    end
  end

  always_ff @(posedge CLK) begin
    if(~RST_N) begin
      len_cnt <= 0;
    end else begin
      case (state)
        RDATA : begin
          if (axi.rvalid && axi.rready) begin
            len_cnt <= len_cnt + 1;    
          end
        end
        WDATA : begin
          if (axi.wvalid && axi.wready) begin
            if (burst == BURST_INCR) buffer[addr + len_cnt] <= axi.wdata;
            else buffer[addr] <= axi.wdata;
            len_cnt <= len_cnt + 1;
          end
        end
        default : len_cnt <= 0;
      endcase
    end
  end

  always_comb begin
    case (state)
      IDLE : next_state = (axi.arvalid) ? RADDR : (axi.awvalid) ? WADDR : IDLE;
      RADDR : if (axi.arvalid && axi.arready) next_state = RDATA;
      RDATA : if (axi.rvalid  && axi.rready && len == len_cnt) next_state = IDLE;
      WADDR : if (axi.awvalid && axi.awready) next_state = WDATA;
      WDATA : if (axi.wvalid  && axi.wready && axi.wlast) next_state = WRESP;
      WRESP : if (axi.bvalid  && axi.bready ) next_state = IDLE;
      default : next_state = IDLE;
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
