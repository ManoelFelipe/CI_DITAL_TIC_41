// ============================================================================
// Arquivo  : full_adder_4bits.v  (implementação STRUCTURAL)
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
// • Implementação estrutural: encadeia N somadores completos de 1 bit.
// • Propagação ripple-carry: o carry percorre em série do bit 0 ao N-1.
// • Parametrizável por N (default: 4).
// =============================================================================

`timescale 1ns/1ps

module full_adder_4bits
#( parameter N = 4 )                      // Parâmetro de largura (default 4)
(
    input  wire [N-1:0] a,               // Primeiro operando N bits
    input  wire [N-1:0] b,               // Segundo  operando N bits
    input  wire         cin,             // Carry-in
    output wire [N-1:0] s,               // Saída soma N bits
    output wire         cout             // Carry-out
);
    // Fios internos de carry: c[0] é o carry-in; c[N] é o carry-out final.
    wire [N:0] c;                         // Barramento de carries intermediários
    assign c[0] = cin;                    // Inicializa ripple com carry de entrada
    assign cout = c[N];                   // Carry final exposto na saída

    // Geração de N instâncias do somador completo de 1 bit
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : GEN_FA
            full_adder_1bit U_FA (       // Instância do full adder 1-bit
                .a   (a[i]),             // Bit i de A
                .b   (b[i]),             // Bit i de B
                .cin (c[i]),             // Carry de entrada do estágio
                .s   (s[i]),             // Bit i da soma
                .cout(c[i+1])            // Carry de saída para o próximo estágio
            );
        end
    endgenerate
endmodule

// ------------------------------ Módulo 1-bit ---------------------------------
// Somador completo de 1 bit (tabela-verdade clássica): s = a ^ b ^ cin;
// cout = (a & b) | (cin & (a ^ b)). Implementação puramente combinacional.
// -----------------------------------------------------------------------------
module full_adder_1bit (
    input  wire a,                        // Bit de A
    input  wire b,                        // Bit de B
    input  wire cin,                      // Carry de entrada
    output wire s,                        // Bit de soma
    output wire cout                      // Carry de saída
);
    assign s    = a ^ b ^ cin;            // XOR encadeado
    assign cout = (a & b) | (cin & (a ^ b)); // Lógica do carry
endmodule
