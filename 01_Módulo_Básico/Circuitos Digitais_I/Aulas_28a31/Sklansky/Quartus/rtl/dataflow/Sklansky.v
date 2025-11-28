// ============================================================================
// Arquivo  : Sklansky.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 10/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador prefixado de Sklansky (4 bits) em estilo "dataflow".
//            Expressamos as equações de propagação (P) e geração (G) e
//            combinamos prefixos em 2 níveis (1 e 2) típicos do Sklansky 4-bit.
// ============================================================================

`timescale 1ns/1ps

module Sklansky (
    input  wire [3:0] A,    // Operando A
    input  wire [3:0] B,    // Operando B
    input  wire       Cin,  // Carry-in
    output wire [3:0] Sum,  // Soma
    output wire       Cout  // Carry-out
);
    // ------------------------- Propagação e Geração --------------------------
    wire [3:0] P;  // Propagação Pi = Ai ^ Bi
    wire [3:0] G;  // Geração    Gi = Ai & Bi
    assign P = A ^ B;   // (linha a linha) XOR bit a bit
    assign G = A & B;   // (linha a linha) AND bit a bit

    // ----------------------------- Nível 1 (distância 1) ---------------------
    // Prefixos de 2 bits: (1:0) e (3:2)
    wire G1_1, P1_1;  // grupo [1:0]
    wire G1_3, P1_3;  // grupo [3:2]

    assign G1_1 = G[1] | (P[1] & G[0]);  // G[1:0]
    assign P1_1 = P[1] & P[0];           // P[1:0]

    assign G1_3 = G[3] | (P[3] & G[2]);  // G[3:2]
    assign P1_3 = P[3] & P[2];           // P[3:2]

    // ----------------------------- Nível 2 (distância 2) ---------------------
    // Prefixo de 4 bits: (3:0) = (3:2) ° (1:0)
    wire G2_3, P2_3;  // grupo [3:0]
    assign G2_3 = G1_3 | (P1_3 & G1_1);  // G[3:0]
    assign P2_3 = P1_3 & P1_1;           // P[3:0]

    // ---------------------------- Cálculo dos carries ------------------------
    // C[0] é o Cin. Para eficiência, usamos os prefixos já obtidos:
    // C1 usa G[0], P[0]; C2 usa G[1:0]; C3 usa G[2] e C2; Cout usa G[3:0].
    wire [3:0] C;
    assign C[0] = Cin;
    assign C[1] = G[0]   | (P[0]   & C[0]);          // carry para bit1
    assign C[2] = G1_1   | (P1_1   & Cin);           // carry para bit2
    assign C[3] = G[2]   | (P[2]   & C[2]);          // carry para bit3
    // Soma final e carry-out pela fronteira superior:
    assign Sum  = P ^ C;                              // Si = Pi ^ Ci
    assign Cout = G2_3 | (P2_3 & Cin);               // carry final

endmodule
