// =============================================================
// Projeto: Decodificador 4→16 (Behavioral, Dataflow, Structural)
// Autor: Manoel Furtado
// Data: 27/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Descrição: Implementa um decodificador binário 4-para-16 com
//            saídas one-hot ativas em nível alto.
// =============================================================

// ------------------------------
// Arquivo: decodificador_4_16.v
// Estilo: Fluxo de Dados (Dataflow)
// ------------------------------
`timescale 1ns/1ps

module decodificador_4_16
(
    input  [3:0]  a,       // Entrada binária (0..15)
    output [15:0] y        // Saídas one-hot ativas em '1'
);
    // Uma única expressão de fluxo de dados usando deslocamento lógico
    // Mapeia "1" para a posição indicada por 'a'
    assign y = 16'h0001 << a;

endmodule
