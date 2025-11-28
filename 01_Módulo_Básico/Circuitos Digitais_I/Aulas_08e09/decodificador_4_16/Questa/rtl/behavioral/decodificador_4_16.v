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
// Estilo: Comportamental (Behavioral)
// ------------------------------
`timescale 1ns/1ps

module decodificador_4_16
(
    input      [3:0] a,    // a[3] MSB ... a[0] LSB
    output reg [15:0] y    // Saídas one-hot ativas em '1'
);
    // Atribuições iniciais para evitar 'x' na simulação
    initial begin
        // Começa com todas as linhas zeradas
        // (boa prática para power-up em simulação)
        y = 16'h0000;
    end

    // Lógica combinacional: mapeia diretamente o valor de 'a'
    // para uma saída one-hot. A cada mudança de 'a', recalcula 'y'.
    always @(*) begin
        // Garante que apenas um bit esteja em '1':
        // desloca 1 para a posição indicada por 'a'
        y = 16'h0001 << a; // Ex.: a=4'd3 -> y=16'b0000_0000_0000_1000
    end
endmodule
