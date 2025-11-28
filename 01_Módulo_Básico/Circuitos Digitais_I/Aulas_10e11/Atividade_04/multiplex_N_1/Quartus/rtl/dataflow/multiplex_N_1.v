// ===============================================================
// Multiplexador Nx1 - Implementação Dataflow
// Autor: Manoel Furtado
// Data: 31/10/2025
// Linguagem: Verilog-2001 (Compatível com Quartus e Questa)
// ===============================================================
`timescale 1ns/1ps
module multiplex_N_1
#(
    parameter integer N = 4,
    parameter integer SEL_WIDTH = $clog2(N)
)
(
    input  wire [N-1:0] din,
    input  wire [SEL_WIDTH-1:0] sel,
    output wire y
);
    assign y = (sel < N) ? din[sel] : 1'bx;
endmodule
