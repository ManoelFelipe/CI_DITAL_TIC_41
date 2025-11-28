// ============================================================================
// Arquivo  : mux_latche (implementação STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplexador de 4 entradas com largura parametrizável.
//            Implementação estrutural usando Lógica de Soma de Produtos (SOP)
//            com realimentação (Feedback).
//            A equação lógica é:
//            Out = (sel==00 & in0) | (sel==01 & in1) | (sel==10 & in2) | (sel==11 & Out)
//            Esta estrutura cria um loop combinacional que funciona como Latch.
// Revisão   : v1.2 — Alteração para SOP com Feedback para estabilidade
// ============================================================================

module mux_latche_structural #(
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
            // Quando sel=11, a saída 'out' é realimentada para manter o valor.
            // O atraso natural do inversor 'not_sel0' ajuda a manter o term10
            // ativo tempo suficiente durante a transição 10->11 antes que
            // o term11 assuma, evitando glitches.
            and u_and11 (term11, out[i], sel[1], sel[0]);

            // OR final combinando todos os termos
            or u_or_final (out[i], term00, term01, term10, term11);
            
        end
    endgenerate

endmodule
