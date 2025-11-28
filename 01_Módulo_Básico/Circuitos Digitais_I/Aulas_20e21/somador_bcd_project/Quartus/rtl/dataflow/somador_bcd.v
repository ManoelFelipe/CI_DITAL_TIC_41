// ============================================================================
//  somador_bcd.v — Somador BCD de 1 dígito (0000 a 1001) com correção por +6
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Compatível com: Verilog 2001 (Quartus/Questa)
//  Descrição: Soma dois dígitos BCD (A e B) e produz dígito BCD (S) e carry (Cout).
//  Observação: Não há carry de entrada; se necessário, componha em cascata.
// ============================================================================
`timescale 1ns/1ps

module somador_bcd(
    input  wire [3:0] A,      // Operando A em BCD (0..9)
    input  wire [3:0] B,      // Operando B em BCD (0..9)
    output wire [3:0] S,      // Saída em BCD (0..9) - unidades
    output wire       Cout    // Carry de saída (dezenas)
);
    // --------------------------------------------------------------------
    // Implementação por fluxo de dados: apenas assign/operadores
    // --------------------------------------------------------------------
    wire [4:0] soma_bin;              // Soma binária A+B (0..18)
    assign soma_bin = A + B;

    // Necessidade de correção: soma_bin > 9
    wire precisa_corrigir = (soma_bin > 5'd9);

    // Resultado corrigido: se precisar, soma 6
    wire [4:0] soma_corrigida = precisa_corrigir ? (soma_bin + 5'd6) : soma_bin;

    // Mapeia saídas
    assign {Cout, S} = soma_corrigida;
endmodule
