`timescale 1ns/1ps
// -------------------------------------------------------------
// Testbench: tb_ieee754_exploracao
// Objetivo: varrer operações básicas com padrões do material (4,75; 2,125;
// 9,5; 3,75) e imprimir campos.
// -------------------------------------------------------------
module tb_ieee754_exploracao;

    reg  [31:0] a, b;
    reg  [1:0]  op_sel;
    wire [31:0] result;

    ieee754_exploracao uut (.a(a), .b(b), .op_sel(op_sel), .result(result));

    // utilitário p/ imprimir campos
    task show(input [31:0] x);
        $display("S=%0d E=%0d M=%b", x[31], x[30:23], x[22:0]);
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ieee754_exploracao);

        // 4.75 (0100_0001 0011 0000...); 2.125 (0100_0000 0001 0000...)
        a = 32'b01000000100110000000000000000000; // 4.75
        b = 32'b01000000000001000000000000000000; // 2.125

        // Soma: 6.875
        op_sel = 2'b00; #10;
        $display("[ADD] 4.75 + 2.125 =>"); show(result);

        // Subtração: 2.625 (4.75 - 2.125)
        op_sel = 2'b01; #10;
        $display("[SUB] 4.75 - 2.125 =>"); show(result);

        // Multiplicação: ~10.09375
        op_sel = 2'b10; #10;
        $display("[MUL] 4.75 * 2.125 =>"); show(result);

        // Divisão: ~2.2352941
        op_sel = 2'b11; #10;
        $display("[DIV] 4.75 / 2.125 =>"); show(result);

        // Outro par: 9.5 e 3.75
        a = 32'b01000001000110000000000000000000; // 9.5
        b = 32'b01000000011100000000000000000000; // 3.75

        op_sel = 2'b00; #10; $display("[ADD] 9.5 + 3.75 =>"); show(result);
        op_sel = 2'b01; #10; $display("[SUB] 9.5 - 3.75 =>"); show(result);
        op_sel = 2'b10; #10; $display("[MUL] 9.5 * 3.75 =>"); show(result);
        op_sel = 2'b11; #10; $display("[DIV] 9.5 / 3.75 =>"); show(result);

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
