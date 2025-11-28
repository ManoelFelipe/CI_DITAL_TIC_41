// ============================================================================
// Arquivo  : comp_2.v  (implementação Dataflow)
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
// Implementação dataflow utilizando operadores bit a bit
module comp_2 (
    input  wire [1:0] a,         // Entrada de 2 bits: operando A
    input  wire [1:0] b,         // Entrada de 2 bits: operando B
    output wire       igual_flag // Saída de 1 bit: 1 se a == b, 0 caso contrário
);

    // Cada bit é comparado com XNOR (~^) e o resultado é "andado"
    // XNOR retorna 1 quando os bits são iguais (0-0 ou 1-1)
    // A igualdade global ocorre quando ambos os XNORs são '1'
    assign igual_flag = (a[1] ~^ b[1]) & (a[0] ~^ b[0]);

endmodule
