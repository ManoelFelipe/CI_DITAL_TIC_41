// ============================================================================
// Arquivo  : ULA_LSL_LSR_mod_2.v  (implementação behavioral)
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
// Módulo principal — implementação behavioral
// ---------------------------------------------------------------------------
module ULA_LSL_LSR_mod_2 (
    input  wire [3:0] a_in,          // Operando A de 4 bits
    input  wire [3:0] b_in,          // Operando B de 4 bits
    input  wire [2:0] op_sel,        // Seleção da operação (3 bits)
    output reg  [3:0] resultado_out, // Resultado da operação
    output reg        flag_c,        // Flag C — transporte/emprestimo (sem sinal)
    output reg        flag_v,        // Flag V — overflow em complemento de dois
    output reg        flag_z,        // Flag Z — resultado igual a zero
    output reg        flag_n         // Flag N — bit de sinal do resultado
);

    // Registrador para guardar fator de deslocamento saturado
    reg [2:0] shift_amt;

    // Registradores auxiliares para operações de soma e subtração estendidas
    reg [4:0] add_ext;              // Resultado estendido da soma (inclui carry)
    reg [4:0] sub_ext;              // Resultado estendido da subtração (inclui borrow)

    // Bloco combinacional principal
    always @* begin
        // -------------------------------------------------------------------
        // Inicialização de valores padrão para evitar latches
        // -------------------------------------------------------------------
        resultado_out = 4'b0000;     // Resultado padrão
        flag_c        = 1'b0;        // C padrão em 0
        flag_v        = 1'b0;        // V padrão em 0
        flag_z        = 1'b0;        // Z será recalculado ao final
        flag_n        = 1'b0;        // N será recalculado ao final
        add_ext       = 5'b00000;    // Zera registrador de soma estendida
        sub_ext       = 5'b00000;    // Zera registrador de subtração estendida

        // -------------------------------------------------------------------
        // Cálculo do fator de deslocamento saturado em até 4 posições
        // -------------------------------------------------------------------
        if (b_in[2:0] > 3'd4) begin
            shift_amt = 3'd4;        // Limita deslocamento máximo a 4
        end else begin
            shift_amt = b_in[2:0];   // Usa diretamente B[2:0] como deslocamento
        end

        // -------------------------------------------------------------------
        // Seleção da operação principal da ULA
        // -------------------------------------------------------------------
        case (op_sel)
            3'b000: begin
                // -----------------------------------------------------------
                // Operação 000 — AND bit a bit entre A e B
                // -----------------------------------------------------------
                resultado_out = a_in & b_in;  // Calcula AND dos 4 bits
                flag_c        = 1'b0;         // Sem carry em operação lógica
                flag_v        = 1'b0;         // Sem overflow em operação lógica
            end

            3'b001: begin
                // -----------------------------------------------------------
                // Operação 001 — OR bit a bit entre A e B
                // -----------------------------------------------------------
                resultado_out = a_in | b_in;  // Calcula OR dos 4 bits
                flag_c        = 1'b0;         // Sem carry
                flag_v        = 1'b0;         // Sem overflow
            end

            3'b010: begin
                // -----------------------------------------------------------
                // Operação 010 — NOT do operando A
                // -----------------------------------------------------------
                resultado_out = ~a_in;        // Inverte todos os bits de A
                flag_c        = 1'b0;         // Sem carry
                flag_v        = 1'b0;         // Sem overflow
            end

            3'b011: begin
                // -----------------------------------------------------------
                // Operação 011 — NAND bit a bit entre A e B
                // -----------------------------------------------------------
                resultado_out = ~(a_in & b_in); // Calcula NAND dos 4 bits
                flag_c        = 1'b0;           // Sem carry
                flag_v        = 1'b0;           // Sem overflow
            end

            3'b100: begin
                // -----------------------------------------------------------
                // Operação 100 — Soma A + B (4 bits)
                // -----------------------------------------------------------
                add_ext       = {1'b0, a_in} + {1'b0, b_in}; // Soma estendida 5 bits
                resultado_out = add_ext[3:0];                // Resultado truncado em 4 bits
                flag_c        = add_ext[4];                  // Carry-out unsigned na posição 4
                flag_v        = (~(a_in[3] ^ b_in[3])) &     // Mesmos sinais em A e B
                                 (resultado_out[3] ^ a_in[3]); // Sinal do resultado difere
            end

            3'b101: begin
                // -----------------------------------------------------------
                // Operação 101 — Subtração A - B (4 bits)
                // -----------------------------------------------------------
                sub_ext       = {1'b0, a_in} - {1'b0, b_in}; // Subtração estendida 5 bits
                resultado_out = sub_ext[3:0];                // Resultado truncado em 4 bits
                flag_c        = ~sub_ext[4];                 // C = 0 indica empréstimo
                flag_v        = (a_in[3] ^ b_in[3]) &        // Sinais diferentes em A e B
                                 (resultado_out[3] ^ a_in[3]); // Resultado com sinal inesperado
            end

            3'b110: begin
                // -----------------------------------------------------------
                // Operação 110 — Deslocamento lógico à esquerda (LSL)
                // -----------------------------------------------------------
                resultado_out = a_in << shift_amt; // Desloca A para esquerda
                flag_c        = 1'b0;              // Não define carry explicitamente
                flag_v        = 1'b0;              // Sem overflow aritmético
            end

            3'b111: begin
                // -----------------------------------------------------------
                // Operação 111 — Deslocamento lógico à direita (LSR)
                // -----------------------------------------------------------
                resultado_out = a_in >> shift_amt; // Desloca A para direita
                flag_c        = 1'b0;              // Sem carry definido
                flag_v        = 1'b0;              // Sem overflow aritmético
            end

            default: begin
                // -----------------------------------------------------------
                // Caso padrão — valor de segurança
                // -----------------------------------------------------------
                resultado_out = 4'b0000;           // Força resultado nulo
                flag_c        = 1'b0;              // Flags desativadas
                flag_v        = 1'b0;
            end
        endcase

        // -------------------------------------------------------------------
        // Cálculo das flags Z (zero) e N (negativo) após a operação
        // -------------------------------------------------------------------
        flag_z = (resultado_out == 4'b0000); // Z é 1 quando resultado é zero
        flag_n = resultado_out[3];           // N copia o bit mais significativo
    end

endmodule
