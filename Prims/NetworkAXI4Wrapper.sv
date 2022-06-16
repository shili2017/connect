`timescale 1ns / 1ps

`include "connect_parameters.v"

import axi4_pkg::*;

module NetworkIdealAXI4Wrapper (
    input CLK_NOC,
    input CLK_FPGA,
    input RST_N,

    axi_interface.slave m0,
    axi_interface.slave m1,

    axi_interface.master s0,
    axi_interface.master s1
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

  localparam AXI4_FLIT_WIDTH = AXI4_FLIT_DATA_WIDTH + 2 + `DEST_BITS + `VC_BITS;

  wire [AXI4_FLIT_WIDTH - 1 : 0] put_flit_0_axi4;
  wire                           put_flit_0_axi4_valid;
  wire                           put_flit_0_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] get_flit_0_axi4;
  wire                           get_flit_0_axi4_valid;
  wire                           get_flit_0_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] put_flit_1_axi4;
  wire                           put_flit_1_axi4_valid;
  wire                           put_flit_1_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] get_flit_1_axi4;
  wire                           get_flit_1_axi4_valid;
  wire                           get_flit_1_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] put_flit_2_axi4;
  wire                           put_flit_2_axi4_valid;
  wire                           put_flit_2_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] get_flit_2_axi4;
  wire                           get_flit_2_axi4_valid;
  wire                           get_flit_2_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] put_flit_3_axi4;
  wire                           put_flit_3_axi4_valid;
  wire                           put_flit_3_axi4_ready;
  wire [AXI4_FLIT_WIDTH - 1 : 0] get_flit_3_axi4;
  wire                           get_flit_3_axi4_valid;
  wire                           get_flit_3_axi4_ready;

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

always_ff @(posedge CLK_NOC) begin
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
    if (put_flit_0_axi4_valid && put_flit_0_axi4_ready)
      $display("%d: Device 0 send flit %x", cycle, put_flit_0_axi4);
    if (put_flit_1_axi4_valid && put_flit_1_axi4_ready)
      $display("%d: Device 1 send flit %x", cycle, put_flit_1_axi4);
    if (put_flit_2_axi4_valid && put_flit_2_axi4_ready)
      $display("%d: Device 2 send flit %x", cycle, put_flit_2_axi4);
    if (put_flit_3_axi4_valid && put_flit_3_axi4_ready)
      $display("%d: Device 3 send flit %x", cycle, put_flit_3_axi4);

    if (get_flit_0_axi4_valid && get_flit_0_axi4_ready)
      $display("%d: Device 0 recv flit %x", cycle, get_flit_0_axi4);
    if (get_flit_1_axi4_valid && get_flit_1_axi4_ready)
      $display("%d: Device 1 recv flit %x", cycle, get_flit_1_axi4);
    if (get_flit_2_axi4_valid && get_flit_2_axi4_ready)
      $display("%d: Device 2 recv flit %x", cycle, get_flit_2_axi4);
    if (get_flit_3_axi4_valid && get_flit_3_axi4_ready)
      $display("%d: Device 3 recv flit %x", cycle, get_flit_3_axi4);
`endif

  end

  InPortFIFO b0_in_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .put_flit                   (put_flit_0                   ),
    .put_flit_valid             (put_flit_0_valid             ),
    .put_flit_ready             (put_flit_0_ready             ),
    .send_ports_putFlit_flit_in (send_ports_0_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_0_putFlit      ),
    .send_ports_getCredits      (send_ports_0_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_0_getCredits   ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b0_in_fifo.device_type = "MASTER";

  OutPortFIFO b0_out_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_0_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_0_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_0_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_0_putCredits   ),
    .get_flit                   (get_flit_0                   ),
    .get_flit_valid             (get_flit_0_valid             ),
    .get_flit_ready             (get_flit_0_ready             ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b0_out_fifo.device_type = "MASTER";

  FlitSerializer b0_serializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (put_flit_0_axi4        ),
    .in_flit_valid  (put_flit_0_axi4_valid  ),
    .in_flit_ready  (put_flit_0_axi4_ready  ),
    .out_flit       (put_flit_0             ),
    .out_flit_valid (put_flit_0_valid       ),
    .out_flit_ready (put_flit_0_ready       )
  );

  defparam b0_serializer.DEBUG_ID = 0;
  defparam b0_serializer.IN_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  FlitDeserializer b0_deserializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (get_flit_0             ),
    .in_flit_valid  (get_flit_0_valid       ),
    .in_flit_ready  (get_flit_0_ready       ),
    .out_flit       (get_flit_0_axi4        ),
    .out_flit_valid (get_flit_0_axi4_valid  ),
    .out_flit_ready (get_flit_0_axi4_ready  )
  );

  defparam b0_deserializer.DEBUG_ID = 0;
  defparam b0_deserializer.OUT_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  AXI4MasterBridge b0 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi            (m0                    ),
    .put_flit       (put_flit_0_axi4       ),
    .put_flit_valid (put_flit_0_axi4_valid ),
    .put_flit_ready (put_flit_0_axi4_ready ),
    .get_flit       (get_flit_0_axi4       ),
    .get_flit_valid (get_flit_0_axi4_valid ),
    .get_flit_ready (get_flit_0_axi4_ready )
  );

  InPortFIFO b1_in_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .put_flit                   (put_flit_1                   ),
    .put_flit_valid             (put_flit_1_valid             ),
    .put_flit_ready             (put_flit_1_ready             ),
    .send_ports_putFlit_flit_in (send_ports_1_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_1_putFlit      ),
    .send_ports_getCredits      (send_ports_1_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_1_getCredits   ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b1_in_fifo.device_type = "MASTER";

  OutPortFIFO b1_out_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_1_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_1_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_1_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_1_putCredits   ),
    .get_flit                   (get_flit_1                   ),
    .get_flit_valid             (get_flit_1_valid             ),
    .get_flit_ready             (get_flit_1_ready             ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b1_out_fifo.device_type = "MASTER";

  FlitSerializer b1_serializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (put_flit_1_axi4        ),
    .in_flit_valid  (put_flit_1_axi4_valid  ),
    .in_flit_ready  (put_flit_1_axi4_ready  ),
    .out_flit       (put_flit_1             ),
    .out_flit_valid (put_flit_1_valid       ),
    .out_flit_ready (put_flit_1_ready       )
  );

  defparam b1_serializer.DEBUG_ID = 1;
  defparam b1_serializer.IN_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  FlitDeserializer b1_deserializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (get_flit_1             ),
    .in_flit_valid  (get_flit_1_valid       ),
    .in_flit_ready  (get_flit_1_ready       ),
    .out_flit       (get_flit_1_axi4        ),
    .out_flit_valid (get_flit_1_axi4_valid  ),
    .out_flit_ready (get_flit_1_axi4_ready  )
  );

  defparam b1_deserializer.DEBUG_ID = 1;
  defparam b1_deserializer.OUT_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  AXI4MasterBridge b1 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi            (m1                    ),
    .put_flit       (put_flit_1_axi4       ),
    .put_flit_valid (put_flit_1_axi4_valid ),
    .put_flit_ready (put_flit_1_axi4_ready ),
    .get_flit       (get_flit_1_axi4       ),
    .get_flit_valid (get_flit_1_axi4_valid ),
    .get_flit_ready (get_flit_1_axi4_ready )
  );

  InPortFIFO b2_in_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .put_flit                   (put_flit_2                   ),
    .put_flit_valid             (put_flit_2_valid             ),
    .put_flit_ready             (put_flit_2_ready             ),
    .send_ports_putFlit_flit_in (send_ports_2_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_2_putFlit      ),
    .send_ports_getCredits      (send_ports_2_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_2_getCredits   ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b2_in_fifo.device_type = "SLAVE";

  OutPortFIFO b2_out_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_2_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_2_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_2_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_2_putCredits   ),
    .get_flit                   (get_flit_2                   ),
    .get_flit_valid             (get_flit_2_valid             ),
    .get_flit_ready             (get_flit_2_ready             ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b2_out_fifo.device_type = "SLAVE";

  FlitSerializer b2_serializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (put_flit_2_axi4        ),
    .in_flit_valid  (put_flit_2_axi4_valid  ),
    .in_flit_ready  (put_flit_2_axi4_ready  ),
    .out_flit       (put_flit_2             ),
    .out_flit_valid (put_flit_2_valid       ),
    .out_flit_ready (put_flit_2_ready       )
  );

  defparam b2_serializer.DEBUG_ID = 2;
  defparam b2_serializer.IN_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  FlitDeserializer b2_deserializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (get_flit_2             ),
    .in_flit_valid  (get_flit_2_valid       ),
    .in_flit_ready  (get_flit_2_ready       ),
    .out_flit       (get_flit_2_axi4        ),
    .out_flit_valid (get_flit_2_axi4_valid  ),
    .out_flit_ready (get_flit_2_axi4_ready  )
  );

  defparam b2_deserializer.DEBUG_ID = 2;
  defparam b2_deserializer.OUT_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  AXI4SlaveBridge b2 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi            (s0                    ),
    .put_flit       (put_flit_2_axi4       ),
    .put_flit_valid (put_flit_2_axi4_valid ),
    .put_flit_ready (put_flit_2_axi4_ready ),
    .get_flit       (get_flit_2_axi4       ),
    .get_flit_valid (get_flit_2_axi4_valid ),
    .get_flit_ready (get_flit_2_axi4_ready )
  );

  InPortFIFO b3_in_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .put_flit                   (put_flit_3                   ),
    .put_flit_valid             (put_flit_3_valid             ),
    .put_flit_ready             (put_flit_3_ready             ),
    .send_ports_putFlit_flit_in (send_ports_3_putFlit_flit_in ),
    .EN_send_ports_putFlit      (EN_send_ports_3_putFlit      ),
    .send_ports_getCredits      (send_ports_3_getCredits      ),
    .EN_send_ports_getCredits   (EN_send_ports_3_getCredits   ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b3_in_fifo.device_type = "SLAVE";

  OutPortFIFO b3_out_fifo (
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .recv_ports_getFlit         (recv_ports_3_getFlit         ),
    .EN_recv_ports_getFlit      (EN_recv_ports_3_getFlit      ),
    .recv_ports_putCredits_cr_in(recv_ports_3_putCredits_cr_in),
    .EN_recv_ports_putCredits   (EN_recv_ports_3_putCredits   ),
    .get_flit                   (get_flit_3                   ),
    .get_flit_valid             (get_flit_3_valid             ),
    .get_flit_ready             (get_flit_3_ready             ),
    .full                       (                             ),
    .almost_full                (                             ),
    .empty                      (                             ),
    .almost_empty               (                             )
  );

  defparam b3_out_fifo.device_type = "SLAVE";

  FlitSerializer b3_serializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (put_flit_3_axi4        ),
    .in_flit_valid  (put_flit_3_axi4_valid  ),
    .in_flit_ready  (put_flit_3_axi4_ready  ),
    .out_flit       (put_flit_3             ),
    .out_flit_valid (put_flit_3_valid       ),
    .out_flit_ready (put_flit_3_ready       )
  );

  defparam b3_serializer.DEBUG_ID = 3;
  defparam b3_serializer.IN_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  FlitDeserializer b3_deserializer (
    .CLK (CLK_FPGA),
    .RST_N,
    .in_flit        (get_flit_3             ),
    .in_flit_valid  (get_flit_3_valid       ),
    .in_flit_ready  (get_flit_3_ready       ),
    .out_flit       (get_flit_3_axi4        ),
    .out_flit_valid (get_flit_3_axi4_valid  ),
    .out_flit_ready (get_flit_3_axi4_ready  )
  );

  defparam b3_deserializer.DEBUG_ID = 3;
  defparam b3_deserializer.OUT_FLIT_WIDTH = AXI4_FLIT_WIDTH;

  AXI4SlaveBridge b3 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi            (s1                    ),
    .put_flit       (put_flit_3_axi4       ),
    .put_flit_valid (put_flit_3_axi4_valid ),
    .put_flit_ready (put_flit_3_axi4_ready ),
    .get_flit       (get_flit_3_axi4       ),
    .get_flit_valid (get_flit_3_axi4_valid ),
    .get_flit_ready (get_flit_3_axi4_ready )
  );

  mkNetwork network (
    .CLK (CLK_NOC),
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
