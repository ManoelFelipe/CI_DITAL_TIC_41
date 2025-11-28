// -----------------------------------------------------------------------------
// Projeto: Multiplexador 16x1 (três descrições: comportamental, dataflow, estrutural)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_16_1.v
// Descr. : Este arquivo implementa um mux 16:1 que seleciona 1 entre 16 entradas
//          de um bit cada, de acordo com 'sel' (4 bits).
// -----------------------------------------------------------------------------

// ===============================
// MÓDULO ESTRUTURAL
// ===============================
// Abordagem: árvore de muxes 2:1 (16 -> 8 -> 4 -> 2 -> 1).
// Submódulo: mux2 - multiplexador 2:1.

// [Linha S1] Submódulo 2:1 com descrição por portas (dataflow simples).
module mux2(input wire a, input wire b, input wire s, output wire y);
    // [Linha S2] y = (s ? b : a);
    assign y = (s) ? b : a;
endmodule

module multiplex_16_1
(
    input  wire [15:0] d,    // [Linha 1] 16 entradas
    input  wire [3:0]  sel,  // [Linha 2] Seleção (MSB é o último estágio)
    output wire        y      // [Linha 3] Saída
);
    // [Linha 4] Fio intermediário entre os estágios da árvore
    wire [7:0]  l1; // Saídas do primeiro nível (16->8)
    wire [3:0]  l2; // Saídas do segundo nível (8->4)
    wire [1:0]  l3; // Saídas do terceiro nível (4->2)

    // ------------------
    // Nível 1: 16 -> 8
    // ------------------
    mux2 m10(d[0],  d[1],  sel[0], l1[0]); // [Linha 5]
    mux2 m11(d[2],  d[3],  sel[0], l1[1]); // [Linha 6]
    mux2 m12(d[4],  d[5],  sel[0], l1[2]); // [Linha 7]
    mux2 m13(d[6],  d[7],  sel[0], l1[3]); // [Linha 8]
    mux2 m14(d[8],  d[9],  sel[0], l1[4]); // [Linha 9]
    mux2 m15(d[10], d[11], sel[0], l1[5]); // [Linha 10]
    mux2 m16(d[12], d[13], sel[0], l1[6]); // [Linha 11]
    mux2 m17(d[14], d[15], sel[0], l1[7]); // [Linha 12]

    // ------------------
    // Nível 2: 8 -> 4
    // ------------------
    mux2 m20(l1[0], l1[1], sel[1], l2[0]); // [Linha 13]
    mux2 m21(l1[2], l1[3], sel[1], l2[1]); // [Linha 14]
    mux2 m22(l1[4], l1[5], sel[1], l2[2]); // [Linha 15]
    mux2 m23(l1[6], l1[7], sel[1], l2[3]); // [Linha 16]

    // ------------------
    // Nível 3: 4 -> 2
    // ------------------
    mux2 m30(l2[0], l2[1], sel[2], l3[0]); // [Linha 17]
    mux2 m31(l2[2], l2[3], sel[2], l3[1]); // [Linha 18]

    // ------------------
    // Nível 4: 2 -> 1
    // ------------------
    mux2 m40(l3[0], l3[1], sel[3], y);     // [Linha 19] Saída final
endmodule
