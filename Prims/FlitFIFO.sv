`include "connect_parameters.v"

//`define USE_FIFO_IP

`ifdef USE_FIFO_IP

module BasicFIFO #(parameter DEPTH = `FLIT_BUFFER_DEPTH, parameter DATA_WIDTH = `FLIT_WIDTH) (
    input CLK,
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

  logic full, empty;

  scfifo in_port_fifo (
    .clock        (CLK        ),
    .sclr         (!RST_N     ),
    .aclr         (!RST_N     ),

    // Input
    .data         (enq_data   ),
    .wrreq        (enq_valid  ),
    .full         (full       ),

    // Output
    .q            (deq_data   ),
    .rdreq        (deq_ready  ),
    .empty        (empty      ),

    // Misc
    .eccstatus    (),
    .usedw        (),
    .almost_full  (),
    .almost_empty ()
  );

  defparam in_port_fifo.lpm_width               = DATA_WIDTH;
  defparam in_port_fifo.lpm_widthu              = $clog2(DEPTH);
  defparam in_port_fifo.lpm_numwords            = DEPTH;
  defparam in_port_fifo.lpm_showahead           = "ON";
  defparam in_port_fifo.lpm_type                = "scfifo";
  defparam in_port_fifo.intended_device_family  = "Stratix";
  defparam in_port_fifo.underflow_checking      = "ON";
  defparam in_port_fifo.overflow_checking       = "ON";
  // defparam in_port_fifo.allow_rwcycle_when_full = "ON";

  assign enq_ready = !full;
  assign deq_valid = !empty;

  logic enq_fire, deq_fire;
  assign enq_fire = enq_valid && enq_ready;
  assign deq_fire = deq_valid && deq_ready;

  reg [15 : 0] cycle = 0;
  reg [15 : 0] count = 0;

  always_ff @(posedge CLK) begin
    cycle <= cycle + 1;
    if (enq_fire && !deq_fire)
      count <= count + 1;
    if (deq_fire && !enq_fire)
      count <= count - 1;
  end

`ifdef DEBUG_FLIT_FIFO
  always_ff @(posedge CLK) begin
    if (enq_fire)
      $display("%d: [ENQ] data=%x", cycle, enq_data);
    if (deq_fire)
      $display("%d: [DEQ] data=%x", cycle, deq_data);
  end
`endif

endmodule

`else

module BasicFIFO #(parameter DEPTH = `FLIT_BUFFER_DEPTH, parameter DATA_WIDTH = `FLIT_WIDTH) (
    input CLK,
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

  logic [DATA_WIDTH - 1 : 0]    buffer [0 : DEPTH];
  logic [$clog2(DEPTH) - 1 : 0] enq_ptr;
  logic [$clog2(DEPTH) - 1 : 0] deq_ptr;
  logic                         ptr_match, empty, full, maybe_full;
  logic                         enq_fire, deq_fire, do_enq, do_deq;

  assign ptr_match  = (enq_ptr == deq_ptr);
  assign empty      = ptr_match && !maybe_full;
  assign full       = ptr_match && maybe_full;

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      enq_ptr <= 0;
      deq_ptr <= 0;
      maybe_full <= 0;
    end else begin
      if (do_enq)
        enq_ptr <= enq_ptr + 1;
      if (do_deq)
        deq_ptr <= deq_ptr + 1;
      if (do_enq != do_deq)
        maybe_full <= do_enq;
    end
  end

  always_ff @(posedge CLK) begin
    if (!RST_N) begin
      for (int i = 0; i < DEPTH; i++) begin
        buffer[i] <= 0;
      end
    end else begin
      if (do_enq)
        buffer[enq_ptr] <= enq_data;
    end
  end

  assign enq_fire = enq_valid && enq_ready;
  assign deq_fire = deq_valid && deq_ready;

  logic [DATA_WIDTH - 1 : 0]  deq_data_;
  logic                       deq_valid_;
  assign deq_data   = deq_data_;
  assign deq_valid  = deq_valid_;

  always_comb begin
    do_enq = enq_fire;
    do_deq = deq_fire;
    deq_data_ = buffer[deq_ptr];
    deq_valid_ = !empty;

    // Flow
    if (empty) begin
      if (deq_ready) begin
        do_enq = 0;
      end
      do_deq = 0;
      deq_data_ = enq_data;
    end
    if (enq_valid) begin
      deq_valid_ = 1;
    end
  end

  logic enq_ready_;
  assign enq_ready = enq_ready_;

  always_comb begin
    enq_ready_ = !full;
    
    // Pipe
    if (deq_ready) begin
      enq_ready_ = 1;
    end
  end

endmodule

`endif

module InPortFIFO (
    input CLK,
    input RST_N,

    // Input from device
    input  [`FLIT_WIDTH - 1 : 0]  put_flit,
    input                         put_flit_valid,
    output                        put_flit_ready,

    // Output to network
    output [`FLIT_WIDTH - 1 : 0]  send_ports_putFlit_flit_in,
    output                        EN_send_ports_putFlit,
    input  [`VC_BITS : 0]         send_ports_getCredits,
    output                        EN_send_ports_getCredits
  );

  /* device_type can be "MASTER" or "SLAVE"
   * MASTER: InPortFIFO sends requests and uses VC 1
   * SLAVE:  InPortFIFO sends responses and uses VC 0
   * SYMMETRIC: InPortFIFO uses VC 0
   */
  parameter device_type = "SYMMETRIC";

  logic deq_valid, deq_ready, deq_fire;
  assign deq_fire = deq_valid && deq_ready;

  logic [`FLIT_WIDTH - 1 : 0] deq_data;

  BasicFIFO in_port_fifo (
    .CLK,
    .RST_N,
    .enq_data   (put_flit       ),
    .enq_valid  (put_flit_valid ),
    .enq_ready  (put_flit_ready ),
    .deq_data   (deq_data       ),
    .deq_valid  (deq_valid      ),
    .deq_ready  (deq_ready      )
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

  always_ff @(posedge CLK) begin
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
    input CLK,
    input RST_N,

    // Input from network
    input  [`FLIT_WIDTH - 1 : 0]  recv_ports_getFlit,
    output                        EN_recv_ports_getFlit,
    output [`VC_BITS : 0]         recv_ports_putCredits_cr_in,
    output                        EN_recv_ports_putCredits,

    // Output to device
    output [`FLIT_WIDTH - 1 : 0]  get_flit,
    output                        get_flit_valid,
    input                         get_flit_ready
  );

  /* device_type can be "MASTER" or "SLAVE"
   * MASTER: OutPortFIFO receives responses and uses VC 0
   * SLAVE:  OutPortFIFO receives requests and uses VC 1
   * SYMMETRIC: OutPortFIFO uses VC 0
   */
  parameter device_type = "SYMMETRIC";

  logic enq_valid, enq_ready;

  BasicFIFO out_port_fifo (
    .CLK,
    .RST_N,
    .enq_data   (recv_ports_getFlit ),
    .enq_valid  (enq_valid          ),
    .enq_ready  (enq_ready          ),
    .deq_data   (get_flit           ),
    .deq_valid  (get_flit_valid     ),
    .deq_ready  (get_flit_ready     )
  );

  assign enq_valid              = recv_ports_getFlit[`FLIT_WIDTH - 1];
  assign EN_recv_ports_getFlit  = enq_ready;

  logic vc;
  always_comb begin
    vc = 0;
    if (device_type == "MASTER" || device_type == "SYMMETRIC") begin
      vc = 0;
    end else begin
      vc = 1;
    end
  end
  assign recv_ports_putCredits_cr_in  = {EN_recv_ports_putCredits, vc};
  assign EN_recv_ports_putCredits     = get_flit_valid && get_flit_ready;

endmodule
