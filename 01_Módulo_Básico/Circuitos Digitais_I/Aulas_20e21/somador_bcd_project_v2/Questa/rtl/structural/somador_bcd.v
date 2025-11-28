// ============================================================================
//  somador_bcd.v — Structural
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Descrição: Soma BCD formada por blocos: FA 1-bit, RC Adder 4-bit e
//             correção +6 por somador adicional quando (A+B) >= 10.
// ============================================================================

`timescale 1ns/1ps                 // Unidades/precisão de simulação

// -------------------------- FA 1 bit ----------------------------------------
module fa1(
    input  wire a,                 // Bit A
    input  wire b,                 // Bit B
    input  wire cin,               // Carry de entrada
    output wire s,                 // Soma (1 bit)
    output wire cout               // Carry de saída
);
    assign {cout, s} = a + b + cin;// Implementação aritmética compacta do FA
endmodule                          // Fim do FA 1 bit

// --------------------- Ripple-Carry Adder 4 bits ----------------------------
module rc_adder4(
    input  wire [3:0] A,           // Operando A (4 bits)
    input  wire [3:0] B,           // Operando B (4 bits)
    input  wire       Cin,         // Carry de entrada
    output wire [3:0] S,           // Soma (4 bits)
    output wire       Cout         // Carry final
);
    wire c1, c2, c3;               // Carries internos entre os FAs

    fa1 u0(.a(A[0]), .b(B[0]), .cin(Cin), .s(S[0]), .cout(c1)); // Bit 0
    fa1 u1(.a(A[1]), .b(B[1]), .cin(c1 ), .s(S[1]), .cout(c2)); // Bit 1
    fa1 u2(.a(A[2]), .b(B[2]), .cin(c2 ), .s(S[2]), .cout(c3)); // Bit 2
    fa1 u3(.a(A[3]), .b(B[3]), .cin(c3 ), .s(S[3]), .cout(Cout)); // Bit 3
endmodule                          // Fim do RC adder 4 bits

// Permite renomear o nome do módulo principal na compilação
`ifndef SOMADOR_NAME
`define SOMADOR_NAME somador_bcd   // Nome padrão se não redefinirmos no vlog
`endif

// -------------------------- Somador BCD -------------------------------------
module `SOMADOR_NAME(
    input  wire [3:0] A,           // Operando A (BCD 0..9)
    input  wire [3:0] B,           // Operando B (BCD 0..9)
    output wire [3:0] S,           // Saída BCD (unidades)
    output wire       Cout         // Carry da dezena
);
    // 1) Soma binária de A e B (4 bits) via ripple-carry
    wire [3:0] soma4;              // Resultado de 4 bits
    wire       c4;                 // Carry do bit mais significativo
    rc_adder4 ADD1(.A(A), .B(B), .Cin(1'b0), .S(soma4), .Cout(c4)); // A+B

    // 2) Detecta se (A+B) >= 10
    //    Condição clássica: c4 | (soma4[3] & (soma4[2] | soma4[1]))
    //    - c4=1 quando excede 15; a segunda parte detecta 10..15 sem carry externo.
    wire precisa_corrigir = c4 | (soma4[3] & (soma4[2] | soma4[1]));

    // 3) Se precisar, somar 6 (0110) para voltar ao intervalo BCD e gerar Cout
    wire [3:0] ajuste = precisa_corrigir ? 4'b0110 : 4'b0000; // Seleciona ajuste +6
    wire [3:0] soma_corr;           // Unidades corrigidas
    wire       cout_corr;           // Carry do somador de correção (caso extremo)
    rc_adder4 ADD2(.A(soma4), .B(ajuste), .Cin(1'b0), .S(soma_corr), .Cout(cout_corr));

    // 4) Saídas finais
    assign Cout = precisa_corrigir | cout_corr; // Cout=1 quando houve correção (ou transbordo)
    assign S    = soma_corr;                    // Unidades após correção
endmodule                                       // Fim do módulo BCD estrutural
