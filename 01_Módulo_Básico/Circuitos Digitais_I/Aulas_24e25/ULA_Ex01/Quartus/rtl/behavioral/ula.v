// =============================================================
//  ula.v  (Behavioral) — 4‑bit ALU with 6 operations
//  Autor: Manoel Furtado | Data: 31/10/2025
//  Compatível com Verilog‑2001 (Quartus/Questa)
// =============================================================

`timescale 1ns/1ps

// ---------------- Portas -----------------
// A, B     : operandos de 4 bits
// seletor  : operação (3 bits)
//            000 AND  | 001 OR | 010 NOT(A)
//            011 NAND | 100 A+B | 101 A-B
// resultado: saída de 4 bits (soma/sub trauncada)
module ula (
    input      [3:0] A,        // Operando A
    input      [3:0] B,        // Operando B
    input      [2:0] seletor,  // Sinal de seleção (3 bits)
    output reg [3:0] resultado // Resultado da operação
);
    // Lógica puramente combinacional
    always @(*) begin
        case (seletor)
            3'b000: resultado = (A & B);   // AND bit a bit
            3'b001: resultado = (A | B);   // OR  bit a bit
            3'b010: resultado = (~A);      // NOT somente em A
            3'b011: resultado = ~(A & B);  // NAND bit a bit
            3'b100: resultado = (A + B);   // Soma (truncada a 4 bits)
            3'b101: resultado = (A - B);   // Subtração (truncada a 4 bits)
            default: resultado = 4'b0000;  // Padrão: zero
        endcase
    end
endmodule
