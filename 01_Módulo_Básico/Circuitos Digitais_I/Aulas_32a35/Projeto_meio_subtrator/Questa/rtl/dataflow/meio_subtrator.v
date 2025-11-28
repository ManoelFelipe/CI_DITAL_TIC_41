//==============================================================================
// meio_subtrator.v  (Dataflow)
//------------------------------------------------------------------------------
// Descrição: Implementação em fluxo de dados (dataflow) de um meio subtrator.
// Entradas: a, b
// Saídas:   diff, borrow
// Equações booleanas: diff = a ^ b ; borrow = (~a) & b
//==============================================================================
`timescale 1ns/1ps

module meio_subtrator (
    input  wire a,      // minuendo
    input  wire b,      // subtraendo
    output wire diff,   // diferença
    output wire borrow  // empréstimo
);
    // Atribuições contínuas representam a lógica combinacional
    assign diff   = a ^ b;     // XOR produz a diferença
    assign borrow = (~a) & b;  // Empréstimo quando a=0 e b=1
endmodule
