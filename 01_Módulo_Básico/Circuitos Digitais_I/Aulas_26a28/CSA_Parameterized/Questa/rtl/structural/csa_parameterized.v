// ============================================================================
// csa_parameterized.v — Structural
// Autor: Manoel Furtado
// Data: 10/11/2025
// Descrição: Carry-Save Adder (CSA) parametrizado em largura.
//            Versão estrutural instanciando N full-adders de 1 bit.
// Compatível com: Verilog 2001 (Quartus/Questa)
// ============================================================================
`timescale 1ns/1ps

// ---------------- Módulo de 1 bit (full-adder sem ripple) -------------------
module fa_1bit(
    input  wire a,     // bit de A
    input  wire b,     // bit de B
    input  wire cin,   // bit de Cin
    output wire sum,   // soma local
    output wire cout   // carry local
);
    // Implementação puramente booleana (estrutura de portas)
    assign sum  = a ^ b ^ cin;                        // XOR de 3 entradas
    assign cout = (a & b) | (b & cin) | (a & cin);    // função majoritária
endmodule

// ---------------- Topo parametrizado ----------------------------------------
module csa_parameterized
#(
    parameter integer WIDTH = 4 // Largura padrão
)
(
    input  wire [WIDTH-1:0] A,   // Operando A
    input  wire [WIDTH-1:0] B,   // Operando B
    input  wire [WIDTH-1:0] Cin, // Terceiro operando
    output wire [WIDTH-1:0] Sum, // Vetor de somas
    output wire [WIDTH-1:0] Cout // Vetor de carries
);
    genvar i; // índice de geração
    generate
        // Instancia WIDTH full-adders independentes
        for (i = 0; i < WIDTH; i = i + 1) begin : GEN_FA
            fa_1bit U_FA (
                .a   (A[i]),
                .b   (B[i]),
                .cin (Cin[i]),
                .sum (Sum[i]),
                .cout(Cout[i])
            );
        end
    endgenerate
endmodule
