`include "../sve/apb_master_test.sv"
`include "../sv/apb_master_package.sv"
// Testbench Top
module top;
  logic pclk;
  logic preset_n;
  
  // Clock generation
  initial begin
    pclk = 0;
    forever #5 pclk = ~pclk;
  end
  
  // Reset generation
  initial begin
    preset_n = 0;
    #20 preset_n = 1;
  end
  
  // APB interface instantiation
  apb_if apb_if_inst(pclk, preset_n);
  
  // Dummy slave instantiation
  //dummy_apb_slave slave(apb_if_inst.SLAVE);
  
  // Test instance
  apb_test test;
  
  initial begin
    // Create test
    test = new(apb_if_inst);
    
    // Run test
    test.run();
    
    // End simulation
    #1000;
    $display("Simulation completed!");
    $finish;
  end
  
  // Dumping waveforms for EPWave
  initial begin
    $dumpfile("apb4_master_vip.vcd");
    $dumpvars(0, top);
  end
endmodule
