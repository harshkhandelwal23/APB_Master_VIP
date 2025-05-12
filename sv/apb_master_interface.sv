// ***************************************************************************
// Interface: apb_Master_inetface
// Description:
//   This is a parameterized APB (Advanced Peripheral Bus) interface that 
//   connects the driver, monitor, and slave components using modports and 
//   clocking blocks. 
// ***************************************************************************
interface apb_intf #(parameter ADDR_WIDTH = 32, DATA_WIDTH = 32) (
  input logic PCLK,       // Clock
  input logic PRESETn     // Active-low reset
);
  logic [ADDR_WIDTH-1:0] PADDR;       // Address bus
  logic                  PSELx;       // Select signal
  logic                  PENABLE;     // Enable signal
  logic                  PWRITE;      // Write control
  logic [DATA_WIDTH-1:0] PWDATA;      // Write data
  logic                  PREADY;      // Ready signal from slave
  logic [DATA_WIDTH-1:0] PRDATA;      // Read data from slave

  // This clocking block is used by the driver to drive outputs to the DUT
  clocking driver_cb @(posedge PCLK);
    output PADDR, PWDATA, PWRITE, PSELx, PENABLE;
    input  PRDATA, PREADY;
  endclocking

  // Monitor samples all interface activity 
  clocking monitor_cb @(posedge PCLK);
    input PADDR, PWDATA, PWRITE, PSELx, PENABLE, PRDATA, PREADY;
  endclocking

  // Slave receives inputs from driver and sends response back
  clocking slave_cb @(posedge PCLK);
    input  PADDR, PWDATA, PWRITE, PSELx, PENABLE;
    output PRDATA, PREADY;
  endclocking

  // Driver modport: used in driver class
  modport DRIVER  (clocking driver_cb, input PCLK, PRESETn);

  // Monitor modport: used in monitor class
  modport MONITOR (clocking monitor_cb, input PCLK, PRESETn);

  // Slave modport: used in slave model
  modport SLAVE   (clocking slave_cb, input PCLK, PRESETn);

endinterface
