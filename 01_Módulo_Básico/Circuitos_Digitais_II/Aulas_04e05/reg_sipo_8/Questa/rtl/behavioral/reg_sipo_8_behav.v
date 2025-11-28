// ============================================================================
// Arquivo  : reg_sipo_8_behav.v (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 25/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Registrador SIPO de 8 bits com deslocamento bidirecional.
//            dir=0: Desloca à direita (LSB <= MSB).
//            dir=1: Desloca à esquerda (MSB <= LSB).
// Revisão   : v1.0 — criação inicial
// ============================================================================

module reg_sipo_8_behav (
    input  wire       clk,    // Clock do sistema
    input  wire       rst,    // Reset assíncrono (ativo alto)
    input  wire       din,    // Entrada serial de dados
    input  wire       dir,    // Direção: 0=Direita, 1=Esquerda
    output reg  [7:0] q       // Saída paralela de 8 bits
);

    // Bloco sequencial sensível à borda de subida do clock ou reset
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset assíncrono: zera a saída
            q <= 8'b00000000;
        end else begin
            // Lógica de deslocamento baseada na direção
            if (dir == 1'b0) begin
                // Deslocamento à direita: entra no MSB (q[7]), desloca para LSB
                // q[7] recebe din, q[6] recebe q[7], ..., q[0] recebe q[1]
                q <= {din, q[7:1]};
            end else begin
                // Deslocamento à esquerda: entra no LSB (q[0]), desloca para MSB
                // q[0] recebe din, q[1] recebe q[0], ..., q[7] recebe q[6]
                q <= {q[6:0], din};
            end
        end
    end

endmodule
