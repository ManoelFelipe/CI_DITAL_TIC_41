
// ============================================================================
// ULA_74181.v — Modelo estrutural (gates + multiplexadores simples)
// Autor: Manoel Furtado   |   Data: 31/10/2025
// Nota: Para manter o foco didático, o estrutural instancia portas básicas
//       para montar um MUX de 16:1 para o bloco lógico e usa um somador
//       de 4 bits para o bloco aritmético.
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

    // sinais de grupo (como nos demais modelos)
    wire [WIDTH-1:0] p = A ^ B;
    wire [WIDTH-1:0] g = A & B;
    assign T = &p;
    assign G = g[3] | (p[3]&g[2]) | (p[3]&p[2]&g[1]) | (p[3]&p[2]&p[1]&g[0]);

    // ---------- bloco lógico: gera 16 candidatos ----------
    wire [WIDTH-1:0] L0  = ~A;
    wire [WIDTH-1:0] L1  = ~(A|B);
    wire [WIDTH-1:0] L2  = (~A)&B;
    wire [WIDTH-1:0] L3  = 4'b0000;
    wire [WIDTH-1:0] L4  = ~(A&B);
    wire [WIDTH-1:0] L5  = ~B;
    wire [WIDTH-1:0] L6  =  A ^ B;
    wire [WIDTH-1:0] L7  = (~A)&(~B);
    wire [WIDTH-1:0] L8  =  A & (~B);
    wire [WIDTH-1:0] L9  = ~(A ^ B);
    wire [WIDTH-1:0] L10 =  B;
    wire [WIDTH-1:0] L11 =  A | (~B);
    wire [WIDTH-1:0] L12 =  A;
    wire [WIDTH-1:0] L13 =  A | B;
    wire [WIDTH-1:0] L14 =  4'b1111;
    wire [WIDTH-1:0] L15 =  A;

    // MUX 16:1 (estrutural via operador condicional por bit)
    wire [WIDTH-1:0] F_logic =
        (S==4'b0000)?L0 :(S==4'b0001)?L1 :(S==4'b0010)?L2 :(S==4'b0011)?L3 :
        (S==4'b0100)?L4 :(S==4'b0101)?L5 :(S==4'b0110)?L6 :(S==4'b0111)?L7 :
        (S==4'b1000)?L8 :(S==4'b1001)?L9 :(S==4'b1010)?L10:(S==4'b1011)?L11:
        (S==4'b1100)?L12:(S==4'b1101)?L13:(S==4'b1110)?L14:               L15 ;

    // ---------- bloco aritmético: somador/ACCs ----------
    wire [WIDTH:0] acc;
    reg  [WIDTH:0] r;

    always @* begin
        case (S)
            4'b0000: r = {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
            4'b0001: r = {{1'b0,A}} + {{1'b0,B}} + (Cn ? 5'd0 : 5'd1);
            4'b0010: r = {{1'b0,(A&B)}} + (Cn ? 5'd0 : 5'd1);
            4'b0011: r = 5'd0 + (Cn ? 5'd0 : 5'd1);
            4'b0100: r = {{1'b0,A}} + {{1'b0,(A|B)}} + (Cn ? 5'd0 : 5'd1);
            4'b0101: r = {{1'b0,B}} + {{1'b0,(A|B)}} + (Cn ? 5'd0 : 5'd1);
            4'b0110: r = {{1'b0,A}} - {{1'b0,B}} + (Cn ? 5'd0 : 5'sd-1);
            4'b0111: r = {{1'b0,(A|B)}} + {{1'b0,(A&B)}} + (Cn ? 5'd0 : 5'd1);
            4'b1000: r = {{1'b0,A}} + {{1'b0,B}} + (Cn ? 5'd0 : 5'd1);
            4'b1001: r = {{1'b0,A}} + {{1'b0,B}} + (Cn ? 5'd1 : 5'd0);
            4'b1010: r = {{1'b0,B}};
            4'b1011: r = {{1'b0,(A|B)}} + {{1'b0,(A&B)}} + (Cn ? 5'd0 : 5'd1);
            4'b1100: r = {{1'b0,A}} + {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
            4'b1101: r = {{1'b0,(A|B)}} + {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
            4'b1110: r = {{1'b0,(A|B)}} + {{1'b0,A}} + (Cn ? 5'd0 : 5'd1);
            4'b1111: r = {{1'b0,A}} + (Cn ? 5'sd-1 : 5'd0);
            default: r = 0;
        endcase
    end
    assign acc = r;

    assign F   = M ? F_logic : acc[WIDTH-1:0];
    assign Cn4 = M ? 1'b0     : acc[WIDTH];

endmodule
