// =============================================================
// Autor: Manoel Furtado
// Data: 10/11/2025
// Projeto: ponto_fixo_8.v (Behavioral)
// Descrição: Somador/subtrator de 8 bits com formato Q4.4
// =============================================================
module ponto_fixo_8(
    input  [7:0] a,         // Operando A (Q4.4)
    input  [7:0] b,         // Operando B (Q4.4)
    input        sel,       // 0 = soma, 1 = subtração
    output reg [7:0] result,// Resultado (Q4.4)
    output reg overflow     // Bit de overflow (soma/subtração)
);
// Bloco combinacional descrevendo o comportamento do circuito
always @(*) begin
    if (!sel)
        {overflow, result} = a + b; // Soma com captura de carry em overflow
    else
        {overflow, result} = a - b; // Subtração com captura de borrow em overflow
end
endmodule
