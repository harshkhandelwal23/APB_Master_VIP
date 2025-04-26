// Define APB4 Interface
interface apb_if(input logic pclk, input logic preset_n);
  // APB4 Master Signals
  logic [31:0] paddr;    // Address
  logic        psel;     // Select
  logic        penable;  // Enable
  logic        pwrite;   // Write (1) or Read (0)
  logic [31:0] pwdata;   // Write data
  logic [31:0] prdata;   // Read data
  logic        pready;   // Ready
  logic        pslverr;  // Slave error

  // Master Clocking Block
  clocking master_cb @(posedge pclk);
    output paddr, psel, penable, pwrite, pwdata;
    input  prdata, pready, pslverr;
  endclocking

  // Monitor Clocking Block
  clocking monitor_cb @(posedge pclk);
    input paddr, psel, penable, pwrite, pwdata, prdata, pready, pslverr;
  endclocking

  // Modports
  modport MASTER (clocking master_cb, input preset_n);
  modport MONITOR (clocking monitor_cb, input preset_n);
 /* modport SLAVE (
    input  pclk, preset_n, paddr, psel, penable, pwrite, pwdata,
    output prdata, pready, pslverr
  );*/
endinterface
