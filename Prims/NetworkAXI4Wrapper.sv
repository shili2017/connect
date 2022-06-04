`timescale 1ns / 1ps

`include "connect_parameters.v"

import axi4_pkg::*;

module NetworkIdealAXI4Wrapper (
    input CLK,
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

  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;
    if (EN_send_ports_0_putFlit)
      $display("%d: Port 0 send flit %x", cycle, send_ports_0_putFlit_flit_in);
    if (EN_send_ports_1_putFlit)
      $display("%d: Port 1 send flit %x", cycle, send_ports_1_putFlit_flit_in);
    if (EN_send_ports_2_putFlit)
      $display("%d: Port 2 send flit %x", cycle, send_ports_2_putFlit_flit_in);
    if (EN_send_ports_3_putFlit)
      $display("%d: Port 3 send flit %x", cycle, send_ports_3_putFlit_flit_in);
    if (recv_ports_0_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 0 recv flit %x", cycle, recv_ports_0_getFlit);
    if (recv_ports_1_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 1 recv flit %x", cycle, recv_ports_1_getFlit);
    if (recv_ports_2_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 2 recv flit %x", cycle, recv_ports_2_getFlit);
    if (recv_ports_3_getFlit[`FLIT_WIDTH - 1])
      $display("%d: Port 3 recv flit %x", cycle, recv_ports_3_getFlit);
    
    if (send_ports_0_getCredits[`VC_BITS])
      $display("%d: Port 0 get a credit", cycle);
    if (send_ports_1_getCredits[`VC_BITS])
      $display("%d: Port 1 get a credit", cycle);
    if (send_ports_2_getCredits[`VC_BITS])
      $display("%d: Port 2 get a credit", cycle);
    if (send_ports_3_getCredits[`VC_BITS])
      $display("%d: Port 3 get a credit", cycle);
    if (EN_recv_ports_0_putCredits)
      $display("%d: Port 0 put a credit", cycle);
    if (EN_recv_ports_1_putCredits)
      $display("%d: Port 1 put a credit", cycle);
    if (EN_recv_ports_2_putCredits)
      $display("%d: Port 2 put a credit", cycle);
    if (EN_recv_ports_3_putCredits)
      $display("%d: Port 3 put a credit", cycle);
  end

  wire [`FLIT_WIDTH - 1 : 0]  put_flit_0;
  wire                        put_flit_0_valid;
  wire                        put_Flit_0_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_0;
  wire                        get_flit_0_valid;
  wire                        get_Flit_0_ready;
  wire [`FLIT_WIDTH - 1 : 0]  put_flit_1;
  wire                        put_flit_1_valid;
  wire                        put_Flit_1_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_1;
  wire                        get_flit_1_valid;
  wire                        get_Flit_1_ready;
  wire [`FLIT_WIDTH - 1 : 0]  put_flit_2;
  wire                        put_flit_2_valid;
  wire                        put_Flit_2_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_2;
  wire                        get_flit_2_valid;
  wire                        get_Flit_2_ready;
  wire [`FLIT_WIDTH - 1 : 0]  put_flit_3;
  wire                        put_flit_3_valid;
  wire                        put_Flit_3_ready;
  wire [`FLIT_WIDTH - 1 : 0]  get_flit_3;
  wire                        get_flit_3_valid;
  wire                        get_Flit_3_ready;

  InPortFIFO b0_in_fifo (
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

  OutPortFIFO b0_out_fifo (
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

  AXI4MasterBridge b0 (
    .CLK,
    .RST_N,
    .axi            (m0               ),
    .put_flit       (put_flit_0       ),
    .put_flit_valid (put_flit_0_valid ),
    .put_flit_ready (put_flit_0_ready ),
    .get_flit       (get_flit_0       ),
    .get_flit_valid (get_flit_0_valid ),
    .get_flit_ready (get_flit_0_ready )
  );

  InPortFIFO b1_in_fifo (
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

  OutPortFIFO b1_out_fifo (
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

  AXI4MasterBridge b1 (
    .CLK,
    .RST_N,
    .axi            (m1               ),
    .put_flit       (put_flit_1       ),
    .put_flit_valid (put_flit_1_valid ),
    .put_flit_ready (put_flit_1_ready ),
    .get_flit       (get_flit_1       ),
    .get_flit_valid (get_flit_1_valid ),
    .get_flit_ready (get_flit_1_ready )
  );

  InPortFIFO b2_in_fifo (
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

  OutPortFIFO b2_out_fifo (
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

  AXI4SlaveBridge b2 (
    .CLK,
    .RST_N,
    .axi            (s0),
    .put_flit       (put_flit_2       ),
    .put_flit_valid (put_flit_2_valid ),
    .put_flit_ready (put_flit_2_ready ),
    .get_flit       (get_flit_2       ),
    .get_flit_valid (get_flit_2_valid ),
    .get_flit_ready (get_flit_2_ready )
  );

  InPortFIFO b3_in_fifo (
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

  OutPortFIFO b3_out_fifo (
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

  AXI4SlaveBridge b3 (
    .CLK,
    .RST_N,
    .axi            (s1),
    .put_flit       (put_flit_3       ),
    .put_flit_valid (put_flit_3_valid ),
    .put_flit_ready (put_flit_3_ready ),
    .get_flit       (get_flit_3       ),
    .get_flit_valid (get_flit_3_valid ),
    .get_flit_ready (get_flit_3_ready )
  );

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
