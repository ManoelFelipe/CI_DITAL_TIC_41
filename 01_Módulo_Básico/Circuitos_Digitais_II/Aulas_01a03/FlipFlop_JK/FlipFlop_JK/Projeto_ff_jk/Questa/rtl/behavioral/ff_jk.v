// ============================================================================
// Arquivo  : ff_jk.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Flip-Flop JK disparado por borda de subida (positive edge).
//            Implementado utilizando bloco always e lógica sequencial comportamental.
//            Possui reset assíncrono (opcional, mas boa prática) ou apenas controle JK.
//            Neste modelo, assumimos reset síncrono ou sem reset explícito conforme diagrama.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module ff_jk (
    input  wire clk, // Sinal de clock
    input  wire j,   // Entrada J
    input  wire k,   // Entrada K
    output reg  q,   // Saída Q
    output wire q_bar // Saída Q barrado
);

    // Inicialização para simulação (evita X inicial)
    initial q = 0;

    // Lógica sequencial disparada na borda de subida do clock
    always @(posedge clk) begin
        case ({j, k})
            2'b00: q <= q;      // Mantém estado (Hold)
            2'b01: q <= 1'b0;   // Reset
            2'b10: q <= 1'b1;   // Set
            2'b11: q <= ~q;     // Toggle
            default: q <= q;    // Segurança
        endcase
    end

    // Atribuição contínua para a saída complementada
    assign q_bar = ~q;

endmodule
