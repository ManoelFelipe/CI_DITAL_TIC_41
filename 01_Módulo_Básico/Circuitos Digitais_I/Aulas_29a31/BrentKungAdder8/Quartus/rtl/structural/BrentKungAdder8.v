// BrentKungAdder8.v — Structural
// Autor: Manoel Furtado
// Data : 10/11/2025
// Descrição:
//   Implementação ESTRUTURAL do somador Brent–Kung de 8 bits utilizando
//   células prefixadas (BLACK e GRAY). BLACK produz (G,P); GRAY produz apenas G.
//   A árvore segue o arranjo clássico em 3 níveis para 8 bits.
//   Compatível com Verilog 2001 (Quartus/Questa).

`timescale 1ns/1ps
`default_nettype none

// ---------- Células prefixo ----------
// Célula BLACK: saída (G,P) = (Gi | (Pi & Gk), Pi & Pk)
module bk_black(output wire Gout, output wire Pout,
                input  wire Gi, input wire Pi,
                input  wire Gk, input wire Pk);
    assign Gout = Gi | (Pi & Gk);  // G combinado
    assign Pout = Pi & Pk;         // P combinado
endmodule

// Célula GRAY: saída G = Gi | (Pi & Gk)
module bk_gray(output wire Gout,
               input  wire Gi, input wire Pi,
               input  wire Gk);
    assign Gout = Gi | (Pi & Gk);
endmodule

// ---------- Top BrentKungAdder8 ----------
module BrentKungAdder8(
    input  wire [7:0] A,    // Operando A
    input  wire [7:0] B,    // Operando B
    input  wire       Cin,  // Carry de entrada
    output wire [7:0] Sum,  // Soma
    output wire       Cout  // Carry de saída
);
    // P e G elementares
    wire [7:0] P = A ^ B;   // Propagate
    wire [7:0] G = A & B;   // Generate

    // ---------- Nível 1 (2 bits) ----------
    wire [7:0] G1, P1;
    assign G1[0] = G[0]; assign P1[0] = P[0];
    bk_black n1_1 (G1[1], P1[1], G[1], P[1], G[0], P[0]);
    assign G1[2] = G[2]; assign P1[2] = P[2];
    bk_black n1_3 (G1[3], P1[3], G[3], P[3], G[2], P[2]);
    assign G1[4] = G[4]; assign P1[4] = P[4];
    bk_black n1_5 (G1[5], P1[5], G[5], P[5], G[4], P[4]);
    assign G1[6] = G[6]; assign P1[6] = P[6];
    bk_black n1_7 (G1[7], P1[7], G[7], P[7], G[6], P[6]);

    // ---------- Nível 2 (4 bits) ----------
    wire [7:0] G2, P2;
    assign G2[0] = G1[0]; assign P2[0] = P1[0];
    assign G2[1] = G1[1]; assign P2[1] = P1[1];
    // 3 <= (3..2) ⊕ (1..0)
    bk_black n2_3 (G2[3], P2[3], G1[3], P1[3], G1[1], P1[1]);
    assign G2[2] = G1[2]; assign P2[2] = P1[2];
    // 5 <= (5..4) ⊕ (3..0)
    bk_black n2_5 (G2[5], P2[5], G1[5], P1[5], G1[3], P1[3]);
    assign G2[4] = G1[4]; assign P2[4] = P1[4];
    // 7 <= (7..6) ⊕ (5..0)
    bk_black n2_7 (G2[7], P2[7], G1[7], P1[7], G1[5], P1[5]);
    assign G2[6] = G1[6]; assign P2[6] = P1[6];

    // ---------- Nível 3 (8 bits) ----------
    wire [7:0] G3, P3;
    assign G3[6:0] = G2[6:0];     // Propagação esquerda
    assign P3[6:0] = P2[6:0];
    // 7 <= (7..4) ⊕ (3..0)
    bk_black n3_7 (G3[7], P3[7], G2[7], P2[7], G2[3], P2[3]);

    // ---------- Carries ----------
    wire [7:0] C;
    assign C[0] = Cin;                                   // C0
    bk_gray c1 (C[1], G[0],  P[0],  Cin);                // C1
    bk_gray c2 (C[2], G1[1], P1[1], Cin);                // C2
    bk_gray c3 (C[3], G2[2], P2[2], Cin);                // C3
    bk_gray c4 (C[4], G3[3], P3[3], Cin);                // C4
    bk_gray c5 (C[5], G3[4], P3[4], Cin);                // C5
    bk_gray c6 (C[6], G3[5], P3[5], Cin);                // C6
    bk_gray c7 (C[7], G3[6], P3[6], Cin);                // C7

    // ---------- Saídas ----------
    assign Sum  = P ^ C;                                 // Soma
    assign Cout = G3[7] | (P3[7] & Cin);                 // Carry final
endmodule

`default_nettype wire
