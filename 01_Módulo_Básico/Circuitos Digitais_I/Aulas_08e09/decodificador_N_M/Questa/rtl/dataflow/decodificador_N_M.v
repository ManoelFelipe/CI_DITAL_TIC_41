// =============================================================
// Projeto: Decodificador Parametrizável N→M (M = 2^N) - Atividade 3
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Notas:
//  - Três abordagens: Behavioral, Dataflow e Structural.
//  - Parâmetros: N (bits de entrada), M (=1<<N) derivado via localparam.
//  - Saídas ativas em ALTO (one-hot). Parâmetro opcional ACTIVE_LOW.
// =============================================================

// ------------------------------
// Arquivo: decodificador_N_M.v
// Estilo: Fluxo de Dados (Dataflow)
// ------------------------------
`timescale 1ns/1ps

module decodificador_N_M_dataflow
#(
    parameter integer N = 4,
    parameter integer ACTIVE_LOW = 0
)
(
    input  [N-1:0] a,
    output [(1<<N)-1:0] y
);
    localparam integer M = (1<<N);
    wire [M-1:0] one_vec = {{(M-1){1'b0}}, 1'b1};
    assign y = ACTIVE_LOW ? ~(one_vec << a) : (one_vec << a);
endmodule
