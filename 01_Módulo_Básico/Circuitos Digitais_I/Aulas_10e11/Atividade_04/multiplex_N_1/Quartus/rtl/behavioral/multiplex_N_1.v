// ===============================================================
// Multiplexador Nx1 - Implementação Comportamental
// Autor: Manoel Furtado
// Data: 31/10/2025
// Linguagem: Verilog-2001 (Compatível com Quartus e Questa)
// ===============================================================
`timescale 1ns/1ps
module multiplex_N_1
#(
    parameter N = 4,
    // Tornamos SEL_WIDTH um PARÂMETRO (visível na lista de portas)
    parameter SEL_WIDTH = $clog2(N)
)
(
    input  wire [N-1:0] din,
    input  wire [SEL_WIDTH-1:0] sel,
    output reg  y
);
    // Lógica combinacional segura
    always @(*) begin
        y = 1'bx;           // padrão defensivo
        if (sel < N)
            y = din[sel];   // indexação variável válida
    end
endmodule
