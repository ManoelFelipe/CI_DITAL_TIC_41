// ============================================================================
// Arquivo  : reg_sipo_8_data.v (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 25/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Registrador SIPO de 8 bits com deslocamento bidirecional.
//            Utiliza atribuição contínua (assign) para lógica de próximo estado.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module reg_sipo_8_data (
    input  wire       clk,    // Clock do sistema
    input  wire       rst,    // Reset assíncrono (ativo alto)
    input  wire       din,    // Entrada serial de dados
    input  wire       dir,    // Direção: 0=Direita, 1=Esquerda
    output reg  [7:0] q       // Saída paralela de 8 bits
);

    wire [7:0] next_q; // Fio para o próximo estado

    // Lógica combinacional para determinar o próximo valor (Dataflow)
    // Se dir=0: {din, q[7:1]} (Direita)
    // Se dir=1: {q[6:0], din} (Esquerda)
    assign next_q = (dir == 1'b0) ? {din, q[7:1]} : {q[6:0], din};

    // Lógica sequencial apenas para atualização do registrador
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q <= 8'b00000000;
        end else begin
            q <= next_q;
        end
    end

endmodule
