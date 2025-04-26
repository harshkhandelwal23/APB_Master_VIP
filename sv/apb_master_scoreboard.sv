import my_pkg::*;
// APB4 Scoreboard
class apb_scoreboard;
  mailbox drv2scb;
  mailbox mon2scb;
  int match_count;    // Renamed from "matches" to fix the syntax error
  int mismatch_count; // Renamed from "mismatches" for consistency
  
  function new(mailbox drv2scb, mailbox mon2scb);
    this.drv2scb = drv2scb;
    this.mon2scb = mon2scb;
    this.match_count = 0;
    this.mismatch_count = 0;
  endfunction
  
  task run();
    apb_transaction tx_drv, tx_mon;
    
    forever begin
      drv2scb.get(tx_drv);
      mon2scb.get(tx_mon);
      
      if(tx_drv.addr != tx_mon.addr) begin
        $error("Scoreboard: Address mismatch! Driver=%0h, Monitor=%0h", tx_drv.addr, tx_mon.addr);
        mismatch_count++;
      end else if(tx_drv.wr_rd != tx_mon.wr_rd) begin
        $error("Scoreboard: Operation mismatch! Driver=%0s, Monitor=%0s", 
               tx_drv.wr_rd ? "WRITE" : "READ", tx_mon.wr_rd ? "WRITE" : "READ");
        mismatch_count++;
      end else if(tx_drv.wr_rd && (tx_drv.data != tx_mon.data)) begin
        $error("Scoreboard: Write data mismatch! Driver=%0h, Monitor=%0h", tx_drv.data, tx_mon.data);
        mismatch_count++;
      end else if(!tx_drv.wr_rd && (tx_drv.rdata != tx_mon.rdata)) begin
        $error("Scoreboard: Read data mismatch! Driver=%0h, Monitor=%0h", tx_drv.rdata, tx_mon.rdata);
        mismatch_count++;
      end else begin
        $display("[%0t] Scoreboard: Transaction match!", $time);
        match_count++;
      end
    end
  endtask
  
  function void report();
    $display("\n--- Scoreboard Report ---");
    $display("Total transactions: %0d", match_count + mismatch_count);
    $display("Matches: %0d", match_count);
    $display("Mismatches: %0d", mismatch_count);
    $display("------------------------\n");
  endfunction
endclass
