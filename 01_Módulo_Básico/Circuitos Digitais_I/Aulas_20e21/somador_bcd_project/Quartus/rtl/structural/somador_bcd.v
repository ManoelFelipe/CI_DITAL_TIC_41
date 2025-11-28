// ============================================================================
//  somador_bcd.v — Somador BCD de 1 dígito (0000 a 1001) com correção por +6
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Compatível com: Verilog 2001 (Quartus/Questa)
//  Descrição: Soma dois dígitos BCD (A e B) e produz dígito BCD (S) e carry (Cout).
//  Observação: Não há carry de entrada; se necessário, componha em cascata.
// ============================================================================
`timescale 1ns/1ps

// --------------------------
// Full Adder de 1 bit
// --------------------------
module fa1(
    input  wire a, b, cin,      // Entradas de 1 bit
    output wire s, cout         // Saída (soma) e carry
);
    assign {cout, s} = a + b + cin;  // Implementação simples
endmodule

// --------------------------
// Somador Ripple-Carry 4 bits
// --------------------------
module rc_adder4(
    input  wire [3:0] A, B,     // Operandos de 4 bits
    input  wire       Cin,      // Carry de entrada
    output wire [3:0] S,        // Soma
    output wire       Cout      // Carry de saída
);
    wire c1, c2, c3;
    fa1 u0(.a(A[0]), .b(B[0]), .cin(Cin), .s(S[0]), .cout(c1));
    fa1 u1(.a(A[1]), .b(B[1]), .cin(c1 ), .s(S[1]), .cout(c2));
    fa1 u2(.a(A[2]), .b(B[2]), .cin(c2 ), .s(S[2]), .cout(c3));
    fa1 u3(.a(A[3]), .b(B[3]), .cin(c3 ), .s(S[3]), .cout(Cout));
endmodule

// --------------------------
// Somador BCD estrutural
// --------------------------
module somador_bcd(
    input  wire [3:0] A,        // Operando A em BCD (0..9)
    input  wire [3:0] B,        // Operando B em BCD (0..9)
    output wire [3:0] S,        // Saída em BCD (0..9) - unidades
    output wire       Cout      // Carry de saída (dezenas)
);
    // 1) Soma binária A+B usando adder ripple
    wire [3:0] soma4;
    wire       c4;
    rc_adder4 ADD1(.A(A), .B(B), .Cin(1'b0), .S(soma4), .Cout(c4));

    // 2) Lógica para detectar condição >= 10:
    //    preciso corrigir quando: c4 == 1 ou (soma4 >= 10)
    //    Uma forma canônica: c4 | (soma4[3] & (soma4[2] | soma4[1]))
    wire precisa_corrigir = c4 | (soma4[3] & (soma4[2] | soma4[1]));

    // 3) Se precisar, somar 6 (0110) usando outro adder ripple
    wire [3:0] ajuste = precisa_corrigir ? 4'b0110 : 4'b0000;
    wire [3:0] soma_corr;
    wire       cout_corr;
    rc_adder4 ADD2(.A(soma4), .B(ajuste), .Cin(1'b0), .S(soma_corr), .Cout(cout_corr));

    // 4) Saídas finais: carry das dezenas e unidades em BCD
    assign Cout = precisa_corrigir | cout_corr; // cout_corr cobre casos extremos
    assign S    = soma_corr;
endmodule
