// Modified from https://github.com/bluespec/Piccolo/blob/master/src_Testbench/Fabrics/AXI4/AXI4_Types.bsv

// AxLEN
typedef Bit #(8)  AXI4_Len;

// AxSIZE
typedef Bit #(3)  AXI4_Size;

AXI4_Size  axsize_1   = 3'b000;
AXI4_Size  axsize_2   = 3'b001;
AXI4_Size  axsize_4   = 3'b010;
AXI4_Size  axsize_8   = 3'b011;
AXI4_Size  axsize_16  = 3'b100;
AXI4_Size  axsize_32  = 3'b101;
AXI4_Size  axsize_64  = 3'b110;
AXI4_Size  axsize_128 = 3'b111;

// AxBURST
typedef Bit #(2)  AXI4_Burst;

AXI4_Burst  axburst_fixed = 2'b00;
AXI4_Burst  axburst_incr  = 2'b01;
AXI4_Burst  axburst_wrap  = 2'b10;

// AxLOCK
typedef Bit #(1)  AXI4_Lock;

AXI4_Lock  axlock_normal    = 1'b0;
AXI4_Lock  axlock_exclusive = 1'b1;

// AxCACHE
typedef Bit #(4)  AXI4_Cache;

AXI4_Cache  arcache_dev_nonbuf           = 4'b0000;
AXI4_Cache  arcache_dev_buf              = 4'b0001;

AXI4_Cache  arcache_norm_noncache_nonbuf = 4'b0010;
AXI4_Cache  arcache_norm_noncache_buf    = 4'b0011;

AXI4_Cache  arcache_wthru_no_alloc       = 4'b1010;
AXI4_Cache  arcache_wthru_r_alloc        = 4'b1110;
AXI4_Cache  arcache_wthru_w_alloc        = 4'b1010;
AXI4_Cache  arcache_wthru_r_w_alloc      = 4'b1110;

AXI4_Cache  arcache_wback_no_alloc       = 4'b1011;
AXI4_Cache  arcache_wback_r_alloc        = 4'b1111;
AXI4_Cache  arcache_wback_w_alloc        = 4'b1011;
AXI4_Cache  arcache_wback_r_w_alloc      = 4'b1111;

AXI4_Cache  awcache_dev_nonbuf           = 4'b0000;
AXI4_Cache  awcache_dev_buf              = 4'b0001;

AXI4_Cache  awcache_norm_noncache_nonbuf = 4'b0010;
AXI4_Cache  awcache_norm_noncache_buf    = 4'b0011;

AXI4_Cache  awcache_wthru_no_alloc       = 4'b0110;
AXI4_Cache  awcache_wthru_r_alloc        = 4'b0110;
AXI4_Cache  awcache_wthru_w_alloc        = 4'b1110;
AXI4_Cache  awcache_wthru_r_w_alloc      = 4'b1110;

AXI4_Cache  awcache_wback_no_alloc       = 4'b0111;
AXI4_Cache  awcache_wback_r_alloc        = 4'b0111;
AXI4_Cache  awcache_wback_w_alloc        = 4'b1111;
AXI4_Cache  awcache_wback_r_w_alloc      = 4'b1111;

// AxPROT
typedef Bit #(3)  AXI4_Prot;

Bit #(1)    axprot_0_unpriv     = 1'b0;
Bit #(1)    axprot_0_priv       = 1'b1;
Bit #(1)    axprot_1_secure     = 1'b0;
Bit #(1)    axprot_1_non_secure = 1'b1;
Bit #(1)    axprot_2_data       = 1'b0;
Bit #(1)    axprot_2_instr      = 1'b1;

// AxQOS
typedef Bit #(4)  AXI4_QoS;

// AxREGION
typedef Bit #(4)  AXI4_Region;

// xRESP
typedef Bit #(2)  AXI4_Resp;

AXI4_Resp  axi4_resp_okay   = 2'b00;
AXI4_Resp  axi4_resp_exokay = 2'b01;
AXI4_Resp  axi4_resp_slverr = 2'b10;
AXI4_Resp  axi4_resp_decerr = 2'b11;

// Check address-alignment
function Bool fn_addr_is_aligned (Bit #(wd_addr) addr, AXI4_Size size);
  return ((size == axsize_1)
          || ((size == axsize_2)   && (addr [0]   == 1'b0))
          || ((size == axsize_4)   && (addr [1:0] == 2'b0))
          || ((size == axsize_8)   && (addr [2:0] == 3'b0))
          || ((size == axsize_16)  && (addr [3:0] == 4'b0))
          || ((size == axsize_32)  && (addr [4:0] == 5'b0))
          || ((size == axsize_64)  && (addr [5:0] == 6'b0))
          || ((size == axsize_128) && (addr [6:0] == 7'b0)));
endfunction

// AXI4 master device interface
interface AXI4MasterInterface #(numeric type wd_id,
                                numeric type wd_addr,
                                numeric type wd_data,
                                numeric type wd_user);

  // Write address channel
  (* always_ready, result="awvalid" *)   method Bool           m_awvalid;     // out
  (* always_ready, result="awid" *)      method Bit #(wd_id)   m_awid;        // out
  (* always_ready, result="awaddr" *)    method Bit #(wd_addr) m_awaddr;      // out
  (* always_ready, result="awlen" *)     method Bit #(8)       m_awlen;       // out
  (* always_ready, result="awsize" *)    method AXI4_Size      m_awsize;      // out
  (* always_ready, result="awburst" *)   method Bit #(2)       m_awburst;     // out
  (* always_ready, result="awlock" *)    method Bit #(1)       m_awlock;      // out
  (* always_ready, result="awcache" *)   method Bit #(4)       m_awcache;     // out
  (* always_ready, result="awprot" *)    method Bit #(3)       m_awprot;      // out
  (* always_ready, result="awqos" *)     method Bit #(4)       m_awqos;       // out
  (* always_ready, result="awregion" *)  method Bit #(4)       m_awregion;    // out
  (* always_ready, result="awuser" *)    method Bit #(wd_user) m_awuser;      // out

  (* always_ready, always_enabled, prefix="" *)
  method Action m_awready ((* port="awready" *) Bool awready);                // in

  // Write data channel
  (* always_ready, result="wvalid" *)  method Bool                      m_wvalid;    // out
  (* always_ready, result="wdata" *)   method Bit #(wd_data)            m_wdata;     // out
  (* always_ready, result="wstrb" *)   method Bit #(TDiv #(wd_data, 8)) m_wstrb;     // out
  (* always_ready, result="wlast" *)   method Bool                      m_wlast;     // out
  (* always_ready, result="wuser" *)   method Bit #(wd_user)            m_wuser;     // out

  (* always_ready, always_enabled, prefix = "" *)
  method Action m_wready ((* port="wready" *)  Bool wready);                         // in

  // Write response channel
  (* always_ready, always_enabled, prefix = "" *)
  method Action m_bvalid ((* port="bvalid" *)  Bool           bvalid,    // in
                          (* port="bid"    *)  Bit #(wd_id)   bid,       // in
                          (* port="bresp"  *)  Bit #(2)       bresp,     // in
                          (* port="buser"  *)  Bit #(wd_user) buser);    // in

  (* always_ready, prefix = "", result="bready" *)
  method Bool m_bready;                                                  // out

  // Read address channel
  (* always_ready, result="arvalid" *)   method Bool            m_arvalid;     // out
  (* always_ready, result="arid" *)      method Bit #(wd_id)    m_arid;        // out
  (* always_ready, result="araddr" *)    method Bit #(wd_addr)  m_araddr;      // out
  (* always_ready, result="arlen" *)     method Bit #(8)        m_arlen;       // out
  (* always_ready, result="arsize" *)    method AXI4_Size       m_arsize;      // out
  (* always_ready, result="arburst" *)   method Bit #(2)        m_arburst;     // out
  (* always_ready, result="arlock" *)    method Bit #(1)        m_arlock;      // out
  (* always_ready, result="arcache" *)   method Bit #(4)        m_arcache;     // out
  (* always_ready, result="arprot" *)    method Bit #(3)        m_arprot;      // out
  (* always_ready, result="arqos" *)     method Bit #(4)        m_arqos;       // out
  (* always_ready, result="arregion" *)  method Bit #(4)        m_arregion;    // out
  (* always_ready, result="aruser" *)    method Bit #(wd_user)  m_aruser;      // out

  (* always_ready, always_enabled, prefix="" *)
  method Action m_arready ((* port="arready" *) Bool arready);    // in

  // Read data channel
  (* always_ready, always_enabled, prefix = "" *)
  method Action m_rvalid ((* port="rvalid" *)  Bool           rvalid,    // in
                          (* port="rid"    *)  Bit #(wd_id)   rid,       // in
                          (* port="rdata"  *)  Bit #(wd_data) rdata,     // in
                          (* port="rresp"  *)  Bit #(2)       rresp,     // in
                          (* port="rlast"  *)  Bool           rlast,     // in
                          (* port="ruser"  *)  Bit #(wd_user) ruser);    // in

  (* always_ready, result="rready" *)
  method Bool m_rready;                                                  // out

endinterface: AXI4MasterInterface

// AXI4 slave device interface
interface AXI4SlaveInterface #(numeric type wd_id,
                               numeric type wd_addr,
                               numeric type wd_data,
                               numeric type wd_user);

  // Write address channel
  (* always_ready, always_enabled, prefix = "" *)
  method Action m_awvalid ((* port="awvalid" *)  Bool            awvalid,     // in
                          (* port="awid" *)      Bit #(wd_id)    awid,        // in
                          (* port="awaddr" *)    Bit #(wd_addr)  awaddr,      // in
                          (* port="awlen" *)     Bit #(8)        awlen,       // in
                          (* port="awsize" *)    AXI4_Size       awsize,      // in
                          (* port="awburst" *)   Bit #(2)        awburst,     // in
                          (* port="awlock" *)    Bit #(1)        awlock,      // in
                          (* port="awcache" *)   Bit #(4)        awcache,     // in
                          (* port="awprot" *)    Bit #(3)        awprot,      // in
                          (* port="awqos" *)     Bit #(4)        awqos,       // in
                          (* port="awregion" *)  Bit #(4)        awregion,    // in
                          (* port="awuser" *)    Bit #(wd_user)  awuser);     // in

  (* always_ready, result="awready" *)
  method Bool m_awready;                                                      // out

  // Write data channel
  (* always_ready, always_enabled, prefix = "" *)
  method Action m_wvalid ((* port="wvalid" *) Bool                      wvalid,    // in
                          (* port="wdata" *)  Bit #(wd_data)            wdata,     // in
                          (* port="wstrb" *)  Bit #(TDiv #(wd_data,8))  wstrb,     // in
                          (* port="wlast" *)  Bool                      wlast,     // in
                          (* port="wuser" *)  Bit #(wd_user)            wuser);    // in

  (* always_ready, result="wready" *)
  method Bool m_wready;                                                            // out

  // Write response channel
  (* always_ready, result="bvalid" *)  method Bool            m_bvalid;    // out
  (* always_ready, result="bid" *)     method Bit #(wd_id)    m_bid;       // out
  (* always_ready, result="bresp" *)   method Bit #(2)        m_bresp;     // out
  (* always_ready, result="buser" *)   method Bit #(wd_user)  m_buser;     // out

  (* always_ready, always_enabled, prefix="" *)
  method Action m_bready  ((* port="bready" *)   Bool bready);             // in

  // Read address channel
  (* always_ready, always_enabled, prefix = "" *)
  method Action m_arvalid ((* port="arvalid" *)  Bool            arvalid,     // in
                          (* port="arid" *)      Bit #(wd_id)    arid,        // in
                          (* port="araddr" *)    Bit #(wd_addr)  araddr,      // in
                          (* port="arlen" *)     Bit #(8)        arlen,       // in
                          (* port="arsize" *)    AXI4_Size       arsize,      // in
                          (* port="arburst" *)   Bit #(2)        arburst,     // in
                          (* port="arlock" *)    Bit #(1)        arlock,      // in
                          (* port="arcache" *)   Bit #(4)        arcache,     // in
                          (* port="arprot" *)    Bit #(3)        arprot,      // in
                          (* port="arqos" *)     Bit #(4)        arqos,       // in
                          (* port="arregion" *)  Bit #(4)        arregion,    // in
                          (* port="aruser" *)    Bit #(wd_user)  aruser);     // in

  (* always_ready, result="arready" *)
  method Bool m_arready;                                                      // out

  // Read data channel
  (* always_ready, result="rvalid" *)  method Bool            m_rvalid;    // out
  (* always_ready, result="rid" *)     method Bit #(wd_id)    m_rid;       // out
  (* always_ready, result="rdata" *)   method Bit #(wd_data)  m_rdata;     // out
  (* always_ready, result="rresp" *)   method Bit #(2)        m_rresp;     // out
  (* always_ready, result="rlast" *)   method Bool            m_rlast;     // out
  (* always_ready, result="ruser" *)   method Bit #(wd_user)  m_ruser;     // out

  (* always_ready, always_enabled, prefix="" *)
  method Action m_rready  ((* port="rready" *)   Bool rready);             // in

endinterface: AXI4SlaveInterface
