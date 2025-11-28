// subtrator_4_cop_2.v — Implementação em Fluxo de Dados (Dataflow)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Descrição: Subtrator de 4 bits usando expressões contínuas (assign).
// Compatibilidade: Verilog-2001 (Quartus/Questa).

module subtrator_4_cop_2 (
    input  wire [3:0] A,      // Minuendo
    input  wire [3:0] B,      // Subtraendo
    output wire [3:0] diff,   // A - B
    output wire       borrow  // 1 quando A < B
);
    // Soma estendida: A + (~B + 1)
    wire [4:0] soma_ext = {1'b0, A} + {1'b0, (~B) + 4'b0001};

    // Diferença é a parte baixa
    assign diff   = soma_ext[3:0];

    // Borrow é o inverso do carry de saída
    assign borrow = ~soma_ext[4];
endmodule
