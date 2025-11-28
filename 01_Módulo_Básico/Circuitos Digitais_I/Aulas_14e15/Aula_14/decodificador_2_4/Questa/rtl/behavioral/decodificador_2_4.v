// -----------------------------------------------------------------------------
// Arquivo     : decodificador_2_4.v
// Módulo      : decodificador_2_4
// Autor       : Manoel Furtado
// Data        : 31/10/2025
// Descrição   : Decodificador 2→4 com saídas Y0..Y3 e duas funções derivadas:
//               f2(A,B) = ~B  = Y0 + Y2
//               f3(A,B,C) = ~C*(A*~B + ~A*B) = ~C*(Y2 + Y1)
// Observações : • Entradas e saídas ESCALARES (sem vetores), conforme enunciado
//               • Compatível com Verilog‑2001 (Quartus e Questa)
//               • Três variações do mesmo módulo: Behavioral, Dataflow e Structural
// -----------------------------------------------------------------------------

`timescale 1ns/1ps                     // Define unidade/precisão de tempo para simulação
// -----------------------------------------------------------------------------
// Implementação COMPORTAMENTAL (Behavioral)
// Usa bloco combinacional com 'case' para ativar exatamente uma saída (one‑hot)
// -----------------------------------------------------------------------------
module decodificador_2_4 (
    input  wire A,                    // A: bit mais significativo do endereço
    input  wire B,                    // B: bit menos significativo do endereço
    input  wire C,                    // C: usado apenas para a função f3 (Exercício 3)
    output reg  Y0,                   // Y0: ativo quando AB = 00
    output reg  Y1,                   // Y1: ativo quando AB = 01
    output reg  Y2,                   // Y2: ativo quando AB = 10
    output reg  Y3,                   // Y3: ativo quando AB = 11
    output wire f2,                   // f2: função do Exercício 2 (deve resultar em ~B)
    output wire f3                    // f3: função do Exercício 3
);
    // Bloco combinacional: calcula as linhas do decodificador (Y0..Y3)
    always @* begin                   // Sensibilidade total (qualquer var. lida altera)
        Y0 = 1'b0;                    // Inicializa todas as saídas em 0
        Y1 = 1'b0;                    // (política one‑hot garante apenas uma em 1)
        Y2 = 1'b0;
        Y3 = 1'b0;
        case ({A,B})                 // Concatena A e B na ordem AB
            2'b00: Y0 = 1'b1;         // AB=00 → ativa Y0
            2'b01: Y1 = 1'b1;         // AB=01 → ativa Y1
            2'b10: Y2 = 1'b1;         // AB=10 → ativa Y2
            2'b11: Y3 = 1'b1;         // AB=11 → ativa Y3
            default: ;                // Nenhum outro caso (mantém todas em 0)
        endcase
    end

    // Funções derivadas a partir das linhas do decodificador:
    assign f2 = (Y0 | Y2);            // f2 = Y0 + Y2 = ~B (independe de A)
    assign f3 = (~C) & (Y1 | Y2);     // f3 = ~C * (A*~B + ~A*B) = ~C*(Y2 + Y1)
endmodule                              // Fim do módulo comportamental
