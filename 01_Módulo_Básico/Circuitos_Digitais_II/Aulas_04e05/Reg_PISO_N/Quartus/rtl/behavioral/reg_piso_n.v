|// ============================================================================
// Arquivo  : reg_piso_n.v  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Registrador de deslocamento PISO (Parallel-In Serial-Out) de N bits.
//            Suporta deslocamento para direita (DIR=0) ou esquerda (DIR=1).
//            Possui carga paralela síncrona (load) e reset assíncrono.
//            Latência de 1 ciclo para carga/deslocamento.
// Revisão  : v1.0 — criação inicial
// ============================================================================

module reg_piso_n #(
    parameter N = 8,       // Largura do registrador
    parameter DIR = 0      // 0: Desloca p/ Direita (LSB out), 1: Esquerda (MSB out)
)(
    input  wire         clk,    // Clock
    input  wire         rst_n,  // Reset ativo em nível baixo
    input  wire         load,   // Habilita carga paralela (prioridade sobre shift)
    input  wire [N-1:0] din,    // Entrada paralela
    output wire         dout    // Saída serial
);

    // Registrador interno para armazenar os dados
    reg [N-1:0] shift_reg;

    // Lógica Sequencial: Controle do registrador
    // Prioridade: Reset > Load > Shift
    always @(posedge clk or negedge rst_n) begin
        // Reset assíncrono: zera o registrador
        if (!rst_n) begin
            shift_reg <= {N{1'b0}};
        end
        // Carga paralela: carrega din no registrador
        else if (load) begin
            shift_reg <= din;
        end
        // Deslocamento: depende do parâmetro DIR
        else begin
            if (DIR == 0) begin
                // Deslocamento para DIREITA (>>): insere 0 no MSB
                shift_reg <= {1'b0, shift_reg[N-1:1]};
            end else begin
                // Deslocamento para ESQUERDA (<<): insere 0 no LSB
                shift_reg <= {shift_reg[N-2:0], 1'b0};
            end
        end
    end

    // Lógica Combinacional: Saída serial
    // Se DIR=0 (Direita), sai o LSB (bit 0)
    // Se DIR=1 (Esquerda), sai o MSB (bit N-1)
    assign dout = (DIR == 0) ? shift_reg[0] : shift_reg[N-1];

endmodule
