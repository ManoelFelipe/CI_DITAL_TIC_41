// ============================================================================
// Arquivo  : ULA_LSL_LSR_mod.v  (implementação dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA combinacional de 4 bits descrita em estilo de fluxo de dados,
//            utilizando atribuições contínuas para cada operação elementar e
//            seleção do resultado final via operador condicional (mux lógico).
//            Implementa deslocamentos LSL/LSR com fator variável vindo de B,
//            saturado em 4 posições para compatibilidade com operandos de 4 bits.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Módulo: ULA_LSL_LSR_mod (implementação dataflow)
// ---------------------------------------------------------------------------
module ULA_LSL_LSR_mod (
    input  wire [3:0] a_in,          // Operando A de 4 bits
    input  wire [3:0] b_in,          // Operando B de 4 bits
    input  wire [2:0] op_sel,        // Seletor da operação
    output wire [3:0] resultado_out  // Resultado combinacional
);
    // -----------------------------------------------------------------------
    // Fator de deslocamento saturado
    // -----------------------------------------------------------------------
    wire [2:0] shift_amt;            // Fator de deslocamento efetivo (0..4)
    assign shift_amt = (b_in > 4'd4) ? 3'd4 : b_in[2:0];

    // -----------------------------------------------------------------------
    // Resultados parciais de cada operação
    // -----------------------------------------------------------------------
    wire [3:0] and_res;              // Resultado da operação AND
    wire [3:0] or_res;               // Resultado da operação OR
    wire [3:0] not_res;              // Resultado da operação NOT(A)
    wire [3:0] nand_res;             // Resultado da operação NAND
    wire [3:0] add_res;              // Resultado da soma A + B
    wire [3:0] sub_res;              // Resultado da subtração A - B
    wire [3:0] lsl_res;              // Resultado do deslocamento lógico esq.
    wire [3:0] lsr_res;              // Resultado do deslocamento lógico dir.

    // -----------------------------------------------------------------------
    // Atribuições contínuas para cada função elementar
    // -----------------------------------------------------------------------
    assign and_res  = a_in & b_in;           // AND bit a bit
    assign or_res   = a_in | b_in;           // OR bit a bit
    assign not_res  = ~a_in;                 // NOT apenas em A
    assign nand_res = ~(a_in & b_in);        // NAND bit a bit
    assign add_res  = a_in + b_in;           // Soma truncada em 4 bits
    assign sub_res  = a_in - b_in;           // Subtração truncada em 4 bits
    assign lsl_res  = a_in << shift_amt;     // LSL com deslocamento variável
    assign lsr_res  = a_in >> shift_amt;     // LSR com deslocamento variável

    // -----------------------------------------------------------------------
    // Multiplexação lógica do resultado final via operador condicional
    // -----------------------------------------------------------------------
    assign resultado_out =
        (op_sel == 3'b000) ? and_res  :
        (op_sel == 3'b001) ? or_res   :
        (op_sel == 3'b010) ? not_res  :
        (op_sel == 3'b011) ? nand_res :
        (op_sel == 3'b100) ? add_res  :
        (op_sel == 3'b101) ? sub_res  :
        (op_sel == 3'b110) ? lsl_res  :
        (op_sel == 3'b111) ? lsr_res  :
                             4'b0000;       // Valor de segurança
endmodule
