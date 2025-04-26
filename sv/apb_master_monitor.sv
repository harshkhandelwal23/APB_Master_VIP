import my_pkg::*;
// APB4 Monitor
class apb_monitor;
  virtual apb_if.MONITOR vif;
  mailbox mon2scb;
  
  function new(virtual apb_if.MONITOR vif, mailbox mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction
  
  task run();
    apb_transaction tx;
    
    forever begin
      tx = new();
      // Wait for transaction start (PSEL assertion)
      do @(vif.monitor_cb); while(!vif.monitor_cb.psel);
      
      // Capture setup phase info
      tx.addr  = vif.monitor_cb.paddr;
      tx.wr_rd = vif.monitor_cb.pwrite;
      if(tx.wr_rd) // Write
        tx.data = vif.monitor_cb.pwdata;
      
      // Wait for access phase (PENABLE)
      do @(vif.monitor_cb); while(!vif.monitor_cb.penable);
      
      // Wait for completion (PREADY)
      do @(vif.monitor_cb); while(!vif.monitor_cb.pready);
      
      // Capture response
      if(!tx.wr_rd) // Read
        tx.rdata = vif.monitor_cb.prdata;
      tx.error = vif.monitor_cb.pslverr;
      
      // Wait for end of transaction
      do @(vif.monitor_cb); while(vif.monitor_cb.psel);
      
      tx.display("Monitor");
      mon2scb.put(tx);
    end
  endtask
endclass
