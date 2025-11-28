// ============================================================================
// csa_multiplier.v — Multiplicador 4-bit com somas intermediárias via CSA
// Autor: Manoel Furtado
// Data: 10/11/2025
// Versão: Verilog 2001 — compatível com Quartus e Questa
// Descrição: Implementa multiplicador de 4 bits usando Carry-Save Adders (CSAs)
// para somar produtos parciais sem propagação imediata de carry. O produto
// final é obtido com uma soma de propagação (RCA) de Sum + (Carry << 1).
// Parametrizável por WIDTH (padrão 4).
// ============================================================================
`timescale 1ns/1ps

// ===================== MÓDULOS AUXILIARES =====================
// CSA em dataflow (equações booleanas por bit)
module csaN_df #(parameter N = 8) (
    input  [N-1:0] A, B, Cin,
    output [N-1:0] Sum, Cout
);
    assign Sum  = A ^ B ^ Cin;
    assign Cout = (A & B) | (A & Cin) | (B & Cin);
endmodule

// RCA final (dataflow)
module rcaN_df #(parameter N = 8) (
    input  [N-1:0] X, Y,
    output [N-1:0] S
);
    assign S = X + Y;
endmodule

// ===================== TOP: csa_multiplier =====================
module csa_multiplier #(parameter WIDTH = 4) (
    input  [WIDTH-1:0] multiplicand,
    input  [WIDTH-1:0] multiplier,
    output [2*WIDTH-1:0] product
);
    // Produtos parciais
    wire [2*WIDTH-1:0] pp [WIDTH-1:0];
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: gen_pp
            assign pp[i] = multiplier[i] ? ( {{WIDTH{1'b0}}, multiplicand} << i ) : {2*WIDTH{1'b0}};
        end
    endgenerate

    // Duas CSAs
    wire [2*WIDTH-1:0] sum1, carry1, sum2, carry2;

    csaN_df #(2*WIDTH) csa1 (.A(pp[0]), .B(pp[1]), .Cin(pp[2]),         .Sum(sum1), .Cout(carry1));
    csaN_df #(2*WIDTH) csa2 (.A(pp[3]), .B(sum1),  .Cin(carry1 << 1),   .Sum(sum2), .Cout(carry2));

    // Soma final
    rcaN_df #(2*WIDTH) rca_final (.X(sum2), .Y(carry2 << 1), .S(product));
endmodule
