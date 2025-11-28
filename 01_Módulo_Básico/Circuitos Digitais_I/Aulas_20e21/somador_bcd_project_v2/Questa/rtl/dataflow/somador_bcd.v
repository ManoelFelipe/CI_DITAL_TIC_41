// ============================================================================
//  somador_bcd.v — Dataflow
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Descrição: Somador BCD de 1 dígito com correção +6 (A+B >= 10) somente
//             com ligações contínuas (assign).
// ============================================================================

`timescale 1ns/1ps               // Unidades/precisão de simulação

`ifndef SOMADOR_NAME
`define SOMADOR_NAME somador_bcd // Nome padrão, caso não seja redefinido no vlog
`endif

// ---------------------------------------------------------------------------
// Implementação por fluxo de dados: expressa a função apenas com wires/assign.
// ---------------------------------------------------------------------------
module `SOMADOR_NAME(
    input  wire [3:0] A,                   // Operando A (BCD)
    input  wire [3:0] B,                   // Operando B (BCD)
    output wire [3:0] S,                   // Saída BCD (unidades)
    output wire       Cout                 // Carry da dezena
);
    wire [4:0] soma_bin    = A + B;        // Soma binária (5 bits para caber 0..18)
    wire       precisa_corrigir =           // Sinal de correção quando resultado >= 10
                    (soma_bin > 5'd9);
    wire [4:0] soma_corrigida   =           // Se precisar, soma 6; senão, mantém
                    (precisa_corrigir ? (soma_bin + 5'd6) : soma_bin);

    assign {Cout, S} = soma_corrigida;     // Descompacta: bit[4] vira Cout, bits[3:0] viram S
endmodule                                   // Fim do módulo
