`timescale 1ns/1ps
// =============================================================
// Testbench: tb_ponto_fixo_8.v  (FIXED: sem declaracoes locais em blocos unnamed)
// Autor: Manoel Furtado | Data: 10/11/2025
// =============================================================
module tb_ponto_fixo_8;
    // ---- Sinais do DUT ----
    reg  [7:0] a, b;      // Entradas Q4.4
    reg        sel;       // 0 = soma | 1 = subtracao
    wire [7:0] result;    // Saida Q4.4
    wire       overflow;  // Flag de overflow

    // DUT (pode apontar para qualquer implementacao — behavioral por padrao)
    ponto_fixo_8 dut(.a(a), .b(b), .sel(sel), .result(result), .overflow(overflow));

    // ---------------- Simulacao ----------------
    initial begin
        // VCD
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ponto_fixo_8);

        $display("=== Simulacao ponto_fixo_8 (Q4.4) ===");

        // Caso 1: 1.5 + 0.5 = 2.0
        a = 8'b0001_1000; b = 8'b0000_1000; sel = 1'b0; #10;
        $display("Soma:  a=%b (%.2f) + b=%b (%.2f) = %b (%.2f) | ovf=%0d",
                 a, $itor($signed(a))/16.0, b, $itor($signed(b))/16.0,
                 result, $itor($signed(result))/16.0, overflow);

        // Caso 2: 2.0 - 0.5 = 1.5
        a = 8'b0010_0000; b = 8'b0000_1000; sel = 1'b1; #10;
        $display("Sub:   a=%b (%.2f) - b=%b (%.2f) = %b (%.2f) | ovf=%0d",
                 a, $itor($signed(a))/16.0, b, $itor($signed(b))/16.0,
                 result, $itor($signed(result))/16.0, overflow);

        // Caso 3: Overflow (teste) 7.0 + 4.0 = overflow
        a = 8'b0111_0000; b = 8'b0100_0000; sel = 1'b0; #10;
        $display("OVF:   a=%b (%.2f) + b=%b (%.2f) = %b (%.2f) | ovf=%0d",
                 a, $itor($signed(a))/16.0, b, $itor($signed(b))/16.0,
                 result, $itor($signed(result))/16.0, overflow);

        $display("Fim da simponto_fixo_8cao.");
        $finish;
    end
endmodule
