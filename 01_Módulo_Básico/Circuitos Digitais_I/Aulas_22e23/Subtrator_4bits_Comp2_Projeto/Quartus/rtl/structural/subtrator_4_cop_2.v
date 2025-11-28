// subtrator_4_cop_2.v — Implementação Estrutural (Structural)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Descrição: Subtrator de 4 bits construído com cadeia de somadores completos.
//            Implementa A - B como A + (~B) + 1 via ripple-carry.
// Compatibilidade: Verilog-2001 (Quartus/Questa).

module full_adder (
    input  wire a,       // bit A
    input  wire b,       // bit B
    input  wire cin,     // carry de entrada
    output wire sum,     // soma
    output wire cout     // carry de saída
);
    // Implementação canônica do somador completo
    assign {cout, sum} = a + b + cin;
endmodule

module subtrator_4_cop_2 (
    input  wire [3:0] A,      // Minuendo
    input  wire [3:0] B,      // Subtraendo
    output wire [3:0] diff,   // Resultado A - B
    output wire       borrow  // 1 quando A < B
);
    // Complemento de 1 de B (inversão bit a bit); o +1 virá via cin inicial = 1
    wire [3:0] nB = ~B;

    wire c1, c2, c3, c4;

    // Cin inicial = 1 garante (~B + 1) somado a A
    full_adder fa0(.a(A[0]), .b(nB[0]), .cin(1'b1), .sum(diff[0]), .cout(c1));
    full_adder fa1(.a(A[1]), .b(nB[1]), .cin(c1),   .sum(diff[1]), .cout(c2));
    full_adder fa2(.a(A[2]), .b(nB[2]), .cin(c2),   .sum(diff[2]), .cout(c3));
    full_adder fa3(.a(A[3]), .b(nB[3]), .cin(c3),   .sum(diff[3]), .cout(c4));

    // Borrow é o inverso do carry final
    assign borrow = ~c4;
endmodule
