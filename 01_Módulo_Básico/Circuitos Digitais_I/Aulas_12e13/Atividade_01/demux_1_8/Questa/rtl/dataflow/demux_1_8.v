// demux_1_8.v — Implementação EM FLUXO DE DADOS (Dataflow)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatível com Quartus e Questa (Verilog 2001)

`timescale 1ns/1ps
`default_nettype none

// Nome do módulo e do arquivo são iguais: demux_1_8
module demux_1_8 (
    input  wire       din,      // Entrada de dados (1 bit)
    input  wire [2:0] sel,      // Seleção de saída (3 bits)
    output wire [7:0] dout      // Saídas do demultiplexador (8 bits)
);
    // Cria um vetor base onde apenas o bit indicado por 'sel' é 1
    // (1'b1 << sel) gera uma máscara de 8 bits com um único 1 na posição 'sel'
    wire [7:0] one_hot = (8'b0000_0001 << sel);
    // Multiplica lógica: quando din=1, a máscara aparece nas saídas;
    // quando din=0, todas as saídas ficam 0. Operação bit a bit (&).
    assign dout = {8{din}} & one_hot;
endmodule

`default_nettype wire
