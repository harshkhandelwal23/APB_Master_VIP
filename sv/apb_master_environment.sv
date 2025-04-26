import my_pkg::*;
// APB4 Environment
class apb_environment;
  apb_generator   generator;
  apb_driver      driver;
  apb_monitor     monitor;
  apb_scoreboard  scoreboard;
  
  mailbox gen2drv;
  mailbox drv2scb;
  mailbox mon2scb;
  
  virtual apb_if vif;
  event gen_done;
  
  function new(virtual apb_if vif);
    this.vif = vif;
    
    gen2drv = new();
    drv2scb = new();
    mon2scb = new();
    
    generator  = new(gen2drv, gen_done);
    driver     = new(vif.MASTER, gen2drv, drv2scb);
    monitor    = new(vif.MONITOR, mon2scb);
    scoreboard = new(drv2scb, mon2scb);
  endfunction
  
  task pre_test();
    driver.reset();
  endtask
  
  task test();
    fork
      generator.run();
      driver.run();
      monitor.run();
      scoreboard.run();
    join_any
  endtask
  
  task post_test();
    wait(gen_done.triggered);
    wait(generator.transaction_count == driver.transactions_done);
    #100;
    scoreboard.report();
  endtask
  
  task run();
    pre_test();
    test();
    post_test();
  endtask
endclass
