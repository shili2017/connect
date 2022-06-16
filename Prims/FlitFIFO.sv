`include "connect_parameters.v"

module BasicSCFIFO #(
    parameter DEPTH               = `FLIT_BUFFER_DEPTH,
    parameter DATA_WIDTH          = `FLIT_WIDTH,
    parameter ALMOST_FULL_VALUE   = `FLIT_BUFFER_DEPTH - 1,
    parameter ALMOST_EMPTY_VALUE  = 1
  ) (
    input CLK_NOC,
    input RST_N,

    // Input
    input  [DATA_WIDTH - 1 : 0] enq_data,
    input                       enq_valid,
    output                      enq_ready,

    // Output
    output [DATA_WIDTH - 1 : 0] deq_data,
    output                      deq_valid,
    input                       deq_ready,

    // Full & Empty
    output full,
    output almost_full,
    output empty,
    output almost_empty
  );

  /* ----- FIFO from Intel FPGA IP ----- */

  scfifo fifo (
    .clock        (CLK_NOC      ),
    .sclr         (!RST_N       ),
    .aclr         (!RST_N       ),

    // Input
    .data         (enq_data     ),
    .wrreq        (enq_valid    ),
    .full         (full         ),
    .almost_full  (almost_full  ),

    // Output
    .q            (deq_data     ),
    .rdreq        (deq_ready    ),
    .empty        (empty        ),
    .almost_empty (almost_empty ),

    // Misc
    .eccstatus    (             ),
    .usedw        (             )
  );

  defparam fifo.lpm_width               = DATA_WIDTH;
  defparam fifo.lpm_widthu              = $clog2(DEPTH);
  defparam fifo.lpm_numwords            = DEPTH;
  defparam fifo.lpm_showahead           = "ON";
  defparam fifo.lpm_type                = "scfifo";
  defparam fifo.intended_device_family  = "Stratix";
  defparam fifo.underflow_checking      = "ON";
  defparam fifo.overflow_checking       = "ON";
  // defparam ififo.allow_rwcycle_when_full = "ON";
  defparam fifo.almost_full_value       = ALMOST_FULL_VALUE;
  defparam fifo.almost_empty_value      = ALMOST_EMPTY_VALUE;

  assign enq_ready = !full;
  assign deq_valid = !empty;

  logic enq_fire, deq_fire;
  assign enq_fire = enq_valid && enq_ready;
  assign deq_fire = deq_valid && deq_ready;

  reg [15 : 0] cycle = 0;
  reg [15 : 0] count = 0;

  always_ff @(posedge CLK_NOC) begin
    cycle <= cycle + 1;
    if (enq_fire && !deq_fire)
      count <= count + 1;
    if (deq_fire && !enq_fire)
      count <= count - 1;
  end

endmodule

module BasicDCFIFO #(
    parameter DEPTH               = `FLIT_BUFFER_DEPTH,
    parameter DATA_WIDTH          = `FLIT_WIDTH
  ) (
    input CLK_RD,
    input CLK_WR,
    input RST_N,

    // Input
    input  [DATA_WIDTH - 1 : 0] enq_data,
    input                       enq_valid,
    output                      enq_ready,

    // Output
    output [DATA_WIDTH - 1 : 0] deq_data,
    output                      deq_valid,
    input                       deq_ready
  );

  /* ----- FIFO from Intel FPGA IP ----- */

  logic wrfull, wrempty, rdfull, rdempty;

  dcfifo fifo (
    .aclr       (!RST_N     ),

    // Input
    .wrclk      (CLK_WR     ),
    .wrreq      (enq_valid  ),
    .data       (enq_data   ),
    .wrfull     (wrfull     ),
    .wrempty    (wrempty    ),

    // Output
    .rdclk      (CLK_RD     ),
    .rdreq      (deq_ready  ),
    .q          (deq_data   ),
    .rdfull     (rdfull     ),
    .rdempty    (rdempty    ),

    // Misc
    .rdusedw    (           ),
    .wrusedw    (           ),
    .eccstatus  (           )
  );

  defparam fifo.lpm_width               = DATA_WIDTH;
  defparam fifo.lpm_widthu              = $clog2(DEPTH);
  defparam fifo.lpm_numwords            = DEPTH;
  defparam fifo.lpm_showahead           = "ON";
  defparam fifo.lpm_type                = "dcfifo";
  defparam fifo.intended_device_family  = "Stratix";
  defparam fifo.underflow_checking      = "ON";
  defparam fifo.overflow_checking       = "ON";

  assign enq_ready = !wrfull;
  assign deq_valid = !rdempty;

  logic enq_fire, deq_fire;
  assign enq_fire = enq_valid && enq_ready;
  assign deq_fire = deq_valid && deq_ready;

endmodule

module InPortFIFO (
    input CLK_NOC,
    input CLK_FPGA,
    input RST_N,

    // Input from device
    input  [`FLIT_WIDTH - 1 : 0]  put_flit,
    input                         put_flit_valid,
    output                        put_flit_ready,

    // Output to network
    output [`FLIT_WIDTH - 1 : 0]  send_ports_putFlit_flit_in,
    output                        EN_send_ports_putFlit,
    input  [`VC_BITS : 0]         send_ports_getCredits,
    output                        EN_send_ports_getCredits,

    // Full & Empty of SCFIFO
    output full,
    output almost_full,
    output empty,
    output almost_empty
  );

  /* device_type can be "MASTER" or "SLAVE"
   * MASTER: InPortFIFO sends requests and uses VC 1
   * SLAVE:  InPortFIFO sends responses and uses VC 0
   */
  parameter device_type = "MASTER";

  logic sc_enq_valid, sc_enq_ready;
  logic [`FLIT_WIDTH - 1 : 0] sc_enq_data;

  BasicDCFIFO in_port_dcfifo (
    .CLK_RD       (CLK_NOC        ),
    .CLK_WR       (CLK_FPGA       ),
    .RST_N,
    .enq_data     (put_flit       ),
    .enq_valid    (put_flit_valid ),
    .enq_ready    (put_flit_ready ),
    .deq_data     (sc_enq_data    ),
    .deq_valid    (sc_enq_valid   ),
    .deq_ready    (sc_enq_ready   )
  );

  logic deq_valid, deq_ready, deq_fire;
  assign deq_fire = deq_valid && deq_ready;

  logic [`FLIT_WIDTH - 1 : 0] deq_data;

  BasicSCFIFO in_port_scfifo (
    .CLK_NOC,
    .RST_N,
    .enq_data     (sc_enq_data    ),
    .enq_valid    (sc_enq_valid   ),
    .enq_ready    (sc_enq_ready   ),
    .deq_data     (deq_data       ),
    .deq_valid    (deq_valid      ),
    .deq_ready    (deq_ready      ),
    .full         (full           ),
    .almost_full  (almost_full    ),
    .empty        (empty          ),
    .almost_empty (almost_empty   )
  );

  logic get_credits_valid;
  logic [$clog2(`FLIT_BUFFER_DEPTH) : 0] credit_counter;

  assign deq_ready                  = (credit_counter != 0);
  assign send_ports_putFlit_flit_in = {EN_send_ports_putFlit, deq_data[`FLIT_WIDTH - 2 : 0]};
  assign EN_send_ports_putFlit      = deq_valid && deq_ready;
  assign EN_send_ports_getCredits   = 1;

  always_comb begin
    get_credits_valid = 0;
    if (device_type == "MASTER") begin
      get_credits_valid = send_ports_getCredits[`VC_BITS] &&
                          (send_ports_getCredits[`VC_BITS - 1 : 0] == 1'b1);
    end else begin
      get_credits_valid = send_ports_getCredits[`VC_BITS] &&
                          (send_ports_getCredits[`VC_BITS - 1 : 0] == 1'b0);
    end
  end

  always_ff @(posedge CLK_NOC) begin
    if (!RST_N) begin
      credit_counter <= `FLIT_BUFFER_DEPTH;
    end else begin
      if (deq_fire && !get_credits_valid)
        credit_counter <= credit_counter - 1;
      else if (get_credits_valid && !deq_fire)
        credit_counter <= credit_counter + 1;
    end
  end

endmodule

module OutPortFIFO (
    input CLK_NOC,
    input CLK_FPGA,
    input RST_N,

    // Input from network
    input  [`FLIT_WIDTH - 1 : 0]  recv_ports_getFlit,
    output                        EN_recv_ports_getFlit,
    output [`VC_BITS : 0]         recv_ports_putCredits_cr_in,
    output                        EN_recv_ports_putCredits,

    // Output to device
    output [`FLIT_WIDTH - 1 : 0]  get_flit,
    output                        get_flit_valid,
    input                         get_flit_ready,

    // Full & Empty of SCFIFO
    output full,
    output almost_full,
    output empty,
    output almost_empty
  );

  /* device_type can be "MASTER" or "SLAVE"
   * MASTER: OutPortFIFO receives responses and uses VC 0
   * SLAVE:  OutPortFIFO receives requests and uses VC 1
   */
  parameter device_type = "MASTER";

  logic enq_valid, enq_ready;

  logic sc_deq_valid, sc_deq_ready;
  logic [`FLIT_WIDTH - 1 : 0] sc_deq_data;

  BasicSCFIFO out_port_scfifo (
    .CLK_NOC,
    .RST_N,
    .enq_data     (recv_ports_getFlit ),
    .enq_valid    (enq_valid          ),
    .enq_ready    (enq_ready          ),
    .deq_data     (sc_deq_data        ),
    .deq_valid    (sc_deq_valid       ),
    .deq_ready    (sc_deq_ready       ),
    .full         (                   ),
    .almost_full  (                   ),
    .empty        (                   ),
    .almost_empty (                   )
  );

  BasicDCFIFO out_port_dcfifo (
    .CLK_RD       (CLK_FPGA       ),
    .CLK_WR       (CLK_NOC        ),
    .RST_N,
    .enq_data     (sc_deq_data    ),
    .enq_valid    (sc_deq_valid   ),
    .enq_ready    (sc_deq_ready   ),
    .deq_data     (get_flit       ),
    .deq_valid    (get_flit_valid ),
    .deq_ready    (get_flit_ready )
  );

  assign enq_valid              = recv_ports_getFlit[`FLIT_WIDTH - 1];
  assign EN_recv_ports_getFlit  = enq_ready;

  logic vc;
  always_comb begin
    vc = 0;
    if (device_type == "MASTER") begin
      vc = 0;
    end else begin
      vc = 1;
    end
  end
  assign recv_ports_putCredits_cr_in  = {EN_recv_ports_putCredits, vc};
  assign EN_recv_ports_putCredits     = get_flit_valid && get_flit_ready;

endmodule
