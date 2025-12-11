// ============================================================================
// Arquivo  : rom_16x8_async  (implementação structural)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo ROM assíncrona 16 x 8 implementada em Verilog-2001.
// Recebe um endereço de 4 bits e retorna, sem clock, um dado de 8 bits.
// Conteúdo fixo: 16 palavras de 8 bits, de 0x00 até 0xFF em passos de 0x11.
// Implementação na abordagem structural, adequada para síntese em FPGAs.
// Como é uma ROM, não há escrita; apenas leitura combinacional.
// Cuidados de síntese: verificar se a ferramenta infere bloco de ROM/ram
// e se não há lógica extra desnecessária que aumente área ou atraso.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo : mux16x1_8bit
// Objetivo: Mux 16:1 de 8 bits, usado na implementação estrutural da ROM
// --------------------------------------------------------------------------
module mux16x1_8bit
(
    input  wire [7:0] d0,   // Entrada de dados 0
    input  wire [7:0] d1,   // Entrada de dados 1
    input  wire [7:0] d2,   // Entrada de dados 2
    input  wire [7:0] d3,   // Entrada de dados 3
    input  wire [7:0] d4,   // Entrada de dados 4
    input  wire [7:0] d5,   // Entrada de dados 5
    input  wire [7:0] d6,   // Entrada de dados 6
    input  wire [7:0] d7,   // Entrada de dados 7
    input  wire [7:0] d8,   // Entrada de dados 8
    input  wire [7:0] d9,   // Entrada de dados 9
    input  wire [7:0] d10,  // Entrada de dados 10
    input  wire [7:0] d11,  // Entrada de dados 11
    input  wire [7:0] d12,  // Entrada de dados 12
    input  wire [7:0] d13,  // Entrada de dados 13
    input  wire [7:0] d14,  // Entrada de dados 14
    input  wire [7:0] d15,  // Entrada de dados 15
    input  wire [3:0] sel,  // Seleção de endereço (4 bits)
    output reg  [7:0] y     // Saída de dados multiplexada
);

    // Bloco combinacional que seleciona uma das 16 entradas
    always @* begin
        case (sel)
            4'd0  : y = d0;   // Selecione d0
            4'd1  : y = d1;   // Selecione d1
            4'd2  : y = d2;   // Selecione d2
            4'd3  : y = d3;   // Selecione d3
            4'd4  : y = d4;   // Selecione d4
            4'd5  : y = d5;   // Selecione d5
            4'd6  : y = d6;   // Selecione d6
            4'd7  : y = d7;   // Selecione d7
            4'd8  : y = d8;   // Selecione d8
            4'd9  : y = d9;   // Selecione d9
            4'd10 : y = d10;  // Selecione d10
            4'd11 : y = d11;  // Selecione d11
            4'd12 : y = d12;  // Selecione d12
            4'd13 : y = d13;  // Selecione d13
            4'd14 : y = d14;  // Selecione d14
            4'd15 : y = d15;  // Selecione d15
            default: y = 8'h00; // Valor default seguro
        endcase
    end

endmodule

// --------------------------------------------------------------------------
// Módulo : rom_16x8_async_structural
// Objetivo: ROM 16x8 assíncrona montada estruturalmente com constantes + mux
// --------------------------------------------------------------------------
module rom_16x8_async_structural
#(
    parameter ADDR_WIDTH = 4,           // Largura de endereço (4 bits)
    parameter DATA_WIDTH = 8            // Largura de dados (8 bits)
)
(
    input  wire [ADDR_WIDTH-1:0] address,   // Endereço de leitura
    output wire [DATA_WIDTH-1:0] data_out   // Dado de saída
);

    // Sinais internos com valores constantes para cada posição da ROM
    wire [DATA_WIDTH-1:0] rom_d0  = 8'h00;  // Conteúdo endereço 0
    wire [DATA_WIDTH-1:0] rom_d1  = 8'h11;  // Conteúdo endereço 1
    wire [DATA_WIDTH-1:0] rom_d2  = 8'h22;  // Conteúdo endereço 2
    wire [DATA_WIDTH-1:0] rom_d3  = 8'h33;  // Conteúdo endereço 3
    wire [DATA_WIDTH-1:0] rom_d4  = 8'h44;  // Conteúdo endereço 4
    wire [DATA_WIDTH-1:0] rom_d5  = 8'h55;  // Conteúdo endereço 5
    wire [DATA_WIDTH-1:0] rom_d6  = 8'h66;  // Conteúdo endereço 6
    wire [DATA_WIDTH-1:0] rom_d7  = 8'h77;  // Conteúdo endereço 7
    wire [DATA_WIDTH-1:0] rom_d8  = 8'h88;  // Conteúdo endereço 8
    wire [DATA_WIDTH-1:0] rom_d9  = 8'h99;  // Conteúdo endereço 9
    wire [DATA_WIDTH-1:0] rom_d10 = 8'hAA;  // Conteúdo endereço 10
    wire [DATA_WIDTH-1:0] rom_d11 = 8'hBB;  // Conteúdo endereço 11
    wire [DATA_WIDTH-1:0] rom_d12 = 8'hCC;  // Conteúdo endereço 12
    wire [DATA_WIDTH-1:0] rom_d13 = 8'hDD;  // Conteúdo endereço 13
    wire [DATA_WIDTH-1:0] rom_d14 = 8'hEE;  // Conteúdo endereço 14
    wire [DATA_WIDTH-1:0] rom_d15 = 8'hFF;  // Conteúdo endereço 15

    // Instância do multiplexador 16:1 de 8 bits
    mux16x1_8bit u_mux16x1_8bit
    (
        .d0  (rom_d0 ),             // Conecta constante do endereço 0
        .d1  (rom_d1 ),             // Conecta constante do endereço 1
        .d2  (rom_d2 ),             // Conecta constante do endereço 2
        .d3  (rom_d3 ),             // Conecta constante do endereço 3
        .d4  (rom_d4 ),             // Conecta constante do endereço 4
        .d5  (rom_d5 ),             // Conecta constante do endereço 5
        .d6  (rom_d6 ),             // Conecta constante do endereço 6
        .d7  (rom_d7 ),             // Conecta constante do endereço 7
        .d8  (rom_d8 ),             // Conecta constante do endereço 8
        .d9  (rom_d9 ),             // Conecta constante do endereço 9
        .d10 (rom_d10),             // Conecta constante do endereço 10
        .d11 (rom_d11),             // Conecta constante do endereço 11
        .d12 (rom_d12),             // Conecta constante do endereço 12
        .d13 (rom_d13),             // Conecta constante do endereço 13
        .d14 (rom_d14),             // Conecta constante do endereço 14
        .d15 (rom_d15),             // Conecta constante do endereço 15
        .sel (address[3:0]),        // Seleção controlada pelo endereço
        .y   (data_out)             // Saída de dados da ROM
    );

endmodule
