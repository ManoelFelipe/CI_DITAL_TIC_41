`timescale 1ns / 1ps

module tb_fsm_mealy;

    // Inputs
    reg clk;
    reg reset;
    reg bi;

    // Outputs
    wire bo;

    // Instantiate the Unit Under Test (UUT)
    fsm_mealy uut (
        .clk(clk), 
        .reset(reset), 
        .bi(bi), 
        .bo(bo)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test Stimulus
    initial begin
        // Initialize Inputs
        reset = 1;
        bi = 0;

        // Wait 100 ns for global reset to finish
        #20;
        reset = 0;

        // Test Sequence
        // 1. State A -> A (bi=0)
        #10 bi = 0;
        
        // 2. State A -> B (bi=1) -> Expect bo=1 (Mealy)
        #10 bi = 1; 

        // 3. State B -> C (bi=1) -> Expect bo=0
        #10 bi = 1;

        // 4. State C -> C (bi=1)
        #10 bi = 1;

        // 5. State C -> A (bi=0)
        #10 bi = 0;

        // 6. State A -> B (bi=1) -> Expect bo=1 again
        #10 bi = 1;

        // 7. State B -> A (bi=0)
        #10 bi = 0;

        // End simulation
        #20 $finish;
    end
      
    // Monitor changes
    initial begin
        $monitor("Time=%0t | Reset=%b | State=%b | Input(bi)=%b | Output(bo)=%b", 
                 $time, reset, uut.state_reg, bi, bo);
    end

    // Optional: Generate VCD file for waveform viewing
    initial begin
        $dumpfile("fsm_mealy.vcd");
        $dumpvars(0, tb_fsm_mealy);
    end

endmodule
