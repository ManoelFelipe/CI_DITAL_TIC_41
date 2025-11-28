// ============================================================================
// Arquivo  : mux_latche_case.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplexador de 4 entradas com largura parametrizável.
//            Utiliza a abordagem Dataflow (assign) com operadores ternários.
//            A condição sel=11 realimenta a saída (out) para a entrada,
//            criando um Latch explícito.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module mux_latche_case_dataflow #(
    parameter WIDTH = 8
)(
    input  wire [1:0]       sel,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    output wire [WIDTH-1:0] out
);

    // ========================================================================
    // Lógica Dataflow
    // ========================================================================
    // Estrutura aninhada de operadores ternários.
    // Se sel=00 -> in0
    // Se sel=01 -> in1
    // Se sel=10 -> in2
    // Se sel=11 -> out (Feedback / Latch)
    
    assign out = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 (sel == 2'b10) ? in2 :
                 out; // Feedback mantém o valor anterior

endmodule
