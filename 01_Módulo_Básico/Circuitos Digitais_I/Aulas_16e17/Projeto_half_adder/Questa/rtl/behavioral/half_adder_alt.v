// ============================================================================
// Arquivo  : half_adder_alt.v  (implementação Behavioral - variante 2)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Meio-somador de 1 bit descrito usando soma binária com concatenação
//            para capturar simultaneamente carry e sum: {carry,sum} = a + b.
//            Largura: 1 bit. Latência: 0 ciclos. Recursos esperados: portas
//            XOR/AND equivalentes inferidas pelo sintetizador a partir do operador
//            de soma. Útil para demonstrar equivalência entre descrição aritmética
//            e lógica booleana em síntese.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Módulo: half_adder_beh_sumop
// Descrição: usa operador '+' e concatenação para formar {carry,sum}
// -----------------------------------------------------------------------------
module half_adder_beh_sumop (
    input  wire a,           // bit A de entrada
    input  wire b,           // bit B de entrada
    output reg  sum_o,       // bit de soma
    output reg  carry_o      // bit de transporte
);
    // -------------------------------------------------------------------------
    // Bloco combinacional: somador de 1 bit via operador '+'
    // -------------------------------------------------------------------------
    always @* begin
        {carry_o, sum_o} = a + b; // soma natural; sintetiza XOR/AND
    end
endmodule
