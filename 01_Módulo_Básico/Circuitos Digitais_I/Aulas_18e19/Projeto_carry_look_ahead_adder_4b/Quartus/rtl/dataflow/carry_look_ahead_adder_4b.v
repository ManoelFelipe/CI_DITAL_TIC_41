// ============================================================================
// Arquivo  : carry_look_ahead_adder_4b.v  (implementação Dataflow)
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
    input  wire [3:0] a,       // Operando A
    input  wire [3:0] b,       // Operando B
    input  wire       c_in,    // Carry de entrada
    output wire [3:0] sum,     // Soma
    output wire       c_out    // Carry de saída
);
    // Sinais de propagação e geração
    wire [3:0] p = a ^ b;      // P[i] = A[i] XOR B[i]
    wire [3:0] g = a & b;      // G[i] = A[i] AND B[i]

    // Equações CLA (forma canônica de 4 bits)
    wire c1 = g[0] | (p[0] & c_in);
    wire c2 = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c_in);
    wire c3 = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c_in);
    assign c_out = g[3] | (p[3] & c3);

    // Vetor de carries alinhado ao índice do bit da soma
    wire [3:0] c_vec = {c3, c2, c1, c_in};

    // Soma final (bitwise)
    assign sum = p ^ c_vec;
endmodule
