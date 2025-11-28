// ============================================================================
// Arquivo  : carry_look_ahead_adder_4b.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador prefixado de 4 bits com lógica Carry Look-Ahead (CLA).
//            Implementa propagação (P=A^B) e geração (G=A&B) por bit e calcula
//            os carries C1..C3 e Cout em paralelo, reduzindo o tempo crítico
//            em relação ao ripple-carry. Largura fixa de 4 bits, latência
//            combinacional (0 ciclos). Uso esperado: ALUs, DSPs e lógica de
//            controle com metas de frequência moderadas/altas.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps
// --------------------------- Porta do módulo -------------------------------
module carry_look_ahead_adder_4b (
    input  wire [3:0] a,      // Operando A (4 bits)
    input  wire [3:0] b,      // Operando B (4 bits)
    input  wire       c_in,   // Carry de entrada
    output reg  [3:0] sum,    // Soma (4 bits)
    output reg        c_out   // Carry de saída
);
    // --------------------- Sinais internos P/G e carries --------------------
    reg [3:0] p;              // Propagação: P[i] = A[i] ^ B[i]
    reg [3:0] g;              // Geração:    G[i] = A[i] & B[i]
    reg [3:0] c;              // Carries intermediários: C[0]=c_in, C[3] -> bit3

    // ---------------------- Bloco combinacional principal -------------------
    always @(*) begin
        // Propagação e geração por bit
        p = a ^ b;           // cada bit propaga quando A!=B
        g = a & b;           // cada bit gera quando A=B=1

        // Carry look-ahead (derivação clássica)
        c[0] = c_in;                                                                 // C0
        c[1] = g[0] | (p[0] & c[0]);                                                 // C1
        c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);                          // C2
        c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]); // C3
        c_out = g[3] | (p[3] & c[3]);                                                // Cout

        // Soma final: S[i] = P[i] ^ C[i]
        sum = p ^ c;
    end
endmodule
