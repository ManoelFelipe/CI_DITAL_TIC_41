// BrentKungAdder8.v — Behavioral
// Autor: Manoel Furtado
// Data : 10/11/2025
// Descrição:
//   Implementação COMPORTAMENTAL de um somador de 8 bits no estilo Brent–Kung.
//   Nesta versão, a soma é realizada usando a operação '+' e atribuições
//   registradas para evidenciar o comportamento sequencial de cálculo do carry.
//   Compatível com Verilog 2001 (Quartus/Questa).

`timescale 1ns/1ps
`default_nettype none

module BrentKungAdder8 (
    input  wire [7:0] A,   // Operando A
    input  wire [7:0] B,   // Operando B
    input  wire       Cin, // Carry de entrada
    output reg  [7:0] Sum, // Saída da soma
    output reg        Cout // Carry de saída
);
    // Comentário: Em um bloco sempre @* (combinacional), calculamos
    // a soma inteira (9 bits) e depois separamos Sum e Cout.
    reg [8:0] full;                  // 9 bits para guardar carry final
    always @* begin                  // Sensível a todas as entradas
        full = {1'b0, A} + {1'b0, B} + {8'b0, Cin}; // Soma com extensão de sinal
        Sum  = full[7:0];           // Bits menos significativos — resultado
        Cout = full[8];             // Bit mais significativo — carry out
    end
endmodule

`default_nettype wire
