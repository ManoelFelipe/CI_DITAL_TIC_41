// ===============================================================
//  ula_8.v (Dataflow) — ULA de 8 bits com soma via Carry Look-Ahead
//  Autor: Manoel Furtado
//  Data:  31/10/2025
//  Compatibilidade: Verilog 2001 (Questa / Quartus)
// ---------------------------------------------------------------

module ula_8 (
    input  wire [7:0] A, B,
    input  wire       carry_in,
    input  wire [2:0] seletor,
    output wire [7:0] resultado,
    output wire       carry_out,
    output wire       P_msb,
    output wire       G_msb
);

    wire [7:0] P = A ^ B;             // Propagate
    wire [7:0] G = A & B;             // Generate
    assign P_msb = P[7];
    assign G_msb = G[7];

    wire [8:0] c;
    assign c[0] = carry_in;
    assign c[1] = G[0] | (P[0] & c[0]);
    assign c[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & c[0]);
    assign c[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & c[0]);
    assign c[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & c[0]);
    assign c[5] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & G[0]) | (P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);
    assign c[6] = G[5] | (P[5] & G[4]) | (P[5] & P[4] & G[3]) | (P[5] & P[4] & P[3] & G[2]) | (P[5] & P[4] & P[3] & P[2] & G[1]) | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);
    assign c[7] = G[6] | (P[6] & G[5]) | (P[6] & P[5] & G[4]) | (P[6] & P[5] & P[4] & G[3]) | (P[6] & P[5] & P[4] & P[3] & G[2]) | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);
    assign c[8] = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4]) | (P[7] & P[6] & P[5] & P[4] & G[3]) | (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);

    wire [7:0] sum;
    assign sum[0] = P[0] ^ c[0];
    assign sum[1] = P[1] ^ c[1];
    assign sum[2] = P[2] ^ c[2];
    assign sum[3] = P[3] ^ c[3];
    assign sum[4] = P[4] ^ c[4];
    assign sum[5] = P[5] ^ c[5];
    assign sum[6] = P[6] ^ c[6];
    assign sum[7] = P[7] ^ c[7];

    wire [7:0] sub  = A + (~B) + 8'd1;
    wire [7:0] band = A & B;
    wire [7:0] bor  = A | B;
    wire [7:0] bxor = A ^ B;
    wire [7:0] nota = ~A;
    wire [7:0] inc  = A + 8'd1;
    wire [7:0] passb= B;

    assign resultado = (seletor==3'b000) ? sum  :
                       (seletor==3'b001) ? sub  :
                       (seletor==3'b010) ? band :
                       (seletor==3'b011) ? bor  :
                       (seletor==3'b100) ? bxor :
                       (seletor==3'b101) ? nota :
                       (seletor==3'b110) ? inc  :
                                           passb;

    wire cout_sub  = (A + (~B) + 8'd1) >> 8;
    wire cout_inc  = (A + 8'd1) >> 8;
    assign carry_out = (seletor==3'b000) ? c[8] :
                       (seletor==3'b001) ? cout_sub :
                       (seletor==3'b110) ? cout_inc : 1'b0;
endmodule
