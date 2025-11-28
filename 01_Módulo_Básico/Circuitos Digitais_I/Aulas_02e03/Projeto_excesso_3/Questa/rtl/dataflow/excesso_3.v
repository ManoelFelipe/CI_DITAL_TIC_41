// ============================================================================
// Arquivo  : excesso_3.v  (implementacao Dataflow)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: Conversor combinacional de codigo BCD 8421 (4 bits) para
//            representacao em Excesso-3. Bloco puramente combinacional,
//            sem registradores, adequado para sintese em FPGAs ou ASICs.
//            Implementacao na abordagem Dataflow com mesma interface
//            externa entre as versoes para facilitar reutilizacao e testes.
// Revisao   : v1.0 — criacao inicial
// ============================================================================

// Conversor BCD 8421 -> Excesso-3
// Implementacao em fluxo de dados usando equacoes booleanas minimizadas

`timescale 1ns/1ps

module excesso_3_dataflow (
    input  wire [3:0] bcd_in,      // Entrada BCD 8421 (A B C D)
    output wire [3:0] excess_out   // Saida em codigo Excesso-3
);

    // Atribuicao de nomes locais para cada bit da entrada
    // A = bit mais significativo (8), D = bit menos significativo (1)
    wire a = bcd_in[3];            // Bit A (peso 8)
    wire b = bcd_in[2];            // Bit B (peso 4)
    wire c = bcd_in[1];            // Bit C (peso 2)
    wire d = bcd_in[0];            // Bit D (peso 1)

    // Bit 0 da saida (LSB) — y0 = ~D
    assign excess_out[0] = ~d;

    // Bit 1 da saida — y1 = (C & D) | (~C & ~D)  (XNOR entre C e D)
    assign excess_out[1] = (c & d) | (~c & ~d);

    // Bit 2 da saida — y2 = (~B & (C | D)) | (B & ~C & ~D)
    assign excess_out[2] = ((~b) & (c | d)) | (b & ~c & ~d);

    // Bit 3 da saida (MSB) — y3 = A | (B & C) | (B & D)
    assign excess_out[3] = a | (b & c) | (b & d);

endmodule
