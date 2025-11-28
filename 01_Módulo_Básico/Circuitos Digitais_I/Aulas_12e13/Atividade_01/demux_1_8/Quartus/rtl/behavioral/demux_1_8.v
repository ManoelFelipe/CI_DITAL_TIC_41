// demux_1_8.v — Implementação COMPORTAMENTAL (Behavioral)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatível com Quartus e Questa (Verilog 2001)

`timescale 1ns/1ps
// Desabilita criação implícita de fios (boa prática)
`default_nettype none

// Nome do módulo e do arquivo são iguais: demux_1_8
module demux_1_8 (
    input  wire       din,      // Entrada de dados (1 bit)
    input  wire [2:0] sel,      // Seleção de saída (3 bits -> 8 possibilidades)
    output reg  [7:0] dout      // Saídas do demultiplexador (8 bits)
);
    // Bloco sempre sensível a qualquer mudança nas entradas
    always @* begin
        // Zera todas as saídas inicialmente
        dout = 8'b0000_0000;    // Todas saídas em 0
        
        // Seleciona qual bit de saída recebe 'din'
        case (sel)               // Analisa o valor de sel
            3'd0: dout[0] = din; // Quando sel=0, envia din para dout[0]
            3'd1: dout[1] = din; // Quando sel=1, envia din para dout[1]
            3'd2: dout[2] = din; // Quando sel=2, envia din para dout[2]
            3'd3: dout[3] = din; // Quando sel=3, envia din para dout[3]
            3'd4: dout[4] = din; // Quando sel=4, envia din para dout[4]
            3'd5: dout[5] = din; // Quando sel=5, envia din para dout[5]
            3'd6: dout[6] = din; // Quando sel=6, envia din para dout[6]
            3'd7: dout[7] = din; // Quando sel=7, envia din para dout[7]
            default: ;           // Demais casos não ocorrem (sel é 3 bits)
        endcase
    end
endmodule

// Reabilita o comportamento padrão de nets implícitas
`default_nettype wire
