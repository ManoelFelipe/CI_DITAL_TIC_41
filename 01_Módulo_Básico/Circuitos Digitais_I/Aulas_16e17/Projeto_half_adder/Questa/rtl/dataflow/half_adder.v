// ============================================================================
// Arquivo  : half_adder.v  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Meio-somador de 1 bit modelado por expressões contínuas (assign).
//            Sinais são do tipo wire e derivam diretamente de A e B.
//            Largura: 1 bit. Latência: 0 ciclos. Recursos: XOR (para sum) e
//            AND (para carry). Ideal para evidenciar a forma canônica booleana.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Módulo: half_adder_dataflow
// -----------------------------------------------------------------------------
module half_adder_dataflow (
    input  wire a,            // entrada A
    input  wire b,            // entrada B
    output wire sum_o,        // saída soma
    output wire carry_o       // saída carry
);
    // -------------------------------------------------------------------------
    // Atribuições contínuas (fluxo de dados)
    // -------------------------------------------------------------------------
    assign sum_o   = a ^ b;   // XOR implementa a soma de 1 bit
    assign carry_o = a & b;   // AND implementa o transporte
endmodule
