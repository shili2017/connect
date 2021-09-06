/* =========================================================================
 *
 * Filename:            NetworkExternalTypes.bsv
 * Date created:        04-23-2011
 * Last modified:       04-23-2011
 * Authors:		Michael Papamichael <papamixATcs.cmu.edu>
 *
 * Description:
 * Types that are exposed for using the network within a bigger system.
 * 
 * =========================================================================
 */

import Vector::*;
// Generic include
`include "inc.v"
///////////////////////////////////////////////////////////////////////////////////////////////
// Set network and router parameters
// include *.conf.bsv file generated by running parse_conf on the network configuration file
///////////////////////////////////////////////////////////////////////////////////////////////
//`define NETWORK_CONF_FILE "default_conf_parameters.bsv"
//`include `NETWORK_PARAMETERS_FILE
//`include "net_configs/n1.txt.conf.bsv"

////////////////////////////////////////////////
// Bluespec router and network types
//typedef `NUM_TOTAL_USER_PORTS     NumTotalUserPorts;
typedef `NUM_USER_SEND_PORTS     NumUserSendPorts;
typedef `NUM_USER_RECV_PORTS     NumUserRecvPorts;
typedef `NUM_ROUTERS        NumRouters;
typedef `NUM_IN_PORTS       NumInPorts;
typedef `NUM_OUT_PORTS      NumOutPorts;
typedef `CREDIT_DELAY       CreditDelay;
typedef `NUM_VCS            NumVCs;
typedef `NUM_LINKS          NumLinks;
typedef `FLIT_DATA_WIDTH    FlitDataWidth;
typedef `FLIT_BUFFER_DEPTH  FlitBufferDepth;
typedef `NETWORK_CUT	    NetworkCut; // used by 'ideal' and 'xbar'
typedef `XBAR_LANES	    XbarLanes;
//typedef `ALLOC_TYPE         SelectedAllocator;
//typedef `PIPELINE_ALLOCATOR PipelineAllocator;
//typedef `PIPELINE_LINKS     PipelineLinks;

function Integer getPipeLineStages();
  if(`PIPELINE_CORE && `PIPELINE_LINKS && `PIPELINE_ALLOCATOR) begin // 3 pipe stages
    return 3;
  end else if((`PIPELINE_CORE && `PIPELINE_LINKS) || (`PIPELINE_CORE && `PIPELINE_ALLOCATOR) || (`PIPELINE_ALLOCATOR && `PIPELINE_LINKS)) begin // 2 pipe stages
    return 2;
    //typedef 2     NumPipelineStages;
  end else if (`PIPELINE_CORE || `PIPELINE_LINKS || `PIPELINE_ALLOCATOR) begin // 1 pipe stage
    return 1;
    //typedef 1     NumPipelineStages;
  end else begin // no pipelining
    //typedef 0     NumPipelineStages;
    return 0;
  end
endfunction

// Derived parameters
//typedef Bit#(TLog#(NumTotalUserPorts)) UserPortID_t;
typedef Bit#(TLog#(NumUserSendPorts)) UserSendPortID_t;
typedef Bit#(TLog#(NumUserRecvPorts)) UserRecvPortID_t;
typedef Bit#(TLog#(NumRouters)) RouterID_t;
typedef Bit#(TLog#(TMax#(NumVCs, 2))) VC_t;  // I want this to be at least 1 bit
typedef Bit#(FlitDataWidth) FlitData_t;


//////////////////////////////////////////////////////
// Flit and Credit Types
typedef struct{
  //Bool            is_head; // turns out this was not needed
  //Bool            prio; // priority packet
  Bool            is_tail; // only required for multi-flit packets
  //RouterID_t      dst;
  UserRecvPortID_t        dst;
  //OutPort_t       out_p; // only for debugging
  VC_t            vc;  
  FlitData_t      data; // payload of flit
} Flit_t
  deriving(Bits, Eq);

typedef Maybe#(VC_t) Credit_t;  // credits carry VC to which they belong
typedef Vector#(NumVCs, Bool) CreditSimple_t;  // bitmask indicating available VCs

////////////////////////////////////////////////
// InPort and OutPort interfaces
//   - Uses credits
// Implemented by routers and traffic sources
////////////////////////////////////////////////
interface InPort;
  (* always_ready *) method Action putFlit(Maybe#(Flit_t) flit_in);
  (* always_ready *) method ActionValue#(Credit_t) getCredits;
endinterface

interface OutPort;
  (* always_ready *) method ActionValue#(Maybe#(Flit_t)) getFlit();
  (* always_ready *) method Action putCredits(Credit_t cr_in);
endinterface

////////////////////////////////////////////////
// Simpler InPort and OutPort interfaces
//   - Routers only exchange notFull signals, instead of credits
// Implemented by routers and traffic sources                      
////////////////////////////////////////////////                   
interface InPortSimple;                             
  (* always_ready *) method Action putFlit(Maybe#(Flit_t) flit_in);
  (* always_ready *) method ActionValue#(Vector#(NumVCs, Bool)) getNonFullVCs;
endinterface

interface OutPortSimple;
  (* always_ready *) method ActionValue#(Maybe#(Flit_t)) getFlit();
  (* always_ready *) method Action putNonFullVCs(Vector#(NumVCs, Bool) nonFullVCs);
endinterface

// Used by clients to obtain response address
interface RecvPortInfo;
  //(* always_ready *) method RouterID_t getRouterID;
  (* always_ready *) method UserRecvPortID_t getRecvPortID;
endinterface