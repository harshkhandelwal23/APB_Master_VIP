import my_pkg::*;
// APB4 Driver
class apb_driver;
  virtual apb_if.MASTER vif;
  mailbox gen2drv;
  mailbox drv2scb;
  int transactions_done;
  
  function new(virtual apb_if.MASTER vif, mailbox gen2drv, mailbox drv2scb);
    this.vif = vif;
    this.gen2drv = gen2drv;
    this.drv2scb = drv2scb;
    this.transactions_done = 0;
  endfunction
  
  task reset();
    $display("[%0t] Driver: Reset started", $time);
    wait(!vif.preset_n);
    vif.master_cb.paddr   <= 32'h0;
    vif.master_cb.pwrite  <= 1'b0;
    vif.master_cb.psel    <= 1'b0;
    vif.master_cb.penable <= 1'b0;
    vif.master_cb.pwdata  <= 32'h0;
    wait(vif.preset_n);
    $display("[%0t] Driver: Reset finished", $time);
  endtask
  
  task run();
    apb_transaction tx;
    
    forever begin
      gen2drv.get(tx);
      drive_transaction(tx);
      drv2scb.put(tx);
      transactions_done++;
    end
  endtask
  
  task drive_transaction(apb_transaction tx);
    apb_transaction tx_copy = tx.copy();
    
    @(vif.master_cb);
    // Setup Phase
    vif.master_cb.paddr   <= tx.addr;
    vif.master_cb.pwrite  <= tx.wr_rd;
    vif.master_cb.psel    <= 1'b1;
    vif.master_cb.penable <= 1'b0;
    if(tx.wr_rd) // If write
      vif.master_cb.pwdata <= tx.data;
    
    @(vif.master_cb);
    // Access Phase
    vif.master_cb.penable <= 1'b1;
    
    // Wait for slave ready
    while(!vif.master_cb.pready)
      @(vif.master_cb);
    
    // Capture response
    if(!tx.wr_rd) // If read
      tx.rdata = vif.master_cb.prdata;
    tx.error = vif.master_cb.pslverr;
    
    // End transaction
    @(vif.master_cb);
    vif.master_cb.psel    <= 1'b0;
    vif.master_cb.penable <= 1'b0;
    
    $display("[%0t] Driver: Transaction completed", $time);
    tx.display("Driver");
  endtask
endclass
