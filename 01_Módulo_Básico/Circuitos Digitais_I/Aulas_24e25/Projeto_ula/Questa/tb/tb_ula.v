// ============================================================================
// Arquivo  : tb_ula.v  (testbench para ULA Behavioral/Dataflow/Structural)
// Autor    : Manoel Furtado
// Data     : 18/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao:
//   Testbench auto-verificador que varre todo o espaco de entradas da ULA
//   (op_a, op_b, seletor) e compara tres implementacoes (behavioral, dataflow,
//   structural) contra um modelo de referencia combinacional.
//
//   Saidas principais:
//     1) Tabela reduzida (a<4, b<4) em decimal e binario.
//     2) TABELA DIDATICA 1: a = 3, b = 5, sel = 0..7, com nome de operacao.
//     3) TABELA DIDATICA 2: a = 6, b = 3, sel = 0..7, com nome de operacao.
//
// Revisao : v2.2 — adicionada segunda tabela didatica (a=6, b=3).
// ============================================================================

`timescale 1ns/1ps               // Define unidade de tempo e precisao

module tb_ula;                    // Inicio do modulo de testbench

    // -------------------------------------------------------------------------
    // Sinais de estimulo (entradas da ULA)
    // -------------------------------------------------------------------------
    reg  [3:0] op_a;              // Operando A (4 bits)
    reg  [3:0] op_b;              // Operando B (4 bits)
    reg  [2:0] seletor;           // Codigo da operacao (0..7)

    // -------------------------------------------------------------------------
    // Sinais de saida das tres implementacoes
    // -------------------------------------------------------------------------
    wire [7:0] resultado_behavioral; // Saida da ULA behavioral
    wire [7:0] resultado_dataflow;   // Saida da ULA dataflow
    wire [7:0] resultado_structural; // Saida da ULA structural

    // -------------------------------------------------------------------------
    // Modelo de referencia e auxiliares
    // -------------------------------------------------------------------------
    reg  [7:0] resultado_esperado;   // Resultado esperado (modelo)
    integer    erro_count;           // Contador de divergencias

    // Nome textual da operacao (string ate 7 caracteres)
    reg [7*8-1:0] nome_operacao;     // Ex.: "AND", "OR", "MUL", etc.

    // -------------------------------------------------------------------------
    // Instancias das tres ULAs
    // -------------------------------------------------------------------------
    ula_behavioral u_ula_behavioral (
        .op_a     (op_a),            // Conecta operando A
        .op_b     (op_b),            // Conecta operando B
        .seletor  (seletor),         // Conecta seletor
        .resultado(resultado_behavioral) // Saida behavioral
    );

    ula_dataflow u_ula_dataflow (
        .op_a     (op_a),            // Conecta operando A
        .op_b     (op_b),            // Conecta operando B
        .seletor  (seletor),         // Conecta seletor
        .resultado(resultado_dataflow)   // Saida dataflow
    );

    ula_structural u_ula_structural (
        .op_a     (op_a),            // Conecta operando A
        .op_b     (op_b),            // Conecta operando B
        .seletor  (seletor),         // Conecta seletor
        .resultado(resultado_structural) // Saida structural
    );

    // -------------------------------------------------------------------------
    // Geracao do arquivo de formas de onda (VCD)
    // -------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");       // Arquivo destino VCD
        $dumpvars(0, tb_ula);        // Registra todos os sinais do testbench
    end

    // -------------------------------------------------------------------------
    // Bloco principal: varredura completa + tabelas didaticas
    // -------------------------------------------------------------------------
    integer i;                       // Indice para op_a
    integer j;                       // Indice para op_b
    integer k;                       // Indice para seletor

    initial begin
        erro_count = 0;              // Zera contador de erros

        // ---------------------------------------------------------------------
        // TABELA REDUZIDA: mostra apenas a<4 e b<4, mas o teste e completo
        // ---------------------------------------------------------------------
        $display("-------------------------------------------------------------------------------------------------------------");
        $display(" a_dec | a_bin | b_dec | b_bin | sel_dec | sel_bin | res_beh(bin) | res_beh(dec) | res_exp(bin) | res_exp(dec)");
        $display("-------------------------------------------------------------------------------------------------------------");

        // Varre todo o espaco de entradas
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 8; k = k + 1) begin
                    op_a    = i[3:0];   // Atribui op_a
                    op_b    = j[3:0];   // Atribui op_b
                    seletor = k[2:0];   // Atribui seletor

                    #1;                 // Tempo de propagacao combinacional

                    // Modelo de referencia
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
                        default: resultado_esperado = 8'b0000_0000;           // Seguranca
                    endcase

                    // Verificacao das tres ULAs
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

                    // Impressao reduzida apenas para a<4, b<4
                    if ((op_a < 4) && (op_b < 4)) begin
                        $display("  %1d    | %04b |   %1d   | %04b |    %1d    |  %03b   |   %08b   |   %3d    |   %08b   |   %3d",
                                 op_a, op_a,                  // a_dec, a_bin
                                 op_b, op_b,                  // b_dec, b_bin
                                 seletor, seletor,            // sel_dec, sel_bin
                                 resultado_behavioral,        // res_beh bin
                                 resultado_behavioral,        // res_beh dec
                                 resultado_esperado,          // res_exp bin
                                 resultado_esperado);         // res_exp dec
                    end
                end
            end
        end

        $display("-------------------------------------------------------------------------------------------------------------");

        // Relatorio geral de consistencia
        if (erro_count == 0)
            $display("SUCESSO: Todas as implementacoes estao consistentes em todas as combinacoes.");
        else
            $display("FIM COM ERROS: %0d divergencias encontradas.", erro_count);

        // =====================================================================
        // TABELA DIDATICA 1: a = 3, b = 5
        // =====================================================================

        op_a = 4'd3;                     // Fixa a = 3 (0011)
        op_b = 4'd5;                     // Fixa b = 5 (0101)

        $display("\n");
        $display("========================================================");
        $display("  TABELA DIDATICA 1 — a = 3 (0011), b = 5 (0101)");
        $display("========================================================\n");

        $display(" a_dec | a_bin | b_dec | b_bin | sel_dec | sel_bin | operacao | res_beh(bin) | res_beh(dec) | res_exp(bin) | res_exp(dec)");
        $display("--------------------------------------------------------------------------------------------------------------------------");

        for (k = 0; k < 8; k = k + 1) begin
            seletor = k[2:0];            // Define operacao
            #1;                          // Propagacao

            // Modelo de referencia para (a=3, b=5)
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
                default: resultado_esperado = 8'b0000_0000;
            endcase

            // Nome da operacao (string)
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

            // Impressao da linha correspondente
            $display("  %1d    | %04b |   %1d   | %04b |    %1d    |  %03b   | %-7s |   %08b   |   %3d    |   %08b   |   %3d",
                     op_a, op_a,               // a_dec, a_bin
                     op_b, op_b,               // b_dec, b_bin
                     seletor, seletor,         // sel_dec, sel_bin
                     nome_operacao,            // texto da operacao
                     resultado_behavioral,     // res_beh bin
                     resultado_behavioral,     // res_beh dec
                     resultado_esperado,       // res_exp bin
                     resultado_esperado);      // res_exp dec
        end

        $display("--------------------------------------------------------------------------------------------------------------------------");

        // =====================================================================
        // TABELA DIDATICA 2: a = 6, b = 3
        // =====================================================================

        op_a = 4'd6;                     // Fixa a = 6 (0110)
        op_b = 4'd3;                     // Fixa b = 3 (0011)

        $display("\n");
        $display("========================================================");
        $display("  TABELA DIDATICA 2 — a = 6 (0110), b = 3 (0011)");
        $display("========================================================\n");

        $display(" a_dec | a_bin | b_dec | b_bin | sel_dec | sel_bin | operacao | res_beh(bin) | res_beh(dec) | res_exp(bin) | res_exp(dec)");
        $display("--------------------------------------------------------------------------------------------------------------------------");

        for (k = 0; k < 8; k = k + 1) begin
            seletor = k[2:0];            // Define operacao
            #1;                          // Propagacao

            // Modelo de referencia para (a=6, b=3)
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
                default: resultado_esperado = 8'b0000_0000;
            endcase

            // Nome da operacao (mesma tabela de antes)
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

            // Impressao da linha da segunda tabela
            $display("  %1d    | %04b |   %1d   | %04b |    %1d    |  %03b   | %-7s |   %08b   |   %3d    |   %08b   |   %3d",
                     op_a, op_a,               // a_dec, a_bin
                     op_b, op_b,               // b_dec, b_bin
                     seletor, seletor,         // sel_dec, sel_bin
                     nome_operacao,            // texto da operacao
                     resultado_behavioral,     // res_beh bin
                     resultado_behavioral,     // res_beh dec
                     resultado_esperado,       // res_exp bin
                     resultado_esperado);      // res_exp dec
        end

        $display("--------------------------------------------------------------------------------------------------------------------------");
        $display("Fim da simulacao."); // Mensagem final

        $finish;                    // Encerra a simulacao
    end

endmodule
