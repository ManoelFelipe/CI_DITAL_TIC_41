// ============================================================================
// Arquivo   : count_ascendente_100 (implementação STRUCTURAL)
// Autor     : Manoel Furtado
// Data      : 26/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição : Implementação estrutural do contador módulo 100. O design é
//             composto pela interconexão de blocos menores.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module count_ascendente_100_struct
#(
    // Parâmetros configuráveis
    parameter integer WIDTH      = 7,  // Largura do contador
    parameter integer MAX_COUNT  = 99  // Módulo do contador
)
(
    // Portas de E/S
    input  wire                     clk,         // Clock
    input  wire                     async_reset, // Reset assíncrono
    output wire [WIDTH-1:0]         count_out    // Saída do contador
);

    // Fios internos para interconexão dos blocos
    wire [WIDTH-1:0] count_reg;         // Saída do registrador (estado atual)
    wire [WIDTH-1:0] incremented_count; // Saída do somador (estado atual + 1)
    wire [WIDTH-1:0] mux_out;           // Saída do multiplexador (próximo estado)
    wire max_reached;                   // Saída do comparador (flag de reset síncrono)

    // Instanciação do Registrador Assíncrono de N bits
    // Armazena o valor atual do contador
    reg_async_nbits
    #(
        .WIDTH(WIDTH)
    ) u_reg_async_nbits (
        .clk        (clk),
        .async_reset(async_reset),
        .d          (mux_out),    // Entrada vem do MUX (próximo estado)
        .q          (count_reg)   // Saída é o estado atual
    );

    // Instanciação do Somador (Incrementador)
    // Calcula o valor atual + 1
    adder_inc_nbits
    #(
        .WIDTH(WIDTH)
    ) u_adder_inc_nbits (
        .a          (count_reg),        // Entrada é o estado atual
        .sum        (incremented_count) // Saída é o valor incrementado
    );

    // Instanciação do Comparador de Igualdade
    // Verifica se o contador atingiu o valor máximo (MAX_COUNT)
    comparator_eq_nbits
    #(
        .WIDTH(WIDTH),
        .CONST_VALUE(MAX_COUNT)
    ) u_comparator_eq_nbits (
        .a          (count_reg),  // Entrada é o estado atual
        .is_equal   (max_reached) // Saída é 1 se igual a MAX_COUNT
    );

    // Instanciação do Multiplexador de 2 canais
    // Seleciona o próximo estado: (atual + 1) ou (0)
    mux2_nbits
    #(
        .WIDTH(WIDTH)
    ) u_mux2_nbits (
        .sel        (max_reached),       // Se max_reached=1, seleciona entrada 'b' (0)
        .a          (incremented_count), // Entrada 'a': valor incrementado
        .b          ({WIDTH{1'b0}}),     // Entrada 'b': valor zero (reset síncrono)
        .y          (mux_out)            // Saída vai para o registrador
    );

    // Conecta o estado interno à saída do módulo
    assign count_out = count_reg;

endmodule

// ============================================================================
// Submódulos Auxiliares
// ============================================================================

// Registrador com Reset Assíncrono
module reg_async_nbits
#(
    parameter integer WIDTH = 7
)
(
    input  wire                 clk,
    input  wire                 async_reset,
    input  wire [WIDTH-1:0]     d,
    output reg  [WIDTH-1:0]     q
);
    // Lógica sequencial padrão
    always @(posedge clk or posedge async_reset) begin
        if (async_reset) begin
            q <= {WIDTH{1'b0}};
        end
        else begin
            q <= d;
        end
    end
endmodule

// Somador (Incrementador de 1)
module adder_inc_nbits
#(
    parameter integer WIDTH = 7
)
(
    input  wire [WIDTH-1:0] a,
    output wire [WIDTH-1:0] sum
);
    // Lógica combinacional de soma
    assign sum = a + 1'b1;
endmodule

// Comparador de Igualdade com Constante
module comparator_eq_nbits
#(
    parameter integer WIDTH       = 7,
    parameter integer CONST_VALUE = 99
)
(
    input  wire [WIDTH-1:0] a,
    output wire             is_equal
);
    // Lógica combinacional de comparação
    assign is_equal = (a == CONST_VALUE[WIDTH-1:0]);
endmodule

// Multiplexador 2 para 1
module mux2_nbits
#(
    parameter integer WIDTH = 7
)
(
    input  wire             sel,
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH-1:0] y
);
    // Lógica combinacional de seleção
    assign y = sel ? b : a;
endmodule
