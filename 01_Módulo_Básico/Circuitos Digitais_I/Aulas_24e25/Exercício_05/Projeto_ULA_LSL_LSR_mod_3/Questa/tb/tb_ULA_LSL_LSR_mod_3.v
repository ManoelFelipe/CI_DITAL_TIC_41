    // ============================================================================
    // Arquivo  : tb_ULA_LSL_LSR_mod_3.v  — Testbench para ULA_LSL_LSR_mod_3
    // Autor    : Manoel Furtado
    // Data     : 15/11/2025
    // Ferramentas: Compatível com Questa (Verilog 2001)
    // Descrição: Testbench combinacional com varredura exaustiva de todos os
    //            operandos A, B e códigos de operação op_sel (4 bits). Verifica
    //            resultado e flags C, V, Z e N contra um modelo de referência
    //            interno, incluindo as novas operações NOR e XOR. Gera VCD para
    //            inspeção de formas de onda e imprime resumo de erros.
    // Revisão   : v1.0 — criação inicial
    // ============================================================================

    `timescale 1ns/1ps

    // -----------------------------------------------------------------------------
    // Testbench principal
    // -----------------------------------------------------------------------------
    module tb_ULA_LSL_LSR_mod_3;

        // Declaração dos sinais de estímulo
        reg  [3:0] a_in;            // Operando A estimulado
        reg  [3:0] b_in;            // Operando B estimulado
        reg  [3:0] op_sel;          // Código de operação estimulado (4 bits)

        // Declaração dos sinais de saída observados
        wire [3:0] resultado_out;   // Resultado da ULA
        wire       flag_c;          // Flag C observada
        wire       flag_v;          // Flag V observada
        wire       flag_z;          // Flag Z observada
        wire       flag_n;          // Flag N observada

        // Sinais de referência (modelo ouro)
        reg  [3:0] ref_resultado;   // Resultado esperado
        reg        ref_c;           // Flag C esperada
        reg        ref_v;           // Flag V esperada
        reg        ref_z;           // Flag Z esperada
        reg        ref_n;           // Flag N esperada

        integer erros;              // Contador de erros encontrados
        integer total_tests;        // Contador de vetores aplicados

        // Índices dos laços
        integer i_op;               // índice para op_sel (0..15)
        integer i_a;                // índice para a_in  (0..15)
        integer i_b;                // índice para b_in  (0..15)

        // -------------------------------------------------------------------------
        // Instância do DUT (Device Under Test)
        // -------------------------------------------------------------------------
        ULA_LSL_LSR_mod_3 dut (
            .a_in         (a_in),
            .b_in         (b_in),
            .op_sel       (op_sel),
            .resultado_out(resultado_out),
            .flag_c       (flag_c),
            .flag_v       (flag_v),
            .flag_z       (flag_z),
            .flag_n       (flag_n)
        );

        // -------------------------------------------------------------------------
        // Geração de VCD para análise das formas de onda
        // -------------------------------------------------------------------------
        initial begin
            $dumpfile("wave.vcd");                       // Nome do arquivo VCD
            $dumpvars(0, tb_ULA_LSL_LSR_mod_3);          // Registra todos os sinais
        end

        // -------------------------------------------------------------------------
        // Tarefa de cálculo do modelo de referência
        // -------------------------------------------------------------------------
        task automatic calcula_referencia;
            input  [3:0] a_val;      // Valor de A recebido
            input  [3:0] b_val;      // Valor de B recebido
            input  [3:0] op_val;     // Código da operação recebida (4 bits)
            output [3:0] res_ref;    // Resultado de referência
            output       c_ref;      // Flag C de referência
            output       v_ref;      // Flag V de referência
            output       z_ref;      // Flag Z de referência
            output       n_ref;      // Flag N de referência

            reg  [4:0] add_ext;      // Soma estendida em 5 bits
            reg  [4:0] sub_ext;      // Subtração estendida em 5 bits
            reg  [2:0] shift_amt;    // Fator de deslocamento saturado

            begin
                // Fator de deslocamento saturado em 4
                if (b_val[2:0] > 3'd4) begin
                    shift_amt = 3'd4;
                end else begin
                    shift_amt = b_val[2:0];
                end

                // Valores padrão
                res_ref = 4'b0000;
                c_ref   = 1'b0;
                v_ref   = 1'b0;
                z_ref   = 1'b0;
                n_ref   = 1'b0;

                // Seleção da operação de referência
                case (op_val)
                    4'b0000: begin
                        // AND bit a bit
                        res_ref = a_val & b_val;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b0001: begin
                        // OR bit a bit
                        res_ref = a_val | b_val;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b0010: begin
                        // NOT de A
                        res_ref = ~a_val;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b0011: begin
                        // NAND bit a bit
                        res_ref = ~(a_val & b_val);
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b0100: begin
                        // Soma A + B
                        add_ext = {1'b0, a_val} + {1'b0, b_val};
                        res_ref = add_ext[3:0];
                        c_ref   = add_ext[4];                          // Carry-out
                        v_ref   = (~(a_val[3] ^ b_val[3])) &           // Mesma polaridade
                                  (res_ref[3] ^ a_val[3]);             // Sinal inesperado
                    end
                    4'b0101: begin
                        // Subtração A - B
                        sub_ext = {1'b0, a_val} - {1'b0, b_val};
                        res_ref = sub_ext[3:0];
                        c_ref   = ~sub_ext[4];                         // C = ~borrow
                        v_ref   = (a_val[3] ^ b_val[3]) &              // Entradas com sinais opostos
                                  (res_ref[3] ^ a_val[3]);             // Resultado com sinal inesperado
                    end
                    4'b0110: begin
                        // Deslocamento lógico à esquerda
                        res_ref = a_val << shift_amt;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b0111: begin
                        // Deslocamento lógico à direita
                        res_ref = a_val >> shift_amt;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b1000: begin
                        // NOR bit a bit
                        res_ref = ~(a_val | b_val);
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    4'b1001: begin
                        // XOR bit a bit
                        res_ref = a_val ^ b_val;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                    default: begin
                        // Códigos não utilizados — resultado nulo
                        res_ref = 4'b0000;
                        c_ref   = 1'b0;
                        v_ref   = 1'b0;
                    end
                endcase

                // Flags Z e N calculadas a partir do resultado
                z_ref = (res_ref == 4'b0000);
                n_ref = res_ref[3];
            end
        endtask

        // -------------------------------------------------------------------------
        // Bloco principal de estímulos
        // -------------------------------------------------------------------------
        initial begin
            // Inicializa contadores
            erros       = 0;
            total_tests = 0;

            // Percorre todas as combinações de op_sel, A e B
            for (i_op = 0; i_op < 16; i_op = i_op + 1) begin
                op_sel = i_op[3:0];            // converte índice para 4 bits

                for (i_a = 0; i_a < 16; i_a = i_a + 1) begin
                    a_in = i_a[3:0];           // converte índice para 4 bits

                    for (i_b = 0; i_b < 16; i_b = i_b + 1) begin
                        b_in = i_b[3:0];       // converte índice para 4 bits

                        // Aguarda propagação combinacional
                        #1;

                        // Calcula valores de referência para o trio atual
                        calcula_referencia(a_in, b_in, op_sel,
                                           ref_resultado, ref_c, ref_v, ref_z, ref_n);

                        // Incrementa contador de testes
                        total_tests = total_tests + 1;

                        // Compara resultado e flags do DUT com o modelo ouro
                        if ((resultado_out !== ref_resultado) ||
                            (flag_c        !== ref_c)        ||
                            (flag_v        !== ref_v)        ||
                            (flag_z        !== ref_z)        ||
                            (flag_n        !== ref_n)) begin
                            // Mensagem detalhada em caso de divergência
                            $display("ERRO: op_sel=%b A=%b B=%b | DUT=(R=%b C=%b V=%b Z=%b N=%b) | REF=(R=%b C=%b V=%b Z=%b N=%b)",
                                     op_sel, a_in, b_in,
                                     resultado_out, flag_c, flag_v, flag_z, flag_n,
                                     ref_resultado, ref_c, ref_v, ref_z, ref_n);
                            erros = erros + 1;
                        end
                    end
                end
            end

            // Resumo final de verificação
            $display("====================================================");
            $display(" Testbench tb_ULA_LSL_LSR_mod_3 — RESUMO ");
            $display(" Vetores aplicados : %0d", total_tests);
            $display(" Erros encontrados  : %0d", erros);
            if (erros == 0) begin
                $display(" STATUS: TODOS OS TESTES PASSARAM.");
            end else begin
                $display(" STATUS: FALHAS DETECTADAS NA IMPLEMENTACAO.");
            end
            $display("====================================================");

            $display("Fim da simulacao.");
            $finish;
        end

    endmodule
