// subtrator_4_cop_2.v — Implementação Comportamental (Behavioral)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Descrição: Subtrator de 4 bits usando complemento de 2 (A - B = A + (~B + 1)).
//            Saídas: diff (resultado de 4 bits) e borrow (1 quando A < B).
// Compatibilidade: Verilog-2001 (Quartus/Questa).

module subtrator_4_cop_2 (
    input  wire [3:0] A,   // Minuendo (valor do qual vamos subtrair)
    input  wire [3:0] B,   // Subtraendo (valor a ser subtraído)
    output reg  [3:0] diff,// Resultado da subtração A - B (4 bits)
    output reg        borrow // Flag de empréstimo (1 se houve empréstimo: A < B)
);
    // Registradores internos para somar A com (~B + 1)
    reg [4:0] soma_ext;    // 5 bits para capturar o carry out

    always @* begin
        // Calcula complemento de 2 de B implicitamente: ~B + 1
        // Soma estendida em 5 bits para não perder o carry de saída
        soma_ext = {1'b0, A} + {1'b0, (~B) + 4'b0001};

        // Resultado final são os 4 bits menos significativos da soma
        diff   = soma_ext[3:0];

        // Em subtração via complemento de 2, borrow = ~carry_out
        borrow = ~soma_ext[4];
    end
endmodule
