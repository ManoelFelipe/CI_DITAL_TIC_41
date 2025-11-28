// =============================================================
// Arquivo   : KoggeStone.v (Structural)
// Autor     : Manoel Furtado
// Data      : 10/11/2025
// Descrição : Somador Kogge-Stone 4 bits - versão estrutural
//             Usa células "black_cell" para a rede de prefixos.
// Padrão    : Verilog 2001 (compatível com Quartus/Questa)
// =============================================================
`timescale 1ns/1ps

// ---------------- Black Cell ----------------
// Entrada  alta  : (Gh, Ph) referente ao bit mais significativo do par
// Entrada  baixa : (Gl, Pl) referente ao prefixo menos significativo
// Saída: (Gout, Pout) = (Gh | (Ph & Gl), Ph & Pl)
module black_cell(
    input  wire Gh,
    input  wire Ph,
    input  wire Gl,
    input  wire Pl,
    output wire Gout,
    output wire Pout
);
    assign Gout = Gh | (Ph & Gl);
    assign Pout = Ph & Pl;
endmodule

// ---------------- Topo Kogge-Stone 4 bits ----------------
module KoggeStone (
    input  wire [3:0] A,    // Operando A
    input  wire [3:0] B,    // Operando B
    input  wire       Cin,  // Carry-in
    output wire [3:0] Sum,  // Saída da soma
    output wire       Cout  // Carry-out
);
    // Propagate/Generate por bit
    wire [3:0] P = A ^ B;
    wire [3:0] G = A & B;

    // --------- Nível 1 (distância 1) ----------
    wire G1_0, P1_0, G2_1, P2_1, G3_2, P3_2;
    black_cell BC10 (.Gh(G[1]), .Ph(P[1]), .Gl(G[0]), .Pl(P[0]), .Gout(G1_0), .Pout(P1_0));
    black_cell BC21 (.Gh(G[2]), .Ph(P[2]), .Gl(G[1]), .Pl(P[1]), .Gout(G2_1), .Pout(P2_1));
    black_cell BC32 (.Gh(G[3]), .Ph(P[3]), .Gl(G[2]), .Pl(P[2]), .Gout(G3_2), .Pout(P3_2));

    // --------- Nível 2 (distância 2) ----------
    wire G2_0, P2_0, G3_1, P3_1;
    black_cell BC20 (.Gh(G2_1), .Ph(P2_1), .Gl(G1_0), .Pl(P1_0), .Gout(G2_0), .Pout(P2_0));
    black_cell BC31 (.Gh(G3_2), .Ph(P3_2), .Gl(G2_1), .Pl(P2_1), .Gout(G3_1), .Pout(P3_1));

    // --------- Nível 3 (distância 4) ----------
    wire G3_0, P3_0;
    black_cell BC30 (.Gh(G3_1), .Ph(P3_1), .Gl(G2_0), .Pl(P2_0), .Gout(G3_0), .Pout(P3_0));

    // ------- Carrys prefixados com Cin --------
    wire [3:0] C;
    assign C[0] = G[0]  | (P[0]  & Cin);
    assign C[1] = G1_0  | (P1_0  & Cin);
    assign C[2] = G2_0  | (P2_0  & Cin);
    assign C[3] = G3_0  | (P3_0  & Cin);

    // --------------- Soma final ---------------
    assign Sum  = P ^ {C[2:0], Cin};
    assign Cout = C[3];
endmodule