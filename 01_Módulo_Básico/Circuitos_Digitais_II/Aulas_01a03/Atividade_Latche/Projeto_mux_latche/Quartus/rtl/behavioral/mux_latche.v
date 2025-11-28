// ============================================================================
// Arquivo  : mux_latche.v  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplexador de 4 entradas com largura parametrizável.
//            Utiliza a abordagem comportamental (always @*) com sentenças
//            IF-ELSEIF incompletas para inferir latches intencionalmente
//            na condição não coberta (sel = 11).
// Revisão   : v1.0 — criação inicial
// ============================================================================

module mux_latche_behavioral #(
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
    // Lógica Comportamental
    // ========================================================================
    // O bloco always abaixo é combinacional (@*), mas a ausência de um
    // 'else' final ou de um valor padrão para 'out' infere memória (Latch).
    always @* begin
        // Seleciona in0 quando sel é 00
        if (sel == 2'b00) begin
            out = in0;
        end
        // Seleciona in1 quando sel é 01
        else if (sel == 2'b01) begin
            out = in1;
        end
        // Seleciona in2 quando sel é 10
        else if (sel == 2'b10) begin
            out = in2;
        end
        // A condição sel == 2'b11 não é tratada.
        // O sintetizador manterá o valor anterior de 'out', inferindo um Latch.
    end

endmodule
