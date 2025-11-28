//==============================================================================
// meio_subtrator.v  (Behavioral)
//------------------------------------------------------------------------------
// Descrição: Implementação comportamental (behavioral) de um meio subtrator.
// Entradas: a, b  (1 bit cada)
// Saídas:   diff (diferença), borrow (empréstimo)
// Lógica esperada: diff = a ^ b ; borrow = (~a) & b
// Compatível com Verilog 2001 (Quartus/Questa).
//==============================================================================
`timescale 1ns/1ps

module meio_subtrator (
    input  wire a,      // minuendo (bit mais significativo do par a,b)
    input  wire b,      // subtraendo
    output reg  diff,   // diferença (a - b)
    output reg  borrow  // empréstimo quando b > a
);
    // Bloco combinacional sensível a todas as entradas
    always @* begin
        // 'diff' é o XOR entre a e b (bit a bit)
        diff   = a ^ b;
        // 'borrow' ocorre quando 'a' é 0 e 'b' é 1
        borrow = (~a) & b;
    end
endmodule
