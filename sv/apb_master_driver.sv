import my_pkg::*;
`define DRIV_IF apb_vif.DRIVER.driver_cb
class driver;
  virtual apb_intf apb_vif;
  mailbox gen2drv;
  transaction trans;
  typedef enum logic [1:0] {
    IDLE   = 2'b00,
    SETUP  = 2'b01,
    ACCESS = 2'b10
    } apb_state;

    apb_state state, next_state;

    function new(virtual apb_intf apb_vif, mailbox gen2drv);
      this.apb_vif = apb_vif;
      this.gen2drv = gen2drv;
    endfunction

    task reset;
      wait(!apb_vif.PRESETn);
        $display("-----------[DRIVER] Reset Started----------");
        `DRIV_IF.PWRITE <= 0;
        `DRIV_IF.PSELx <= 0;
        `DRIV_IF.PADDR <= 0;
        `DRIV_IF.PWDATA <= 0;
        `DRIV_IF.PENABLE <= 0;
         state = IDLE;
        wait(apb_vif.PRESETn);
        $display("---------[DRIVER] Reset Ended---------------");
    endtask

    task main;
        forever 
          begin
            gen2drv.get(trans); //get data from mailbox
            @(posedge apb_vif.PCLK) //on the posedge clk
              case (state) // state are IDLE , SETUP, ACCESS
                IDLE: //first state
                  begin
                    `DRIV_IF.PSELx <= 0; //drive psel = 0
                    `DRIV_IF.PENABLE <= 0;//drive penable = 0
                    state <= SETUP; //next state is setup compulsorily
                  end

                SETUP: 
                  begin
                    `DRIV_IF.PSELx <= 1;//drive psel = 1 so the slave is selected in this state
                    `DRIV_IF.PENABLE <= 0; //drive penable = 0
                    `DRIV_IF.PWRITE <= trans.PWRITE; //get pwrite from transaction class
                    `DRIV_IF.PADDR <= trans.PADDR; //get paddr from transaction class
                       if(trans.PWRITE) //if pwrite =1 then write pwdata
                         `DRIV_IF.PWDATA <= trans.PWDATA;
                    state <= ACCESS;//next state compulsorily access
                  end

              ACCESS: 
                  begin
                    `DRIV_IF.PENABLE <= 1;//drive penable =1 according to the operating states
                      if (!`DRIV_IF.PREADY)//if pready is = 0 the stay in the access phase only   
                        begin
                          state <= ACCESS; 
                        end 
                      else if (`DRIV_IF.PSELx) //otherwise when pready = 1 then if psel =1
                        begin
                          state <= SETUP;//then setup phase
                        end 
                           else
                             state <= IDLE;//otherwise idle phase
                  end
              endcase
            trans.display("DRIVER");
          end
    endtask
endclass
