// ============================================================================
// Arquivo  : sistema_memoria  (implementação [BEHAVIORAL])
// Autor    : Manoel Furtado
// Data     : 2025-12-15
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Sistema de memória endereçável de 128 bytes (7 bits de endereço) com topologia 4x4 de blocos 8x8. As duas linhas superiores são ROM (64 bytes) e as duas inferiores são SRAM (64 bytes). Escrita síncrona na SRAM com WE e CLK; leitura registrada em DOUT para comportamento determinístico em simulação e síntese. A ROM é implementada via função combinacional derivada do endereço (conteúdo fixo), evitando arquivos de inicialização. Riscos: multiplexação grande pode impactar timing; uso de registrador de saída reduz glitches e facilita equivalência entre abordagens.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps

// ============================================================================
// Módulo: sistema_memoria (Behavioral)
// - Endereço A[6:0] mapeia 128 bytes:
//     A6..A5 = seletor de linha (0..3)
//     A4..A3 = seletor de coluna (0..3)
//     A2..A0 = endereço interno do bloco 8x8 (0..7)
// - Linhas 0 e 1 -> ROM (somente leitura)
// - Linhas 2 e 3 -> SRAM (leitura + escrita)
// - Escrita SRAM: síncrona no posedge CLK quando WE=1
// - Leitura (ROM e SRAM): registrada em DOUT no posedge CLK
// ============================================================================
module sistema_memoria_behavioral (
    input  wire        clk,   // clock do sistema
    input  wire        we,    // write enable (válido apenas para SRAM)
    input  wire [6:0]  a,     // endereço global (128 bytes)
    input  wire [7:0]  din,   // dado de entrada (escrita na SRAM)
    output reg  [7:0]  dout   // dado de saída (leitura registrada)
);

    // ------------------------------------------------------------------------
    // Função combinacional para conteúdo de ROM
    // - Conteúdo fixo e determinístico derivado do endereço global:
    //   dout_rom = {linha[1:0], coluna[1:0], offset[2:0], 1'b0}
    // - Isso evita arquivos .mif/.hex e mantém compatibilidade entre ferramentas.
    // ------------------------------------------------------------------------
    function [7:0] rom_byte;
        input [6:0] addr;                      // endereço global
        begin
            rom_byte = {addr[6:5], addr[4:3], addr[2:0], 1'b0};
        end
    endfunction

    // ------------------------------------------------------------------------
    // SRAM (64 bytes) para as linhas 2 e 3 (metade inferior)
    // - Usamos um único vetor linear para simplificar: 0..63
    // - Mapeamento: addr[6:0] 64..127 -> sram_index = addr - 64
    // ------------------------------------------------------------------------
    reg [7:0] sram_mem [0:63];                 // memória SRAM linear

    integer i;                                  // índice para loops de inicialização

    // ------------------------------------------------------------------------
    // Inicialização (apenas para simulação)
    // - Em síntese, esta inicialização pode ser ignorada dependendo da FPGA.
    // - Mantemos zeros para previsibilidade em testes.
    // ------------------------------------------------------------------------
    initial begin
        for (i = 0; i < 64; i = i + 1) begin
            sram_mem[i] = 8'h00;               // zera toda a SRAM
        end
    end

    // ------------------------------------------------------------------------
    // Leitura combinacional da fonte selecionada (ROM ou SRAM)
    // - Em seguida, o valor é registrado em DOUT no clock.
    // ------------------------------------------------------------------------
    reg [7:0] read_data;                        // dado lido antes do registro

    always @(*) begin
        // default seguro para evitar latch em read_data
        read_data = 8'h00;

        // Se a linha selecionada for 0 ou 1, estamos na região ROM (0..63).
        if (a[6:5] < 2'd2) begin
            read_data = rom_byte(a);           // lê da ROM por função
        end
        // Caso contrário (linhas 2 ou 3), estamos na SRAM (64..127).
        else begin
            read_data = sram_mem[a - 7'd64];   // lê da SRAM linearizada
        end
    end

    // ------------------------------------------------------------------------
    // Escrita síncrona na SRAM
    // - Só ocorre se:
    //     (1) endereço na metade inferior (linhas 2/3) e
    //     (2) WE = 1
    // ------------------------------------------------------------------------
    always @(posedge clk) begin
        // Se estiver na região SRAM e we estiver ativo, escreve em sram_mem.
        if ((a[6:5] >= 2'd2) && (we == 1'b1)) begin
            sram_mem[a - 7'd64] <= din;        // escrita síncrona
        end

        // Registro de saída: sempre captura o dado lido (ROM ou SRAM).
        dout <= read_data;
    end

endmodule
