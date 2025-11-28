// csa.v — Carry-Save Adder (CSA) 4-bit — Structural
// Autor: Manoel Furtado
// Data: 31/10/2025
// Descrição: Hierarquia explícita de 4 somadores completos (um por bit).

// Célula básica: Somador completo 1‑bit (full adder) sem carry‑in encadeado.
module fa1 (
    input  wire a,     // bit A
    input  wire b,     // bit B
    input  wire cin,   // bit Cin (terceiro operando)
    output wire sum,   // soma parcial
    output wire cout   // carry parcial (maioria de três)
);
    // Implementação gate‑level simples
    wire axb   = a ^ b;            // XOR parcial
    assign sum = axb ^ cin;        // Soma final
    assign cout = (a & b) | (b & cin) | (cin & a); // Carry
endmodule

// Top‑level CSA 4‑bit
module csa (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] Cin,
    output wire [3:0] Sum,
    output wire [3:0] Cout
);
    // Instancia quatro somadores completos independentes (sem ripple)
    fa1 u0 (.a(A[0]), .b(B[0]), .cin(Cin[0]), .sum(Sum[0]), .cout(Cout[0]));
    fa1 u1 (.a(A[1]), .b(B[1]), .cin(Cin[1]), .sum(Sum[1]), .cout(Cout[1]));
    fa1 u2 (.a(A[2]), .b(B[2]), .cin(Cin[2]), .sum(Sum[2]), .cout(Cout[2]));
    fa1 u3 (.a(A[3]), .b(B[3]), .cin(Cin[3]), .sum(Sum[3]), .cout(Cout[3]));
endmodule
