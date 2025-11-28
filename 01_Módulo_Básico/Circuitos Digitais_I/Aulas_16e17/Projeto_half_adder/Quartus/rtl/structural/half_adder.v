// ============================================================================
// Arquivo  : half_adder.v  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Meio-somador de 1 bit interconectando portas primitivas.
//            A estrutura explicita uma porta XOR (para sum) e uma AND (para carry).
//            Largura: 1 bit. Latência: 0 ciclos. Recursos: 1 XOR + 1 AND.
//            Útil para exercitar o nível estrutural e mapeamento direto.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Módulo: half_adder_struct
// -----------------------------------------------------------------------------
module half_adder_struct (
    input  wire a,            // entrada A
    input  wire b,            // entrada B
    output wire sum_o,        // saída soma
    output wire carry_o       // saída carry
);
    // -------------------------------------------------------------------------
    // Instanciação explícita de primitivas de porta
    // -------------------------------------------------------------------------
    xor u_xor (sum_o,   a, b);  // porta XOR gera sum
    and u_and (carry_o, a, b);  // porta AND gera carry
endmodule
