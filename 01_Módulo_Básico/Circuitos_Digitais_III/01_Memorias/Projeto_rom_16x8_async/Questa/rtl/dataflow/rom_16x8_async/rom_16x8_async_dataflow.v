// ============================================================================
// Arquivo  : rom_16x8_async  (implementação dataflow)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo ROM assíncrona 16 x 8 implementada em Verilog-2001.
// Recebe um endereço de 4 bits e retorna, sem clock, um dado de 8 bits.
// Conteúdo fixo: 16 palavras de 8 bits, de 0x00 até 0xFF em passos de 0x11.
// Implementação na abordagem dataflow, adequada para síntese em FPGAs.
// Como é uma ROM, não há escrita; apenas leitura combinacional.
// Cuidados de síntese: verificar se a ferramenta infere bloco de ROM/ram
// e se não há lógica extra desnecessária que aumente área ou atraso.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo : rom_16x8_async_dataflow
// Objetivo: Implementar ROM 16x8 assíncrona usando array + assign (dataflow)
// --------------------------------------------------------------------------
module rom_16x8_async_dataflow
#(
    parameter ADDR_WIDTH = 4,                     // Largura do endereço (4 bits)
    parameter DATA_WIDTH = 8,                     // Largura dos dados (8 bits)
    parameter DEPTH      = 1 << ADDR_WIDTH        // Profundidade da ROM (16)
)
(
    input  wire [ADDR_WIDTH-1:0] address,         // Endereço de leitura
    output wire [DATA_WIDTH-1:0] data_out         // Dado de saída
);

    // Declaração da memória ROM como array de registradores
    reg [DATA_WIDTH-1:0] rom_mem [0:DEPTH-1];     // 16 posições de 8 bits

    // Bloco de inicialização: executado apenas em simulação
    initial begin
        rom_mem[ 0] = 8'h00;                      // Endereço 0  -> 0x00
        rom_mem[ 1] = 8'h11;                      // Endereço 1  -> 0x11
        rom_mem[ 2] = 8'h22;                      // Endereço 2  -> 0x22
        rom_mem[ 3] = 8'h33;                      // Endereço 3  -> 0x33
        rom_mem[ 4] = 8'h44;                      // Endereço 4  -> 0x44
        rom_mem[ 5] = 8'h55;                      // Endereço 5  -> 0x55
        rom_mem[ 6] = 8'h66;                      // Endereço 6  -> 0x66
        rom_mem[ 7] = 8'h77;                      // Endereço 7  -> 0x77
        rom_mem[ 8] = 8'h88;                      // Endereço 8  -> 0x88
        rom_mem[ 9] = 8'h99;                      // Endereço 9  -> 0x99
        rom_mem[10] = 8'hAA;                      // Endereço 10 -> 0xAA
        rom_mem[11] = 8'hBB;                      // Endereço 11 -> 0xBB
        rom_mem[12] = 8'hCC;                      // Endereço 12 -> 0xCC
        rom_mem[13] = 8'hDD;                      // Endereço 13 -> 0xDD
        rom_mem[14] = 8'hEE;                      // Endereço 14 -> 0xEE
        rom_mem[15] = 8'hFF;                      // Endereço 15 -> 0xFF
    end

    // Atribuição contínua: leitura assíncrona da ROM
    assign data_out = rom_mem[address];           // Saída segue conteúdo endereçado

endmodule
