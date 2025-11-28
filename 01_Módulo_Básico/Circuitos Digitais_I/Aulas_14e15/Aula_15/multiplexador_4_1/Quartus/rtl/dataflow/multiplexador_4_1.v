// ================================================================
// Arquivo : multiplexador_4_1.v
// Projeto : MUX 4x1 — três abordagens (Behavioral/Dataflow/Structural)
// Autor   : Manoel Furtado
// Data    : 31/10/2025
// Ferramentas: Compatível com Verilog‑2001 (Quartus/Questa)
// Descrição: Multiplexador 4:1 com sinais escalares (duas seleções e
//            quatro entradas de dados). Nome do módulo e do arquivo
//            coincidem exatamente: multiplexador_4_1.
// ================================================================
// Implementação em fluxo de dados (expressão booleana canônica).
module multiplexador_4_1 (
    input  wire d0,     // Entrada 0
    input  wire d1,     // Entrada 1
    input  wire d2,     // Entrada 2
    input  wire d3,     // Entrada 3
    input  wire s1,     // Seleção MSB
    input  wire s0,     // Seleção LSB
    output wire y       // Saída
);
    // Equação: y = (~s1 & ~s0 & d0) | (~s1 & s0 & d1) | (s1 & ~s0 & d2) | (s1 & s0 & d3)
    assign y =
          ((~s1) & (~s0) & d0)   // Termo para s1s0 = 00
        | ((~s1) &  s0   & d1)   // Termo para s1s0 = 01
        | ( s1   & (~s0) & d2)   // Termo para s1s0 = 10
        | ( s1   &  s0   & d3);  // Termo para s1s0 = 11
endmodule
