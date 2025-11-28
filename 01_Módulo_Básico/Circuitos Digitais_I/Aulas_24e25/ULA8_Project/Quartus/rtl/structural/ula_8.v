// ===============================================================
//  ula_8.v (Structural) — ULA de 8 bits com soma via Carry Look-Ahead
//  Autor: Manoel Furtado
//  Data:  31/10/2025
//  Compatibilidade: Verilog 2001 (Questa / Quartus)
// ===============================================================

module PGbit (input wire a,b, output wire p,g);
    assign p = a ^ b;
    assign g = a & b;
endmodule

module CLA8 (input wire [7:0] p,g, input wire cin, output wire [8:0] c);
    assign c[0] = cin;
    assign c[1] = g[0] | (p[0] & c[0]);
    assign c[2] = g[1] | (p[1] & g[0]) | (p[1] & p[0] & c[0]);
    assign c[3] = g[2] | (p[2] & g[1]) | (p[2] & p[1] & g[0]) | (p[2] & p[1] & p[0] & c[0]);
    assign c[4] = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]) | (p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[5] = g[4] | (p[4] & g[3]) | (p[4] & p[3] & g[2]) | (p[4] & p[3] & p[2] & g[1]) | (p[4] & p[3] & p[2] & p[1] & g[0]) | (p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[6] = g[5] | (p[5] & g[4]) | (p[5] & p[4] & g[3]) | (p[5] & p[4] & p[3] & g[2]) | (p[5] & p[4] & p[3] & p[2] & g[1]) | (p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[7] = g[6] | (p[6] & g[5]) | (p[6] & p[5] & g[4]) | (p[6] & p[5] & p[4] & g[3]) | (p[6] & p[5] & p[4] & p[3] & g[2]) | (p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) | (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
    assign c[8] = g[7] | (p[7] & g[6]) | (p[7] & p[6] & g[5]) | (p[7] & p[6] & p[5] & g[4]) | (p[7] & p[6] & p[5] & p[4] & g[3]) | (p[7] & p[6] & p[5] & p[4] & p[3] & g[2]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & g[1]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & g[0]) | (p[7] & p[6] & p[5] & p[4] & p[3] & p[2] & p[1] & p[0] & c[0]);
endmodule

module SUM8 (input wire [7:0] p, input wire [8:0] c, output wire [7:0] s);
    assign s[0] = p[0] ^ c[0];
    assign s[1] = p[1] ^ c[1];
    assign s[2] = p[2] ^ c[2];
    assign s[3] = p[3] ^ c[3];
    assign s[4] = p[4] ^ c[4];
    assign s[5] = p[5] ^ c[5];
    assign s[6] = p[6] ^ c[6];
    assign s[7] = p[7] ^ c[7];
endmodule

module ula_8 (
    input  wire [7:0] A, B,
    input  wire       carry_in,
    input  wire [2:0] seletor,
    output wire [7:0] resultado,
    output wire       carry_out,
    output wire       P_msb,
    output wire       G_msb
);
    wire [7:0] p, g;
    PGbit pg0(.a(A[0]), .b(B[0]), .p(p[0]), .g(g[0]));
    PGbit pg1(.a(A[1]), .b(B[1]), .p(p[1]), .g(g[1]));
    PGbit pg2(.a(A[2]), .b(B[2]), .p(p[2]), .g(g[2]));
    PGbit pg3(.a(A[3]), .b(B[3]), .p(p[3]), .g(g[3]));
    PGbit pg4(.a(A[4]), .b(B[4]), .p(p[4]), .g(g[4]));
    PGbit pg5(.a(A[5]), .b(B[5]), .p(p[5]), .g(g[5]));
    PGbit pg6(.a(A[6]), .b(B[6]), .p(p[6]), .g(g[6]));
    PGbit pg7(.a(A[7]), .b(B[7]), .p(p[7]), .g(g[7]));

    assign P_msb = p[7];
    assign G_msb = g[7];

    wire [8:0] c;
    CLA8 cla(.p(p), .g(g), .cin(carry_in), .c(c));
    wire [7:0] sum;
    SUM8 sb(.p(p), .c(c), .s(sum));

    wire [7:0] sub   = A + (~B) + 8'd1;
    wire [7:0] band  = A & B;
    wire [7:0] bor   = A | B;
    wire [7:0] bxor  = A ^ B;
    wire [7:0] nota  = ~A;
    wire [7:0] inc   = A + 8'd1;
    wire [7:0] passb = B;

    assign resultado = (seletor==3'b000) ? sum  :
                       (seletor==3'b001) ? sub  :
                       (seletor==3'b010) ? band :
                       (seletor==3'b011) ? bor  :
                       (seletor==3'b100) ? bxor :
                       (seletor==3'b101) ? nota :
                       (seletor==3'b110) ? inc  : passb;

    wire cout_sub  = (A + (~B) + 8'd1) >> 8;
    wire cout_inc  = (A + 8'd1) >> 8;
    assign carry_out = (seletor==3'b000) ? c[8] :
                       (seletor==3'b001) ? cout_sub :
                       (seletor==3'b110) ? cout_inc : 1'b0;
endmodule
