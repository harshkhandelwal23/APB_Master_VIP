// ***************************************************************************
// Class: APB_master_Generator
// Description:
//   This class generates random transactions for the APB bus 
// Methods:
//   - sanity: This task runs the first test case where one write and one 
//     read transaction are generated
//   - directed: This task generates five read and write 
//     transactions
// ***************************************************************************
import my_pkg::*;
class generator;
  mailbox gen2drv; //Mailbox to communicate with driver
  rand transaction trans;

  // Constructor: Initializes the generator with a mailbox to the driver
  function new(mailbox gen2drv);
    this.gen2drv = gen2drv;  // Assign the provided mailbox to the generator
  endfunction

  // -----------------------------[ TESTCASE 1 ]-----------------------------
  task sanity();
    trans = new();
    trans.randomize() with {PWRITE == 1; PADDR  == 32'h70;}; // Generate a write transaction (PWRITE = 1)
    gen2drv.put(trans);  // Send the transaction to the driver
    trans.display("Generator");  // Display the generated transaction
    trans = new();
    trans.randomize() with {PWRITE == 0; PADDR  == 32'h70;}; // Generate a read transaction (PWRITE = 0) 
    gen2drv.put(trans);  // Send the transaction to the driver
    trans.display("Generator");  // Display the generated transaction
  endtask

  // -----------------------------[ TESTCASE 2 ]-----------------------------
  // Directed test: Generates five read and write transactions.
  task directed();
  bit [31:0] addr_list[5] = '{32'h70, 32'h80, 32'h90, 32'h54, 32'h40};
  bit [31:0] addr_list1 [5] = '{32'h40, 32'h54, 32'h90, 32'h80, 32'h70};
  // Write transactions
  foreach (addr_list[i]) begin
    trans = new();
    trans.randomize() with { PWRITE == 1; };
    trans.PADDR = addr_list[i];
    gen2drv.put(trans);
    trans.display("Generator");
  end

  // Read transactions
  foreach (addr_list[i]) begin
    trans = new();
    trans.randomize() with { PWRITE == 0; };
    trans.PADDR = addr_list[i];
    gen2drv.put(trans);
    trans.display("Generator");
  end
endtask

endclass
