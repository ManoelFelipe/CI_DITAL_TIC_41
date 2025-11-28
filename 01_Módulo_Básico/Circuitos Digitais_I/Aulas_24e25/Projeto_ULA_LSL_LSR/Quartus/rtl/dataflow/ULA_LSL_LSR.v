// ============================================================================
// Arquivo  : ULA_LSL_LSR.v  (implementação dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação em estilo dataflow de uma ULA de 4 bits.
//            Toda a lógica é descrita por meio de expressões contínuas
//            (assign) e operadores aritméticos/lógicos. O seletor de 3 bits
//            escolhe entre oito operações: AND, OR, NOT(A), NAND, soma,
//            subtração, LSL(A) e LSR(A). Não há registradores internos,
//            preservando comportamento puramente combinacional e latência zero.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Módulo: ULA_LSL_LSR (implementação dataflow)
// ---------------------------------------------------------------------------
// Portas:
//   A        : operando A de 4 bits
//   B        : operando B de 4 bits
//   seletor  : código da operação (3 bits)
//   resultado: saída combinacional de 4 bits
// ---------------------------------------------------------------------------
module ULA_LSL_LSR (
    input  wire [3:0] A,         // Operando A de 4 bits
    input  wire [3:0] B,         // Operando B de 4 bits
    input  wire [2:0] seletor,   // Seletor da operação (3 bits)
    output wire [3:0] resultado  // Resultado da operação (wire)
);
    // -----------------------------------------------------------------------
    // Sinais internos para cada operação elementar.
    // Cada wire é calculado continuamente a partir de A e/ou B.
    // -----------------------------------------------------------------------
    wire [3:0] and_result;       // Resultado da operação AND
    wire [3:0] or_result;        // Resultado da operação OR
    wire [3:0] not_result;       // Resultado da operação NOT(A)
    wire [3:0] nand_result;      // Resultado da operação NAND
    wire [3:0] add_result;       // Resultado da soma A + B
    wire [3:0] sub_result;       // Resultado da subtração A - B
    wire [3:0] lsl_result;       // Resultado do deslocamento lógico para a esquerda
    wire [3:0] lsr_result;       // Resultado do deslocamento lógico para a direita

    // -----------------------------------------------------------------------
    // Definição das operações em estilo dataflow (assign contínuos).
    // -----------------------------------------------------------------------
    assign and_result  = A & B;                  // AND bit a bit
    assign or_result   = A | B;                  // OR  bit a bit
    assign not_result  = ~A;                     // NOT apenas em A
    assign nand_result = ~(A & B);               // NAND bit a bit
    assign add_result  = A + B;                  // Soma (truncada em 4 bits)
    assign sub_result  = A - B;                  // Subtração (truncada em 4 bits)
    assign lsl_result  = {A[2:0], 1'b0};         // LSL: desloca A para a esquerda e insere 0 no LSB
    assign lsr_result  = {1'b0, A[3:1]};         // LSR: desloca A para a direita e insere 0 no MSB

    // -----------------------------------------------------------------------
    // Multiplexação do resultado com operador condicional ternário.
    // A expressão abaixo encadeia comparações do seletor, retornando o wire
    // correspondente à operação desejada. Caso nenhum código seja casado,
    // o valor padrão 4'b0000 é retornado.
// -----------------------------------------------------------------------
    assign resultado =
          (seletor == 3'b000) ? and_result  :   // Código 000 → AND
          (seletor == 3'b001) ? or_result   :   // Código 001 → OR
          (seletor == 3'b010) ? not_result  :   // Código 010 → NOT(A)
          (seletor == 3'b011) ? nand_result :   // Código 011 → NAND
          (seletor == 3'b100) ? add_result  :   // Código 100 → A + B
          (seletor == 3'b101) ? sub_result  :   // Código 101 → A - B
          (seletor == 3'b110) ? lsl_result  :   // Código 110 → LSL(A)
          (seletor == 3'b111) ? lsr_result  :   // Código 111 → LSR(A)
                               4'b0000;         // Valor default de segurança
endmodule
