// ============================================================================
// Arquivo  : tb_ieee754_subtractor.v  (Testbench)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench com vetores dirigidos e verificação automática.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps
module tb_ieee754_subtractor;
    reg  [31:0] a, b;
    wire [31:0] y;
    integer success;

    ieee754_subtractor uut(.a(a), .b(b), .result(y));

    task check(input [31:0] aa, input [31:0] bb, input [31:0] exp_hex, input [127:0] msg);
        begin
            a = aa; b = bb; #10;
            if (y !== exp_hex) begin
                $display("FALHA %0s: got=%08x exp=%08x", msg, y, exp_hex);
                success = 0;
            end else begin
                $display("OK    %0s: %08x", msg, y);
            end
        end
    endtask

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ieee754_subtractor);
        success = 1;

        // 4.75 (0x40980000) - 2.125 (0x40080000) = 2.625 (0x40280000)
        check(32'h40980000, 32'h40080000, 32'h40280000, "4.75 - 2.125");

        // 9.5 (0x41180000) - 3.75 (0x40700000) = 5.75 (0x40B80000)
        check(32'h41180000, 32'h40700000, 32'h40B80000, "9.5 - 3.75");

        if (success) $display(">> SUBTRATOR: TODOS OS TESTES PASSARAM");
        else         $display(">> SUBTRATOR: FALHAS ENCONTRADAS");

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
