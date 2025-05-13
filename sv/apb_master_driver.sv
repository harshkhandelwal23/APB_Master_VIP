import my_pkg::*;
`define DRIV_IF apb_vif.DRIVER.driver_cb
// ***************************************************************************
// Class: APB_Master_driver
// Description:
//   This class drives APB transactions to the DUT (Design Under Test) using
//   a simple FSM-based approach. It receives transactions from the generator
//   via a mailbox and drives them onto the APB interface in accordance with
//   the APB4 protocol.
// ***************************************************************************
class driver;
  // Virtual interface to drive APB signals
  virtual apb_intf apb_vif;
  // Mailbox to receive transactions from the generator
  mailbox gen2drv;

  transaction trans;

  // Enum: apb_state
  //   Represents the three main states of APB protocol
  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10
  } apb_state;

  apb_state state;

  // Constructor
  function new(virtual apb_intf apb_vif, mailbox gen2drv);
    this.apb_vif = apb_vif;
    this.gen2drv = gen2drv;
  endfunction

  // Task: reset
  // Drives default values during reset and waits for deassertion.
  task reset();
    wait(!apb_vif.PRESETn);  // Wait for reset assertion
    $display("-----------[DRIVER] Reset Started----------");
    `DRIV_IF.PWRITE  <= 0;
    `DRIV_IF.PSELx   <= 0;
    `DRIV_IF.PADDR   <= 0;
    `DRIV_IF.PWDATA  <= 0;
    `DRIV_IF.PENABLE <= 0;
    state = IDLE;
    wait(apb_vif.PRESETn);  // Wait for reset deassertion
    $display("---------[DRIVER] Reset Ended---------------");
  endtask

  // Task: main
  // Implements the FSM to drive transactions to the DUT using the APB4 protocol.
  task main();
    forever @(posedge apb_vif.PCLK) begin
      case (state)
        // IDLE: Default state. No transfer in progress.
        IDLE: begin
          $display("-----------------IDLE PHASE------------------------");
          `DRIV_IF.PSELx   <= 0;
          `DRIV_IF.PENABLE <= 0;
          state <= SETUP;
        end

        // SETUP: Start of new APB transaction.
        // Read from mailbox and set up signals.
        SETUP: begin
          $display("-----------------SETUP PHASE------------------------");
          `DRIV_IF.PSELx   <= 1;
          `DRIV_IF.PENABLE <= 0;
          gen2drv.get(trans);  // Get next transaction
          `DRIV_IF.PWRITE  <= trans.PWRITE;
          `DRIV_IF.PADDR   <= trans.PADDR;
          if (trans.PWRITE)
            `DRIV_IF.PWDATA <= trans.PWDATA;
          trans.display("DRIVER");
          state <= ACCESS;
          $display(" setup phase display PSELx = %0b, PENABLE = %0b, PWRITE = %0b, PADDR = %0h, PWDATA = %0h, PRDATA = %0h, state = %p", 
             trans.PSELx, trans.PENABLE, trans.PWRITE, trans.PADDR, trans.PWDATA, trans.PRDATA, state.name());
        end

        // ACCESS: Drive PENABLE, wait for PREADY from slave.
        ACCESS: begin
          $display("-----------------ACCESS PHASE------------------------");
          `DRIV_IF.PENABLE <= 1;

          // Wait here until PREADY is high
          if (!`DRIV_IF.PREADY)
            state <= ACCESS;
          else
            state <= SETUP;
        end

        // Default fallback (shouldn't be hit ideally)
        default: state <= IDLE;
      endcase
    end
  endtask

endclass
