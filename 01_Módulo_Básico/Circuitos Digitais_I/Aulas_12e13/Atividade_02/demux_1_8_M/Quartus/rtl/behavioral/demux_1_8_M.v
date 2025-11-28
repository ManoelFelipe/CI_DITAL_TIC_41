// ============================================================================
// Arquivo.....: demux_1_8_M.v
// Módulo......: demux_1_8_M
// Abordagem...: Comportamental (Behavioral)
// Descrição...: Demultiplexador 1x8 compatível com Verilog 2001.
// Autor.......: Manoel Furtado
// Data........: 31/10/2025
// Ferramentas.: Quartus / Questa (ModelSim)
// ============================================================================

`timescale 1ns/1ps

// Módulo principal do demultiplexador 1x8
module demux_1_8_M (
    input  wire       D,        // Entrada de dados (1 bit)
    input  wire [2:0] S,        // Seleção (3 bits) - escolhe qual saída receberá D
    output reg  [7:0] Y         // Saídas (8 bits) - codificação one-hot de D
);
    // Lógica combinacional: distribui D para uma única saída definida por S
    always @* begin
        // Zera todas as saídas a cada avaliação
        Y = 8'b0;
        // Direciona D para a saída selecionada
        case (S)
            3'd0: Y[0] = D;     // Se S==0, Y0 recebe D
            3'd1: Y[1] = D;     // Se S==1, Y1 recebe D
            3'd2: Y[2] = D;     // Se S==2, Y2 recebe D
            3'd3: Y[3] = D;     // Se S==3, Y3 recebe D
            3'd4: Y[4] = D;     // Se S==4, Y4 recebe D
            3'd5: Y[5] = D;     // Se S==5, Y5 recebe D
            3'd6: Y[6] = D;     // Se S==6, Y6 recebe D
            3'd7: Y[7] = D;     // Se S==7, Y7 recebe D
            default: Y = 8'b0;  // Segurança: padrão zerado
        endcase
    end
endmodule
