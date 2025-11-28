// ============================================================================
// csa_parameterized.v — Dataflow
// Autor: Manoel Furtado
// Data: 10/11/2025
// Descrição: Carry-Save Adder (CSA) parametrizado em largura.
//            Versão dataflow com atribuições contínuas e generate-for.
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
    output wire [WIDTH-1:0] Sum, // Soma por bit (sem propagação)
    output wire [WIDTH-1:0] Cout // Carry por bit (sem propagação)
);
    genvar i; // gerador de instâncias/atribuições
    generate
        // Atribuições por bit — forma canônica do full-adder
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_CSA_BITS
            assign Sum[i]  = A[i] ^ B[i] ^ Cin[i];
            assign Cout[i] = (A[i] & B[i]) | (B[i] & Cin[i]) | (A[i] & Cin[i]);
        end
    endgenerate
endmodule
