// *****************************************************************************
// Class: APB master scoreboard
// Description:
//   Compares expected read data based on previous writes stored in memory.
//   Receives transactions from the monitor through a mailbox and checks correctness.
// *****************************************************************************
import my_pkg::*;
class scoreboard;
  mailbox mon2scb;                      // Receives transactions from the monitor
  bit [31:0] mem[bit];            // Associative array 

  // -------------------------[ Constructor ]-------------------------
  function new(mailbox mon2scb);
    this.mon2scb = mon2scb;
  endfunction

  // -------------------------[ Main Scoreboard Task ]-------------------------
  task main;
    transaction trans;
    forever begin
      // Wait for a transaction from the monitor
      mon2scb.get(trans);
      trans.display("Scoreboard");

      if (trans.PWRITE) begin
        // ---------------------- WRITE OPERATION ----------------------
        // Store the written data in the memory model
        mem[trans.PADDR] = trans.PWDATA;
        $display("[SCOREBOARD] WRITE: Addr = 0x%0h, Data = 0x%0h", 
                  trans.PADDR, trans.PWDATA);
      end
      else begin
        // ---------------------- READ OPERATION -----------------------
        // Check if the address was previously written
        if (mem.exists(trans.PADDR)) begin
          // Compare expected and actual read data
          if (mem[trans.PADDR] === trans.PRDATA) begin
            $display("[SCOREBOARD] READ PASS: Addr = 0x%0h, Data = 0x%0h", 
                      trans.PADDR, trans.PRDATA);
            $display("\n-------------------- Testcase Passed --------------------\n");
          end
          else begin
            $display("[SCOREBOARD] READ FAIL: Addr = 0x%0h, Expected = 0x%0h, Got = 0x%0h", 
                      trans.PADDR, mem[trans.PADDR], trans.PRDATA);
            $error("\n-------------------- Testcase Failed --------------------\n");
          end
        end
        else begin
          // Read from unknown address
          $display("[SCOREBOARD] READ from unknown Addr = 0x%0h, Got = 0x%0h", 
                    trans.PADDR, trans.PRDATA);
          $display("\n-------------------- Testcase Failed --------------------\n");
        end
      end
    end
  endtask
endclass
