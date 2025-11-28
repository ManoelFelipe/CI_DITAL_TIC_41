// ============================================================================
// Arquivo  : full_adder_4bits.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador parametrizável de largura N (padrão N=4) que calcula
//            S = A + B + Cin com propagação ripple-carry. O módulo expõe os
//            sinais de soma (s) e carry-out (cout). A versão behavioral usa
//            operação aritmética em bloco procedural; a dataflow usa uma
//            atribuição contínua vetorial; a structural instancia N somadores
//            completos de 1 bit (full adders) encadeados. Latência combinacional,
//            sem registradores; área e atraso escalam ~O(N).
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================== Visão Geral ==================================
// • Implementação dataflow usando atribuição contínua vetorial.
// • Parametrização via parameter N (default: 4).
// • Sem registradores — lógica puramente combinacional.
// =============================================================================

`timescale 1ns/1ps

module full_adder_4bits
#( parameter N = 4 )                      // Parâmetro de largura (default 4)
(
    input  wire [N-1:0] a,               // Primeiro operando N bits
    input  wire [N-1:0] b,               // Segundo  operando N bits
    input  wire         cin,             // Carry-in
    output wire [N-1:0] s,               // Soma N bits
    output wire         cout             // Carry-out
);
    // Atribuição contínua: concatenação captura carry e soma de uma vez.
    assign {cout, s} = a + b + cin;      // Vetor {carry, soma}
endmodule
