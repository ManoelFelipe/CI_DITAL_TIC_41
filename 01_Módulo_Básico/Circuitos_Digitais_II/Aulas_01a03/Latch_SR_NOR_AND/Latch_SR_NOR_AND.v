// ============================================================================
// Arquivo  : Latch_SR_NOR_AND.v  (implementação behavioral)
// Autor    : Manoel Furtado
// Data     : 19/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Atividade 12 - Aula 1 - Disciplina Circuitos 2
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

//====================================================
// Latch SR com NOR (entradas ativas em nível ALTO)
//====================================================
module sr_latch_nor (
    input  wire S,   // Set  (ativo em 1)
    input  wire R,   // Reset(ativo em 1)
    output reg  Qa,  // Saída principal
    output wire Qb   // Saída complementar
);

    // Complemento de Qa
    assign Qb = ~Qa;

    // Estado inicial pedido no enunciado: Qa = 0
    initial begin
        Qa = 1'b0;
    end

    // Tabela de funcionamento:
    // S R | Próximo Qa
    // 0 0 -> mantém (latch/memória)
    // 1 0 -> 1 (SET)
    // 0 1 -> 0 (RESET)
    // 1 1 -> x (condição proibida)
    always @* begin
        case ({S, R})
            2'b00: Qa = Qa;      // memória
            2'b10: Qa = 1'b1;    // SET
            2'b01: Qa = 1'b0;    // RESET
            2'b11: Qa = 1'bx;    // proibido (S=R=1)
            default: Qa = 1'bx;
        endcase
    end

endmodule


//====================================================
// Latch SR "equivalente" com NAND
// Interface externa continua ativa em nível ALTO,
// mas internamente S/R são invertidos para um
// latch SR típico com NAND (entradas ativas em 0).
//====================================================
module sr_latch_nand (
    input  wire S,   // Set  (ativo em 1 - interface externa)
    input  wire R,   // Reset(ativo em 1 - interface externa)
    output reg  Qa,  // Saída principal
    output wire Qb   // Saída complementar
);

    assign Qb = ~Qa;

    // Mesmo estado inicial do enunciado
    initial begin
        Qa = 1'b0;
    end

    // Aqui eu já uso diretamente a "versão equivalente"
    // do latch NAND, mas com entradas ativas em 1:
    //
    // S R | Próximo Qa
    // 0 0 -> mantém (latch/memória)
    // 1 0 -> 1 (SET)
    // 0 1 -> 0 (RESET)
    // 1 1 -> x (proibido)
    //
    // Ou seja: mesma tabela do NOR, o que facilita comparar
    // as duas formas de onda.
    always @* begin
        case ({S, R})
            2'b00: Qa = Qa;      // memória
            2'b10: Qa = 1'b1;    // SET
            2'b01: Qa = 1'b0;    // RESET
            2'b11: Qa = 1'bx;    // proibido
            default: Qa = 1'bx;
        endcase
    end

endmodule
