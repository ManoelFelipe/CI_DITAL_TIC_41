// ============================================================================
// Arquivo  : mux_latche.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplexador de 4 entradas com largura parametrizável.
//            Utiliza a abordagem fluxo de dados (assign) com operador
//            condicional ternário. O latch é inferido ao atribuir o próprio
//            sinal de saída (feedback) na condição sel = 11.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module mux_latche_dataflow #(
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
    // A atribuição contínua utiliza operadores ternários aninhados.
    // Quando sel == 11 (condição final), 'out' recebe 'out', criando
    // um laço combinacional que atua como elemento de memória (Latch).
    // Nota: Isso pode gerar avisos de "combinational loop" em algumas ferramentas,
    // mas é a forma de representar a função de memória em dataflow puro.
    
    assign out = (sel == 2'b00) ? in0 :
                 (sel == 2'b01) ? in1 :
                 (sel == 2'b10) ? in2 :
                 out; // Feedback explícito para manter o valor (Latch)

endmodule
