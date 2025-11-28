// -----------------------------------------------------------------------------
// Projeto: Multiplexador 16x1 (três descrições: comportamental, dataflow, estrutural)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_16_1.v
// Descr. : Este arquivo implementa um mux 16:1 que seleciona 1 entre 16 entradas
//          de um bit cada, de acordo com 'sel' (4 bits).
// -----------------------------------------------------------------------------

// ===============================
// MÓDULO COMPORTAMENTAL
// ===============================
module multiplex_16_1
(
    input  wire [15:0] d,   // [Linha 1] Vetor de 16 entradas de 1 bit (d[0] a d[15])
    input  wire [3:0]  sel, // [Linha 2] Seleção de 4 bits: 0..15 escolhe qual d[i] vai à saída
    output reg         y    // [Linha 3] Saída do multiplexador
);
    // [Linha 4] Bloco sensível a qualquer variação das entradas (modelo combinacional)
    always @(*) begin
        // [Linha 5] Atribuição por "índice variável": pega exatamente o bit 'd[sel]'
        //            Esta sintaxe é suportada pelo Verilog-2001 e sintetizável.
        y = d[sel];
        // [Linha 6] Não há necessidade de "default", pois todos os casos de 'sel' (0..15) são cobertos.
    end
endmodule
