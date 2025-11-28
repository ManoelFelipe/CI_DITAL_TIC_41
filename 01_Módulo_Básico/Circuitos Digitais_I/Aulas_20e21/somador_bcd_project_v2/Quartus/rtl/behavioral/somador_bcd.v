// ============================================================================
//  somador_bcd.v — Behavioral
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Descrição: Somador BCD de 1 dígito com correção +6 (quando A+B >= 10).
//  Observação: Este arquivo usa o macro SOMADOR_NAME para permitir renomear o
//              módulo na compilação (ex.: somador_bcd_beh).
// ============================================================================

`timescale 1ns/1ps               // Define a unidade/precisão de tempo para simulação

// ---------------------------------------------------------------------------
// Se SOMADOR_NAME não for definido no vlog (+define+SOMADOR_NAME=...),
// usamos o nome padrão 'somador_bcd'.
// ---------------------------------------------------------------------------
`ifndef SOMADOR_NAME
`define SOMADOR_NAME somador_bcd // Nome padrão do módulo
`endif

// ---------------------------------------------------------------------------
// Módulo: `SOMADOR_NAME` (substituído pelo nome definido no compile.do)
// Entradas: A, B (4 bits, BCD 0..9)
// Saídas:   S (4 bits, BCD corrigido), Cout (carry da dezena)
// Implementação: Comportamental (always @*)
// ---------------------------------------------------------------------------
module `SOMADOR_NAME(
    input  wire [3:0] A,        // Operando A em BCD (0000..1001)
    input  wire [3:0] B,        // Operando B em BCD (0000..1001)
    output reg  [3:0] S,        // Saída BCD (unidades após correção)
    output reg        Cout      // Carry da dezena (1 quando A+B >= 10)
);
    reg [4:0] soma_bin;         // Registrador de 5 bits para acomodar A+B (0..18)

    always @* begin              // Bloco combinacional (sensível a todas as entradas)
        soma_bin = A + B;        // Soma binária direta dos nibbles BCD (ainda sem correção)
        if (soma_bin > 9) begin  // Se resultado binário for maior que 9, precisa corrigir
            {Cout, S} = soma_bin + 6; // Correção BCD: soma 6 (0110) -> ajusta unidades e gera carry
        end else begin           // Caso NÃO precise corrigir (0..9)
            Cout = 1'b0;         // Carry de dezena é zero
            S    = soma_bin[3:0];// Unidades recebem a soma sem ajuste
        end                      // Fim do if/else
    end                          // Fim do always
endmodule                         // Fim do módulo
