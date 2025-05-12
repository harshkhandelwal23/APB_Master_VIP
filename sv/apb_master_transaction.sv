// ************************************************************************
// Class: apb_master_transaction
// Purpose: This class represents a single transaction for the APB interface,
// which includes the address, data, and control signals necessary for an APB 
// ************************************************************************

import my_pkg::*;  
class transaction #(int ADDR_WIDTH = 32, int DATA_WIDTH = 32);
  
  rand bit [ADDR_WIDTH-1:0] PADDR;   // Address bus 
  rand bit [DATA_WIDTH-1:0] PWDATA;  // Write Data bus 
  rand bit PSELx;                   // APB select signal 
  rand bit PENABLE;                  // APB enable signal
  rand bit PWRITE;                   // Write enable signal (1 for write, 0 for read)
  bit [DATA_WIDTH-1:0] PRDATA;       // Read Data bus 
  bit PREADY;                        // Ready signal 

  constraint addr { 
    PADDR inside {[32'h0000_0000:32'h0000_0400]}; // Address between 0x0000_0000 and 0x0000_0400
  }

  constraint ratio { 
    PWRITE dist {1 := 50, 0 := 50}; // Half-Half chance for PWRITE to be 1 (write) or 0 (read)
  }

  constraint valid { 
    if (PWRITE) 
      PWDATA inside {[0 : 32'hFFFF_FFFF]}; // Valid range for write data
    else 
      PWDATA == 0; // For reads, no data is written
  }

  function void display(string class_name); //Display method
    $display("------------------[%s]-------------------------", class_name);
    $display("[%0t] PSELx = %0b, PENABLE = %0b, PWRITE = %0b, PADDR = %0h, PWDATA = %0h, PRDATA = %0h", 
             $time, PSELx, PENABLE, PWRITE, PADDR, PWDATA, PRDATA);
  endfunction

endclass
