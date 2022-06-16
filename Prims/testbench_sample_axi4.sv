`ifndef XST_SYNTH

`timescale 1ns / 1ps

`include "connect_parameters.v"

import axi4_pkg::*;

module CONNECT_testbench_sample_axi4;
  parameter HalfClkPeriod = 20;
  localparam ClkPeriod = 2 * HalfClkPeriod;
  localparam ClkDividerFactor = 4;

  reg CLK_NOC, CLK_FPGA;
  reg RST_N;

  axi_interface m0();
  axi_interface m1();
  axi_interface s0();
  axi_interface s1();

  reg [15 : 0] cycle = 0;
  integer i;

  // Generate Clock
  initial begin
    CLK_NOC = 0;
    CLK_FPGA = 0;
  end
  always #(HalfClkPeriod / ClkDividerFactor) CLK_NOC = ~CLK_NOC;
  always #(HalfClkPeriod) CLK_FPGA = ~CLK_FPGA;

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
    #(5 * ClkPeriod + HalfClkPeriod); 
    RST_N = 1;
    #(HalfClkPeriod);

    #(ClkPeriod);
    start_write_m0 = 1;
  
    #(ClkPeriod);
    start_write_m0 = 0;
    start_read_m1 = 1;
  
    #(ClkPeriod);
    start_read_m1 = 0;

    #(ClkPeriod * 500);

    test_write();
    test_read();
    $finish;
  end

  axi_addr_t addr_m0 = 32'h2;
  axi_addr_t addr_m1 = 32'h3;
  axi_data_t data = 64'hdeadbeefdeadbeef;
  int flag_w = 1, flag_r = 1;

  always_ff @(posedge CLK_NOC) begin
    cycle <= cycle + 1;
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
    .CLK_NOC,
    .CLK_FPGA,
    .RST_N,
    .m0 (m0),
    .m1 (m1),
    .s0 (s0),
    .s1 (s1)
  );

  AXI4MasterDevice d0 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi         (m0),
    .start_read  (start_read_m0),
    .start_write (start_write_m0),
    .addr        (addr_m0)
  );

  defparam d0.ID = 0;

  AXI4MasterDevice d1 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi         (m1),
    .start_read  (start_read_m1),
    .start_write (start_write_m1),
    .addr        (addr_m1)
  );

  defparam d1.ID = 1;

  AXI4SlaveDevice d2 (
    .CLK (CLK_FPGA),
    .RST_N,
    .axi (s0)
  );

  AXI4SlaveDevice d3 (
    .CLK (CLK_FPGA),
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
