// =============================================================
//  ula.v  (Structural) — 4‑bit ALU with 6 operations
//  Autor: Manoel Furtado | Data: 31/10/2025
//  Compatível com Verilog‑2001 (Quartus/Questa)
// =============================================================

`timescale 1ns/1ps

// --------- Submódulos básicos -----------

// Porta AND de 4 bits
module and4(input [3:0] a,b, output [3:0] y); assign y = a & b; endmodule
// Porta OR  de 4 bits
module or4 (input [3:0] a,b, output [3:0] y); assign y = a | b; endmodule
// NOT em A (4 bits)
module not4a(input [3:0] a,   output [3:0] y); assign y = ~a;  endmodule
// NAND de 4 bits
module nand4(input [3:0] a,b, output [3:0] y); assign y = ~(a & b); endmodule

// Somador completo (full adder) 1 bit
module fa(input a,b,cin, output sum, cout);
    assign {cout,sum} = a ^ b ^ cin ? { (a&b)|(a&cin)|(b&cin) , ~(a^b^cin) } : { (a&b)|(a&cin)|(b&cin) , (a^b^cin) };
    // A linha acima mantém tudo em dataflow; alternativa clássica:
    // assign {cout,sum} = a + b + cin;
endmodule

// Ripple‑carry adder 4 bits
module add4(input [3:0] a,b, output [3:0] s);
    wire c1,c2,c3,c4;
    fa u0(a[0], b[0], 1'b0, s[0], c1);
    fa u1(a[1], b[1], c1  , s[1], c2);
    fa u2(a[2], b[2], c2  , s[2], c3);
    fa u3(a[3], b[3], c3  , s[3], c4);
endmodule

// Subtrator 4 bits usando soma com complemento de dois (A + (~B + 1))
module sub4(input [3:0] a,b, output [3:0] d);
    wire [3:0] nb = ~b;         // complemento de B
    wire [3:0] t;               // soma parcial nb + 1
    wire c1,c2,c3,c4;
    fa s0(nb[0], 1'b1, 1'b0, t[0], c1);
    fa s1(nb[1], 1'b0, c1  , t[1], c2);
    fa s2(nb[2], 1'b0, c2  , t[2], c3);
    fa s3(nb[3], 1'b0, c3  , t[3], c4);
    add4 add_ab (.a(a), .b(t), .s(d)); // A + (~B+1)
endmodule

// MUX 8‑para‑1 de 4 bits (seis usados; dois deixam zero)
module mux8_4(
    input [3:0] d0,d1,d2,d3,d4,d5,d6,d7,
    input [2:0] sel,
    output [3:0] y
);
    wire [3:0] y0 = (sel==3'b000) ? d0 : 4'b0000;
    wire [3:0] y1 = (sel==3'b001) ? d1 : 4'b0000;
    wire [3:0] y2 = (sel==3'b010) ? d2 : 4'b0000;
    wire [3:0] y3 = (sel==3'b011) ? d3 : 4'b0000;
    wire [3:0] y4 = (sel==3'b100) ? d4 : 4'b0000;
    wire [3:0] y5 = (sel==3'b101) ? d5 : 4'b0000;
    wire [3:0] y6 = (sel==3'b110) ? d6 : 4'b0000;
    wire [3:0] y7 = (sel==3'b111) ? d7 : 4'b0000;
    assign y = y0 | y1 | y2 | y3 | y4 | y5 | y6 | y7; // OR de linhas "one‑hot"
endmodule

// ------------------ Topo -----------------
module ula (
    input  [3:0] A,            // Operando A
    input  [3:0] B,            // Operando B
    input  [2:0] seletor,      // Sinal de seleção
    output [3:0] resultado     // Resultado da operação
);
    // Saídas dos blocos de operação
    wire [3:0] w_and, w_or, w_not, w_nand, w_add, w_sub;

    // Instâncias
    and4   i_and  (.a(A), .b(B), .y(w_and));
    or4    i_or   (.a(A), .b(B), .y(w_or));
    not4a  i_not  (.a(A),         .y(w_not));
    nand4  i_nand (.a(A), .b(B), .y(w_nand));
    add4   i_add  (.a(A), .b(B), .s(w_add));
    sub4   i_sub  (.a(A), .b(B), .d(w_sub));

    // MUX seleciona uma entre 8 entradas (duas zeradas)
    mux8_4 i_mux(
        .d0(w_and), .d1(w_or), .d2(w_not), .d3(w_nand),
        .d4(w_add), .d5(w_sub), .d6(4'b0000), .d7(4'b0000),
        .sel(seletor),
        .y(resultado)
    );
endmodule
