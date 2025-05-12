// *****************************************************************************
// Class: environment
// Description:
//   integration class that connects generator, driver, monitor,
//   and scoreboard. Manages simulation flow using mailboxes and virtual interface.
// *****************************************************************************
import my_pkg::*;
class environment;
  generator gen;
  driver driv;
  monitor mon;
  scoreboard scb;

  mailbox gen2drv;   // Generator to driver communication
  mailbox mon2scb;   // Monitor to scoreboard communication

  virtual apb_intf apb_vif;  // Virtual interface for APB

  // -------------------------[ Constructor ]-------------------------
  function new(virtual apb_intf apb_vif);
    this.apb_vif = apb_vif;

    // Initialize mailboxes
    gen2drv = new();
    mon2scb = new();

    // Create component instances and pass appropriate arguments
    gen  = new(gen2drv);
    driv = new(apb_vif, gen2drv);
    mon  = new(apb_vif, mon2scb);
    scb  = new(mon2scb);
  endfunction

  // -------------------------[ Reset Phase ]-------------------------
  task pre_test();
    driv.reset(); // Assert and deassert reset via driver
  endtask

  // -------------------------[ Test Phase ]-------------------------
  task test();
    fork
      driv.main();  // Drive transactions to DUT
      mon.main();   // Monitor signals from DUT
      scb.main();   // Compare expected vs actual using scoreboard
    join
  endtask

  // -------------------------[ Run Sequence ]-------------------------
  task run;
    pre_test();  // Reset DUT
    test();      // Execute main test
  endtask
endclass
