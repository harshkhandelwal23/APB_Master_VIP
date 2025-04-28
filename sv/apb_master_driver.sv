import my_pkg::*;
class driver;
  virtual apb_intf vif;
  mailbox gen2drv;
  event drv_ready;
  
  // Simplified FSM states
  typedef enum {IDLE, SETUP, ACCESS} state_e;
  state_e current_state = IDLE;
  transaction trans;
  
  function new(virtual apb_intf vif, mailbox gen2drv);
    this.vif = vif;
    this.gen2drv = gen2drv;
  endfunction

  task reset();
    vif.master_cb.PSELx <= 0;
    vif.master_cb.PENABLE <= 0;
    current_state = IDLE;
  endtask
  task run();
    forever begin
      case(current_state)
        IDLE: begin
          // Signal ready and get new transaction
          -> drv_ready;
          gen2drv.get(trans);
          current_state = SETUP;
        end
        
        SETUP: begin
          // Drive SETUP phase signals
          vif.master_cb.PSELx <= 1;
          vif.master_cb.PENABLE <= 0;
          vif.master_cb.PWRITE <= trans.PWRITE;
          vif.master_cb.PADDR <= trans.PADDR;
          if(trans.PWRITE) vif.master_cb.PWDATA <= trans.PWDATA;
          
          @(vif.master_cb);
          current_state = ACCESS;
        end
        
        ACCESS: begin
          // Drive ACCESS phase signals
          vif.master_cb.PENABLE <= 1;
          
          // Wait for PREADY (may take multiple cycles)
          do begin
            @(vif.master_cb);
          end while (!vif.master_cb.PREADY);
          
          // Capture response
          if(!trans.PWRITE) trans.PRDATA = vif.master_cb.PRDATA;
          trans.PSLVERR = vif.master_cb.PSLVERR;
          trans.PREADY = 1;
          
          // End transfer
          vif.master_cb.PSELx <= 0;
          vif.master_cb.PENABLE <= 0;
          current_state = IDLE;
        end
      endcase
    end
  endtask
endclass
