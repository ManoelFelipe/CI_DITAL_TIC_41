// =============================================================
// Arquivo   : KoggeStone.v (Dataflow)
// Autor     : Manoel Furtado
// Data      : 10/11/2025
// Descrição : Somador Kogge-Stone 4 bits - versão dataflow
//             Implementa a rede de prefixos (estágios) por assigns.
// Padrão    : Verilog 2001 (compatível com Quartus/Questa)
// =============================================================
`timescale 1ns/1ps

module KoggeStone (
    input  wire [3:0] A,    // Operando A
    input  wire [3:0] B,    // Operando B
    input  wire       Cin,  // Carry-in
    output wire [3:0] Sum,  // Saída da soma
    output wire       Cout  // Carry-out
);
    // ---------------- Propagate e Generate por bit ----------------
    wire [3:0] P;           // Propagação
    wire [3:0] G;           // Geração
    assign P = A ^ B;       // Propaga se A!=B (XOR)
    assign G = A & B;       // Gera se A=B=1

    // ------------- Nível 1 (intervalo de 1 bit: i,i-1) ------------
    wire G1_0, P1_0, G2_1, P2_1, G3_2, P3_2;
    assign G1_0 = G[1] | (P[1] & G[0]);
    assign P1_0 = P[1] & P[0];
    assign G2_1 = G[2] | (P[2] & G[1]);
    assign P2_1 = P[2] & P[1];
    assign G3_2 = G[3] | (P[3] & G[2]);
    assign P3_2 = P[3] & P[2];

    // ------------- Nível 2 (intervalo de 2 bits: i,i-2) -----------
    wire G2_0, P2_0, G3_1, P3_1;
    assign G2_0 = G2_1 | (P2_1 & G1_0);
    assign P2_0 = P2_1 & P1_0;
    assign G3_1 = G3_2 | (P3_2 & G2_1);
    assign P3_1 = P3_2 & P2_1;

    // ------------- Nível 3 (intervalo de 4 bits: i,i-3) -----------
    wire G3_0, P3_0;
    assign G3_0 = G3_1 | (P3_1 & G2_0);
    assign P3_0 = P3_1 & P2_0; // (não é usado no carry final, mas mantido por completude)

    // --------- Carrys prefixados (considerando Cin explícito) ------
    wire [3:0] C;
    assign C[0] = G[0]  | (P[0]  & Cin);
    assign C[1] = G1_0  | (P1_0  & Cin);
    assign C[2] = G2_0  | (P2_0  & Cin);
    assign C[3] = G3_0  | (P3_0  & Cin);

    // -------------------- Soma e Carry-out -------------------------
    assign Sum  = P ^ {C[2:0], Cin};
    assign Cout = C[3];
endmodule