`timescale 1ns / 1ps

`include "connect_parameters.v"

import axi4_pkg::*;

module NetworkIdealAXI4StreamWrapper (
    input CLK,
    input RST_N,

    axi_stream_interface.slave m0,
    axi_stream_interface.slave m1,
    axi_stream_interface.slave m2,
    axi_stream_interface.slave m3,

    axi_stream_interface.master s0,
    axi_stream_interface.master s1,
    axi_stream_interface.master s2,
    axi_stream_interface.master s3
  );

  wire [`FLIT_WIDTH - 1 : 0] send_ports_0_putFlit_flit_in;
  wire EN_send_ports_0_putFlit;

  wire [`VC_BITS : 0] send_ports_0_getCredits;
  wire EN_send_ports_0_getCredits;

  wire [`FLIT_WIDTH - 1 : 0] send_ports_1_putFlit_flit_in;
  wire EN_send_ports_1_putFlit;

  wire [`VC_BITS : 0] send_ports_1_getCredits;
  wire EN_send_ports_1_getCredits;

  wire [`FLIT_WIDTH - 1 : 0] send_ports_2_putFlit_flit_in;
  wire EN_send_ports_2_putFlit;

  wire [`VC_BITS : 0] send_ports_2_getCredits;
  wire EN_send_ports_2_getCredits;

  wire [`FLIT_WIDTH - 1 : 0] send_ports_3_putFlit_flit_in;
  wire EN_send_ports_3_putFlit;

  wire [`VC_BITS : 0] send_ports_3_getCredits;
  wire EN_send_ports_3_getCredits;

  wire EN_recv_ports_0_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_0_getFlit;

  wire [`VC_BITS : 0] recv_ports_0_putCredits_cr_in;
  wire EN_recv_ports_0_putCredits;

  wire EN_recv_ports_1_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_1_getFlit;

  wire [`VC_BITS : 0] recv_ports_1_putCredits_cr_in;
  wire EN_recv_ports_1_putCredits;

  wire EN_recv_ports_2_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_2_getFlit;

  wire [`VC_BITS : 0] recv_ports_2_putCredits_cr_in;
  wire EN_recv_ports_2_putCredits;

  wire EN_recv_ports_3_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_3_getFlit;

  wire [`VC_BITS : 0] recv_ports_3_putCredits_cr_in;
  wire EN_recv_ports_3_putCredits;

  wire [1 : 0] recv_ports_info_0_getRecvPortID;
  wire [1 : 0] recv_ports_info_1_getRecvPortID;
  wire [1 : 0] recv_ports_info_2_getRecvPortID;
  wire [1 : 0] recv_ports_info_3_getRecvPortID;

  reg [15 : 0] cycle = 0;

  localparam AXI4S_FLIT_WIDTH = AXI4S_FLIT_DATA_WIDTH + 2 + `DEST_BITS + `VC_BITS;

  wire [AXI4S_FLIT_WIDTH - 1 : 0] put_flit_0_axi4s;
  wire                            put_flit_0_axi4s_valid;
  wire                            put_flit_0_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] get_flit_0_axi4s;
  wire                            get_flit_0_axi4s_valid;
  wire                            get_flit_0_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] put_flit_1_axi4s;
  wire                            put_flit_1_axi4s_valid;
  wire                            put_flit_1_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] get_flit_1_axi4s;
  wire                            get_flit_1_axi4s_valid;
  wire                            get_flit_1_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] put_flit_2_axi4s;
  wire                            put_flit_2_axi4s_valid;
  wire                            put_flit_2_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] get_flit_2_axi4s;
  wire                            get_flit_2_axi4s_valid;
  wire                            get_flit_2_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] put_flit_3_axi4s;
  wire                            put_flit_3_axi4s_valid;
  wire                            put_flit_3_axi4s_ready;
  wire [AXI4S_FLIT_WIDTH - 1 : 0] get_flit_3_axi4s;
  wire                            get_flit_3_axi4s_valid;
  wire                            get_flit_3_axi4s_ready;

  wire [`FLIT_WIDTH - 1 : 0]  put_flit_0;
  wire                        put_flit_0_valid;
  wire                        put_flit_0_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_0;
  wire                        get_flit_0_valid;
  wire                        get_flit_0_ready;
  wire [`FLIT_WIDTH - 1 : 0]  put_flit_1;
  wire                        put_flit_1_valid;
  wire                        put_flit_1_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_1;
  wire                        get_flit_1_valid;
  wire                        get_flit_1_ready;
  wire [`FLIT_WIDTH - 1 : 0]  put_flit_2;
  wire                        put_flit_2_valid;
  wire                        put_flit_2_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_2;
  wire                        get_flit_2_valid;
  wire                        get_flit_2_ready;
  wire [`FLIT_WIDTH - 1 : 0]  put_flit_3;
  wire                        put_flit_3_valid;
  wire                        put_flit_3_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_3;
  wire                        get_flit_3_valid;
  wire                        get_flit_3_ready;

  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;

`ifdef DEBUG_PORT_FLIT
    if (EN_send_ports_0_putFlit)
      $display("%d: Port 0 send flit %x (tail=%x dst=%x vc=%x)", cycle,
        send_ports_0_putFlit_flit_in,
        send_ports_0_putFlit_flit_in[`FLIT_WIDTH - 2],
        send_ports_0_putFlit_flit_in[`FLIT_WIDTH - 3 -: `DEST_BITS],
        send_ports_0_putFlit_flit_in[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (EN_send_ports_1_putFlit)
      $display("%d: Port 1 send flit %x (tail=%x dst=%x vc=%x)", cycle,
        send_ports_1_putFlit_flit_in,
        send_ports_1_putFlit_flit_in[`FLIT_WIDTH - 2],
        send_ports_1_putFlit_flit_in[`FLIT_WIDTH - 3 -: `DEST_BITS],
        send_ports_1_putFlit_flit_in[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (EN_send_ports_2_putFlit)
      $display("%d: Port 2 send flit %x (tail=%x dst=%x vc=%x)", cycle,
        send_ports_2_putFlit_flit_in,
        send_ports_2_putFlit_flit_in[`FLIT_WIDTH - 2],
        send_ports_2_putFlit_flit_in[`FLIT_WIDTH - 3 -: `DEST_BITS],
        send_ports_2_putFlit_flit_in[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (EN_send_ports_3_putFlit)
      $display("%d: Port 3 send flit %x (tail=%x dst=%x vc=%x)", cycle,
        send_ports_3_putFlit_flit_in,
        send_ports_3_putFlit_flit_in[`FLIT_WIDTH - 2],
        send_ports_3_putFlit_flit_in[`FLIT_WIDTH - 3 -: `DEST_BITS],
        send_ports_3_putFlit_flit_in[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (recv_ports_0_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 0 recv flit %x (tail=%x dst=%x vc=%x)", cycle,
        recv_ports_0_getFlit,
        recv_ports_0_getFlit[`FLIT_WIDTH - 2],
        recv_ports_0_getFlit[`FLIT_WIDTH - 3 -: `DEST_BITS],
        recv_ports_0_getFlit[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (recv_ports_1_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 1 recv flit %x (tail=%x dst=%x vc=%x)", cycle,
        recv_ports_1_getFlit,
        recv_ports_1_getFlit[`FLIT_WIDTH - 2],
        recv_ports_1_getFlit[`FLIT_WIDTH - 3 -: `DEST_BITS],
        recv_ports_1_getFlit[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (recv_ports_2_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 2 recv flit %x (tail=%x dst=%x vc=%x)", cycle,
        recv_ports_2_getFlit,
        recv_ports_2_getFlit[`FLIT_WIDTH - 2],
        recv_ports_2_getFlit[`FLIT_WIDTH - 3 -: `DEST_BITS],
        recv_ports_2_getFlit[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
    if (recv_ports_3_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 3 recv flit %x (tail=%x dst=%x vc=%x)", cycle,
        recv_ports_3_getFlit,
        recv_ports_3_getFlit[`FLIT_WIDTH - 2],
        recv_ports_3_getFlit[`FLIT_WIDTH - 3 -: `DEST_BITS],
        recv_ports_3_getFlit[`FLIT_WIDTH - 3 - `DEST_BITS -: `VC_BITS]
      );
`endif

`ifdef DEBUG_PORT_CREDIT
    if (send_ports_0_getCredits[`VC_BITS])
      $display("%d: Port 0 get a credit (vc=%x)", cycle,
        send_ports_0_getCredits[`VC_BITS - 1 : 0]
      );
    if (send_ports_1_getCredits[`VC_BITS])
      $display("%d: Port 1 get a credit (vc=%x)", cycle,
        send_ports_1_getCredits[`VC_BITS - 1 : 0]
      );
    if (send_ports_2_getCredits[`VC_BITS])
      $display("%d: Port 2 get a credit (vc=%x)", cycle,
        send_ports_2_getCredits[`VC_BITS - 1 : 0]
      );
    if (send_ports_3_getCredits[`VC_BITS])
      $display("%d: Port 3 get a credit (vc=%x)", cycle,
        send_ports_3_getCredits[`VC_BITS - 1 : 0]
      );
    if (EN_recv_ports_0_putCredits)
      $display("%d: Port 0 put a credit (vc=%x)", cycle,
        recv_ports_0_putCredits_cr_in[`VC_BITS - 1 : 0]
      );
    if (EN_recv_ports_1_putCredits)
      $display("%d: Port 1 put a credit (vc=%x)", cycle,
        recv_ports_1_putCredits_cr_in[`VC_BITS - 1 : 0]
      );
    if (EN_recv_ports_2_putCredits)
      $display("%d: Port 2 put a credit (vc=%x)", cycle,
        recv_ports_2_putCredits_cr_in[`VC_BITS - 1 : 0]
      );
    if (EN_recv_ports_3_putCredits)
      $display("%d: Port 3 put a credit (vc=%x)", cycle,
        recv_ports_3_putCredits_cr_in[`VC_BITS - 1 : 0]
      );
`endif

`ifdef DEBUG_DEVICE_FLIT
    if (put_flit_0_axi4s_valid && put_flit_0_axi4s_ready)
      $display("%d: Device 0 send flit %x", cycle, put_flit_0_axi4s);
    if (put_flit_1_axi4s_valid && put_flit_1_axi4s_ready)
      $display("%d: Device 1 send flit %x", cycle, put_flit_1_axi4s);
    if (put_flit_2_axi4s_valid && put_flit_2_axi4s_ready)
      $display("%d: Device 2 send flit %x", cycle, put_flit_2_axi4s);
    if (put_flit_3_axi4s_valid && put_flit_3_axi4s_ready)
      $display("%d: Device 3 send flit %x", cycle, put_flit_3_axi4s);

    if (get_flit_0_axi4s_valid && get_flit_0_axi4s_ready)
      $display("%d: Device 0 recv flit %x", cycle, get_flit_0_axi4s);
    if (get_flit_1_axi4s_valid && get_flit_1_axi4s_ready)
      $display("%d: Device 1 recv flit %x", cycle, get_flit_1_axi4s);
    if (get_flit_2_axi4s_valid && get_flit_2_axi4s_ready)
      $display("%d: Device 2 recv flit %x", cycle, get_flit_2_axi4s);
    if (get_flit_3_axi4s_valid && get_flit_3_axi4s_ready)
      $display("%d: Device 3 recv flit %x", cycle, get_flit_3_axi4s);
`endif

  end

  InPortFIFO b0m_in_fifo (
    .CLK,
    .RST_N,
    .put_flit                   (put_flit_0                   ),
    .put_flit_valid             (put_flit_0_valid             ),
    .put_flit_ready             (put_flit_0_ready             ),
    .send_ports_putFlit_flit_in (send_ports_0_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_0_putFlit      ),
    .send_ports_getCredits      (send_ports_0_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_0_getCredits   )
  );

  defparam b0m_in_fifo.device_type = "MASTER";

  OutPortFIFO b0s_out_fifo (
    .CLK,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_0_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_0_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_0_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_0_putCredits   ),
    .get_flit                   (get_flit_0                   ),
    .get_flit_valid             (get_flit_0_valid             ),
    .get_flit_ready             (get_flit_0_ready             )
  );

  defparam b0s_out_fifo.device_type = "SLAVE";

  AXI4StreamMasterBridge b0m (
    .CLK,
    .RST_N,
    .axis           (m0                     ),
    .put_flit       (put_flit_0_axi4s       ),
    .put_flit_valid (put_flit_0_axi4s_valid ),
    .put_flit_ready (put_flit_0_axi4s_ready )
  );

  FlitSerializer b0m_serializer (
    .CLK,
    .RST_N,
    .in_flit        (put_flit_0_axi4s       ),
    .in_flit_valid  (put_flit_0_axi4s_valid ),
    .in_flit_ready  (put_flit_0_axi4s_ready ),
    .out_flit       (put_flit_0             ),
    .out_flit_valid (put_flit_0_valid       ),
    .out_flit_ready (put_flit_0_ready       )
  );

  defparam b0m_serializer.DEBUG_ID = 0;
  defparam b0m_serializer.IN_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  AXI4StreamSlaveBridge b0s (
    .CLK,
    .RST_N,
    .axis           (s0                     ),
    .get_flit       (get_flit_0_axi4s       ),
    .get_flit_valid (get_flit_0_axi4s_valid ),
    .get_flit_ready (get_flit_0_axi4s_ready )
  );

  FlitDeserializer b0s_deserializer (
    .CLK,
    .RST_N,
    .in_flit        (get_flit_0             ),
    .in_flit_valid  (get_flit_0_valid       ),
    .in_flit_ready  (get_flit_0_ready       ),
    .out_flit       (get_flit_0_axi4s       ),
    .out_flit_valid (get_flit_0_axi4s_valid ),
    .out_flit_ready (get_flit_0_axi4s_ready )
  );

  defparam b0s_deserializer.DEBUG_ID = 0;
  defparam b0s_deserializer.OUT_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  InPortFIFO b1m_in_fifo (
    .CLK,
    .RST_N,
    .put_flit                   (put_flit_1                   ),
    .put_flit_valid             (put_flit_1_valid             ),
    .put_flit_ready             (put_flit_1_ready             ),
    .send_ports_putFlit_flit_in (send_ports_1_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_1_putFlit      ),
    .send_ports_getCredits      (send_ports_1_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_1_getCredits   )
  );

  defparam b1m_in_fifo.device_type = "MASTER";

  OutPortFIFO b1s_out_fifo (
    .CLK,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_1_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_1_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_1_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_1_putCredits   ),
    .get_flit                   (get_flit_1                   ),
    .get_flit_valid             (get_flit_1_valid             ),
    .get_flit_ready             (get_flit_1_ready             )
  );

  defparam b1s_out_fifo.device_type = "SLAVE";

  AXI4StreamMasterBridge b1m (
    .CLK,
    .RST_N,
    .axis           (m1                     ),
    .put_flit       (put_flit_1_axi4s       ),
    .put_flit_valid (put_flit_1_axi4s_valid ),
    .put_flit_ready (put_flit_1_axi4s_ready )
  );

  FlitSerializer b1m_serializer (
    .CLK,
    .RST_N,
    .in_flit        (put_flit_1_axi4s       ),
    .in_flit_valid  (put_flit_1_axi4s_valid ),
    .in_flit_ready  (put_flit_1_axi4s_ready ),
    .out_flit       (put_flit_1             ),
    .out_flit_valid (put_flit_1_valid       ),
    .out_flit_ready (put_flit_1_ready       )
  );

  defparam b1m_serializer.DEBUG_ID = 1;
  defparam b1m_serializer.IN_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  AXI4StreamSlaveBridge b1s (
    .CLK,
    .RST_N,
    .axis           (s1                     ),
    .get_flit       (get_flit_1_axi4s       ),
    .get_flit_valid (get_flit_1_axi4s_valid ),
    .get_flit_ready (get_flit_1_axi4s_ready )
  );

  FlitDeserializer b1s_deserializer (
    .CLK,
    .RST_N,
    .in_flit        (get_flit_1             ),
    .in_flit_valid  (get_flit_1_valid       ),
    .in_flit_ready  (get_flit_1_ready       ),
    .out_flit       (get_flit_1_axi4s       ),
    .out_flit_valid (get_flit_1_axi4s_valid ),
    .out_flit_ready (get_flit_1_axi4s_ready )
  );

  defparam b1s_deserializer.DEBUG_ID = 1;
  defparam b1s_deserializer.OUT_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  InPortFIFO b2m_in_fifo (
    .CLK,
    .RST_N,
    .put_flit                   (put_flit_2                   ),
    .put_flit_valid             (put_flit_2_valid             ),
    .put_flit_ready             (put_flit_2_ready             ),
    .send_ports_putFlit_flit_in (send_ports_2_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_2_putFlit      ),
    .send_ports_getCredits      (send_ports_2_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_2_getCredits   )
  );

  defparam b2m_in_fifo.device_type = "MASTER";

  OutPortFIFO b2s_out_fifo (
    .CLK,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_2_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_2_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_2_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_2_putCredits   ),
    .get_flit                   (get_flit_2                   ),
    .get_flit_valid             (get_flit_2_valid             ),
    .get_flit_ready             (get_flit_2_ready             )
  );

  defparam b2s_out_fifo.device_type = "SLAVE";

  
  AXI4StreamMasterBridge b2m (
    .CLK,
    .RST_N,
    .axis           (m2                     ),
    .put_flit       (put_flit_2_axi4s       ),
    .put_flit_valid (put_flit_2_axi4s_valid ),
    .put_flit_ready (put_flit_2_axi4s_ready )
  );

  FlitSerializer b2m_serializer (
    .CLK,
    .RST_N,
    .in_flit        (put_flit_2_axi4s       ),
    .in_flit_valid  (put_flit_2_axi4s_valid ),
    .in_flit_ready  (put_flit_2_axi4s_ready ),
    .out_flit       (put_flit_2             ),
    .out_flit_valid (put_flit_2_valid       ),
    .out_flit_ready (put_flit_2_ready       )
  );

  defparam b2m_serializer.DEBUG_ID = 2;
  defparam b2m_serializer.IN_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  AXI4StreamSlaveBridge b2s (
    .CLK,
    .RST_N,
    .axis           (s2                     ),
    .get_flit       (get_flit_2_axi4s       ),
    .get_flit_valid (get_flit_2_axi4s_valid ),
    .get_flit_ready (get_flit_2_axi4s_ready )
  );

  FlitDeserializer b2s_deserializer (
    .CLK,
    .RST_N,
    .in_flit        (get_flit_2             ),
    .in_flit_valid  (get_flit_2_valid       ),
    .in_flit_ready  (get_flit_2_ready       ),
    .out_flit       (get_flit_2_axi4s       ),
    .out_flit_valid (get_flit_2_axi4s_valid ),
    .out_flit_ready (get_flit_2_axi4s_ready )
  );

  defparam b2s_deserializer.DEBUG_ID = 2;
  defparam b2s_deserializer.OUT_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  InPortFIFO b3m_in_fifo (
    .CLK,
    .RST_N,
    .put_flit                   (put_flit_3                   ),
    .put_flit_valid             (put_flit_3_valid             ),
    .put_flit_ready             (put_flit_3_ready             ),
    .send_ports_putFlit_flit_in (send_ports_3_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_3_putFlit      ),
    .send_ports_getCredits      (send_ports_3_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_3_getCredits   )
  );

  defparam b3m_in_fifo.device_type = "MASTER";

  OutPortFIFO b3s_out_fifo (
    .CLK,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_3_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_3_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_3_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_3_putCredits   ),
    .get_flit                   (get_flit_3                   ),
    .get_flit_valid             (get_flit_3_valid             ),
    .get_flit_ready             (get_flit_3_ready             )
  );

  defparam b3s_out_fifo.device_type = "SLAVE";

  AXI4StreamMasterBridge b3m (
    .CLK,
    .RST_N,
    .axis           (m3                     ),
    .put_flit       (put_flit_3_axi4s       ),
    .put_flit_valid (put_flit_3_axi4s_valid ),
    .put_flit_ready (put_flit_3_axi4s_ready )
  );

  FlitSerializer b3m_serializer (
    .CLK,
    .RST_N,
    .in_flit        (put_flit_3_axi4s       ),
    .in_flit_valid  (put_flit_3_axi4s_valid ),
    .in_flit_ready  (put_flit_3_axi4s_ready ),
    .out_flit       (put_flit_3             ),
    .out_flit_valid (put_flit_3_valid       ),
    .out_flit_ready (put_flit_3_ready       )
  );

  defparam b3m_serializer.DEBUG_ID = 3;
  defparam b3m_serializer.IN_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  AXI4StreamSlaveBridge b3s (
    .CLK,
    .RST_N,
    .axis           (s3                     ),
    .get_flit       (get_flit_3_axi4s       ),
    .get_flit_valid (get_flit_3_axi4s_valid ),
    .get_flit_ready (get_flit_3_axi4s_ready )
  );

  FlitDeserializer b3s_deserializer (
    .CLK,
    .RST_N,
    .in_flit        (get_flit_3             ),
    .in_flit_valid  (get_flit_3_valid       ),
    .in_flit_ready  (get_flit_3_ready       ),
    .out_flit       (get_flit_3_axi4s       ),
    .out_flit_valid (get_flit_3_axi4s_valid ),
    .out_flit_ready (get_flit_3_axi4s_ready )
  );

  defparam b3s_deserializer.DEBUG_ID = 3;
  defparam b3s_deserializer.OUT_FLIT_WIDTH = AXI4S_FLIT_WIDTH;

  mkNetwork network (
    .CLK,
    .RST_N,

    .send_ports_0_putFlit_flit_in,
    .EN_send_ports_0_putFlit,

    .EN_send_ports_0_getCredits,
    .send_ports_0_getCredits,

    .send_ports_1_putFlit_flit_in,
    .EN_send_ports_1_putFlit,

    .EN_send_ports_1_getCredits,
    .send_ports_1_getCredits,

    .send_ports_2_putFlit_flit_in,
    .EN_send_ports_2_putFlit,

    .EN_send_ports_2_getCredits,
    .send_ports_2_getCredits,

    .send_ports_3_putFlit_flit_in,
    .EN_send_ports_3_putFlit,

    .EN_send_ports_3_getCredits,
    .send_ports_3_getCredits,

    .EN_recv_ports_0_getFlit,
    .recv_ports_0_getFlit,

    .recv_ports_0_putCredits_cr_in,
    .EN_recv_ports_0_putCredits,

    .EN_recv_ports_1_getFlit,
    .recv_ports_1_getFlit,

    .recv_ports_1_putCredits_cr_in,
    .EN_recv_ports_1_putCredits,

    .EN_recv_ports_2_getFlit,
    .recv_ports_2_getFlit,

    .recv_ports_2_putCredits_cr_in,
    .EN_recv_ports_2_putCredits,

    .EN_recv_ports_3_getFlit,
    .recv_ports_3_getFlit,

    .recv_ports_3_putCredits_cr_in,
    .EN_recv_ports_3_putCredits,

    .recv_ports_info_0_getRecvPortID,
    .recv_ports_info_1_getRecvPortID,
    .recv_ports_info_2_getRecvPortID,
    .recv_ports_info_3_getRecvPortID
  );

endmodule
