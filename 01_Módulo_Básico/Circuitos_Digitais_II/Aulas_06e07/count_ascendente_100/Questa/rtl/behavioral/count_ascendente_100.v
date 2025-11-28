// ============================================================================
// Arquivo   : count_ascendente_100 (implementação BEHAVIORAL)
// Autor     : Manoel Furtado
// Data      : 26/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição : Contador síncrono ascendente módulo 100, com reset assíncrono
//             ativo em nível alto. A abordagem behavioral descreve o
//             comportamento completo do registrador usando um único bloco
//             always sensível à borda de subida do clock e à borda de subida
//             do sinal de reset. Quando o reset é ativado, a saída vai
//             imediatamente para zero. Quando o contador atinge MAX_COUNT
//             (99 por padrão), ele retorna para zero no próximo pulso de
//             clock, implementando um contador módulo 100. Parametrização de
//             largura permite reutilizar o módulo com outros limites.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module count_ascendente_100_behav
#(
    // Parâmetros configuráveis para largura do contador e valor máximo de contagem
    parameter integer WIDTH      = 7,  // Largura do barramento de saída (bits)
    parameter integer MAX_COUNT  = 99  // Valor máximo de contagem (módulo)
)
(
    // Declaração das portas de entrada e saída
    input  wire                     clk,         // Sinal de clock (borda de subida)
    input  wire                     async_reset, // Reset assíncrono (ativo em nível alto)
    output reg  [WIDTH-1:0]         count_out    // Saída do contador (tipo reg pois é atribuído em always)
);

    // Bloco always sequencial: sensível à borda de subida do clock ou do reset
    // A lista de sensibilidade inclui 'posedge async_reset' para comportamento assíncrono
    always @(posedge clk or posedge async_reset) begin
        // Verificação prioritária do Reset (Assíncrono)
        if (async_reset) begin
            // Se reset for 1, a saída é forçada a 0 imediatamente, independente do clock
            count_out <= {WIDTH{1'b0}}; // {WIDTH{1'b0}} replica o bit 0 'WIDTH' vezes
        end
        // Lógica Síncrona (na borda do clock)
        // Verifica se o contador atingiu o valor máximo
        else if (count_out == MAX_COUNT[WIDTH-1:0]) begin
            // Se atingiu o máximo, reinicia para 0 no próximo clock
            count_out <= {WIDTH{1'b0}};
        end
        // Caso normal de contagem
        else begin
            // Incrementa o valor atual em 1
            count_out <= count_out + 1'b1;
        end
    end

endmodule
