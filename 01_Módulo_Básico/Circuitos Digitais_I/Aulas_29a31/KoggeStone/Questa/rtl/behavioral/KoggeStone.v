// =============================================================
// Arquivo   : KoggeStone.v (Behavioral)
// Autor     : Manoel Furtado
// Data      : 10/11/2025
// Descrição : Somador Kogge-Stone 4 bits - versão comportamental
// Padrão    : Verilog 2001 (compatível com Quartus/Questa)
// =============================================================
`timescale 1ns/1ps

module KoggeStone (
    input  wire [3:0] A,   // Operando A
    input  wire [3:0] B,   // Operando B
    input  wire       Cin, // Carry-in
    output reg  [3:0] Sum, // Saída da soma
    output reg        Cout // Carry-out
);
    // Lógica comportamental usando operador +.
    // Apesar de usar o somador do Verilog, mantemos o nome do módulo
    // e a interface para padronização com as demais abordagens.
    always @* begin
        // Soma de 4 bits com propagação de carry-in.
        {Cout, Sum} = A + B + Cin;
    end
endmodule