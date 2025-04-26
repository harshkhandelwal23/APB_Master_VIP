import my_pkg::*;
// APB4 Generator
class apb_generator;
  int transaction_count;
  mailbox gen2drv;
  event gen_done;
  
  function new(mailbox gen2drv, event gen_done);
    this.gen2drv = gen2drv;
    this.gen_done = gen_done;
    this.transaction_count = 10; // Default count
  endfunction
  
  task run();
    apb_transaction tx;
    
    for(int i = 0; i < transaction_count; i++) begin
      tx = new();
      if(!tx.randomize()) begin
        $fatal("Generator: Transaction randomization failed!");
      end
      $display("[%0t] Generator: Transaction %0d created", $time, i);
      tx.display("Generator");
      gen2drv.put(tx);
      #5; // Some delay between transactions
    end
    
    -> gen_done; // Signal generator is done
    $display("[%0t] Generator: All %0d transactions generated", $time, transaction_count);
  endtask
endclass
