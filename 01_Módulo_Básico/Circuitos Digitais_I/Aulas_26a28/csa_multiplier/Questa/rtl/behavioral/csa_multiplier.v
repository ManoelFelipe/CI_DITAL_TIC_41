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
// CSA de largura N (bitwise), implementado de forma comportamental
module csaN #(parameter N = 8) (
    input      [N-1:0] A,   // parcela A
    input      [N-1:0] B,   // parcela B
    input      [N-1:0] Cin, // parcela Cin (terceiro operando)
    output reg [N-1:0] Sum, // soma sem propagação de carry
    output reg [N-1:0] Cout // carry por bit
);
    // comportamento por sempre combinacional
    integer i;
    always @* begin
        for (i = 0; i < N; i = i + 1) begin
            // soma de 3 operandos por bit (full-adder)
            Sum[i]  = A[i] ^ B[i] ^ Cin[i];
            Cout[i] = (A[i] & B[i]) | (A[i] & Cin[i]) | (B[i] & Cin[i]);
        end
    end
endmodule

// RCA de largura N para a etapa final (propagação de carry)
module rcaN #(parameter N = 8) (
    input  [N-1:0] X,
    input  [N-1:0] Y,
    output [N-1:0] S
);
    assign S = X + Y; // permitido em behavioral
endmodule

// ===================== TOP: csa_multiplier =====================
module csa_multiplier #(parameter WIDTH = 4) (
    input  [WIDTH-1:0] multiplicand, // multiplicando
    input  [WIDTH-1:0] multiplier,   // multiplicador
    output [2*WIDTH-1:0] product     // produto de 2*WIDTH bits
);
    // ---------- Geração dos produtos parciais (shift-and-add) ----------
    // Cada linha tem 2*WIDTH bits (alinhadas por deslocamento i)
    wire [2*WIDTH-1:0] pp [WIDTH-1:0];
    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin: gen_pp
            assign pp[i] = multiplier[i] ? ( {{WIDTH{1'b0}}, multiplicand} << i ) : {2*WIDTH{1'b0}};
        end
    endgenerate

    // ---------- Duas etapas de CSA para combinar 4 produtos parciais ----------
    wire [2*WIDTH-1:0] sum1, carry1;
    wire [2*WIDTH-1:0] sum2, carry2;

    csaN #(2*WIDTH) u_csa1 (
        .A  (pp[0]),
        .B  (pp[1]),
        .Cin(pp[2]),
        .Sum(sum1),
        .Cout(carry1)
    );

    csaN #(2*WIDTH) u_csa2 (
        .A  (pp[3]),
        .B  (sum1),
        .Cin(carry1 << 1),
        .Sum(sum2),
        .Cout(carry2)
    );

    // ---------- Etapa final: propagação (RCA) ----------
    rcaN #(2*WIDTH) u_final (
        .X(sum2),
        .Y(carry2 << 1),
        .S(product)
    );
endmodule
