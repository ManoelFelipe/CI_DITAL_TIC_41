// ============================================================================
// Arquivo  : ram_16x8_sync  (implementação dataflow)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo de memória RAM síncrona 16x8. Implementa 16 posições de
//            memória. Utiliza construções dataflow (assigns/always) explícitas
//            para controle de escrita e leitura síncrona.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps                          // Define unidade e precisão de tempo

module ram_16x8_sync_dataflow (             // Declaração do módulo dataflow
    input  wire        clk,                 // Clock da RAM
    input  wire        we,                  // Sinal de escrita (Write Enable)
    input  wire [3:0]  address,             // Endereço de 4 bits
    input  wire [7:0]  data_in,             // Dado de entrada
    output wire [7:0]  data_out             // Dado de saída (wire, dirigido por reg)
);                                          // Fim da lista de portas

    // Memória interna: 16 palavras de 8 bits
    reg [7:0] mem_array [0:15];             // Vetor de registradores
    reg [7:0] data_out_reg;                 // Registrador de saída

    integer i;                              // Índice de inicialização

    initial begin                           // Bloco de inicialização
        for (i = 0; i < 16; i = i + 1)      // Percorre todas as posições
            mem_array[i] = 8'h00;           // Zera a memória
        data_out_reg = 8'h00;               // Zera registrador de saída
    end                                     // Fim do bloco initial

    // Atribuição contínua: saída externa conectada ao registrador interno
    assign data_out = data_out_reg;         // Mapeia reg para a porta de saída

    always @(posedge clk) begin             // Bloco sequencial síncrono
        // Escrita controlada por decoder lógico com operador condicional
        if (we) begin                       // Se habilitado para escrita
            mem_array[address] <= data_in;  // Atualiza posição selecionada
        end                                 // Fim do if de escrita

        // Leitura síncrona usando operador case (estilo dataflow controlado)
        case (address)                      // Seleciona posição de memória
            4'd0  : data_out_reg <= mem_array[0];  // Endereço 0
            4'd1  : data_out_reg <= mem_array[1];  // Endereço 1
            4'd2  : data_out_reg <= mem_array[2];  // Endereço 2
            4'd3  : data_out_reg <= mem_array[3];  // Endereço 3
            4'd4  : data_out_reg <= mem_array[4];  // Endereço 4
            4'd5  : data_out_reg <= mem_array[5];  // Endereço 5
            4'd6  : data_out_reg <= mem_array[6];  // Endereço 6
            4'd7  : data_out_reg <= mem_array[7];  // Endereço 7
            4'd8  : data_out_reg <= mem_array[8];  // Endereço 8
            4'd9  : data_out_reg <= mem_array[9];  // Endereço 9
            4'd10 : data_out_reg <= mem_array[10]; // Endereço 10
            4'd11 : data_out_reg <= mem_array[11]; // Endereço 11
            4'd12 : data_out_reg <= mem_array[12]; // Endereço 12
            4'd13 : data_out_reg <= mem_array[13]; // Endereço 13
            4'd14 : data_out_reg <= mem_array[14]; // Endereço 14
            4'd15 : data_out_reg <= mem_array[15]; // Endereço 15
            default: data_out_reg <= 8'h00;        // Proteção contra valores inválidos
        endcase                               // Fim do case de leitura
    end                                       // Fim do bloco always

endmodule                                     // Fim do módulo ram_16x8_sync_dataflow
