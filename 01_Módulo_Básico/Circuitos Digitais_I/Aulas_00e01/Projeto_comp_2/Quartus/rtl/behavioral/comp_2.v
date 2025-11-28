// ============================================================================
// Arquivo  : comp_2.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Comparador de igualdade de 2 bits com duas entradas vetoriais
//            a[1:0] e b[1:0], produzindo uma saída de 1 bit igual_flag.
//            O bloco verifica igualdade total entre os bits, sem sinais X/Z,
//            sendo adequado para síntese combinacional de baixa latência e
//            uso em caminhos de controle ou lógica de decisão simples.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Módulo: comp_2
// Implementação behavioral utilizando comparação de vetores
module comp_2 (
    input  wire [1:0] a,        // Entrada de 2 bits: operando A
    input  wire [1:0] b,        // Entrada de 2 bits: operando B
    output reg        igual_flag // Saída de 1 bit: 1 se a == b, 0 caso contrário
);

    // Bloco always combinacional que calcula a igualdade entre A e B
    always @* begin
        // Verifica se os dois vetores são exatamente iguais
        if (a == b) begin
            // Quando todos os bits coincidirem, saída vai a '1'
            igual_flag = 1'b1;
        end else begin
            // Caso qualquer bit seja diferente, saída vai a '0'
            igual_flag = 1'b0;
        end
    end

endmodule
