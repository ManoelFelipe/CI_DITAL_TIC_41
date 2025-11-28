// ============================================================================
// Arquivo  : half_adder.v  (implementação Behavioral - variante 1)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Meio-somador combinacional de 1 bit. Gera sum (S) e carry (C)
//            a partir de entradas A e B. Implementação puramente behavioral,
//            usando bloco procedural `always @*` e atribuições para regs.
//            Largura: 1 bit. Latência: 0 ciclos. Recursos esperados: portas
//            XOR e AND inferidas pelo sintetizador. Útil para estudo de mapeamento
//            de lógica combinacional descrita de forma procedimental.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// -----------------------------------------------------------------------------
// Módulo: half_adder_beh
// Interface: entradas a,b (1 bit), saídas sum_o, carry_o (1 bit)
// Notas: saídas declaradas como reg por uso dentro do bloco always combinacional.
// -----------------------------------------------------------------------------
module half_adder_beh (
    input  wire a,           // bit A de entrada
    input  wire b,           // bit B de entrada
    output reg  sum_o,       // bit de soma (A ^ B)
    output reg  carry_o      // bit de transporte (A & B)
);
    // -------------------------------------------------------------------------
    // Bloco combinacional: calcula as saídas para qualquer mudança em a ou b
    // -------------------------------------------------------------------------
    always @* begin
        sum_o   = a ^ b;     // linha a linha: XOR produz a soma de 1 bit
        carry_o = a & b;     // linha a linha: AND produz o carry de 1 bit
    end
endmodule
