// =============================================================
// Projeto: Decodificador 4→16 (Behavioral, Dataflow, Structural)
// Autor: Manoel Furtado
// Data: 27/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Descrição: Implementa um decodificador binário 4-para-16 com
//            saídas one-hot ativas em nível alto.
// =============================================================

// ------------------------------
/* Arquivo: decodificador_4_16.v
   Estilo: Estrutural (Structural)

   Estratégia:
   - Divide a entrada a[3:0] em dois pares: hi = a[3:2] e lo = a[1:0].
   - Gera dois vetores one-hot de 2→4 (d_hi e d_lo).
   - Combina cada linha via portas AND (produto cartesiano) para formar 4×4 = 16 saídas.
*/
// ------------------------------
`timescale 1ns/1ps

// Bloco reutilizável: decodificador 2→4 (ativo alto)
module dec2to4(
    input  [1:0] a,    // Entrada binária (0..3)
    output [3:0] y     // Saídas one-hot
);
    // Implementação puramente de dados para minimizar profundidade lógica
    assign y[0] = (~a[1]) & (~a[0]);
    assign y[1] = (~a[1]) &  (a[0]);
    assign y[2] =  (a[1]) & (~a[0]);
    assign y[3] =  (a[1]) &  (a[0]);
endmodule

// Topo 4→16
module decodificador_4_16(
    input  [3:0]  a,   // a[3:2] = hi, a[1:0] = lo
    output [15:0] y    // Saídas one-hot
);
    wire [3:0] d_hi;   // Saídas do decodificador de 'a[3:2]'
    wire [3:0] d_lo;   // Saídas do decodificador de 'a[1:0]'

    // Instâncias 2→4
    dec2to4 u_dec_hi (.a(a[3:2]), .y(d_hi));
    dec2to4 u_dec_lo (.a(a[1:0]), .y(d_lo));

    // Combinações estruturais: y[i*4 + j] = d_hi[i] & d_lo[j]
    assign y[0]  = d_hi[0] & d_lo[0]; // 0000
    assign y[1]  = d_hi[0] & d_lo[1]; // 0001
    assign y[2]  = d_hi[0] & d_lo[2]; // 0010
    assign y[3]  = d_hi[0] & d_lo[3]; // 0011

    assign y[4]  = d_hi[1] & d_lo[0]; // 0100
    assign y[5]  = d_hi[1] & d_lo[1]; // 0101
    assign y[6]  = d_hi[1] & d_lo[2]; // 0110
    assign y[7]  = d_hi[1] & d_lo[3]; // 0111

    assign y[8]  = d_hi[2] & d_lo[0]; // 1000
    assign y[9]  = d_hi[2] & d_lo[1]; // 1001
    assign y[10] = d_hi[2] & d_lo[2]; // 1010
    assign y[11] = d_hi[2] & d_lo[3]; // 1011

    assign y[12] = d_hi[3] & d_lo[0]; // 1100
    assign y[13] = d_hi[3] & d_lo[1]; // 1101
    assign y[14] = d_hi[3] & d_lo[2]; // 1110
    assign y[15] = d_hi[3] & d_lo[3]; // 1111
endmodule
