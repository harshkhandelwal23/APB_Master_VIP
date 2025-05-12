// *****************************************************************************
// Class: APB_master_monitor
// Description:
//   This class observes APB transactions on the interface using the MONITOR 
//   modport. It captures transactions and sends them to the scoreboard via mailbox.
// *****************************************************************************
import my_pkg::*;
`define MON_IF apb_vif.MONITOR.monitor_cb
class monitor;
  virtual apb_intf apb_vif;   // Virtual APB interface handle
  mailbox mon2scb;            // Mailbox to communicate with the scoreboard

  // Constructor
  function new(virtual apb_intf apb_vif, mailbox mon2scb);
    this.apb_vif = apb_vif;
    this.mon2scb = mon2scb;
  endfunction

  //  Main Monitor Task 
  task main;
    forever begin
      transaction trans;

      // Wait until reset is deasserted
      wait(apb_vif.PRESETn == 1);

      // Wait for positive clock edge
      @(posedge apb_vif.PCLK);

      // Detect valid APB transfer (PSELx & PENABLE & PREADY all high)
      if (`MON_IF.PSELx && `MON_IF.PENABLE && `MON_IF.PREADY) begin
        trans = new();

        // Capture basic control/address info
        trans.PADDR   = `MON_IF.PADDR;
        trans.PWRITE  = `MON_IF.PWRITE;
        trans.PENABLE = `MON_IF.PENABLE;
        trans.PSELx   = `MON_IF.PSELx;

        // Capture write or read data based on PWRITE
        if (`MON_IF.PWRITE) begin
          trans.PWDATA = `MON_IF.PWDATA;
          $display("[%0t] Monitor: WRITE detected", $time);
        end else begin
          trans.PRDATA = `MON_IF.PRDATA;
          $display("[%0t] Monitor: READ detected", $time);
        end

        // Send captured transaction to scoreboard
        mon2scb.put(trans);
        trans.display("MONITOR");
      end
    end
  endtask
endclass
