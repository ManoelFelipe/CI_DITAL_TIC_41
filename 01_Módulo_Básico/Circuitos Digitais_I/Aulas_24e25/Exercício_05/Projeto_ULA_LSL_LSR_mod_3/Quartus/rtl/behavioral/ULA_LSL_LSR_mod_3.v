    // ============================================================================
    // Arquivo  : ULA_LSL_LSR_mod_3.v  (implementação behavioral)
    // Autor    : Manoel Furtado
    // Data     : 15/11/2025
    // Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
    // Descrição: Unidade Lógica e Aritmética (ULA) combinacional de 4 bits, com
    //            suporte a dez operações (AND, OR, NOT, NAND, NOR, XOR, soma,
    //            subtração, deslocamento lógico à esquerda e à direita). A
    //            palavra de seleção op_sel foi expandida para 4 bits, mantendo
    //            compatibilidade com os oito códigos originais e acrescentando
    //            NOR e XOR. Gera flags C, V, Z e N com latência zero, adequada
    //            para síntese em FPGAs e implementação em datapaths simples.
    // Revisão   : v1.0 — criação inicial
    // ============================================================================

    `timescale 1ns/1ps

    // ---------------------------------------------------------------------------
    // Módulo principal — implementação comportamental
    // ---------------------------------------------------------------------------
    module ULA_LSL_LSR_mod_3 (
        input  wire [3:0] a_in,          // Operando A de 4 bits
        input  wire [3:0] b_in,          // Operando B de 4 bits
        input  wire [3:0] op_sel,        // Código de operação (4 bits)
        output reg  [3:0] resultado_out, // Resultado da operação selecionada
        output reg        flag_c,        // Flag C — carry / borrow
        output reg        flag_v,        // Flag V — overflow em complemento de dois
        output reg        flag_z,        // Flag Z — resultado igual a zero
        output reg        flag_n         // Flag N — bit de sinal do resultado
    );

        // Registrador para guardar o fator de deslocamento saturado
        reg [2:0] shift_amt;             // Fator de deslocamento (0..4)

        // Registradores auxiliares para operações aritméticas estendidas
        reg [4:0] add_ext;               // Soma estendida em 5 bits
        reg [4:0] sub_ext;               // Subtração estendida em 5 bits

        // -----------------------------------------------------------------------
        // Bloco combinacional principal — descrição comportamental
        // -----------------------------------------------------------------------
        always @* begin
            // -------------------------------------------------------------------
            // Inicialização de valores padrão para evitar inferência de latches
            // -------------------------------------------------------------------
            resultado_out = 4'b0000;     // Resultado padrão
            flag_c        = 1'b0;        // Carry padrão
            flag_v        = 1'b0;        // Overflow padrão
            flag_z        = 1'b0;        // Z será recalculado ao final
            flag_n        = 1'b0;        // N será recalculado ao final

            // -------------------------------------------------------------------
            // Cálculo do fator de deslocamento saturado
            // -------------------------------------------------------------------
            if (b_in[2:0] > 3'd4) begin
                // Se B excede 4, força saturação em 4 posições
                shift_amt = 3'd4;
            end else begin
                // Caso contrário, usa diretamente os 3 bits menos significativos
                shift_amt = b_in[2:0];
            end

            // -------------------------------------------------------------------
            // Seleção da operação principal da ULA
            // -------------------------------------------------------------------
            case (op_sel)
                4'b0000: begin
                    // -----------------------------------------------------------
                    // Operação 0000 — AND bit a bit entre A e B
                    // -----------------------------------------------------------
                    resultado_out = a_in & b_in;  // AND dos quatro bits
                    flag_c        = 1'b0;         // Sem carry em operações lógicas
                    flag_v        = 1'b0;         // Sem overflow em operações lógicas
                end

                4'b0001: begin
                    // -----------------------------------------------------------
                    // Operação 0001 — OR bit a bit entre A e B
                    // -----------------------------------------------------------
                    resultado_out = a_in | b_in;  // OR dos quatro bits
                    flag_c        = 1'b0;         // Sem carry
                    flag_v        = 1'b0;         // Sem overflow
                end

                4'b0010: begin
                    // -----------------------------------------------------------
                    // Operação 0010 — NOT do operando A
                    // -----------------------------------------------------------
                    resultado_out = ~a_in;        // Inverte todos os bits de A
                    flag_c        = 1'b0;         // Sem carry
                    flag_v        = 1'b0;         // Sem overflow
                end

                4'b0011: begin
                    // -----------------------------------------------------------
                    // Operação 0011 — NAND bit a bit entre A e B
                    // -----------------------------------------------------------
                    resultado_out = ~(a_in & b_in); // NAND dos quatro bits
                    flag_c        = 1'b0;           // Sem carry
                    flag_v        = 1'b0;           // Sem overflow
                end

                4'b0100: begin
                    // -----------------------------------------------------------
                    // Operação 0100 — Soma A + B (4 bits)
                    // -----------------------------------------------------------
                    add_ext       = {1'b0, a_in} + {1'b0, b_in}; // Soma estendida
                    resultado_out = add_ext[3:0];                // Resultado truncado
                    flag_c        = add_ext[4];                  // Carry-out sem sinal
                    flag_v        = (~(a_in[3] ^ b_in[3])) &     // Entradas com mesmo sinal
                                     (resultado_out[3] ^ a_in[3]); // Resultado com sinal diferente
                end

                4'b0101: begin
                    // -----------------------------------------------------------
                    // Operação 0101 — Subtração A - B (4 bits)
                    // -----------------------------------------------------------
                    sub_ext       = {1'b0, a_in} - {1'b0, b_in}; // Subtração estendida
                    resultado_out = sub_ext[3:0];                // Resultado truncado
                    flag_c        = ~sub_ext[4];                 // Carry = ~borrow (convenção)
                    flag_v        = (a_in[3] ^ b_in[3]) &        // Entradas com sinais opostos
                                     (resultado_out[3] ^ a_in[3]); // Resultado com sinal inesperado
                end

                4'b0110: begin
                    // -----------------------------------------------------------
                    // Operação 0110 — Deslocamento lógico à esquerda (LSL)
                    // -----------------------------------------------------------
                    resultado_out = a_in << shift_amt; // Desloca A para a esquerda
                    flag_c        = 1'b0;              // Não mede bits descartados
                    flag_v        = 1'b0;              // Sem overflow aritmético
                end

                4'b0111: begin
                    // -----------------------------------------------------------
                    // Operação 0111 — Deslocamento lógico à direita (LSR)
                    // -----------------------------------------------------------
                    resultado_out = a_in >> shift_amt; // Desloca A para a direita
                    flag_c        = 1'b0;              // Não mede bits descartados
                    flag_v        = 1'b0;              // Sem overflow aritmético
                end

                4'b1000: begin
                    // -----------------------------------------------------------
                    // Operação 1000 — NOR bit a bit entre A e B
                    // -----------------------------------------------------------
                    resultado_out = ~(a_in | b_in); // NOR de quatro bits
                    flag_c        = 1'b0;           // Operação lógica — sem carry
                    flag_v        = 1'b0;           // Operação lógica — sem overflow
                end

                4'b1001: begin
                    // -----------------------------------------------------------
                    // Operação 1001 — XOR bit a bit entre A e B
                    // -----------------------------------------------------------
                    resultado_out = a_in ^ b_in; // XOR de quatro bits
                    flag_c        = 1'b0;        // Operação lógica — sem carry
                    flag_v        = 1'b0;        // Operação lógica — sem overflow
                end

                default: begin
                    // -----------------------------------------------------------
                    // Demais códigos de operação — resultado nulo
                    // -----------------------------------------------------------
                    resultado_out = 4'b0000;     // Força resultado nulo
                    flag_c        = 1'b0;        // Flags limpas
                    flag_v        = 1'b0;
                end
            endcase

            // -------------------------------------------------------------------
            // Cálculo das flags Z (zero) e N (negativo) após a operação
            // -------------------------------------------------------------------
            flag_z = (resultado_out == 4'b0000); // Z = 1 se resultado é zero
            flag_n = resultado_out[3];           // N copia o bit mais significativo
        end

    endmodule
