import my_pkg::*;
// Test class
class apb_test;
  apb_environment env;
  
  function new(virtual apb_if vif);
    env = new(vif);
  endfunction
  
  task run();
    env.generator.transaction_count = 20; // Set number of transactions
    env.run();
  endtask
endclass
