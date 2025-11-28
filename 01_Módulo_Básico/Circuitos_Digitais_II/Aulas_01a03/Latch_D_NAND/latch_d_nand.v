//==============================================================
//  latch_d_nand.v
//  Implementação Comportamental de um Latch D (Nível Alto)
//
//  Descrição:
//  Este módulo modela o comportamento de um Latch D transparente
//  em nível alto. Embora o nome sugira uma implementação com
//  portas NAND (nível de portas), o código usa uma descrição
//  comportamental (RTL) que é funcionalmente equivalente.
//
//  Tabela Verdade Simplificada:
//  +-----+-----+-----+
//  | CLK |  D  |  Q  |
//  +-----+-----+-----+
//  |  0  |  X  | Q_ant| (Estado de Memória/Latch)
//  |  1  |  0  |  0  | (Transparente - Segue D)
//  |  1  |  1  |  1  | (Transparente - Segue D)
//  +-----+-----+-----+
//==============================================================
`timescale 1ns/1ps

module latch_d_nand (
    input  wire D,     // Entrada de Dados (Data)
    input  wire CLK,   // Entrada de Habilitação (Clock/Enable)
    output reg  Q,     // Saída Principal
    output wire Qb     // Saída Complementar (Q barra)
);

    // A saída complementar é sempre o inverso de Q
    assign Qb = ~Q;

    // Inicialização para simulação (Q começa em 0 conforme exercício)
    initial begin
        Q = 1'b0;
    end

    // Bloco Always descrevendo o comportamento do Latch
    // A lista de sensibilidade inclui CLK e D, pois ambos podem alterar a saída
    always @(CLK or D) begin
        if (CLK) begin
            // Modo Transparente:
            // Quando CLK é ALTO (1), a saída Q reflete imediatamente a entrada D.
            // Qualquer mudança em D será vista em Q.
            Q = D;
        end
        // else:
        // Modo Memória (Latch):
        // Quando CLK é BAIXO (0), o bloco não executa nada (implícito),
        // mantendo o valor anterior de Q armazenado.
    end

endmodule