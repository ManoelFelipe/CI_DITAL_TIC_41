// ============================================================================
// Arquivo  : mux_latche_case.v  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplexador de 4 entradas com largura parametrizável.
//            Utiliza a abordagem comportamental (always @*) com diretiva
//            CASE incompleta (sem default e sem cobrir sel=11) para
//            inferir latches intencionalmente.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module mux_latche_case_behavioral #(
    parameter WIDTH = 8
)(
    input  wire [1:0]       sel,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    output reg  [WIDTH-1:0] out
);

    // ========================================================================
    // Lógica Comportamental com CASE
    // ========================================================================
    // O bloco always abaixo é combinacional (@*).
    // A instrução CASE cobre apenas 00, 01 e 10.
    // A ausência do caso 11 e do 'default' faz com que o sintetizador
    // infira memória (Latch) para manter o valor anterior nessas condições.
    always @(*) begin
        case (sel)
            2'b00: out = in0;
            2'b01: out = in1;
            2'b10: out = in2;
            // 2'b11: Não coberto -> Latch inferido
            // default: Não presente -> Latch inferido
        endcase
    end

endmodule
