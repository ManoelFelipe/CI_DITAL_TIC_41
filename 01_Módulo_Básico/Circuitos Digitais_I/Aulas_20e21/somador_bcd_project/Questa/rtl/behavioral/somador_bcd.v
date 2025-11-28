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
    output reg  [3:0] S,      // Saída em BCD (0..9) - unidades
    output reg        Cout    // Carry de saída (dezenas)
);
    // --------------------------------------------------------------------
    // Implementação comportamental: usa bloco always e aritmética inteira
    // --------------------------------------------------------------------
    reg [4:0] soma_bin;       // Guarda soma binária A+B (0..18)
    always @* begin
        // 1) Soma binária direta
        soma_bin = A + B;
        // 2) Detecta necessidade de correção (>= 10)
        if (soma_bin > 9) begin
            // 3) Corrige somando 6 (0110) e gera carry da dezena
            {Cout, S} = soma_bin + 6;
        end else begin
            // 4) Sem correção: carry=0 e S recebe soma
            Cout = 1'b0;
            S    = soma_bin[3:0];
        end
    end
endmodule
