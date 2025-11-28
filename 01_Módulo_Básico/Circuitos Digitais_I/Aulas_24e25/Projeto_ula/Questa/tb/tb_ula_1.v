// ============================================================================
// Arquivo  : tb_ula.v  (testbench para ULA Behavioral/Dataflow/Structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Comatível com Quartus e Questa (Verilog 2001)
// Descricao: Testbench auto-verificador para tres implementacoes da ULA.
//            Varre todo o espaco de entradas (op_a, op_b, seletor) e verifica
//            consistencia entre behavioral, dataflow e structural.
//            Para fins didaticos, imprime uma tabela reduzida (a<4, b<4)
//            contendo, para cada combinacao:
//              - a em decimal e binario
//              - b em decimal e binario
//              - seletor em decimal e binario
//              - resultado da abordagem behavioral em binario e decimal
//              - resultado esperado em binario e decimal
// Revisao  : v1.4 — tabela detalhada com colunas decimais e binarias
// ============================================================================

`timescale 1ns/1ps

module tb_ula;
    // -------------------------------------------------------------------------
    // Sinais de estimulo
    // -------------------------------------------------------------------------
    reg  [3:0] op_a;         // Operando A (4 bits)
    reg  [3:0] op_b;         // Operando B (4 bits)
    reg  [2:0] seletor;      // Codigo da operacao (3 bits)

    // Sinais de saida das tres abordagens
    wire [7:0] resultado_behavioral;  // Saida da ULA behavioral
    wire [7:0] resultado_dataflow;    // Saida da ULA dataflow
    wire [7:0] resultado_structural;  // Saida da ULA structural

    // Modelo de referencia
    reg  [7:0] resultado_esperado;    // Resultado esperado para comparacao

    // Contador de erros
    integer erro_count;               // Numero de divergencias encontradas

    // -------------------------------------------------------------------------
    // Instancias das tres ULAs
    // -------------------------------------------------------------------------
    ula_behavioral u_ula_behavioral (
        .op_a     (op_a),
        .op_b     (op_b),
        .seletor  (seletor),
        .resultado(resultado_behavioral)
    );

    ula_dataflow u_ula_dataflow (
        .op_a     (op_a),
        .op_b     (op_b),
        .seletor  (seletor),
        .resultado(resultado_dataflow)
    );

    ula_structural u_ula_structural (
        .op_a     (op_a),
        .op_b     (op_b),
        .seletor  (seletor),
        .resultado(resultado_structural)
    );

    // -------------------------------------------------------------------------
    // VCD para analise de formas de onda
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula);
    end

    // -------------------------------------------------------------------------
    // Geração de estímulos e verificação
    // -------------------------------------------------------------------------
    integer i; // indice para op_a
    integer j; // indice para op_b
    integer k; // indice para seletor

    initial begin
        erro_count = 0;

        // Cabecalho da tabela reduzida (com dec e bin)
        $display("-----------------------------------------------------------------------------------------------");
        $display(" a_dec | a_bin | b_dec | b_bin | sel_dec | sel_bin | res_beh(bin) | res_beh(dec) | res_exp(bin) | res_exp(dec)");
        $display("-----------------------------------------------------------------------------------------------");

        // Varre TODO o espaco de entradas (checa tudo)
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 8; k = k + 1) begin
                    op_a    = i[3:0];
                    op_b    = j[3:0];
                    seletor = k[2:0];

                    #1; // tempo de propagacao combinacional

                    // -----------------------------------------------------------------
                    // Modelo de referencia: mesma convencao das ULAs
                    // -----------------------------------------------------------------
                    case (seletor)
                        3'b000: begin
                            // AND: resultado em 4 bits, zero-extend para 8 bits
                            resultado_esperado = {4'b0000, (op_a & op_b)};
                        end
                        3'b001: begin
                            // OR: resultado em 4 bits, zero-extend
                            resultado_esperado = {4'b0000, (op_a | op_b)};
                        end
                        3'b010: begin
                            // NOT de op_a: 4 bits, zero-extend
                            resultado_esperado = {4'b0000, (~op_a)};
                        end
                        3'b011: begin
                            // NAND: ~(a & b), 4 bits, zero-extend
                            resultado_esperado = {4'b0000, ~(op_a & op_b)};
                        end
                        3'b100: begin
                            // Soma: truncada em 4 bits, zero-extend
                            resultado_esperado = {4'b0000, (op_a + op_b)};
                        end
                        3'b101: begin
                            // Subtracao: truncada em 4 bits, zero-extend
                            resultado_esperado = {4'b0000, (op_a - op_b)};
                        end
                        3'b110: begin
                            // Multiplicacao 4x4: produto completo em 8 bits
                            resultado_esperado = op_a * op_b;
                        end
                        3'b111: begin
                            // Divisao inteira com tratamento de divisor zero
                            if (op_b == 4'b0000) begin
                                // Convencao: quociente = 0, resto = op_a
                                resultado_esperado[3:0] = 4'b0000; // quociente
                                resultado_esperado[7:4] = op_a;    // resto
                            end else begin
                                resultado_esperado[3:0] = op_a / op_b; // quociente
                                resultado_esperado[7:4] = op_a % op_b; // resto
                            end
                        end
                        default: begin
                            // Caso default: zera o resultado
                            resultado_esperado = 8'b0000_0000;
                        end
                    endcase

                    // -----------------------------------------------------------------
                    // Verificacao das tres abordagens contra o modelo de referencia
                    // -----------------------------------------------------------------
                    if ((resultado_behavioral !== resultado_esperado) ||
                        (resultado_dataflow   !== resultado_esperado) ||
                        (resultado_structural !== resultado_esperado)) begin
                        erro_count = erro_count + 1;
                        $display("ERRO: a=%0d b=%0d sel=%0d | esp=%08b beh=%08b data=%08b str=%08b",
                                 op_a, op_b, seletor,
                                 resultado_esperado,
                                 resultado_behavioral,
                                 resultado_dataflow,
                                 resultado_structural);
                    end

                    // -----------------------------------------------------------------
                    // Impressao ENXUTA e DIDATICA:
                    // so alguns exemplos (a<4, b<4), mas ja cobrindo as 8 operacoes.
                    // Aqui mostramos decimal e binario para operandos, seletor
                    // e resultados (behavioral e esperado).
                    // -----------------------------------------------------------------
                    if ((op_a < 4) && (op_b < 4)) begin
                        $display("  %1d    | %04b |   %1d   | %04b |   %1d     |  %03b   |   %08b   |    %3d     |   %08b   |    %3d",
                                 op_a, op_a,
                                 op_b, op_b,
                                 seletor, seletor,
                                 resultado_behavioral,
                                 resultado_behavioral,
                                 resultado_esperado,
                                 resultado_esperado);
                    end
                end
            end
        end

        $display("-----------------------------------------------------------------------------------------------");

        // ---------------------------------------------------------------------
        // Relatorio final de erros / sucesso
        // ---------------------------------------------------------------------
        if (erro_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes para todas as combinacoes.");
        end else begin
            $display("FIM COM ERROS: Foram encontrados %0d casos com divergencias.", erro_count);
        end

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
