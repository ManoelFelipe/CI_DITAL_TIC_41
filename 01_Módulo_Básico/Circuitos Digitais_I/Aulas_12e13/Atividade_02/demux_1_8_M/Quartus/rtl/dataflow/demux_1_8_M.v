// ============================================================================
// Arquivo.....: demux_1_8_M.v
// Módulo......: demux_1_8_M
// Abordagem...: Fluxo de Dados (Dataflow)
// Descrição...: Demultiplexador 1x8 compatível com Verilog 2001.
// Autor.......: Manoel Furtado
// Data........: 31/10/2025
// Ferramentas.: Quartus / Questa (ModelSim)
// ============================================================================

`timescale 1ns/1ps

// Módulo principal do demultiplexador 1x8
module demux_1_8_M (
    input  wire       D,        // Entrada de dados
    input  wire [2:0] S,        // Seleção (3 bits)
    output wire [7:0] Y         // Saídas
);
    // Implementação em dataflow: expressões booleanas diretas
    assign Y[0] = D & (S == 3'd0); // Y0 é D quando S=0
    assign Y[1] = D & (S == 3'd1); // Y1 é D quando S=1
    assign Y[2] = D & (S == 3'd2); // Y2 é D quando S=2
    assign Y[3] = D & (S == 3'd3); // Y3 é D quando S=3
    assign Y[4] = D & (S == 3'd4); // Y4 é D quando S=4
    assign Y[5] = D & (S == 3'd5); // Y5 é D quando S=5
    assign Y[6] = D & (S == 3'd6); // Y6 é D quando S=6
    assign Y[7] = D & (S == 3'd7); // Y7 é D quando S=7
endmodule
