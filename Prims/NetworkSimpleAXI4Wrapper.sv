`timescale 1ns / 1ps

`include "connect_parameters.v"

import axi4_pkg::*;

module NetworkIdealSimpleAXI4Wrapper (
    input CLK,
    input RST_N,

    axi_interface.slave m0,
    axi_interface.slave m1,

    axi_interface.master s0,
    axi_interface.master s1
  );

  wire [`FLIT_WIDTH - 1 : 0] send_ports_0_putFlit_flit_in;
  wire EN_send_ports_0_putFlit;

  wire EN_send_ports_0_getNonFullVCs;
  wire [`NUM_VCS - 1 : 0] send_ports_0_getNonFullVCs;

  wire [`FLIT_WIDTH - 1 : 0] send_ports_1_putFlit_flit_in;
  wire EN_send_ports_1_putFlit;

  wire EN_send_ports_1_getNonFullVCs;
  wire [`NUM_VCS - 1 : 0] send_ports_1_getNonFullVCs;

  wire [`FLIT_WIDTH - 1 : 0] send_ports_2_putFlit_flit_in;
  wire EN_send_ports_2_putFlit;

  wire EN_send_ports_2_getNonFullVCs;
  wire [`NUM_VCS - 1 : 0] send_ports_2_getNonFullVCs;

  wire [`FLIT_WIDTH - 1 : 0] send_ports_3_putFlit_flit_in;
  wire EN_send_ports_3_putFlit;

  wire EN_send_ports_3_getNonFullVCs;
  wire [`NUM_VCS - 1 : 0] send_ports_3_getNonFullVCs;

  wire EN_recv_ports_0_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_0_getFlit;

  wire [`NUM_VCS - 1 : 0] recv_ports_0_putNonFullVCs_nonFullVCs;
  wire EN_recv_ports_0_putNonFullVCs;

  wire EN_recv_ports_1_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_1_getFlit;

  wire [`NUM_VCS - 1 : 0] recv_ports_1_putNonFullVCs_nonFullVCs;
  wire EN_recv_ports_1_putNonFullVCs;

  wire EN_recv_ports_2_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_2_getFlit;

  wire [`NUM_VCS - 1 : 0] recv_ports_2_putNonFullVCs_nonFullVCs;
  wire EN_recv_ports_2_putNonFullVCs;

  wire EN_recv_ports_3_getFlit;
  wire [`FLIT_WIDTH - 1 : 0] recv_ports_3_getFlit;

  wire [`NUM_VCS - 1 : 0] recv_ports_3_putNonFullVCs_nonFullVCs;
  wire EN_recv_ports_3_putNonFullVCs;

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
  end

  AXI4MasterBridge b0 (
    .CLK,
    .RST_N,
    .axi                    (m0),
    .put_flit               (send_ports_0_putFlit_flit_in),
    .put_flit_valid         (EN_send_ports_0_putFlit),
    .get_non_full_vcs       (send_ports_0_getNonFullVCs),
    .get_non_full_vcs_ready (EN_send_ports_0_getNonFullVCs),
    .get_flit               (recv_ports_0_getFlit),
    .get_flit_ready         (EN_recv_ports_0_getFlit),
    .put_non_full_vcs       (recv_ports_0_putNonFullVCs_nonFullVCs),
    .put_non_full_vcs_valid (EN_recv_ports_0_putNonFullVCs)
  );

  AXI4MasterBridge b1 (
    .CLK,
    .RST_N,
    .axi                    (m1),
    .put_flit               (send_ports_1_putFlit_flit_in),
    .put_flit_valid         (EN_send_ports_1_putFlit),
    .get_non_full_vcs       (send_ports_1_getNonFullVCs),
    .get_non_full_vcs_ready (EN_send_ports_1_getNonFullVCs),
    .get_flit               (recv_ports_1_getFlit),
    .get_flit_ready         (EN_recv_ports_1_getFlit),
    .put_non_full_vcs       (recv_ports_1_putNonFullVCs_nonFullVCs),
    .put_non_full_vcs_valid (EN_recv_ports_1_putNonFullVCs)
  );

  AXI4SlaveBridge b2 (
    .CLK,
    .RST_N,
    .axi                    (s0),
    .put_flit               (send_ports_2_putFlit_flit_in),
    .put_flit_valid         (EN_send_ports_2_putFlit),
    .get_non_full_vcs       (send_ports_2_getNonFullVCs),
    .get_non_full_vcs_ready (EN_send_ports_2_getNonFullVCs),
    .get_flit               (recv_ports_2_getFlit),
    .get_flit_ready         (EN_recv_ports_2_getFlit),
    .put_non_full_vcs       (recv_ports_2_putNonFullVCs_nonFullVCs),
    .put_non_full_vcs_valid (EN_recv_ports_2_putNonFullVCs)
  );

  AXI4SlaveBridge b3 (
    .CLK,
    .RST_N,
    .axi                    (s1),
    .put_flit               (send_ports_3_putFlit_flit_in),
    .put_flit_valid         (EN_send_ports_3_putFlit),
    .get_non_full_vcs       (send_ports_3_getNonFullVCs),
    .get_non_full_vcs_ready (EN_send_ports_3_getNonFullVCs),
    .get_flit               (recv_ports_3_getFlit),
    .get_flit_ready         (EN_recv_ports_3_getFlit),
    .put_non_full_vcs       (recv_ports_3_putNonFullVCs_nonFullVCs),
    .put_non_full_vcs_valid (EN_recv_ports_3_putNonFullVCs)
  );

  mkNetworkSimple network (
    CLK,
    RST_N,

    send_ports_0_putFlit_flit_in,
    EN_send_ports_0_putFlit,

    EN_send_ports_0_getNonFullVCs,
    send_ports_0_getNonFullVCs,

    send_ports_1_putFlit_flit_in,
    EN_send_ports_1_putFlit,

    EN_send_ports_1_getNonFullVCs,
    send_ports_1_getNonFullVCs,

    send_ports_2_putFlit_flit_in,
    EN_send_ports_2_putFlit,

    EN_send_ports_2_getNonFullVCs,
    send_ports_2_getNonFullVCs,

    send_ports_3_putFlit_flit_in,
    EN_send_ports_3_putFlit,

    EN_send_ports_3_getNonFullVCs,
    send_ports_3_getNonFullVCs,

    EN_recv_ports_0_getFlit,
    recv_ports_0_getFlit,

    recv_ports_0_putNonFullVCs_nonFullVCs,
    EN_recv_ports_0_putNonFullVCs,

    EN_recv_ports_1_getFlit,
    recv_ports_1_getFlit,

    recv_ports_1_putNonFullVCs_nonFullVCs,
    EN_recv_ports_1_putNonFullVCs,

    EN_recv_ports_2_getFlit,
    recv_ports_2_getFlit,

    recv_ports_2_putNonFullVCs_nonFullVCs,
    EN_recv_ports_2_putNonFullVCs,

    EN_recv_ports_3_getFlit,
    recv_ports_3_getFlit,

    recv_ports_3_putNonFullVCs_nonFullVCs,
    EN_recv_ports_3_putNonFullVCs,

    recv_ports_info_0_getRecvPortID,

    recv_ports_info_1_getRecvPortID,

    recv_ports_info_2_getRecvPortID,

    recv_ports_info_3_getRecvPortID
  );

endmodule
