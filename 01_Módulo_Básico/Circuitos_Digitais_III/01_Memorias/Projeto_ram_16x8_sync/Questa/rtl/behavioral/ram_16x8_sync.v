// ============================================================================
// Arquivo  : ram_16x8_sync  (implementação behavioral)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo de memória RAM síncrona 16x8. Implementa 16 posições de
//            memória, cada uma com 8 bits. Escrita e leitura síncronas.
//            Modelagem comportamental ideal para inferência de Block RAM.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps                      // Define unidade e precisão de tempo

module ram_16x8_sync_behavioral (       // Declaração do módulo behavioral
    input  wire        clk,             // Clock da RAM
    input  wire        we,              // Sinal de escrita (Write Enable)
    input  wire [3:0]  address,         // Endereço de 4 bits (16 posições)
    input  wire [7:0]  data_in,         // Dado de entrada (8 bits)
    output reg  [7:0]  data_out         // Dado de saída registrado
);                                      // Fim da lista de portas

    // Memória representada como vetor de registradores
    reg [7:0] mem_array [0:15];         // 16 posições de 8 bits cada

    integer i;                          // Índice para laço de inicialização

    initial begin                       // Bloco de inicialização
        for (i = 0; i < 16; i = i + 1)  // Percorre todas as posições
            mem_array[i] = 8'h00;       // Zera o conteúdo da memória
        data_out = 8'h00;               // Zera saída inicial
    end                                 // Fim do bloco initial

    always @(posedge clk) begin         // Bloco sensível à borda de subida
        if (we) begin                   // Se sinal de escrita ativo
            mem_array[address] <= data_in; // Escreve dado na posição endereçada
        end                             // Fim do if de escrita

        data_out <= mem_array[address]; // Leitura síncrona: registra dado lido
    end                                 // Fim do bloco always

endmodule                               // Fim do módulo ram_16x8_sync_behavioral
