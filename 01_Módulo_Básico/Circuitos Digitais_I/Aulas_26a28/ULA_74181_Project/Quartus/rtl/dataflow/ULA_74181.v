 
// ============================================================================
// ULA_74181.v — Modelo em Dataflow (assign/expressões)
// Autor: Manoel Furtado   |   Data: 31/10/2025
// ============================================================================
`timescale 1ns/1ps

module ULA_74181 #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] A, B,
    input  wire             M,
    input  wire [3:0]       S,
    input  wire             Cn,
    output wire [WIDTH-1:0] F,
    output wire             Cn4,
    output wire             G,
    output wire             T,
    output wire             AeqB
);
    assign AeqB = (A==B);

    wire [WIDTH-1:0] p = A ^ B;
    wire [WIDTH-1:0] g = A & B;
    assign T = &p;
    assign G = g[3] | (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]);

    // bloco lógico
    wire [WIDTH-1:0] F_logic =
        (S==4'b0000) ? ~A :
        (S==4'b0001) ? ~(A|B) :
        (S==4'b0010) ? ((~A)&B) :
        (S==4'b0011) ? 4'b0000 :
        (S==4'b0100) ? ~(A&B) :
        (S==4'b0101) ? ~B :
        (S==4'b0110) ? (A^B) :
        (S==4'b0111) ? ((~A)&(~B)) :
        (S==4'b1000) ? (A&(~B)) :
        (S==4'b1001) ? ~(A^B) :
        (S==4'b1010) ? B :
        (S==4'b1011) ? (A|(~B)) :
        (S==4'b1100) ? A :
        (S==4'b1101) ? (A|B) :
        (S==4'b1110) ? 4'b1111 :
                        A ;

    // bloco aritmético (soma/sub aproximando tabela ativa-alta)
    wire [WIDTH:0] acc0000 = {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc0001 = {{1'b0,A}} + {{1'b0,B}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc0010 = {{1'b0,(A&B)}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc0011 = 5'd0 + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc0100 = {{1'b0,A}} + {{1'b0,(A|B)}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc0101 = {{1'b0,B}} + {{1'b0,(A|B)}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc0110 = {{1'b0,A}} - {{1'b0,B}} + (Cn ? 5'd0 : 5'sd-1);
    wire [WIDTH:0] acc0111 = {{1'b0,(A|B)}} + {{1'b0,(A&B)}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc1000 = {{1'b0,A}} + {{1'b0,B}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc1001 = {{1'b0,A}} + {{1'b0,B}} + (Cn ? 5'd1 : 5'd0);
    wire [WIDTH:0] acc1010 = {{1'b0,B}};
    wire [WIDTH:0] acc1011 = {{1'b0,(A|B)}} + {{1'b0,(A&B)}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc1100 = {{1'b0,A}} + {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc1101 = {{1'b0,(A|B)}} + {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc1110 = {{1'b0,(A|B)}} + {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
    wire [WIDTH:0] acc1111 = {{1'b0,A}} + (Cn ? 5'sd-1 : 5'd0);

    wire [WIDTH:0] acc =
        (S==4'b0000) ? acc0000 :
        (S==4'b0001) ? acc0001 :
        (S==4'b0010) ? acc0010 :
        (S==4'b0011) ? acc0011 :
        (S==4'b0100) ? acc0100 :
        (S==4'b0101) ? acc0101 :
        (S==4'b0110) ? acc0110 :
        (S==4'b0111) ? acc0111 :
        (S==4'b1000) ? acc1000 :
        (S==4'b1001) ? acc1001 :
        (S==4'b1010) ? acc1010 :
        (S==4'b1011) ? acc1011 :
        (S==4'b1100) ? acc1100 :
        (S==4'b1101) ? acc1101 :
        (S==4'b1110) ? acc1110 :
                       acc1111 ;

    assign F   = M ? F_logic : acc[WIDTH-1:0];
    assign Cn4 = M ? 1'b0     : acc[WIDTH];

endmodule
