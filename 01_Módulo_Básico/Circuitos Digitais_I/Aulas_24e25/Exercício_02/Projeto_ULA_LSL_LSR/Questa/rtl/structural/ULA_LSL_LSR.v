// ============================================================================
// Arquivo  : ULA_LSL_LSR.v  (implementação structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação estrutural de uma ULA de 4 bits, construída a
//            partir da composição de blocos menores: operadores lógicos
//            elementares, somador, subtrator, blocos de deslocamento lógico
//            e um multiplexador 8:1 de 4 bits. A ULA é puramente combinacional
//            e cobre as operações AND, OR, NOT(A), NAND, soma, subtração,
//            LSL(A) e LSR(A), selecionadas por um campo seletor de 3 bits.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Módulo de topo: ULA_LSL_LSR (implementação structural)
// ---------------------------------------------------------------------------
// Portas:
//   A        : operando A de 4 bits
//   B        : operando B de 4 bits
//   seletor  : código da operação (3 bits)
//   resultado: resultado combinacional de 4 bits
// ---------------------------------------------------------------------------
module ULA_LSL_LSR (
    input  wire [3:0] A,         // Operando A
    input  wire [3:0] B,         // Operando B
    input  wire [2:0] seletor,   // Código da operação
    output wire [3:0] resultado  // Resultado final
);
    // -----------------------------------------------------------------------
    // Sinais internos para cada operação elementar.
    // -----------------------------------------------------------------------
    wire [3:0] and_result;       // Saída do bloco AND
    wire [3:0] or_result;        // Saída do bloco OR
    wire [3:0] not_result;       // Saída do bloco NOT(A)
    wire [3:0] nand_result;      // Saída do bloco NAND
    wire [3:0] add_result;       // Saída do bloco soma
    wire [3:0] sub_result;       // Saída do bloco subtração
    wire [3:0] lsl_result;       // Saída do bloco LSL
    wire [3:0] lsr_result;       // Saída do bloco LSR

    // -----------------------------------------------------------------------
    // Instâncias dos blocos funcionais elementares.
    // Cada bloco recebe A/B e produz uma saída específica.
    // -----------------------------------------------------------------------
    and4_block   u_and4   (.a(A), .b(B), .y(and_result));
    or4_block    u_or4    (.a(A), .b(B), .y(or_result));
    not4A_block  u_not4   (.a(A), .y(not_result));
    nand4_block  u_nand4  (.a(A), .b(B), .y(nand_result));
    add4_block   u_add4   (.a(A), .b(B), .y(add_result));
    sub4_block   u_sub4   (.a(A), .b(B), .y(sub_result));
    lsl4_block   u_lsl4   (.a(A), .y(lsl_result));
    lsr4_block   u_lsr4   (.a(A), .y(lsr_result));

    // -----------------------------------------------------------------------
    // Multiplexador 8:1 de 4 bits.
    // Seleciona qual resultado será encaminhado à saída da ULA com base
    // no campo de 3 bits 'seletor'.
// -----------------------------------------------------------------------
    mux8_1_4bit u_mux (
        .sel (seletor),          // Entradas de seleção
        .d0  (and_result),       // 000 → AND
        .d1  (or_result),        // 001 → OR
        .d2  (not_result),       // 010 → NOT(A)
        .d3  (nand_result),      // 011 → NAND
        .d4  (add_result),       // 100 → A + B
        .d5  (sub_result),       // 101 → A - B
        .d6  (lsl_result),       // 110 → LSL(A)
        .d7  (lsr_result),       // 111 → LSR(A)
        .y   (resultado)         // Saída multiplexada
    );
endmodule

// ---------------------------------------------------------------------------
// Bloco AND de 4 bits
// ---------------------------------------------------------------------------
module and4_block (
    input  wire [3:0] a,         // Operando de entrada A
    input  wire [3:0] b,         // Operando de entrada B
    output wire [3:0] y          // Saída AND de 4 bits
);
    assign y = a & b;            // AND bit a bit entre a e b
endmodule

// ---------------------------------------------------------------------------
// Bloco OR de 4 bits
// ---------------------------------------------------------------------------
module or4_block (
    input  wire [3:0] a,         // Operando de entrada A
    input  wire [3:0] b,         // Operando de entrada B
    output wire [3:0] y          // Saída OR de 4 bits
);
    assign y = a | b;            // OR bit a bit entre a e b
endmodule

// ---------------------------------------------------------------------------
// Bloco NOT(A) de 4 bits
// ---------------------------------------------------------------------------
module not4A_block (
    input  wire [3:0] a,         // Operando de entrada A
    output wire [3:0] y          // Saída NOT de 4 bits
);
    assign y = ~a;               // Inversão bit a bit de a
endmodule

// ---------------------------------------------------------------------------
// Bloco NAND de 4 bits
// ---------------------------------------------------------------------------
module nand4_block (
    input  wire [3:0] a,         // Operando de entrada A
    input  wire [3:0] b,         // Operando de entrada B
    output wire [3:0] y          // Saída NAND de 4 bits
);
    assign y = ~(a & b);         // NAND bit a bit entre a e b
endmodule

// ---------------------------------------------------------------------------
// Bloco de soma de 4 bits (A + B)
// ---------------------------------------------------------------------------
module add4_block (
    input  wire [3:0] a,         // Operando de entrada A
    input  wire [3:0] b,         // Operando de entrada B
    output wire [3:0] y          // Saída da soma truncada em 4 bits
);
    assign y = a + b;            // Soma aritmética simples
endmodule

// ---------------------------------------------------------------------------
// Bloco de subtração de 4 bits (A - B)
// ---------------------------------------------------------------------------
module sub4_block (
    input  wire [3:0] a,         // Operando de entrada A
    input  wire [3:0] b,         // Operando de entrada B
    output wire [3:0] y          // Saída da subtração truncada em 4 bits
);
    assign y = a - b;            // Subtração aritmética simples
endmodule

// ---------------------------------------------------------------------------
// Bloco LSL de 4 bits (deslocamento lógico à esquerda)
// ---------------------------------------------------------------------------
module lsl4_block (
    input  wire [3:0] a,         // Operando de entrada A
    output wire [3:0] y          // Saída com deslocamento lógico à esquerda
);
    assign y = {a[2:0], 1'b0};   // Desloca 1 bit à esquerda, insere 0 no LSB
endmodule

// ---------------------------------------------------------------------------
// Bloco LSR de 4 bits (deslocamento lógico à direita)
// ---------------------------------------------------------------------------
module lsr4_block (
    input  wire [3:0] a,         // Operando de entrada A
    output wire [3:0] y          // Saída com deslocamento lógico à direita
);
    assign y = {1'b0, a[3:1]};   // Desloca 1 bit à direita, insere 0 no MSB
endmodule

// ---------------------------------------------------------------------------
// Multiplexador 8:1 de 4 bits
// ---------------------------------------------------------------------------
module mux8_1_4bit (
    input  wire [2:0] sel,       // Seletor de 3 bits
    input  wire [3:0] d0,        // Entrada para código 000
    input  wire [3:0] d1,        // Entrada para código 001
    input  wire [3:0] d2,        // Entrada para código 010
    input  wire [3:0] d3,        // Entrada para código 011
    input  wire [3:0] d4,        // Entrada para código 100
    input  wire [3:0] d5,        // Entrada para código 101
    input  wire [3:0] d6,        // Entrada para código 110
    input  wire [3:0] d7,        // Entrada para código 111
    output reg  [3:0] y          // Saída multiplexada
);
    // Multiplexação comportamental em bloco always combinacional
    always @(*) begin
        case (sel)
            3'b000: y = d0;      // Seleciona entrada d0
            3'b001: y = d1;      // Seleciona entrada d1
            3'b010: y = d2;      // Seleciona entrada d2
            3'b011: y = d3;      // Seleciona entrada d3
            3'b100: y = d4;      // Seleciona entrada d4
            3'b101: y = d5;      // Seleciona entrada d5
            3'b110: y = d6;      // Seleciona entrada d6
            3'b111: y = d7;      // Seleciona entrada d7
            default: y = 4'b0000;// Valor padrão de segurança
        endcase
    end
endmodule
