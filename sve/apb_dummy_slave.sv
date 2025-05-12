// *****************************************************************************
// Class: apb_slave
// Description:
//   Models an APB-compliant slave that stores data in a memory array.
//   Responds to APB read and write operations based on PSELx, PENABLE, and PWRITE.
// *****************************************************************************
class apb_slave;

  // ----------------------[ Virtual Interface Handle ]------------------------
  virtual apb_intf vif;

  logic [31:0] mem [*];  

  // -----------------------------[ Constructor ]------------------------------
  function new(virtual apb_intf vif);
    this.vif = vif;
  endfunction

  // ------------------------------[ Main Task ]-------------------------------
  task run();
    // Default outputs
    vif.PRDATA = 32'h0;
    vif.PREADY = 1'b0;

    forever begin
      @(posedge vif.PCLK);

      if (!vif.PRESETn) begin
        vif.PRDATA <= 32'h0;
        vif.PREADY <= 1'b0;
      end else begin
        // APB ready signal asserted 
        vif.PREADY <= 1'b1;

        // ------------------[ READ SETUP Phase ]------------------
        // Prepare PRDATA just before ACCESS phase (cycle before PENABLE is asserted)
        if (vif.PSELx && !vif.PENABLE && !vif.PWRITE) begin
          vif.PRDATA <= mem[vif.PADDR];
        end

        // ------------------[ READ ACCESS Phase ]-----------------
        if (vif.PSELx && vif.PENABLE && !vif.PWRITE) begin
          $display("[%0t] Slave READ  | ADDR = 0x%0h | RDATA = 0x%0h", 
                    $time, vif.PADDR, vif.PRDATA);
        
        // ------------------[ WRITE ACCESS Phase ]----------------
        end else if (vif.PSELx && vif.PENABLE && vif.PWRITE) begin
          mem[vif.PADDR] = vif.PWDATA;
          $display("[%0t] Slave WRITE | ADDR = 0x%0h | DATA  = 0x%0h", 
                    $time, vif.PADDR, vif.PWDATA);
        end
      end
    end
  endtask

endclass
