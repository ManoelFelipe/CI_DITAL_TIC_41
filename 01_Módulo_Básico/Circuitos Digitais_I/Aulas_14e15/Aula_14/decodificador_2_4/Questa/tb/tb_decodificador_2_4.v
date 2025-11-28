// -----------------------------------------------------------------------------
// Arquivo     : tb_decodificador_2_4.v
// Testbench   : tb_decodificador_2_4
// Autor       : Manoel Furtado
// Data        : 31/10/2025
// Objetivo    : Exercitar o módulo decodificador_2_4 em 3 FASES:
//               FASE 1 — Ex.1: Decodificador 2×4 (Y0..Y3) com C=0
//               FASE 2 — Ex.2: f2 = ~B  (usando Y0 | Y2)
//               FASE 3 — Ex.3: f3 = ~C * (Y1 | Y2)
// Observação  : Gera wave.vcd, imprime tabelas com $display e finaliza limpo.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps                     // Unidade/precisão de tempo

module tb_decodificador_2_4;           // Início do testbench (sem portas)

    // --------- Estímulos (registradores dirigidos por 'initial') ------------
    reg A;                             // Entrada A do DUT
    reg B;                             // Entrada B do DUT
    reg C;                             // Entrada C do DUT

    // --------- Observação das saídas do DUT ---------------------------------
    wire Y0;                           // Saída Y0 (AB=00)
    wire Y1;                           // Saída Y1 (AB=01)
    wire Y2;                           // Saída Y2 (AB=10)
    wire Y3;                           // Saída Y3 (AB=11)
    wire f2;                           // Saída f2 (Ex.2)
    wire f3;                           // Saída f3 (Ex.3)

    // --------- Instancia o DUT (Device Under Test) ---------------------------
    decodificador_2_4 DUT (
        .A(A), .B(B), .C(C),          // Liga entradas do TB às entradas do DUT
        .Y0(Y0), .Y1(Y1), .Y2(Y2), .Y3(Y3), // Liga observáveis Y0..Y3
        .f2(f2), .f3(f3)              // Liga observáveis f2/f3
    );

    // --------- Geração de VCD para visualização de ondas ---------------------
    initial begin
        $dumpfile("wave.vcd");         // Nome do arquivo de ondas
        $dumpvars(0, tb_decodificador_2_4); // Exporta todos os sinais do TB/DUT
    end

    // --------- Sequência de estímulos e impressões ---------------------------
    initial begin
        // Cabeçalho geral do teste
        $display("\\n=== TESTE: decodificador_2_4 ===");
        $display("Tempo | A B C | Y0 Y1 Y2 Y3 | f2 | f3");

        // ======================= FASE 1 — Exercício 1 ========================
        $display("\\n[FASE 1] Ex.1 — Decodificador 2x4 (C=0)");
        C = 1'b0;                      // C não interfere no Ex.1 (mantém 0)

        // Varredura AB = 00, 01, 10, 11 com passo de 10 ns
        A=1'b0; B=1'b0;  #10; $display("%4t | %0d %0d %0d |  %0d  %0d  %0d  %0d |  %0d |  %0d",
                                        $time,A,B,C,Y0,Y1,Y2,Y3,f2,f3);
        A=1'b0; B=1'b1;  #10; $display("%4t | %0d %0d %0d |  %0d  %0d  %0d  %0d |  %0d |  %0d",
                                        $time,A,B,C,Y0,Y1,Y2,Y3,f2,f3);
        A=1'b1; B=1'b0;  #10; $display("%4t | %0d %0d %0d |  %0d  %0d  %0d  %0d |  %0d |  %0d",
                                        $time,A,B,C,Y0,Y1,Y2,Y3,f2,f3);
        A=1'b1; B=1'b1;  #10; $display("%4t | %0d %0d %0d |  %0d  %0d  %0d  %0d |  %0d |  %0d",
                                        $time,A,B,C,Y0,Y1,Y2,Y3,f2,f3);

        // ======================= FASE 2 — Exercício 2 ========================
        $display("\\n[FASE 2] Ex.2 — f(A,B)=A'B' + AB' = ~B");
        C = 1'b0;                      // C irrelevante para f2 (mantém 0)
        $display("A B | f2 (esperado=~B)");

        // Tabela verdade de f2 (independe de A)
        A=1'b0; B=1'b0;  #10; $display("%0d %0d |  %0d", A,B,f2);
        A=1'b0; B=1'b1;  #10; $display("%0d %0d |  %0d", A,B,f2);
        A=1'b1; B=1'b0;  #10; $display("%0d %0d |  %0d", A,B,f2);
        A=1'b1; B=1'b1;  #10; $display("%0d %0d |  %0d", A,B,f2);

        // ======================= FASE 3 — Exercício 3 ========================
        $display("\\n[FASE 3] Ex.3 — f(A,B,C)=A B' C' + A' B C' = ~C*(Y2+Y1)");
        $display("A B C | f3");

        // Primeiro com C=0 (f3 equivale a A XOR B)
        C=1'b0;
        A=1'b0; B=1'b0;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);
        A=1'b0; B=1'b1;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);
        A=1'b1; B=1'b0;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);
        A=1'b1; B=1'b1;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);

        // Depois com C=1 (máscara zera f3)
        C=1'b1;
        A=1'b0; B=1'b0;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);
        A=1'b0; B=1'b1;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);
        A=1'b1; B=1'b0;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);
        A=1'b1; B=1'b1;  #10; $display("%0d %0d %0d |  %0d", A,B,C,f3);

        // Encerramento limpo
        $display("\\nFim da simulacao."); // Mensagem final amigável
        $finish;                           // Termina a simulação
    end
endmodule                                   // Fim do testbench
