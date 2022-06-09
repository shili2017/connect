package axi4_pkg;

parameter ADDR_WIDTH   = 32;
parameter DATA_WIDTH   = 64;
parameter STRB_WIDTH   = DATA_WIDTH / 8;
parameter ID_WIDTH     = 8;
parameter USER_WIDTH   = 8;
parameter KEEP_WIDTH   = DATA_WIDTH / 8;  // AXI4-Stream
parameter DEST_WIDTH   = 4;               // AXI4-Stream

parameter AXSIZE_1     = 3'b000;
parameter AXSIZE_2     = 3'b001;
parameter AXSIZE_4     = 3'b010;
parameter AXSIZE_8     = 3'b011;
parameter AXSIZE_16    = 3'b100;
parameter AXSIZE_32    = 3'b101;
parameter AXSIZE_64    = 3'b110;
parameter AXSIZE_128   = 3'b111;

parameter BURST_FIXED  = 2'b00;
parameter BURST_INCR   = 2'b01;
parameter BURST_WRAP   = 2'b10;

parameter RESP_OKAY    = 2'b00;
parameter RESP_EXOKAY  = 2'b01;
parameter RESP_SLVERR  = 2'b10;
parameter RESP_DECERR  = 2'b11;

typedef logic [ID_WIDTH   - 1 : 0] axi_id_t;
typedef logic [ADDR_WIDTH - 1 : 0] axi_addr_t;
typedef logic [DATA_WIDTH - 1 : 0] axi_data_t;
typedef logic [STRB_WIDTH - 1 : 0] axi_strb_t;
typedef logic [7 : 0]              axi_len_t;
typedef logic [2 : 0]              axi_size_t;
typedef logic [1 : 0]              axi_burst_t;
typedef logic [1 : 0]              axi_resp_t;
typedef logic [3 : 0]              axi_cache_t;
typedef logic [2 : 0]              axi_prot_t;
typedef logic [3 : 0]              axi_qos_t;
typedef logic [3 : 0]              axi_region_t;
typedef logic [USER_WIDTH - 1 : 0] axi_user_t;

typedef logic [KEEP_WIDTH - 1 : 0] axi_keep_t;  // AXI4-Stream
typedef logic [DEST_WIDTH - 1 : 0] axi_dest_t;  // AXI4-Stream

parameter CHANNEL_AW  = 3'b001;
parameter CHANNEL_W   = 3'b011;
parameter CHANNEL_B   = 3'b101;
parameter CHANNEL_AR  = 3'b010;
parameter CHANNEL_R   = 3'b110;

parameter AXI4_FLIT_DATA_WIDTH  = 92;
parameter AXI4S_FLIT_DATA_WIDTH = 101;

endpackage
