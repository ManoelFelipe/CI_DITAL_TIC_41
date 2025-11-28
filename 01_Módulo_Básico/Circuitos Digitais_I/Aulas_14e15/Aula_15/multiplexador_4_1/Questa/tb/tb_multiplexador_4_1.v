`timescale 1ns/1ps
// ====================================================================
// Testbench: tb_multiplexador_4_1
// Autor   : Manoel Furtado
// Data    : 31/10/2025
// Objetivo: Validar o MUX 4x1 em três frentes:
//   (Ex.1) Sequência de formas de onda como na figura;
//   (Ex.2) Implementação de f(A,B) = ~B usando o MUX;
//   (Ex.3) Implementação de f(A,B,C) = A·~B·~C + ~A·B·~C usando o MUX.
// Compatível com Questa e Quartus (Verilog‑2001).
// ====================================================================

module tb_multiplexador_4_1;
    // ------------------------- DUT (Ex.1) ----------------------------
    reg  d0, d1, d2, d3;   // Entradas de dados
    reg  s1, s0;           // Seleções
    wire y;                // Saída do MUX (Ex.1)

    // Instância do MUX para o Exercício 1
    multiplexador_4_1 dut_ex1 (
        .d0(d0), .d1(d1), .d2(d2), .d3(d3),
        .s1(s1), .s0(s0),
        .y(y)
    );

    // ------------------------- DUT (Ex.2) ----------------------------
    reg  A, B;             // Entradas lógicas da função f(A,B)
    wire f_ab;             // Saída da função f(A,B) = ~B (usando MUX)

    // Mapeamento para obter f(A,B) = ~B:
    // Seleções = {A,B}; Entradas constantes: D0=1, D1=0, D2=1, D3=0
    // Assim, quando B=0 => y=1; quando B=1 => y=0; independente de A.
    multiplexador_4_1 dut_ex2 (
        .d0(1'b1), .d1(1'b0), .d2(1'b1), .d3(1'b0),
        .s1(A), .s0(B),
        .y(f_ab)
    );

    // ------------------------- DUT (Ex.3) ----------------------------
    reg  C;                // Entrada extra da função f(A,B,C)
    wire f_abc;            // Saída da função f(A,B,C)

    // f(A,B,C) = A·~B·~C + ~A·B·~C = ~C · (A xor B)
    // Usando MUX com seleções {A,B} e entradas D0=0, D1=~C, D2=~C, D3=0
    wire nC = ~C;
    multiplexador_4_1 dut_ex3 (
        .d0(1'b0), .d1(nC), .d2(nC), .d3(1'b0),
        .s1(A), .s0(B),
        .y(f_abc)
    );

    // --------------------- Geração de formas (Ex.1) ------------------
    // Padrões distintos nas entradas para reproduzir a ideia da figura.
    initial begin
        d0 = 0; d1 = 0; d2 = 0; d3 = 0;
        s0 = 0; s1 = 0;
        // d0 alterna a cada 10 ns; d1 a cada 20 ns; d2 a cada 30 ns; d3 a cada 40 ns
        // s0 alterna a cada 15 ns; s1 muda mais devagar (a cada 60 ns)
    end

    always #10 d0 = ~d0;  // Entrada 0
    always #20 d1 = ~d1;  // Entrada 1
    always #30 d2 = ~d2;  // Entrada 2
    always #40 d3 = ~d3;  // Entrada 3

    always #15 s0 = ~s0;  // Seleção LSB
    always #60 s1 = ~s1;  // Seleção MSB

    // -------------------- Estímulos p/ Ex.2 e Ex.3 -------------------
    // Varredura completa da tabela-verdade para (A,B) e (A,B,C)
    integer i;
    initial begin
        A = 0; B = 0; C = 0;
        // Aguarda um pouco para observar Ex.1
        #5;
        $display("==== Iniciando testes (Ex.2 e Ex.3) ====\n");
        $display("A B | f(A,B)=~B | C | f(A,B,C)=~C*(A^B)");
        for (i = 0; i < 8; i = i + 1) begin
            {A,B,C} = i[2:0]; // Atribuição combinada: percorre A,B,C
            #5;               // Tempo para propagação
            $display("%0d %0d |     %0d     | %0d |        %0d",
                     A, B, f_ab, C, f_abc);
        end
        $display("==== Fim dos testes logicos ====");
    end

    // --------------------- Dump de ondas (VCD) ------------------------
    initial begin
        $dumpfile("wave.vcd");                 // Arquivo VCD
        $dumpvars(0, tb_multiplexador_4_1);    // Exporta todos os sinais
    end

    // --------------------- Encerramento limpo -------------------------
    initial begin
        // Duração total da simulação (ajuste conforme necessidade)
        #200;
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
