import axi4_pkg::*;

interface axi_interface;

  // Write address channel
  axi_id_t     awid;
  axi_addr_t   awaddr;
  axi_len_t    awlen;
  axi_size_t   awsize;
  axi_burst_t  awburst;
  logic        awlock;
  axi_cache_t  awcache;
  axi_prot_t   awprot;
  axi_qos_t    awqos;
  axi_region_t awregion;
  axi_user_t   awuser;
  logic        awvalid;
  logic        awready;

  // Write data channel
  axi_id_t     wid;
  axi_data_t   wdata;
  axi_strb_t   wstrb;
  logic        wlast;
  axi_user_t   wuser;
  logic        wvalid;
  logic        wready;

  // Write response channel
  axi_id_t     bid;
  axi_resp_t   bresp;
  axi_user_t   buser;
  logic        bvalid;
  logic        bready;

  // Read address channel
  axi_id_t     arid;
  axi_addr_t   araddr;
  axi_len_t    arlen;
  axi_size_t   arsize;
  axi_burst_t  arburst;
  logic        arlock;
  axi_cache_t  arcache;
  axi_prot_t   arprot;
  axi_qos_t    arqos;
  axi_region_t arregion;
  axi_user_t   aruser;
  logic        arvalid;
  logic        arready;

  // Read data channel
  axi_id_t     rid;
  axi_data_t   rdata;
  axi_resp_t   rresp;
  logic        rlast;
  axi_user_t   ruser;
  logic        rvalid;
  logic        rready;

  modport master (
    output awid,
    output awaddr,
    output awlen,
    output awsize,
    output awburst,
    output awlock,
    output awcache,
    output awprot,
    output awqos,
    output awregion,
    output awuser,
    output awvalid,
    input  awready,

    output wid,
    output wdata,
    output wstrb,
    output wlast,
    output wuser,
    output wvalid,
    input  wready,

    input  bid,
    input  bresp,
    input  buser,
    input  bvalid,
    output bready,

    output arid,
    output araddr,
    output arlen,
    output arsize,
    output arburst,
    output arlock,
    output arcache,
    output arprot,
    output arqos,
    output arregion,
    output aruser,
    output arvalid,
    input  arready,

    input  rid,
    input  rdata,
    input  rresp,
    input  rlast,
    input  ruser,
    input  rvalid,
    output rready
  );

  modport slave (
    input  awid,
    input  awaddr,
    input  awlen,
    input  awsize,
    input  awburst,
    input  awlock,
    input  awcache,
    input  awprot,
    input  awqos,
    input  awregion,
    input  awuser,
    input  awvalid,
    output awready,

    input  wid,
    input  wdata,
    input  wstrb,
    input  wlast,
    input  wuser,
    input  wvalid,
    output wready,

    output bid,
    output bresp,
    output buser,
    output bvalid,
    input  bready,

    input  arid,
    input  araddr,
    input  arlen,
    input  arsize,
    input  arburst,
    input  arlock,
    input  arcache,
    input  arprot,
    input  arqos,
    input  arregion,
    input  aruser,
    input  arvalid,
    output arready,

    output rid,
    output rdata,
    output rresp,
    output rlast,
    output ruser,
    output rvalid,
    input  rready
  );

endinterface
