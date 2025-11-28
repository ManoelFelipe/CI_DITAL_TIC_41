// ============================================================================
// Arquivo  : conver.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Conversor combinacional de código BCD 5311 (H,G,F,E) para
//            BCD 8421 (D,C,B,A). Implementação em estilo dataflow,
//            utilizando expressões booleanas minimizadas a partir da
//            tabela verdade do conversor. Largura fixa de 4 bits, sem
//            elementos sequenciais, resultando em latência zero em termos
//            de ciclos de clock. Estrutura adequada para síntese direta
//            em FPGAs, com boa previsibilidade de timing e área.
// Revisão  : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo dataflow: conver_dataflow
// Implementa as equações booleanas fornecidas para cada saída D,C,B,A.
// --------------------------------------------------------------------------
module conver_dataflow (
    input  wire h,  // bit mais significativo do código 5311
    input  wire g,  // segundo bit
    input  wire f,  // terceiro bit
    input  wire e,  // bit menos significativo
    output wire d,  // bit mais significativo do código 8421
    output wire c,  // segundo bit
    output wire b,  // terceiro bit
    output wire a   // bit menos significativo
);

    // ----------------------------------------------------------------------
    // Equações booleanas na forma dataflow. As expressões foram derivadas
    // da tabela de conversão BCD 5311 -> BCD 8421 e já se encontram em
    // forma simplificada, com operadores lógicos padrão de Verilog.
    // ----------------------------------------------------------------------
    assign d = h & g;

    assign c = (!h & g & e) | (h & !g);

    assign b = (!h & g & !e) | (!g & f) | (h & !g);

    assign a = (!h & !g & !f & e) |
               (!h & g  & !e)     |
               (g  & f)          |
               (h & g & e)       |
               (h & f);

endmodule
