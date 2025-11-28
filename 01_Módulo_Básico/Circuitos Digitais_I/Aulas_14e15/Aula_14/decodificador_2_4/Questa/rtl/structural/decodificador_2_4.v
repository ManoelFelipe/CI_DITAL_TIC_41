// -----------------------------------------------------------------------------
// Arquivo     : decodificador_2_4.v
// Módulo      : decodificador_2_4
// Autor       : Manoel Furtado
// Data        : 31/10/2025
// Descrição   : Decodificador 2→4 com saídas Y0..Y3 e duas funções derivadas:
//               f2(A,B) = ~B  = Y0 + Y2
//               f3(A,B,C) = ~C*(A*~B + ~A*B) = ~C*(Y2 + Y1)
// Observações : • Entradas e saídas ESCALARES (sem vetores), conforme enunciado
//               • Compatível com Verilog‑2001 (Quartus e Questa)
//               • Três variações do mesmo módulo: Behavioral, Dataflow e Structural
// -----------------------------------------------------------------------------

`timescale 1ns/1ps                     // Define unidade/precisão de tempo para simulação
// -----------------------------------------------------------------------------
// Implementação ESTRUTURAL (Structural)
// Ligações explícitas de portas lógicas básicas (NOT/AND/OR)
// -----------------------------------------------------------------------------
module decodificador_2_4 (
    input  wire A,                    // Entrada A
    input  wire B,                    // Entrada B
    input  wire C,                    // Entrada C (para f3)
    output wire Y0,                   // Saída Y0
    output wire Y1,                   // Saída Y1
    output wire Y2,                   // Saída Y2
    output wire Y3,                   // Saída Y3
    output wire f2,                   // Saída f2
    output wire f3                    // Saída f3
);
    // Fios internos para inversões
    wire nA;                          // nA = ~A
    wire nB;                          // nB = ~B
    wire nC;                          // nC = ~C

    // Inversores
    not UinvA(nA, A);                 // Calcula ~A
    not UinvB(nB, B);                 // Calcula ~B
    not UinvC(nC, C);                 // Calcula ~C

    // Mintermos do decodificador 2×4
    and UandY0(Y0, nA, nB);           // Y0 = ~A & ~B
    and UandY1(Y1, nA,  B);           // Y1 = ~A &  B
    and UandY2(Y2,  A, nB);           // Y2 =  A & ~B
    and UandY3(Y3,  A,  B);           // Y3 =  A &  B

    // Combinações para as funções
    or  UorF2(f2, Y0, Y2);            // f2 = Y0 | Y2 = ~B
    wire y12;                         // y12 será Y1 | Y2
    or  UorY12(y12, Y1, Y2);          // y12 = Y1 | Y2 = A*~B + ~A*B
    and UandF3(f3, nC, y12);          // f3 = ~C & (Y1 | Y2)
endmodule                              // Fim do módulo estrutural
