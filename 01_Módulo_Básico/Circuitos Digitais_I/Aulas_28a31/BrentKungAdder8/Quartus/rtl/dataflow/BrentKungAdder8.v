// BrentKungAdder8.v — Dataflow
// Autor: Manoel Furtado
// Data : 10/11/2025
// Descrição:
//   Implementação em FLUXO DE DADOS (dataflow) do somador Brent–Kung de 8 bits.
//   Constrói os sinais de Propagate (P) e Generate (G), percorre a árvore
//   prefixada Brent–Kung em 3 níveis (2, 4 e 8) e então obtém os carries.
//   Compatível com Verilog 2001 (Quartus/Questa).

`timescale 1ns/1ps
`default_nettype none

module BrentKungAdder8 (
    input  wire [7:0] A,    // Operando A
    input  wire [7:0] B,    // Operando B
    input  wire       Cin,  // Carry de entrada
    output wire [7:0] Sum,  // Soma
    output wire       Cout  // Carry de saída
);
    // ---------------- Nível 0: P e G elementares ----------------
    // P[i] = A[i] ^ B[i] (propaga carry)
    // G[i] = A[i] & B[i] (gera carry)
    wire [7:0] P /* synthesis keep */;
    wire [7:0] G /* synthesis keep */;
    assign P = A ^ B;  // Linha‑a‑linha: XOR forma o bit de propagação
    assign G = A & B;  // Linha‑a‑linha: AND forma o bit de geração

    // ---------------- Nível 1: intervalos de 2 bits ----------------
    // (g,p) o operador prefixo: (g,p) oplus (Gk,Pk) = (g | (p & Gk), p & Pk)
    wire [7:0] G1, P1;
    assign G1[0] = G[0];                         // Borda esquerda
    assign P1[0] = P[0];
    assign G1[1] = G[1] | (P[1] & G[0]);         // Combina 1..0
    assign P1[1] = P[1] & P[0];
    assign G1[2] = G[2];                         // Recomeça par
    assign P1[2] = P[2];
    assign G1[3] = G[3] | (P[3] & G[2]);         // Combina 3..2
    assign P1[3] = P[3] & P[2];
    assign G1[4] = G[4];
    assign P1[4] = P[4];
    assign G1[5] = G[5] | (P[5] & G[4]);         // Combina 5..4
    assign P1[5] = P[5] & P[4];
    assign G1[6] = G[6];
    assign P1[6] = P[6];
    assign G1[7] = G[7] | (P[7] & G[6]);         // Combina 7..6
    assign P1[7] = P[7] & P[6];

    // ---------------- Nível 2: intervalos de 4 bits ----------------
    wire [7:0] G2, P2;
    assign {G2[1],G2[0]} = {G1[1],G1[0]};        // Borda esquerda
    assign {P2[1],P2[0]} = {P1[1],P1[0]};
    assign G2[3] = G1[3] | (P1[3] & G1[1]);      // Combina 3..0 via 3..2 ⊕ 1..0
    assign P2[3] = P1[3] & P1[1];
    assign G2[2] = G1[2];                        // Passa adiante
    assign P2[2] = P1[2];
    assign G2[5] = G1[5] | (P1[5] & G1[3]);      // Combina 5..0 via 5..4 ⊕ 3..0
    assign P2[5] = P1[5] & P1[3];
    assign G2[4] = G1[4];
    assign P2[4] = P1[4];
    assign G2[7] = G1[7] | (P1[7] & G1[5]);      // Combina 7..0 via 7..6 ⊕ 5..0
    assign P2[7] = P1[7] & P1[5];
    assign G2[6] = G1[6];
    assign P2[6] = P1[6];

    // ---------------- Nível 3: intervalos de 8 bits ----------------
    wire [7:0] G3, P3;
    assign {G3[6:0]} = {G2[6:0]};                // Copia esquerda
    assign {P3[6:0]} = {P2[6:0]};
    assign G3[7] = G2[7] | (P2[7] & G2[3]);      // Combina 7..0 via 7..4 ⊕ 3..0
    assign P3[7] = P2[7] & P2[3];

    // ---------------- Cálculo dos carries ----------------
    wire [7:0] C;
    assign C[0] = Cin;                            // C0 = Cin
    assign C[1] = G[0] | (P[0] & Cin);            // C1
    assign C[2] = G1[1] | (P1[1] & Cin);          // C2
    assign C[3] = G2[2] | (P2[2] & Cin);          // C3
    assign C[4] = G3[3] | (P3[3] & Cin);          // C4
    assign C[5] = G3[4] | (P3[4] & Cin);          // C5
    assign C[6] = G3[5] | (P3[5] & Cin);          // C6
    assign C[7] = G3[6] | (P3[6] & Cin);          // C7

    // ---------------- Saídas ----------------
    assign Sum  = P ^ C;                          // Soma = P XOR C
    assign Cout = G3[7] | (P3[7] & Cin);          // Carry out global
endmodule

`default_nettype wire
