// ============================================================================
// Arquivo.....: demux_1_8_M.v
// Módulo......: demux_1_8_M
// Abordagem...: Estrutural (Structural)
// Descrição...: Demultiplexador 1x8 compatível com Verilog 2001.
// Autor.......: Manoel Furtado
// Data........: 31/10/2025
// Ferramentas.: Quartus / Questa (ModelSim)
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Submódulo: demux 1x2
// Divide a entrada D entre Y0 e Y1 com base em S.
// --------------------------------------------------------------------------
module demux_1_2_M (
    input  wire D,     // Entrada
    input  wire S,     // Seleção (1 bit)
    output wire Y0,    // Saída 0
    output wire Y1     // Saída 1
);
    assign Y0 = (~S) ? D : 1'b0; // Quando S=0, Y0 recebe D
    assign Y1 = ( S) ? D : 1'b0; // Quando S=1, Y1 recebe D
endmodule

// --------------------------------------------------------------------------
// Submódulo: demux 1x4
// Pode ser visto como cascata de dois demux_1_2_M.
// --------------------------------------------------------------------------
module demux_1_4_M (
    input  wire       D,       // Entrada
    input  wire [1:0] S,       // Seleção (2 bits)
    output wire [3:0] Y        // Saídas
);
    wire l, h;                  // Fios internos vindos do 1x2
    demux_1_2_M u10 (.D(D), .S(S[1]), .Y0(l), .Y1(h)); // Bit mais significativo escolhe bloco inferior/superior

    // Dentro de cada bloco 1x2, outro 1x2 resolve o bit menos significativo
    demux_1_2_M u20 (.D(l), .S(S[0]), .Y0(Y[0]), .Y1(Y[1]));
    demux_1_2_M u21 (.D(h), .S(S[0]), .Y0(Y[2]), .Y1(Y[3]));
endmodule

// --------------------------------------------------------------------------
// Módulo principal 1x8 construído com UM 1x2 e DOIS 1x4.
// S[2] seleciona qual 1x4 recebe D; S[1:0] endereça a linha dentro do 1x4.
// --------------------------------------------------------------------------
module demux_1_8_M (
    input  wire       D,        // Entrada de dados
    input  wire [2:0] S,        // Seleção (3 bits) [2] alto/baixo, [1:0] interno
    output wire [7:0] Y         // Saídas
);
    wire D_low, D_high;         // Saídas do 1x2

    // Primeiro nível: 1x2 decide entre os nibbles baixo (Y[3:0]) e alto (Y[7:4])
    demux_1_2_M u0 (.D(D), .S(S[2]), .Y0(D_low), .Y1(D_high));

    // Segundo nível: dois 1x4 resolvendo S[1:0]
    demux_1_4_M u1 (.D(D_low),  .S(S[1:0]), .Y(Y[3:0]));  // Saídas 0..3
    demux_1_4_M u2 (.D(D_high), .S(S[1:0]), .Y(Y[7:4]));  // Saídas 4..7
endmodule
