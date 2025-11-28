// =============================================================
// Projeto: ponto_fixo_8.v (Dataflow)
// Autor: Manoel Furtado | Data: 10/11/2025
// Descrição: Implementação por fluxo de dados
// =============================================================
module ponto_fixo_8(
    input  [7:0] a,     // Q4.4
    input  [7:0] b,     // Q4.4
    input        sel,   // 0: soma | 1: subtração
    output [7:0] result,
    output       overflow
);
// Atribuição contínua: escolhe operação e agrega carry/borrow em overflow
assign {overflow, result} = (sel) ? (a - b) : (a + b);
endmodule
