// ============================================================================
// Arquivo  : ULA_LSL_LSR_mod.v  (implementação behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Unidade Lógica e Aritmética (ULA) de 4 bits com suporte a oito
//            operações combinacionais, incluindo deslocamentos lógicos LSL/LSR
//            com fator de deslocamento variável informado pelo operando B.
//            O valor de deslocamento é saturado em até 4 posições, adequado a
//            operandos de 4 bits, preservando largura fixa e latência 0 ciclos.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Módulo: ULA_LSL_LSR_mod (implementação behavioral)
// ---------------------------------------------------------------------------
// Portas:
//   a_in         : operando A de 4 bits
//   b_in         : operando B de 4 bits (inclui fator de deslocamento)
//   op_sel       : código da operação (3 bits)
//                  000 AND    | 001 OR     | 010 NOT(A) | 011 NAND
//                  100 A + B  | 101 A - B  | 110 LSL(A) | 111 LSR(A)
//   resultado_out: saída de 4 bits, valor combinacional da operação escolhida
// ---------------------------------------------------------------------------
module ULA_LSL_LSR_mod (
    input  wire [3:0] a_in,          // Operando A de 4 bits
    input  wire [3:0] b_in,          // Operando B de 4 bits
    input  wire [2:0] op_sel,        // Seletor da operação
    output reg  [3:0] resultado_out  // Resultado da operação
);
    // -----------------------------------------------------------------------
    // Registrador interno para armazenar o fator de deslocamento efetivo
    //   - Calculado a partir de b_in
    //   - Saturado em no máximo 4 posições (valor 4'd4)
    // -----------------------------------------------------------------------
    reg [2:0] shift_amt;             // Fator de deslocamento saturado (0..4)

    // -----------------------------------------------------------------------
    // Bloco always combinacional principal
    //   - Recalcula o fator de deslocamento e o resultado sempre que
    //     qualquer entrada (a_in, b_in ou op_sel) se altera.
    // -----------------------------------------------------------------------
    always @(*) begin
        // -------------------------------------------------------------------
        // Cálculo do fator de deslocamento saturado
        //   - Se b_in > 4, utiliza-se 4
        //   - Caso contrário, usa-se b_in[2:0] diretamente
        // -------------------------------------------------------------------
        if (b_in > 4'd4) begin
            shift_amt = 3'd4;        // Limita deslocamentos excessivos a 4
        end else begin
            shift_amt = b_in[2:0];   // Usa parte menos significativa de B
        end

        // -------------------------------------------------------------------
        // Seleção da operação conforme op_sel
        // -------------------------------------------------------------------
        case (op_sel)
            3'b000: begin
                resultado_out = (a_in & b_in);          // AND bit a bit
            end
            3'b001: begin
                resultado_out = (a_in | b_in);          // OR bit a bit
            end
            3'b010: begin
                resultado_out = (~a_in);                // NOT de A
            end
            3'b011: begin
                resultado_out = ~(a_in & b_in);         // NAND bit a bit
            end
            3'b100: begin
                resultado_out = (a_in + b_in);          // Soma truncada em 4 bits
            end
            3'b101: begin
                resultado_out = (a_in - b_in);          // Subtração truncada em 4 bits
            end
            3'b110: begin
                resultado_out = (a_in << shift_amt);    // LSL com deslocamento variável
            end
            3'b111: begin
                resultado_out = (a_in >> shift_amt);    // LSR com deslocamento variável
            end
            default: begin
                resultado_out = 4'b0000;                // Valor de segurança
            end
        endcase
    end
endmodule
