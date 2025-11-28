
`timescale 1ns/1ps
// ===============================================================
// Testbench: tb_multiplex_N_1
// ===============================================================
module tb_multiplex_N_1;
    localparam integer N = 4;
    reg  [N-1:0] din;
    reg  [1:0]   sel;
    wire y_beh, y_dat, y_str;

    // Instâncias (assumem que o nome do módulo é o mesmo)
    multiplex_N_1 #(.N(N)) dut_behavioral (.din(din), .sel(sel), .y(y_beh));
    multiplex_N_1 #(.N(N)) dut_dataflow    (.din(din), .sel(sel), .y(y_dat));
    multiplex_N_1 #(.N(N)) dut_structural  (.din(din), .sel(sel), .y(y_str));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_multiplex_N_1);
    end

    integer i;
    initial begin
        $display("\n=== Teste do multiplexador N=4 (t=%0t) ===", $time);
        $display("din sel | y_beh y_dat y_str");
        for (i = 0; i < 16; i = i + 1) begin
            {din, sel} = i[5:0];
            #5;
            $display("%b  %0d |   %b     %b     %b", din, sel, y_beh, y_dat, y_str);
        end
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
