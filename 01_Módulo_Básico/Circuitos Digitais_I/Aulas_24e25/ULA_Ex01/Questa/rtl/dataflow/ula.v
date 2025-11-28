// =============================================================
//  ula.v  (Dataflow) — 4‑bit ALU with 6 operations
//  Autor: Manoel Furtado | Data: 31/10/2025
//  Compatível com Verilog‑2001 (Quartus/Questa)
// =============================================================

`timescale 1ns/1ps

module ula (
    input  [3:0] A,           // Operando A
    input  [3:0] B,           // Operando B
    input  [2:0] seletor,     // Sinal de seleção (3 bits)
    output [3:0] resultado    // Resultado da operação
);
    // Pré‑cálculo das operações em fios (wires)
    wire [3:0] op_and  =  A & B;  // AND
    wire [3:0] op_or   =  A | B;  // OR
    wire [3:0] op_not  = ~A;      // NOT(A) apenas
    wire [3:0] op_nand = ~(A & B);// NAND
    wire [3:0] op_add  =  A + B;  // Soma (truncada a 4 bits)
    wire [3:0] op_sub  =  A - B;  // Subtração (truncada a 4 bits)

    // Multiplexação via operador ternário encadeado
    assign resultado =
           (seletor == 3'b000) ? op_and  :
           (seletor == 3'b001) ? op_or   :
           (seletor == 3'b010) ? op_not  :
           (seletor == 3'b011) ? op_nand :
           (seletor == 3'b100) ? op_add  :
           (seletor == 3'b101) ? op_sub  :
                                  4'b0000;  // padrão
endmodule
