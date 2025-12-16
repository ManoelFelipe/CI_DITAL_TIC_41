// ============================================================================
// Arquivo  : regfile8x16c.v (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 2025-12-16
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Banco de 8 registradores de 16 bits com 1 porta de escrita síncrona
//            e 2 portas de leitura assíncronas (combinacionais). Reset síncrono.
//            Esta modelagem usa "Behavioral", descrevendo o comportamento
//            de alto nível (array de registradores) sem detalhar a estrutura lógica.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Definição do módulo com as portas de entrada e saída
module regfile8x16c_beh (
    input         clk,       // Sinal de clock (sincronismo para escrita e reset)
    input         reset,     // Sinal de reset (ativo em nível alto)
    input         write,     // Sinal de habilitação de escrita (Write Enable)
    input  [2:0]  wr_addr,   // Endereço de escrita (3 bits para selecionar 1 de 8 registradores)
    input  [15:0] wr_data,   // Dado a ser escrito (16 bits)
    input  [2:0]  rd_addr_a, // Endereço de leitura para a porta A (3 bits)
    output [15:0] rd_data_a, // Dado lido da porta A (16 bits)
    input  [2:0]  rd_addr_b, // Endereço de leitura para a porta B (3 bits)
    output [15:0] rd_data_b  // Dado lido da porta B (16 bits)
);

    // Declaração do banco de registradores: array de 8 posições de 16 bits cada
    reg [15:0] regfile [0:7];

    // Leitura assíncrona (combinacional) para a porta A:
    // O valor de 'rd_data_a' reflete imediatamente o conteúdo do registrador selecionado por 'rd_addr_a'
    assign rd_data_a = regfile[rd_addr_a];

    // Leitura assíncrona (combinacional) para a porta B:
    // O valor de 'rd_data_b' reflete imediatamente o conteúdo do registrador selecionado por 'rd_addr_b'
    assign rd_data_b = regfile[rd_addr_b];

    // Variável inteira para uso no loop de inicialização/reset
    integer i;

    // Bloco sequencial acionado na borda de subida do clock
    always @(posedge clk) begin
        // Verificação do sinal de reset (síncrono)
        if (reset) begin
            // Se reset estiver ativo, zera todos os registradores do banco
            for (i = 0; i < 8; i = i + 1) begin
                regfile[i] <= 16'h0000; // Escreve 0 em cada posição
            end
        end else begin
            // Se não estiver em reset, verifica se a escrita está habilitada
            if (write) begin
                // Escreve o dado 'wr_data' no registrador apontado por 'wr_addr'
                regfile[wr_addr] <= wr_data;
            end
        end
    end

endmodule
