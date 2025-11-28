// ============================================================================
// Arquivo  : Sklansky.v  (implementação STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 10/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador prefixado de Sklansky (4 bits) com composição estrutural.
//            Usa células "gp" (propagação/geração), "black" (G,P) e "gray" (G).
// ============================================================================

`timescale 1ns/1ps

// ------------------------- Célula de P/G elementar --------------------------
module gp (
    input  wire a, b,       // bits de entrada
    output wire p, g        // p = a ^ b; g = a & b
);
    assign p = a ^ b;       // XOR
    assign g = a & b;       // AND
endmodule

// ------------------------- Célula BLACK (G,P de grupos) ---------------------
// Combina (Gh, Ph) com (Gl, Pl): resultado (G, P) = (Gh | Ph&Gl, Ph&Pl)
module black (
    input  wire Gl, Pl,     // grupo inferior
    input  wire Gh, Ph,     // grupo superior
    output wire G,  P       // grupo combinado
);
    assign G = Gh | (Ph & Gl);
    assign P = Ph & Pl;
endmodule

// ------------------------- Célula GRAY (apenas G de grupos) -----------------
// G = Gh | (Ph & Gl)
module gray (
    input  wire Gl,
    input  wire Gh, Ph,
    output wire G
);
    assign G = Gh | (Ph & Gl);
endmodule

// ------------------------------ Topo Sklansky -------------------------------
module Sklansky (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] Sum,
    output wire       Cout
);
    // P/G elementares
    wire [3:0] P, G;
    gp gp0 (.a(A[0]), .b(B[0]), .p(P[0]), .g(G[0]));
    gp gp1 (.a(A[1]), .b(B[1]), .p(P[1]), .g(G[1]));
    gp gp2 (.a(A[2]), .b(B[2]), .p(P[2]), .g(G[2]));
    gp gp3 (.a(A[3]), .b(B[3]), .p(P[3]), .g(G[3]));

    // Nível 1: grupos [1:0] e [3:2]
    wire G1_1, P1_1, G1_3, P1_3;
    black blk10 (.Gl(G[0]), .Pl(P[0]), .Gh(G[1]), .Ph(P[1]), .G(G1_1), .P(P1_1)); // [1:0]
    black blk32 (.Gl(G[2]), .Pl(P[2]), .Gh(G[3]), .Ph(P[3]), .G(G1_3), .P(P1_3)); // [3:2]

    // Nível 2: grupo [3:0] = [3:2] ° [1:0]
    wire G2_3, P2_3;
    black blk30 (.Gl(G1_1), .Pl(P1_1), .Gh(G1_3), .Ph(P1_3), .G(G2_3), .P(P2_3)); // [3:0]

    // Carries
    wire [3:0] C;
    assign C[0] = Cin;
    assign C[1] = G[0]   | (P[0] & C[0]);   // Cin -> bit0
    assign C[2] = G1_1   | (P1_1 & Cin);    // usa [1:0]
    assign C[3] = G[2]   | (P[2] & C[2]);   // incremental para bit2

    // Somas e carry final
    assign Sum  = P ^ C;
    gray  gryco (.Gl(Cin), .Gh(G2_3), .Ph(P2_3), .G(Cout)); // Cout = G[3:0] | P[3:0]&Cin
endmodule
