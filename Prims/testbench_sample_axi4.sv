`ifndef XST_SYNTH

`timescale 1ns / 1ps

`include "connect_parameters.v"

import axi4_pkg::*;

module CONNECT_testbench_sample_axi4;
  parameter HalfClkPeriod = 5;
  localparam ClkPeriod = 2 * HalfClkPeriod;
  localparam test_cycles = 30;

  reg CLK;
  reg RST_N;

  axi_interface m0();
  axi_interface m1();
  axi_interface s0();
  axi_interface s1();

  reg [15 : 0] cycle = 0;
  integer i;

  // Generate Clock
  initial CLK = 0;
  always #(HalfClkPeriod) CLK = ~CLK;

  reg start_read_m0, start_write_m0;
  reg start_read_m1, start_write_m1;

  // Run simulation 
  initial begin
    start_write_m0 = 0;
    start_write_m1 = 0;
    start_read_m0 = 0;
    start_read_m1 = 0;

    $display("---- Performing Reset ----");
    RST_N = 0; // perform reset (active low) 
    #(5 * ClkPeriod+HalfClkPeriod); 
    RST_N = 1;
    #(HalfClkPeriod);

    #(ClkPeriod);
    start_write_m0 = 1;
  
    #(ClkPeriod);
    start_write_m0 = 0;
    start_read_m1 = 1;
  
    #(ClkPeriod);
    start_read_m1 = 0;

    #(ClkPeriod * 30);

    test_write();
    test_read();
    $finish;
  end

  axi_addr_t addr_m0 = 32'h2;
  axi_addr_t addr_m1 = 32'h3;
  axi_data_t data = 64'hdeadbeefdeadbeef;
  int flag_w = 1, flag_r = 1;

  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;
    if (m0.awvalid && m0.awready)
      $display("%d: [m0-aw] addr=%x", cycle, m0.awaddr);
    if (m0.wvalid && m0.wready)
      $display("%d: [m0- w] data=%x", cycle, m0.wdata);
    if (m0.bvalid && m0.bready)
      $display("%d: [m0- b]", cycle);
    if (m0.arvalid && m0.arready)
      $display("%d: [m0-ar] addr=%x", cycle, m0.araddr);
    if (m0.rvalid && m0.rready)
      $display("%d: [m0- r] data=%x", cycle, m0.rdata);

    if (m1.awvalid && m1.awready)
      $display("%d: [m1-aw] addr=%x", cycle, m1.awaddr);
    if (m1.wvalid && m1.wready)
      $display("%d: [m1- w] data=%x", cycle, m1.wdata);
    if (m1.bvalid && m1.bready)
      $display("%d: [m1- b]", cycle);
    if (m1.arvalid && m1.arready)
      $display("%d: [m1-ar] addr=%x", cycle, m1.araddr);
    if (m1.rvalid && m1.rready)
      $display("%d: [m1- r] data=%x", cycle, m1.rdata);

    if (s0.awvalid && s0.awready)
      $display("%d: [s0-aw] addr=%x", cycle, s0.awaddr);
    if (s0.wvalid && s0.wready)
      $display("%d: [s0- w] data=%x", cycle, s0.wdata);
    if (s0.bvalid && s0.bready)
      $display("%d: [s0- b]", cycle);
    if (s0.arvalid && s0.arready)
      $display("%d: [s0-ar] addr=%x", cycle, s0.araddr);
    if (s0.rvalid && s0.rready)
      $display("%d: [s0- r] data=%x", cycle, s0.rdata);

    if (s1.awvalid && s1.awready)
      $display("%d: [s1-aw] addr=%x", cycle, s1.awaddr);
    if (s1.wvalid && s1.wready)
      $display("%d: [s1- w] data=%x", cycle, s1.wdata);
    if (s1.bvalid && s0.bready)
      $display("%d: [s1- b]", cycle);
    if (s1.arvalid && s1.arready)
      $display("%d: [s1-ar] addr=%x", cycle, s1.araddr);
    if (s1.rvalid && s1.rready)
      $display("%d: [s1- r] data=%x", cycle, s1.rdata);
  end

  task test_write;
    for (int i = 0; i < 8; i++) begin
      if (d2.buffer[addr_m0 + i] != data + i) flag_w = 0;
      $display("actual:%h expected:%h", d2.buffer[addr_m0 + i], data + i);
    end

    if (flag_w) $display("Pass");
    else $display("Fail");
  endtask : test_write

  task test_read;
    for (int i = 0; i < 8; i++) begin
      if (d1.rdata[addr_m1 + i] != data + i) flag_r = 0;
      $display("actual:%h expected:%h", d1.rdata[addr_m1 + i], data + i);
    end

    if (flag_r) $display("Pass");
    else $display("Fail");
  endtask : test_read

  NetworkIdealAXI4Wrapper dut (
    .CLK,
    .RST_N,
    .m0 (m0),
    .m1 (m1),
    .s0 (s0),
    .s1 (s1)
  );

  AXI4MasterDevice d0 (
    .CLK,
    .RST_N,
    .axi         (m0),
    .start_read  (start_read_m0),
    .start_write (start_write_m0),
    .addr        (addr_m0)
  );

  defparam d0.ID = 0;

  AXI4MasterDevice d1 (
    .CLK,
    .RST_N,
    .axi         (m1),
    .start_read  (start_read_m1),
    .start_write (start_write_m1),
    .addr        (addr_m1)
  );

  defparam d1.ID = 1;

  AXI4SlaveDevice d2 (
    .CLK,
    .RST_N,
    .axi (s0)
  );

  AXI4SlaveDevice d3 (
    .CLK,
    .RST_N,
    .axi (s1)
  );

  // Dump waveform for gtkwave
  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars;
  end

endmodule

`endif
