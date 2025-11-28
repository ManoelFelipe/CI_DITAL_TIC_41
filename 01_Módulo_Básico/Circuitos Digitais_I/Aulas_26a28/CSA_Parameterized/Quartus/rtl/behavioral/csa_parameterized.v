// ============================================================================
// csa_parameterized.v — Behavioral
// Autor: Manoel Furtado
// Data: 10/11/2025
// Descrição: Carry-Save Adder (CSA) parametrizado em largura.
//            Versão comportamental usando bloco procedural e laço for.
// Compatível com: Verilog 2001 (Quartus/Questa)
// ============================================================================
`timescale 1ns/1ps

module csa_parameterized
#(
    parameter integer WIDTH = 4 // Largura padrão dos vetores
)
(
    input  wire [WIDTH-1:0] A,   // Operando A
    input  wire [WIDTH-1:0] B,   // Operando B
    input  wire [WIDTH-1:0] Cin, // Terceiro operando (carry "virtual" por bit)
    output reg  [WIDTH-1:0] Sum, // Soma por bit (sem propagação)
    output reg  [WIDTH-1:0] Cout // Carry por bit (sem propagação)
);
    // Bloco sempre-combinacional descrevendo o comportamento por bit
    integer i; // índice de iteração
    always @* begin
        // Inicialização explícita para evitar 'x' em simulação
        Sum  = {WIDTH{1'b0}}; // zera vetor de soma
        Cout = {WIDTH{1'b0}}; // zera vetor de carry
        // Cálculo bit a bit (full-adder independente)
        for (i = 0; i < WIDTH; i = i + 1) begin
            // Soma é XOR de A, B e Cin no bit i
            Sum[i]  = A[i] ^ B[i] ^ Cin[i];
            // Carry de saída é função majoritária dos três bits
            Cout[i] = (A[i] & B[i]) | (B[i] & Cin[i]) | (A[i] & Cin[i]);
        end
    end
endmodule
