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

// ===================== MÓDULOS BÁSICOS =====================
module fa ( // full adder 1-bit
    input  a, b, cin,
    output sum, cout
);
    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (a & cin) | (b & cin);
endmodule

// Vetor de FAs para um CSA de N bits
module csaN_st #(parameter N = 8) (
    input  [N-1:0] A, B, Cin,
    output [N-1:0] Sum, Cout
);
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: gen_fa
            fa u_fa (.a(A[i]), .b(B[i]), .cin(Cin[i]), .sum(Sum[i]), .cout(Cout[i]));
        end
    endgenerate
endmodule

// Ripple-Carry Adder estruturado
module rcaN_st #(parameter N = 8) (
    input  [N-1:0] X, Y,
    output [N-1:0] S
);
    wire [N:0] c;
    assign c[0] = 1'b0;
    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin: gen_rca
            fa u_fa (.a(X[i]), .b(Y[i]), .cin(c[i]), .sum(S[i]), .cout(c[i+1]));
        end
    endgenerate
endmodule

// ===================== TOP: csa_multiplier =====================
module csa_multiplier #(parameter WIDTH = 4) (
    input  [WIDTH-1:0] multiplicand,
    input  [WIDTH-1:0] multiplier,
    output [2*WIDTH-1:0] product
);
    // Produtos parciais (structural via assign é aceitável para fios)
    wire [2*WIDTH-1:0] pp [WIDTH-1:0];
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: gen_pp
            assign pp[i] = multiplier[i] ? ( {{WIDTH{1'b0}}, multiplicand} << i ) : {2*WIDTH{1'b0}};
        end
    endgenerate

    // Duas CSAs estruturais
    wire [2*WIDTH-1:0] sum1, carry1, sum2, carry2;
    csaN_st #(2*WIDTH) csa1 (.A(pp[0]), .B(pp[1]), .Cin(pp[2]),        .Sum(sum1), .Cout(carry1));
    csaN_st #(2*WIDTH) csa2 (.A(pp[3]), .B(sum1),  .Cin(carry1 << 1),  .Sum(sum2), .Cout(carry2));

    // Etapa final: RCA
    rcaN_st #(2*WIDTH) rca_final (.X(sum2), .Y(carry2 << 1), .S(product));
endmodule
