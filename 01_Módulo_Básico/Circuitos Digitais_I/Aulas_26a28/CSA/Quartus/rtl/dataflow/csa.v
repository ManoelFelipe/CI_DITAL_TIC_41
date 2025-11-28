// csa.v — Carry-Save Adder (CSA) 4-bit — Dataflow
// Autor: Manoel Furtado
// Data: 31/10/2025
// Descrição: Implementação puramente com atribuições contínuas vetoriais.
module csa (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire [3:0] Cin,
    output wire [3:0] Sum,
    output wire [3:0] Cout
);
    // Soma parcial: XOR bit a bit dos três vetores
    assign Sum  = A ^ B ^ Cin; 
    // Carry parcial: função de maioria bit a bit
    assign Cout = (A & B) | (B & Cin) | (Cin & A);
endmodule
