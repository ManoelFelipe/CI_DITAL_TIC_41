// ============================================================================
// Arquivo  : ULA_LSL_LSR_mod_2.v  (implementação structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Unidade Lógica e Aritmética (ULA) combinacional de 4 bits, com
//            suporte a oito operações (AND, OR, NOT, NAND, soma, subtração,
//            deslocamento lógico à esquerda e à direita). Implementa geração
//            de flags C, V, Z e N para análise de estouro e sinal tanto em
//            aritmética sem sinal quanto em complemento de dois, latência 0.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Módulo principal — implementação structural
// ---------------------------------------------------------------------------
module ULA_LSL_LSR_mod_2 (
    input  wire [3:0] a_in,          // Operando A de 4 bits
    input  wire [3:0] b_in,          // Operando B de 4 bits
    input  wire [2:0] op_sel,        // Código da operação
    output wire [3:0] resultado_out, // Resultado da ULA
    output wire       flag_c,        // Flag C — transporte/emprestimo
    output wire       flag_v,        // Flag V — overflow em complemento de dois
    output wire       flag_z,        // Flag Z — resultado nulo
    output wire       flag_n         // Flag N — resultado negativo
);

    // -----------------------------------------------------------------------
    // Instâncias das unidades funcionais básicas
    // -----------------------------------------------------------------------

    // Saídas individuais de cada operação
    wire [3:0] res_and;              // Saída do bloco AND
    wire [3:0] res_or;               // Saída do bloco OR
    wire [3:0] res_not;              // Saída do bloco NOT
    wire [3:0] res_nand;             // Saída do bloco NAND
    wire [3:0] res_add;              // Saída do somador
    wire [3:0] res_sub;              // Saída do subtrator
    wire [3:0] res_lsl;              // Saída do deslocador à esquerda
    wire [3:0] res_lsr;              // Saída do deslocador à direita

    // Flags aritméticas provenientes dos blocos de soma e subtração
    wire       c_add;                // Carry-out da soma
    wire       v_add;                // Overflow da soma
    wire       c_sub;                // Carry-flag da subtração
    wire       v_sub;                // Overflow da subtração

    // Instancia bloco lógico com AND, OR, NOT e NAND
    ula_logic_block u_logic (
        .a_in     (a_in),            // Conecta A à porta A do bloco lógico
        .b_in     (b_in),            // Conecta B à porta B do bloco lógico
        .res_and  (res_and),         // Saída AND
        .res_or   (res_or),          // Saída OR
        .res_not  (res_not),         // Saída NOT
        .res_nand (res_nand)         // Saída NAND
    );

    // Instancia somador de 4 bits com flags
    ula_adder_block u_adder (
        .a_in   (a_in),              // Entrada A para o somador
        .b_in   (b_in),              // Entrada B para o somador
        .sum    (res_add),           // Saída de soma
        .flag_c (c_add),             // Carry-out da soma
        .flag_v (v_add)              // Overflow da soma
    );

    // Instancia subtrator de 4 bits com flags
    ula_subtractor_block u_subtractor (
        .a_in   (a_in),              // Entrada A para o subtrator
        .b_in   (b_in),              // Entrada B para o subtrator
        .diff   (res_sub),           // Saída de diferença
        .flag_c (c_sub),             // Flag C (1 = sem empréstimo)
        .flag_v (v_sub)              // Overflow da subtração
    );

    // Instancia deslocador lógico com saturação de fator
    ula_shifter_block u_shifter (
        .a_in    (a_in),             // Entrada A para o deslocador
        .b_in    (b_in),             // Entrada B (fornece fator)
        .res_lsl (res_lsl),          // Saída de deslocamento à esquerda
        .res_lsr (res_lsr)           // Saída de deslocamento à direita
    );

    // -----------------------------------------------------------------------
    // MUX de seleção da operação com base em op_sel
    // -----------------------------------------------------------------------
    assign resultado_out =
          (op_sel == 3'b000) ? res_and  :
          (op_sel == 3'b001) ? res_or   :
          (op_sel == 3'b010) ? res_not  :
          (op_sel == 3'b011) ? res_nand :
          (op_sel == 3'b100) ? res_add  :
          (op_sel == 3'b101) ? res_sub  :
          (op_sel == 3'b110) ? res_lsl  :
          (op_sel == 3'b111) ? res_lsr  :
                               4'b0000; // Valor de segurança

    // -----------------------------------------------------------------------
    // Multiplexação das flags C e V a partir dos blocos aritméticos
    // -----------------------------------------------------------------------
    assign flag_c =
          (op_sel == 3'b100) ? c_add :
          (op_sel == 3'b101) ? c_sub :
                               1'b0;  // Demais operações não afetam C

    assign flag_v =
          (op_sel == 3'b100) ? v_add :
          (op_sel == 3'b101) ? v_sub :
                               1'b0;  // Demais operações não afetam V

    // -----------------------------------------------------------------------
    // Flags Z e N geradas por bloco dedicado
    // -----------------------------------------------------------------------
    ula_flag_zn_block u_flags_zn (
        .resultado_in (resultado_out), // Recebe resultado global
        .flag_z       (flag_z),        // Gera flag Z
        .flag_n       (flag_n)         // Gera flag N
    );

endmodule

// ---------------------------------------------------------------------------
// Bloco lógico: AND, OR, NOT, NAND em 4 bits
// ---------------------------------------------------------------------------
module ula_logic_block (
    input  wire [3:0] a_in,          // Operando A
    input  wire [3:0] b_in,          // Operando B
    output wire [3:0] res_and,       // Resultado AND
    output wire [3:0] res_or,        // Resultado OR
    output wire [3:0] res_not,       // Resultado NOT de A
    output wire [3:0] res_nand       // Resultado NAND
);
    assign res_and  = a_in & b_in;   // AND bit a bit
    assign res_or   = a_in | b_in;   // OR bit a bit
    assign res_not  = ~a_in;         // NOT de A
    assign res_nand = ~(a_in & b_in);// NAND bit a bit
endmodule

// ---------------------------------------------------------------------------
// Bloco somador de 4 bits com geração de C e V
// ---------------------------------------------------------------------------
module ula_adder_block (
    input  wire [3:0] a_in,          // Operando A
    input  wire [3:0] b_in,          // Operando B
    output wire [3:0] sum,           // Soma truncada em 4 bits
    output wire       flag_c,        // Carry-out unsigned
    output wire       flag_v         // Overflow em complemento de dois
);
    wire [4:0] add_ext;              // Resultado estendido da soma

    assign add_ext = {1'b0, a_in} + {1'b0, b_in}; // Soma sem sinal
    assign sum     = add_ext[3:0];                // Resultado de 4 bits
    assign flag_c  = add_ext[4];                  // Carry-out

    assign flag_v  = (~(a_in[3] ^ b_in[3])) &     // Mesma polaridade entradas
                     (sum[3] ^ a_in[3]);          // Sinal de saída inesperado
endmodule

// ---------------------------------------------------------------------------
// Bloco subtrator de 4 bits com geração de C e V
// ---------------------------------------------------------------------------
module ula_subtractor_block (
    input  wire [3:0] a_in,          // Operando A
    input  wire [3:0] b_in,          // Operando B
    output wire [3:0] diff,          // Diferença truncada em 4 bits
    output wire       flag_c,        // C = ~borrow
    output wire       flag_v         // Overflow em complemento de dois
);
    wire [4:0] sub_ext;              // Resultado estendido da subtração

    assign sub_ext = {1'b0, a_in} - {1'b0, b_in}; // Subtração sem sinal
    assign diff    = sub_ext[3:0];                // Diferença 4 bits
    assign flag_c  = ~sub_ext[4];                 // C = 0 indica empréstimo

    assign flag_v  = (a_in[3] ^ b_in[3]) &        // Sinais diferentes nas entradas
                     (diff[3] ^ a_in[3]);         // Sinal de saída inesperado
endmodule

// ---------------------------------------------------------------------------
// Bloco deslocador lógico com saturação do fator de deslocamento
// ---------------------------------------------------------------------------
module ula_shifter_block (
    input  wire [3:0] a_in,          // Operando A a ser deslocado
    input  wire [3:0] b_in,          // Operando B fornece o fator
    output wire [3:0] res_lsl,       // Resultado LSL
    output wire [3:0] res_lsr        // Resultado LSR
);
    wire [2:0] shift_raw;            // Valor bruto de deslocamento
    wire [2:0] shift_amt;            // Valor saturado do deslocamento

    assign shift_raw = b_in[2:0];    // Extrai os 3 bits menos significativos
    assign shift_amt = (shift_raw > 3'd4) ? 3'd4 : shift_raw; // Saturação

    assign res_lsl   = a_in << shift_amt; // Deslocamento lógico à esquerda
    assign res_lsr   = a_in >> shift_amt; // Deslocamento lógico à direita
endmodule

// ---------------------------------------------------------------------------
// Bloco de geração das flags Z e N a partir do resultado
// ---------------------------------------------------------------------------
module ula_flag_zn_block (
    input  wire [3:0] resultado_in,  // Resultado da ULA
    output wire       flag_z,        // Flag Z — resultado nulo
    output wire       flag_n         // Flag N — resultado negativo
);
    assign flag_z = (resultado_in == 4'b0000); // Z ativo quando resultado é zero
    assign flag_n = resultado_in[3];           // N copia o bit mais significativo
endmodule
