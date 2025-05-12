`include "../sv/apb_master_environment.sv"
`include "../sv/apb_master_interface.sv"
`include "apb_dummy_slave.sv"
// *****************************************************************************
// Class: test
// Description:
//   Top-level test class that connects the environment and APB slave model.
//   It selects the test scenario based on command-line plusargs and coordinates
//   the run sequence of environment and slave.
// *****************************************************************************
class test;
  environment env;
  apb_slave slave;
  virtual apb_intf intf;

  // -----------------------------[ Constructor ]------------------------------
  function new(virtual apb_intf intf);
    this.intf = intf;
    env = new(intf);        // Create environment instance
    slave = new(intf);      // Create slave model instance
  endfunction

  // -----------------------------[ Main Run Task ]----------------------------
  task run();
    fork
      testcase();           // Select and run the appropriate testcase
      env.run();            // Start environment (driver, monitor, scoreboard)
      slave.run();          // Start slave logic
    join
  endtask

  // -----------------------------[ Testcase Selector ]------------------------
  task testcase();
    // Command-line switch for TEST1: single write and read
    if ($test$plusargs("TEST1")) begin
      env.gen.sanity();
    
    // Command-line switch for TEST2: random mix of read/write transactions
    end else if ($test$plusargs("TEST2")) begin
      env.gen.random(10);
    end
  endtask

endclass
