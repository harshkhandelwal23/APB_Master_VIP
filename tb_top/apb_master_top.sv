`include "../sve/apb_master_test.sv"
// Testbench Top
module top;
  logic PCLK;
  logic PRESETn;

  always #5 PCLK = ~PCLK;

  initial begin
    PCLK = 0;
    PRESETn = 0;
    #10 PRESETn = 1;
  end

  apb_intf intf(PCLK, PRESETn);

  test t1;

  initial begin
    t1 = new(intf);
    t1.run();
  end

  initial begin
    $dumpfile("APB.vcd");
    $dumpvars(0, top);
  end

  initial begin
    #500;
    $finish;
  end
endmodule
