// csa.v — Carry-Save Adder (CSA) 4-bit — Behavioral
// Autor: Manoel Furtado
// Data: 31/10/2025
// Descrição:
//  - Soma três vetores binários de 4 bits (A, B, Cin) sem propagação de carry.
//  - Produz duas saídas: Sum (soma parcial) e Cout (carry parcial bit‑a‑bit).
//  - Compatível com Verilog 2001 (Quartus/Questa).
//
// Observação de CSA:
//  Em um CSA, cada bit i é somado por um "full adder" independente:
//     Sum[i]  = A[i] ^ B[i] ^ Cin[i]
//     Cout[i] = (A[i] & B[i]) | (B[i] & Cin[i]) | (Cin[i] & A[i])
//  Não há encadeamento de carry entre bits (sem ripple). O vetor Cout
//  normalmente é deslocado e somado depois em outra etapa da árvore CSA.
//
// Comentários linha a linha incluídos ao longo do código.
module csa (
    input  wire [3:0] A,   // Entradas de 4 bits
    input  wire [3:0] B,
    input  wire [3:0] Cin, // Carry de entrada por bit (terceiro operando)
    output reg  [3:0] Sum, // Soma parcial por bit
    output reg  [3:0] Cout // Carry parcial por bit
);

    integer i; // Índice de laço

    // Bloco combinacional que calcula Sum e Cout para cada bit.
    always @* begin
        // Inicializa as saídas (boa prática para evitar inferência de latches)
        Sum  = 4'b0000; // Zera a soma parcial
        Cout = 4'b0000; // Zera o carry parcial

        // Calcula bit a bit usando um laço para maior clareza
        for (i = 0; i < 4; i = i + 1) begin
            // Soma (paridade ímpar dos três bits)
            Sum[i]  = A[i] ^ B[i] ^ Cin[i];
            // Carry (maioria de três)
            Cout[i] = (A[i] & B[i]) | (B[i] & Cin[i]) | (Cin[i] & A[i]);
        end
    end
endmodule
