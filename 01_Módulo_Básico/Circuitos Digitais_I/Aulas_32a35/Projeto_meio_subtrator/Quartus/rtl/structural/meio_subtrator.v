//==============================================================================
// meio_subtrator.v  (Structural)
//------------------------------------------------------------------------------
// Descrição: Implementação estrutural utilizando portas lógicas básicas.
// Entradas: a, b
// Saídas:   diff, borrow
// Estrutura: diff = xor(a,b)
//            borrow = and(not(a), b)
//==============================================================================
`timescale 1ns/1ps

module meio_subtrator (
    input  wire a,       // minuendo
    input  wire b,       // subtraendo
    output wire diff,    // diferença
    output wire borrow   // empréstimo
);
    wire na;             // fio interno para ~a

    // Porta NOT para gerar ~a
    not  u_not (na, a);
    // Porta AND para (~a) & b  -> borrow
    and  u_and (borrow, na, b);
    // Porta XOR para a ^ b     -> diff
    xor  u_xor (diff, a, b);
endmodule
