// ============================================================================
// Projeto: Somador BCD de 3 Dígitos (000–999)             
// Arquivo: somador_bcd_3.v
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Versão : Verilog 2001 – Compatível com Quartus e Questa
// Descrição: Implementação Estrutural (structural) do somador BCD de 3 dígitos com carry-in e
//            carry-out. Cada dígito BCD (centenas/dezenas/unidades) é somado
//            com propagação de carry.
// Observações:
//  - Números de entrada A e B estão no formato BCD em 12 bits: [11:8]=centenas,
//    [7:4]=dezenas, [3:0]=unidades.
//  - A saída SUM segue o mesmo formato e COUT indica milhar.
//  - Comentários linha a linha para fins didáticos.
// ============================================================================
`timescale 1ns/1ps

// -------------------- Bloco lógico: Somador Completo (1 bit) -----------------
module fa (
    input  wire a,      // bit A
    input  wire b,      // bit B
    input  wire cin,    // carry de entrada
    output wire s,      // soma do bit
    output wire cout    // carry de saída
);
    assign s    = a ^ b ^ cin;                 // Soma de 1 bit
    assign cout = (a & b) | (a & cin) | (b & cin); // Carry maioria
endmodule

// -------------------- Somador ripple de 4 bits -------------------------------
module add4 (
    input  wire [3:0] a,       // operando A
    input  wire [3:0] b,       // operando B
    input  wire       cin,     // carry de entrada
    output wire [3:0] s,       // soma
    output wire       cout     // carry de saída (bit 4)
);
    wire c1, c2, c3;           // carries internos entre os estágios
    fa F0(a[0], b[0], cin, s[0], c1);
    fa F1(a[1], b[1], c1,  s[1], c2);
    fa F2(a[2], b[2], c2,  s[2], c3);
    fa F3(a[3], b[3], c3,  s[3], cout);
endmodule

// -------------- Somador BCD de 1 dígito com correção por 6 -------------------
module bcd_digit_adder_structural (
    input  wire [3:0] a,      // dígito A
    input  wire [3:0] b,      // dígito B
    input  wire       cin,    // carry de entrada
    output wire [3:0] s,      // soma BCD corrigida
    output wire       cout    // carry de saída
);
    // 1) Soma binária básica de 4 bits (a+b+cin)
    wire [3:0] sum_bin;
    wire       c4;
    add4 SUM1(.a(a), .b(b), .cin(cin), .s(sum_bin), .cout(c4));

    // 2) Detecta se resultado é > 9. Expressão clássica: gt9 = c4 | (s3&(s2|s1))
    wire gt9 = c4 | (sum_bin[3] & (sum_bin[2] | sum_bin[1]));

    // 3) Se gt9==1, soma 6 (0110) ao resultado via outro ripple-adder
    wire [3:0] corr = gt9 ? 4'b0110 : 4'b0000;
    wire [3:0] sum_fix;
    wire       c5;
    add4 SUM2(.a(sum_bin), .b(corr), .cin(1'b0), .s(sum_fix), .cout(c5));

    // 4) Saídas finais
    assign s    = sum_fix;     // Dígito BCD já corrigido
    assign cout = c5;          // Carry para o próximo dígito
endmodule

// -------------------- Topo 3 dígitos (Structural) ----------------------------
module somador_bcd_3_structural (
    input  wire [11:0] a,   // Entradas BCD A
    input  wire [11:0] b,   // Entradas BCD B
    input  wire        cin, // Carry global de entrada
    output wire [11:0] sum, // Saída BCD
    output wire        cout // Carry de milhar
);
    wire c1, c2; // carries entre dígitos

    bcd_digit_adder_structural U0 (a[3:0],  b[3:0],  cin, sum[3:0],  c1);
    bcd_digit_adder_structural U1 (a[7:4],  b[7:4],  c1,  sum[7:4],  c2);
    bcd_digit_adder_structural U2 (a[11:8], b[11:8], c2,  sum[11:8], cout);
endmodule
