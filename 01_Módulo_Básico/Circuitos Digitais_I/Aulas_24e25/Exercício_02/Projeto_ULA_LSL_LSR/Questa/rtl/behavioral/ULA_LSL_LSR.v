// ============================================================================
// Arquivo  : ULA_LSL_LSR.v  (implementação behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Unidade Lógica e Aritmética (ULA) de 4 bits parametrizada para
//            operar sobre dois operandos A e B, selecionando a operação por
//            meio de um campo seletor de 3 bits. Implementa oito funções
//            combinacionais: AND, OR, NOT(A), NAND, soma, subtração,
//            deslocamento lógico para a esquerda (LSL) e deslocamento lógico
//            para a direita (LSR). Implementação puramente comportamental,
//            com lógica combinacional descrita via bloco always e case.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Módulo: ULA_LSL_LSR (implementação behavioral)
// ---------------------------------------------------------------------------
// Portas:
//   A        : operando A de 4 bits
//   B        : operando B de 4 bits
//   seletor  : código da operação (3 bits)
//              000 AND   | 001 OR   | 010 NOT(A) | 011 NAND
//              100 A + B | 101 A - B| 110 LSL(A) | 111 LSR(A)
//   resultado: saída de 4 bits, valor combinacional da operação selecionada
// ---------------------------------------------------------------------------
module ULA_LSL_LSR (
    input  wire [3:0] A,         // Operando A de 4 bits
    input  wire [3:0] B,         // Operando B de 4 bits
    input  wire [2:0] seletor,   // Seletor da operação (3 bits)
    output reg  [3:0] resultado  // Resultado da operação selecionada
);
    // -----------------------------------------------------------------------
    // Bloco always combinacional
    //   - Sensível a qualquer variação em A, B ou seletor
    //   - Utiliza estrutura case para mapear diretamente cada código de
    //     operação ao resultado correspondente.
    // -----------------------------------------------------------------------
    always @(*) begin
        // Seleção da operação conforme o valor de 'seletor'
        case (seletor)
            3'b000: resultado = (A & B);          // AND bit a bit entre A e B
            3'b001: resultado = (A | B);          // OR  bit a bit entre A e B
            3'b010: resultado = (~A);             // NOT bit a bit apenas em A
            3'b011: resultado = ~(A & B);         // NAND bit a bit entre A e B
            3'b100: resultado = (A + B);          // Soma de A e B (truncada em 4 bits)
            3'b101: resultado = (A - B);          // Subtração A - B (truncada em 4 bits)
            3'b110: resultado = {A[2:0], 1'b0};   // LSL: desloca A 1 bit para a esquerda
            3'b111: resultado = {1'b0, A[3:1]};   // LSR: desloca A 1 bit para a direita
            default: resultado = 4'b0000;         // Valor padrão de segurança (zero)
        endcase
    end
endmodule
