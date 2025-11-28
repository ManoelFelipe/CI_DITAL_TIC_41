// ============================================================================
// Arquivo   : count_ascendente_100 (implementação DATAFLOW)
// Autor     : Manoel Furtado
// Data      : 26/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição : Implementação em estilo "dataflow" usando sinais intermediários
//             para representar o próximo valor do contador. O registrador em
//             si é descrito em um bloco sequencial simples, enquanto a lógica
//             combinacional do próximo estado é feita via assign.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module count_ascendente_100_data
#(
    // Parâmetros configuráveis
    parameter integer WIDTH      = 7,  // Largura do contador
    parameter integer MAX_COUNT  = 99  // Módulo do contador
)
(
    // Portas
    input  wire                     clk,         // Clock
    input  wire                     async_reset, // Reset assíncrono
    output wire [WIDTH-1:0]         count_out    // Saída (wire pois é atribuída via assign)
);

    // Sinais internos
    reg [WIDTH-1:0] count_reg;       // Registrador que armazena o estado atual
    wire max_reached;                // Sinal de controle: indica se atingiu o máximo
    wire [WIDTH-1:0] next_count;     // Sinal combinacional: próximo valor do contador

    // Lógica Combinacional (Dataflow)
    // 1. Verifica se o valor atual é igual ao máximo
    assign max_reached = (count_reg == MAX_COUNT[WIDTH-1:0]);
    
    // 2. Define o próximo valor usando operador ternário (mux)
    // Se max_reached for verdadeiro, próximo é 0; senão, é atual + 1
    assign next_count  = max_reached ? {WIDTH{1'b0}} :
                                      (count_reg + 1'b1);

    // Lógica Sequencial (Registrador de Estado)
    always @(posedge clk or posedge async_reset) begin
        // Reset assíncrono
        if (async_reset) begin
            count_reg <= {WIDTH{1'b0}}; // Zera o registrador
        end
        // Atualização síncrona
        else begin
            count_reg <= next_count;    // Carrega o próximo valor calculado
        end
    end

    // Atribuição da saída
    assign count_out = count_reg; // Conecta o registrador interno à saída do módulo

endmodule
