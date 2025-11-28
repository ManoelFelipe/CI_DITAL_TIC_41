// ============================================================================
// Arquivo  : tb_ieee754_divider.v  (Testbench)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench dirigido com VCD e flag de sucesso.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps
module tb_ieee754_divider;
    reg  [31:0] a, b;
    wire [31:0] y;
    integer success;

    ieee754_divider dut(.a(a), .b(b), .result(y));

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
        $dumpvars(0, tb_ieee754_divider);
        success = 1;

        // 9.0 (0x41100000) / 3.0 (0x40400000) = 3.0 (0x40400000)
        check(32'h41100000, 32'h40400000, 32'h40400000, "9.0 / 3.0");

        // 10.0 (0x41200000) / 2.5 (0x40200000) = 4.0 (0x40800000)
        check(32'h41200000, 32'h40200000, 32'h40800000, "10.0 / 2.5");

        if (success) $display(">> DIVISOR: TODOS OS TESTES PASSARAM");
        else         $display(">> DIVISOR: FALHAS ENCONTRADAS");

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
