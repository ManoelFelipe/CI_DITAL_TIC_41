// ============================================================================
// Arquivo  : full_adder_4bits.v  (implementação BEHAVIORAL)
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
// • Implementação comportamental (behavioral) usando bloco 'always @*'.
// • Parametrização via parameter N (default: 4) — mantém compatibilidade com
//   o enunciado (4 bits), permitindo reuso para outras larguras.
// • Sinais de saída 's' (N bits) e 'cout' (1 bit).
// • 'resultado' agrega soma + carry para facilitar a separação de campos.
// =============================================================================

`timescale 1ns/1ps

module full_adder_4bits
#( parameter N = 4 )                      // Parâmetro de largura (default 4)
(
    input  wire [N-1:0] a,               // Primeiro operando N bits
    input  wire [N-1:0] b,               // Segundo  operando N bits
    input  wire         cin,             // Carry-in (bit menos significativo)
    output reg  [N-1:0] s,               // Saída de soma N bits
    output reg          cout             // Carry-out (bit mais significativo)
);
    // Registrador auxiliar com N+1 bits para armazenar soma e carry.
    reg [N:0] resultado;                 // [N] = carry-out, [N-1:0] = soma

    // Bloco combinacional: realiza A + B + Cin (sem latência)
    always @* begin                      // Sensível a qualquer mudança de entrada
        resultado = a + b + cin;         // Soma aritmética vetorial
        s        = resultado[N-1:0];     // Extrai os N bits menos significativos
        cout     = resultado[N];         // Bit mais significativo vira carry-out
    end
endmodule
