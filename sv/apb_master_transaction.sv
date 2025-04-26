// APB4 Transaction Class
class apb_transaction;
  // Transaction fields
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit        wr_rd; // 1: Write, 0: Read
  bit [31:0]      rdata; // For read operations
  bit             error; // To store slave error response
  
  // Constraints
  constraint addr_c {
    addr inside {[32'h0000_0000:32'h0000_0400]}; // Address range
  }
  
  // Copy method
  function apb_transaction copy();
    apb_transaction tx;
    tx = new();
    tx.addr  = this.addr;
    tx.data  = this.data;
    tx.wr_rd = this.wr_rd;
    tx.rdata = this.rdata;
    tx.error = this.error;
    return tx;
  endfunction
  
  // Display method
  function void display(string tag="");
    $display("[%0t] %s Transaction: addr=0x%0h, %s, data/rdata=0x%0h, error=%0d", 
             $time, tag, addr, wr_rd ? "WRITE" : "READ", wr_rd ? data : rdata, error);
  endfunction
endclass
