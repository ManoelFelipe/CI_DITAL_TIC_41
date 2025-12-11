// ============================================================================
// Arquivo  : rom_16x8_async  (implementação behavioral)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo ROM assíncrona 16 x 8 implementada em Verilog-2001.
// Recebe um endereço de 4 bits e retorna, sem clock, um dado de 8 bits.
// Conteúdo fixo: 16 palavras de 8 bits, de 0x00 até 0xFF em passos de 0x11.
// Implementação na abordagem behavioral, adequada para síntese em FPGAs.
// Como é uma ROM, não há escrita; apenas leitura combinacional.
// Cuidados de síntese: verificar se a ferramenta infere bloco de ROM/ram
// e se não há lógica extra desnecessária que aumente área ou atraso.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo : rom_16x8_async_behavioral
// Objetivo: Implementar ROM 16x8 assíncrona usando case dentro de always @*
// --------------------------------------------------------------------------
module rom_16x8_async_behavioral
#(
    parameter ADDR_WIDTH = 4,               // Largura do barramento de endereço
    parameter DATA_WIDTH = 8                // Largura do barramento de dados
)
(
    input  wire [ADDR_WIDTH-1:0] address,   // Endereço de leitura (0 a 15)
    output reg  [DATA_WIDTH-1:0] data_out   // Dado de saída da ROM
);

    // Bloco always combinacional sensível a qualquer mudança em "address"
    always @* begin
        // Decodificação de endereço via case
        case (address)
            // Para cada endereço, atribui o dado constante correspondente
            4'd0  : data_out = 8'h00;       // Endereço 0  -> dado 0x00
            4'd1  : data_out = 8'h11;       // Endereço 1  -> dado 0x11
            4'd2  : data_out = 8'h22;       // Endereço 2  -> dado 0x22
            4'd3  : data_out = 8'h33;       // Endereço 3  -> dado 0x33
            4'd4  : data_out = 8'h44;       // Endereço 4  -> dado 0x44
            4'd5  : data_out = 8'h55;       // Endereço 5  -> dado 0x55
            4'd6  : data_out = 8'h66;       // Endereço 6  -> dado 0x66
            4'd7  : data_out = 8'h77;       // Endereço 7  -> dado 0x77
            4'd8  : data_out = 8'h88;       // Endereço 8  -> dado 0x88
            4'd9  : data_out = 8'h99;       // Endereço 9  -> dado 0x99
            4'd10 : data_out = 8'hAA;       // Endereço 10 -> dado 0xAA
            4'd11 : data_out = 8'hBB;       // Endereço 11 -> dado 0xBB
            4'd12 : data_out = 8'hCC;       // Endereço 12 -> dado 0xCC
            4'd13 : data_out = 8'hDD;       // Endereço 13 -> dado 0xDD
            4'd14 : data_out = 8'hEE;       // Endereço 14 -> dado 0xEE
            4'd15 : data_out = 8'hFF;       // Endereço 15 -> dado 0xFF
            // Caso default para evitar inferência de latches e X
            default: data_out = {DATA_WIDTH{1'b0}}; // Valor seguro padrão
        endcase
    end

endmodule
