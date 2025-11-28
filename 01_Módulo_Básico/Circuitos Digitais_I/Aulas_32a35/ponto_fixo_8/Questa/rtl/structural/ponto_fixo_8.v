// =============================================================
// Projeto: ponto_fixo_8.v (Structural)
// Autor: Manoel Furtado | Data: 10/11/2025
// Descrição: Rede de full adders com inversão condicional de B
// =============================================================
module full_adder(
    input a, b, cin,
    output sum, cout
);
    // Implementação por expressões booleanas (equivalente a a+b+cin)
    assign {cout, sum} = a + b + cin;
endmodule

module ponto_fixo_8(
    input  [7:0] a,      // Q4.4
    input  [7:0] b,      // Q4.4
    input        sel,    // 0: soma | 1: subtração
    output [7:0] result, // Q4.4
    output       overflow
);
    wire [7:0] bxor;     // B invertido quando subtração
    wire [8:0] carry;    // Vetor de carries (carry[0] = sel)
    assign bxor = b ^ {8{sel}}; // Inverte B se for subtração (complemento de 2)
    assign carry[0] = sel;      // +1 para completar o complemento de 2

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin: adders
            full_adder fa(
                .a(a[i]),
                .b(bxor[i]),
                .cin(carry[i]),
                .sum(result[i]),
                .cout(carry[i+1])
            );
        end
    endgenerate

    // Overflow para números com sinal: XOR dos dois últimos carries
    assign overflow = carry[8] ^ carry[7];
endmodule
