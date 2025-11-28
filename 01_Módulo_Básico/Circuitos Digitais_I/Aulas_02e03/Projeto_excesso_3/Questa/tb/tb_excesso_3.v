// ============================================================================
// Arquivo  : tb_excesso_3.v  (testbench)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: Testbench auto-verificante para o conversor BCD 8421 para
//            Excesso-3. Estimula digitoss BCD de 0 a 15, verifica
//            automaticamente as tres abordagens (Behavioral, Dataflow,
//            Structural) e gera arquivo VCD para analise de ondas.
// Revisao   : v1.0 — criacao inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Testbench para os tres conversores: behavioral, dataflow e structural
// ---------------------------------------------------------------------------
module tb_excesso_3;

    // Registrador de entrada compartilhado entre as tres abordagens
    reg  [3:0] bcd_in;              // Entrada BCD aplicada a todos os DUTs

    // Fios de saida de cada implementacao
    wire [3:0] excess_behavioral;   // Saida da versao behavioral
    wire [3:0] excess_dataflow;     // Saida da versao dataflow
    wire [3:0] excess_structural;   // Saida da versao structural

    // Contador de erros durante a simulacao
    integer error_count;            // Total de discrepancias encontradas
    integer i;                      // Indice de estimulo no loop for
    reg [3:0] expected;             // Valor esperado de Excesso-3 para comparacao

    // -----------------------------------------------------------------------
    // Instanciacao dos DUTs — Device Under Test
    // -----------------------------------------------------------------------
    excesso_3_behavioral u_dut_behavioral (
        .bcd_in    (bcd_in),        // Ligacao da entrada BCD
        .excess_out(excess_behavioral) // Ligacao da saida Excesso-3
    );

    excesso_3_dataflow u_dut_dataflow (
        .bcd_in    (bcd_in),        // Ligacao da mesma entrada BCD
        .excess_out(excess_dataflow) // Saida da versao dataflow
    );

    excesso_3_structural u_dut_structural (
        .bcd_in    (bcd_in),        // Ligacao da mesma entrada BCD
        .excess_out(excess_structural) // Saida da versao structural
    );

    // -----------------------------------------------------------------------
    // Funcao auxiliar que calcula o Excesso-3 esperado para um dado BCD
    // -----------------------------------------------------------------------
    function [3:0] expected_excess_3;
        input [3:0] bcd_value;      // Valor BCD de entrada
        begin
            // Tabela direta de conversao conforme enunciado (0 a 9)
            case (bcd_value)
                4'd0: expected_excess_3 = 4'b0011; // 0 -> 3
                4'd1: expected_excess_3 = 4'b0100; // 1 -> 4
                4'd2: expected_excess_3 = 4'b0101; // 2 -> 5
                4'd3: expected_excess_3 = 4'b0110; // 3 -> 6
                4'd4: expected_excess_3 = 4'b0111; // 4 -> 7
                4'd5: expected_excess_3 = 4'b1000; // 5 -> 8
                4'd6: expected_excess_3 = 4'b1001; // 6 -> 9
                4'd7: expected_excess_3 = 4'b1010; // 7 -> 10
                4'd8: expected_excess_3 = 4'b1011; // 8 -> 11
                4'd9: expected_excess_3 = 4'b1100; // 9 -> 12
                default: expected_excess_3 = 4'b0000; // Valores invalidos (10-15)
            endcase
        end
    endfunction

    // -----------------------------------------------------------------------
    // Bloco inicial principal com geracao de estimulos e checagem
    // -----------------------------------------------------------------------
    initial begin
        // Inicializa contadores e entrada
        bcd_in      = 4'd0;        // Inicia com digito 0
        error_count = 0;           // Zera o contador de erros

        $display("======= Inicio da simulacao do conversor BCD -> Excesso-3 =======");

        // Aplica todos os valores de 0 a 15 para testar a sensibilidade
        for (i = 0; i < 16; i = i + 1) begin
            bcd_in = i[3:0];       // Aplica o valor atual na entrada
            #10;                   // Aguarda tempo para propagacao

            // Calcula o valor esperado somente para entradas validas (0 a 9)
            if (i < 10) begin
                expected = expected_excess_3(bcd_in); // Chama funcao auxiliar

                // Checagem das tres abordagens contra o valor esperado
                if (excess_behavioral !== expected ||
                    excess_dataflow   !== expected ||
                    excess_structural !== expected) begin

                    // Incrementa contador de erros e exibe detalhes
                    error_count = error_count + 1;
                    $display("ERRO: BCD=%0d (%b) -> Esperado=%b | Beh=%b Data=%b Struct=%b",
                              i, bcd_in, expected,
                              excess_behavioral,
                              excess_dataflow,
                              excess_structural);
                end else begin
                    // Mensagem de sucesso para o estimulo atual
                    $display("OK   : BCD=%0d (%b) -> Excesso-3=%b (todas as abordagens)", 
                              i, bcd_in, expected);
                end
            end else begin
                // Para entradas invalidas de BCD apenas monitora as saidas
                $display("INFO : BCD invalido=%0d (%b) | Beh=%b Data=%b Struct=%b",
                          i, bcd_in,
                          excess_behavioral,
                          excess_dataflow,
                          excess_structural);
            end
        end

        // Resumo final da simulacao
        if (error_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes para BCD 0-9.");
        end else begin
            $display("FALHA  : Foram encontrados %0d erros na comparacao das implementacoes.",
                      error_count);
        end

        $display("Fim da simulacao.");
        $finish;
    end

    // -----------------------------------------------------------------------
    // Geracao de arquivo VCD para analise de formas de onda
    // -----------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");      // Nome do arquivo de ondas
        $dumpvars(0, tb_excesso_3); // Registra todos os sinais do testbench
    end

endmodule
