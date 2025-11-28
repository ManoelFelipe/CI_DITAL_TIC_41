// ============================================================================
// Arquivo  : comp_2.v  (implementação Structural)
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
// Implementação structural com portas lógicas primitivas
module comp_2 (
    input  wire [1:0] a,         // Entrada de 2 bits: operando A
    input  wire [1:0] b,         // Entrada de 2 bits: operando B
    output wire       igual_flag // Saída de 1 bit: 1 se a == b, 0 caso contrário
);

    // Sinais internos para resultados das comparações por bit
    wire bit1_igual; // Resultado da comparação do bit mais significativo
    wire bit0_igual; // Resultado da comparação do bit menos significativo

    // Porta XNOR compara os bits a[1] e b[1]
    xnor u_xnor_msb (
        bit1_igual, // Saída: 1 quando a[1] == b[1]
        a[1],       // Entrada: bit mais significativo de A
        b[1]        // Entrada: bit mais significativo de B
    );

    // Porta XNOR compara os bits a[0] e b[0]
    xnor u_xnor_lsb (
        bit0_igual, // Saída: 1 quando a[0] == b[0]
        a[0],       // Entrada: bit menos significativo de A
        b[0]        // Entrada: bit menos significativo de B
    );

    // Porta AND combina os dois resultados de igualdade por bit
    and u_and_equal (
        igual_flag, // Saída final: 1 somente se bit1_igual e bit0_igual forem 1
        bit1_igual, // Entrada: igualdade no bit mais significativo
        bit0_igual  // Entrada: igualdade no bit menos significativo
    );

endmodule
