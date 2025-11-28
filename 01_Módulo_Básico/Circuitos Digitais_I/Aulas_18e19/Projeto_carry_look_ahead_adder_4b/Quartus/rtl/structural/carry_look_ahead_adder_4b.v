// ============================================================================
// Arquivo  : carry_look_ahead_adder_4b.v  (implementação Structural)
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
module carry_look_ahead_adder_4b (
    input  wire [3:0] a,      // Operando A
    input  wire [3:0] b,      // Operando B
    input  wire       c_in,   // Carry de entrada
    output wire [3:0] sum,    // Soma
    output wire       c_out   // Carry de saída
);
    // P (xor) e G (and) por instâncias primárias
    wire [3:0] p, g;   // propagação e geração
    xor (p[0], a[0], b[0]);
    xor (p[1], a[1], b[1]);
    xor (p[2], a[2], b[2]);
    xor (p[3], a[3], b[3]);
    and (g[0], a[0], b[0]);
    and (g[1], a[1], b[1]);
    and (g[2], a[2], b[2]);
    and (g[3], a[3], b[3]);

    // Sinais intermediários para CLA (gate-level)
    wire c1, c2, c3;
    wire t10, t11, t20, t21, t22, t30, t31, t32, t33;

    // C1 = G0 + P0*C0
    and (t10, p[0], c_in);
    or  (c1,  g[0], t10);

    // C2 = G1 + P1*G0 + P1*P0*C0
    and (t20, p[1], g[0]);
    and (t21, p[1], p[0], c_in);
    or  (c2,  g[1], t20, t21);

    // C3 = G2 + P2*G1 + P2*P1*G0 + P2*P1*P0*C0
    and (t30, p[2], g[1]);
    and (t31, p[2], p[1], g[0]);
    and (t32, p[2], p[1], p[0], c_in);
    or  (c3,  g[2], t30, t31, t32);

    // Cout = G3 + P3*C3
    and (t33, p[3], c3);
    or  (c_out, g[3], t33);

    // Soma: S = P ^ C
    xor (sum[0], p[0], c_in);
    xor (sum[1], p[1], c1);
    xor (sum[2], p[2], c2);
    xor (sum[3], p[3], c3);
endmodule
