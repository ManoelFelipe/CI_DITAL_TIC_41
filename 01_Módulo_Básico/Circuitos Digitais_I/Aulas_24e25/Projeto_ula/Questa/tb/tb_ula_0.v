// ============================================================================
// Arquivo  : tb_ula.v  (testbench para ULA Behavioral/Dataflow/Structural)
// Autor    : Manoel Furtado
// Data     : 18/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao:
//   Testbench auto-verificador que varre todo o espaco de entradas da ULA
//   (op_a, op_b, seletor) e compara tres implementacoes (behavioral, dataflow,
//   structural) contra um modelo de referencia puramente combinacional.
//
//   Adicionalmente, imprime:
//     1) Uma tabela reduzida para a<4 e b<4, em decimal e binario, para todas
//        as operacoes (sel=0..7), facilitando a leitura didatica.
//     2) Uma tabela DIDATICA dedicada para o par fixo a=3, b=5, detalhando
//        todas as 8 operacoes, com nome textual, resultado binario e decimal.
//
// Revisao : v2.1 — correcao de declaracoes internas e documentacao detalhada.
// ============================================================================

`timescale 1ns/1ps               // Define unidade de tempo e precisao para simulacao

module tb_ula;                    // Inicio do modulo de testbench tb_ula

    // -------------------------------------------------------------------------
    // Declaracao de sinais de estimulo (entradas da ULA)
    // -------------------------------------------------------------------------
    reg  [3:0] op_a;              // Operando A de 4 bits (0 a 15)
    reg  [3:0] op_b;              // Operando B de 4 bits (0 a 15)
    reg  [2:0] seletor;           // Codigo da operacao (0 a 7)

    // -------------------------------------------------------------------------
    // Sinais de saida das tres implementacoes
    // -------------------------------------------------------------------------
    wire [7:0] resultado_behavioral; // Saida da ULA behavioral
    wire [7:0] resultado_dataflow;   // Saida da ULA dataflow
    wire [7:0] resultado_structural; // Saida da ULA structural

    // -------------------------------------------------------------------------
    // Modelo de referencia e variaveis auxiliares
    // -------------------------------------------------------------------------
    reg  [7:0] resultado_esperado;   // Resultado calculado pelo modelo de referencia
    integer    erro_count;           // Contador de divergencias encontradas

    // Variavel para nome textual da operacao no bloco didatico (ate 7 caracteres)
    reg [7*8-1:0] nome_operacao;     // Armazena string da operacao para impressao

    // -------------------------------------------------------------------------
    // Instancias das tres ULAs em teste
    // -------------------------------------------------------------------------
    ula_behavioral u_ula_behavioral ( // Instancia da ULA behavioral
        .op_a     (op_a),             // Conecta operando A
        .op_b     (op_b),             // Conecta operando B
        .seletor  (seletor),          // Conecta seletor de operacao
        .resultado(resultado_behavioral) // Conecta saida behavioral
    );

    ula_dataflow u_ula_dataflow (     // Instancia da ULA dataflow
        .op_a     (op_a),             // Conecta operando A
        .op_b     (op_b),             // Conecta operando B
        .seletor  (seletor),          // Conecta seletor de operacao
        .resultado(resultado_dataflow) // Conecta saida dataflow
    );

    ula_structural u_ula_structural ( // Instancia da ULA structural
        .op_a     (op_a),             // Conecta operando A
        .op_b     (op_b),             // Conecta operando B
        .seletor  (seletor),          // Conecta seletor de operacao
        .resultado(resultado_structural) // Conecta saida structural
    );

    // -------------------------------------------------------------------------
    // Geracao do arquivo de formas de onda (VCD)
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");        // Nome do arquivo VCD a ser gerado
        $dumpvars(0, tb_ula);         // Registra todos os sinais do testbench
    end

    // -------------------------------------------------------------------------
    // Bloco principal de estimulo e verificacao
    // -------------------------------------------------------------------------
    integer i;                        // Indice para varrer op_a
    integer j;                        // Indice para varrer op_b
    integer k;                        // Indice para varrer seletor

    initial begin
        erro_count = 0;               // Inicializa contador de erros com zero

        // Cabecalho da tabela reduzida (a<4, b<4) com dec e bin
        $display("-------------------------------------------------------------------------------------------------------------");
        $display(" a_dec | a_bin | b_dec | b_bin | sel_dec | sel_bin | res_beh(bin) | res_beh(dec) | res_exp(bin) | res_exp(dec)");
        $display("-------------------------------------------------------------------------------------------------------------");

        // ---------------------------------------------------------------------
        // Varredura completa do espaco de entradas:
        //   op_a    : 0 a 15
        //   op_b    : 0 a 15
        //   seletor : 0 a 7
        // ---------------------------------------------------------------------
        for (i = 0; i < 16; i = i + 1) begin
            // Loop externo: percorre todos os valores possiveis de op_a
            for (j = 0; j < 16; j = j + 1) begin
                // Loop intermediario: percorre todos os valores possiveis de op_b
                for (k = 0; k < 8; k = k + 1) begin
                    // Loop interno: percorre todos os codigos de operacao (seletor)

                    op_a    = i[3:0]; // Atribui os 4 LSB de i para op_a
                    op_b    = j[3:0]; // Atribui os 4 LSB de j para op_b
                    seletor = k[2:0]; // Atribui os 3 LSB de k para seletor

                    #1;               // Aguarda 1ns para propagacao combinacional

                    // ---------------------------------------------------------
                    // Modelo de referencia da ULA (mesma semantica das ULAs)
                    // ---------------------------------------------------------
                    case (seletor)
                        3'b000: begin
                            // Operacao 0: AND entre op_a e op_b (4 bits),
                            // estendida para 8 bits com zeros nos MSBs.
                            resultado_esperado = {4'b0000, (op_a & op_b)};
                        end
                        3'b001: begin
                            // Operacao 1: OR entre op_a e op_b (4 bits),
                            // estendida para 8 bits.
                            resultado_esperado = {4'b0000, (op_a | op_b)};
                        end
                        3'b010: begin
                            // Operacao 2: NOT de op_a (4 bits),
                            // estendida para 8 bits.
                            resultado_esperado = {4'b0000, (~op_a)};
                        end
                        3'b011: begin
                            // Operacao 3: NAND entre op_a e op_b (4 bits),
                            // estendida para 8 bits.
                            resultado_esperado = {4'b0000, ~(op_a & op_b)};
                        end
                        3'b100: begin
                            // Operacao 4: SOMA (op_a + op_b) em 4 bits,
                            // truncada naturalmente e estendida para 8 bits.
                            resultado_esperado = {4'b0000, (op_a + op_b)};
                        end
                        3'b101: begin
                            // Operacao 5: SUBTRACAO (op_a - op_b) em 4 bits,
                            // tambem truncada e estendida para 8 bits.
                            resultado_esperado = {4'b0000, (op_a - op_b)};
                        end
                        3'b110: begin
                            // Operacao 6: MULTIPLICACAO 4x4,
                            // resultado completo em 8 bits.
                            resultado_esperado = op_a * op_b;
                        end
                        3'b111: begin
                            // Operacao 7: DIVISAO inteira com resto.
                            // Convencao:
                            //   resultado[3:0] = quociente
                            //   resultado[7:4] = resto
                            // Caso especial divisor zero:
                            //   quociente = 0, resto = op_a.
                            if (op_b == 4'b0000) begin
                                resultado_esperado[3:0] = 4'b0000; // quociente
                                resultado_esperado[7:4] = op_a;    // resto
                            end else begin
                                resultado_esperado[3:0] = op_a / op_b; // quociente
                                resultado_esperado[7:4] = op_a % op_b; // resto
                            end
                        end
                        default: begin
                            // Caso default (na pratica nao alcancado):
                            // resultado forcado para zero.
                            resultado_esperado = 8'b0000_0000;
                        end
                    endcase

                    // ---------------------------------------------------------
                    // Comparacao das tres implementacoes com o modelo
                    // ---------------------------------------------------------
                    if ((resultado_behavioral !== resultado_esperado) ||
                        (resultado_dataflow   !== resultado_esperado) ||
                        (resultado_structural !== resultado_esperado)) begin
                        // Se qualquer implementacao divergir, incrementa o contador
                        erro_count = erro_count + 1;
                        // Imprime relatorio detalhado de erro
                        $display("ERRO: a=%0d b=%0d sel=%0d | esp=%08b beh=%08b data=%08b str=%08b",
                                 op_a, op_b, seletor,
                                 resultado_esperado,
                                 resultado_behavioral,
                                 resultado_dataflow,
                                 resultado_structural);
                    end

                    // ---------------------------------------------------------
                    // Impressao ENXUTA e DIDATICA:
                    // apenas para a<4 e b<4, cobrindo todas as operacoes.
                    // Mostra a, b e seletor em decimal e binario, alem dos
                    // resultados da abordagem behavioral e do modelo.
                    // ---------------------------------------------------------
                    if ((op_a < 4) && (op_b < 4)) begin
                        $display("  %1d    | %04b |   %1d   | %04b |    %1d    |  %03b   |   %08b   |   %3d    |   %08b   |   %3d",
                                 op_a, op_a,                // a em dec e bin
                                 op_b, op_b,                // b em dec e bin
                                 seletor, seletor,          // seletor em dec e bin
                                 resultado_behavioral,      // resultado behavioral (bin)
                                 resultado_behavioral,      // resultado behavioral (dec)
                                 resultado_esperado,        // resultado esperado (bin)
                                 resultado_esperado);       // resultado esperado (dec)
                    end
                end
            end
        end

        // Linha de separacao apos a tabela reduzida
        $display("-------------------------------------------------------------------------------------------------------------");

        // Relatorio final de consistencia das implementacoes
        if (erro_count == 0) begin
            // Nenhum erro encontrado
            $display("SUCESSO: Todas as implementacoes estao consistentes em todas as combinacoes.");
        end else begin
            // Pelo menos uma divergencia detectada
            $display("FIM COM ERROS: %0d divergencias encontradas.", erro_count);
        end

        // =====================================================================
        // BLOCO DIDATICO: TABELA COMPLETA PARA a=3, b=5 E TODAS AS OPERACOES
        // =====================================================================

        // Ajusta op_a e op_b para os valores fixos da demonstracao
        op_a = 4'd3;                      // Define a = 3 (0011)
        op_b = 4'd5;                      // Define b = 5 (0101)

        // Cabecalho da tabela didatica
        $display("\n");
        $display("===============================================");
        $display("  TABELA DIDATICA COMPLETA PARA a=3 (0011), b=5 (0101)");
        $display("===============================================\n");

        $display(" a_dec | a_bin | b_dec | b_bin | sel_dec | sel_bin | operacao | res_beh(bin) | res_beh(dec) | res_exp(bin) | res_exp(dec)");
        $display("--------------------------------------------------------------------------------------------------------------------------");

        // Loop apenas sobre o seletor (0..7) para o par fixo (a=3, b=5)
        for (k = 0; k < 8; k = k + 1) begin
            seletor = k[2:0];             // Define o codigo da operacao
            #1;                           // Aguarda propagacao combinacional

            // Recalcula o modelo de referencia para este par fixo (a=3, b=5)
            case (seletor)
                3'b000: resultado_esperado = {4'b0000, (op_a & op_b)}; // AND
                3'b001: resultado_esperado = {4'b0000, (op_a | op_b)}; // OR
                3'b010: resultado_esperado = {4'b0000, (~op_a)};       // NOT(a)
                3'b011: resultado_esperado = {4'b0000, ~(op_a & op_b)};// NAND
                3'b100: resultado_esperado = {4'b0000, (op_a + op_b)}; // ADD
                3'b101: resultado_esperado = {4'b0000, (op_a - op_b)}; // SUB
                3'b110: resultado_esperado = op_a * op_b;              // MUL
                3'b111: begin                                          // DIV
                    if (op_b == 4'b0000) begin
                        resultado_esperado[3:0] = 4'b0000;             // quociente
                        resultado_esperado[7:4] = op_a;                // resto
                    end else begin
                        resultado_esperado[3:0] = op_a / op_b;         // quociente
                        resultado_esperado[7:4] = op_a % op_b;         // resto
                    end
                end
                default: resultado_esperado = 8'b0000_0000;            // Seguranca
            endcase

            // Define nome textual da operacao para impressao
            case (seletor)
                3'b000: nome_operacao = "AND";
                3'b001: nome_operacao = "OR";
                3'b010: nome_operacao = "NOT(a)";
                3'b011: nome_operacao = "NAND";
                3'b100: nome_operacao = "ADD";
                3'b101: nome_operacao = "SUB";
                3'b110: nome_operacao = "MUL";
                3'b111: nome_operacao = "DIV";
                default: nome_operacao = "???";
            endcase

            // Impressao da linha da tabela didatica para o seletor atual
            $display("  %1d    | %04b |   %1d   | %04b |    %1d    |  %03b   | %-7s |   %08b   |   %3d    |   %08b   |   %3d",
                     op_a, op_a,                 // a em dec e bin
                     op_b, op_b,                 // b em dec e bin
                     seletor, seletor,           // seletor em dec e bin
                     nome_operacao,              // nome textual da operacao
                     resultado_behavioral,       // resultado behavioral (bin)
                     resultado_behavioral,       // resultado behavioral (dec)
                     resultado_esperado,         // resultado esperado (bin)
                     resultado_esperado);        // resultado esperado (dec)
        end

        // Linha final de separacao e encerramento
        $display("--------------------------------------------------------------------------------------------------------------------------");
        $display("Fim da simulacao."); // Mensagem final de encerramento

        $finish;                          // Encerra a simulacao
    end

endmodule
