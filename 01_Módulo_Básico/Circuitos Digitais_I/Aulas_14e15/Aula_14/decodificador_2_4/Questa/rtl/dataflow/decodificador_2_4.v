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
// Implementação por FLUXO DE DADOS (Dataflow)
// As saídas são expressas diretamente pelas equações booleanas canônicas
// -----------------------------------------------------------------------------
module decodificador_2_4 (
    input  wire A,                    // Entrada A
    input  wire B,                    // Entrada B
    input  wire C,                    // Entrada C (para f3)
    output wire Y0,                   // Y0 = ~A & ~B
    output wire Y1,                   // Y1 = ~A &  B
    output wire Y2,                   // Y2 =  A & ~B
    output wire Y3,                   // Y3 =  A &  B
    output wire f2,                   // f2 = Y0 | Y2 = ~B
    output wire f3                    // f3 = ~C & (Y1 | Y2)
);
    assign Y0 = (~A) & (~B);          // Ativo somente quando AB=00
    assign Y1 = (~A) & ( B);          // Ativo somente quando AB=01
    assign Y2 = ( A) & (~B);          // Ativo somente quando AB=10
    assign Y3 = ( A) & ( B);          // Ativo somente quando AB=11

    assign f2 = (Y0 | Y2);            // f2: combinação de mintermos → ~B
    assign f3 = (~C) & (Y1 | Y2);     // f3: máscara por ~C e OR dos mintermos 01 e 10
endmodule                              // Fim do módulo dataflow
