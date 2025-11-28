// ============================================================================
// Arquivo  : mux_latche_case.v  (implementação STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplexador de 4 entradas com largura parametrizável.
//            Implementação estrutural usando Lógica de Soma de Produtos (SOP)
//            com realimentação (Feedback).
//            Topologia robusta contra hazards de transição.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module mux_latche_case_structural #(
    parameter WIDTH = 8
)(
    input  wire [1:0]       sel,
    input  wire [WIDTH-1:0] in0,
    input  wire [WIDTH-1:0] in1,
    input  wire [WIDTH-1:0] in2,
    input  wire [WIDTH-1:0] in3,
    output wire [WIDTH-1:0] out
);

    genvar i;
    generate
        for (i = 0; i < WIDTH; i = i + 1) begin : gen_struct
            
            // Fios para os termos de produto
            wire term00, term01, term10, term11;
            wire not_sel0, not_sel1;

            // Inversores
            not u_not0 (not_sel0, sel[0]);
            not u_not1 (not_sel1, sel[1]);

            // Termo 00: in0 selecionado
            and u_and00 (term00, in0[i], not_sel1, not_sel0);

            // Termo 01: in1 selecionado
            and u_and01 (term01, in1[i], not_sel1, sel[0]);

            // Termo 10: in2 selecionado
            and u_and10 (term10, in2[i], sel[1], not_sel0);

            // Termo 11: Feedback (Latch Hold)
            // Quando sel=11, a saída 'out' é realimentada.
            and u_and11 (term11, out[i], sel[1], sel[0]);

            // OR final combinando todos os termos
            or u_or_final (out[i], term00, term01, term10, term11);
            
        end
    endgenerate

endmodule
