// ============================================================================
// Arquivo  : ULA_LSL_LSR_mod_2.v  (implementação dataflow)
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
// Módulo principal — implementação dataflow
// ---------------------------------------------------------------------------
module ULA_LSL_LSR_mod_2 (
    input  wire [3:0] a_in,          // Operando A de 4 bits
    input  wire [3:0] b_in,          // Operando B de 4 bits
    input  wire [2:0] op_sel,        // Seleção da operação
    output wire [3:0] resultado_out, // Resultado combinacional
    output wire       flag_c,        // Flag C — transporte/emprestimo
    output wire       flag_v,        // Flag V — overflow em complemento de dois
    output wire       flag_z,        // Flag Z — resultado igual a zero
    output wire       flag_n         // Flag N — bit de sinal
);

    // -----------------------------------------------------------------------
    // Preparação do fator de deslocamento saturado
    // -----------------------------------------------------------------------
    wire [2:0] shift_raw;            // Valor bruto de deslocamento (B[2:0])
    wire [2:0] shift_amt;            // Valor saturado em até 4 posições

    assign shift_raw = b_in[2:0];    // Extrai 3 bits menos significativos
    assign shift_amt = (shift_raw > 3'd4) ? 3'd4 : shift_raw; // Saturação

    // -----------------------------------------------------------------------
    // Operações lógicas básicas
    // -----------------------------------------------------------------------
    wire [3:0] res_and;              // Resultado de A AND B
    wire [3:0] res_or;               // Resultado de A OR B
    wire [3:0] res_not;              // Resultado de NOT A
    wire [3:0] res_nand;             // Resultado de NAND(A,B)

    assign res_and  = a_in & b_in;   // AND bit a bit
    assign res_or   = a_in | b_in;   // OR bit a bit
    assign res_not  = ~a_in;         // NOT de A
    assign res_nand = ~(a_in & b_in);// NAND bit a bit

    // -----------------------------------------------------------------------
    // Operações aritméticas — soma e subtração em 4 bits
    // -----------------------------------------------------------------------
    wire [4:0] add_ext;              // Resultado estendido da soma
    wire [4:0] sub_ext;              // Resultado estendido da subtração

    assign add_ext = {1'b0, a_in} + {1'b0, b_in}; // Soma sem sinal estendida
    assign sub_ext = {1'b0, a_in} - {1'b0, b_in}; // Subtração sem sinal estendida

    wire [3:0] res_add;              // Resultado truncado da soma
    wire [3:0] res_sub;              // Resultado truncado da subtração
    wire       c_add;                // Carry-out da soma
    wire       c_sub;                // Carry-flag da subtração (1 = sem empréstimo)

    assign res_add = add_ext[3:0];   // Soma truncada em 4 bits
    assign res_sub = sub_ext[3:0];   // Subtração truncada em 4 bits
    assign c_add   = add_ext[4];     // Carry-out para aritmética sem sinal
    assign c_sub   = ~sub_ext[4];    // C = ~borrow para a subtração

    // -----------------------------------------------------------------------
    // Operações de deslocamento lógico com saturação de fator
    // -----------------------------------------------------------------------
    wire [3:0] res_lsl;              // Resultado do deslocamento à esquerda
    wire [3:0] res_lsr;              // Resultado do deslocamento à direita

    assign res_lsl = a_in << shift_amt; // LSL com fator saturado
    assign res_lsr = a_in >> shift_amt; // LSR com fator saturado

    // -----------------------------------------------------------------------
    // Mux combinacional de resultado principal da ULA
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
    // Flags C e V — dependentes da operação aritmética
    // -----------------------------------------------------------------------
    wire v_add;                      // Overflow da soma
    wire v_sub;                      // Overflow da subtração

    assign v_add = (~(a_in[3] ^ b_in[3])) &  // Mesma polaridade em A e B
                    (res_add[3] ^ a_in[3]);  // Resultado com sinal diferente

    assign v_sub = (a_in[3] ^ b_in[3]) &     // Sinais diferentes em A e B
                    (res_sub[3] ^ a_in[3]);  // Resultado com sinal inesperado

    assign flag_c =
          (op_sel == 3'b100) ? c_add :
          (op_sel == 3'b101) ? c_sub :
                               1'b0;  // Demais operações não afetam C

    assign flag_v =
          (op_sel == 3'b100) ? v_add :
          (op_sel == 3'b101) ? v_sub :
                               1'b0;  // Demais operações não afetam V

    // -----------------------------------------------------------------------
    // Flags Z e N — dependentes apenas do resultado final
    // -----------------------------------------------------------------------
    assign flag_z = (resultado_out == 4'b0000); // Z ativo em resultado nulo
    assign flag_n = resultado_out[3];           // N reflete o bit mais significativo

endmodule
