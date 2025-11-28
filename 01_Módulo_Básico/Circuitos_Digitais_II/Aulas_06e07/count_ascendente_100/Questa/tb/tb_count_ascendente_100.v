// ============================================================================
// Arquivo   : tb_count_ascendente_100
// Autor     : Manoel Furtado
// Data      : 26/11/2025
// Ferramentas: Compatível com Questa (Verilog 2001)
// Descrição : Testbench que instancia simultaneamente as três implementações.
// Revisão   : v1.1 — correção de declaração (integer k em escopo de módulo)
// ============================================================================

`timescale 1ns/1ps

module tb_count_ascendente_100;

    // Sinais de estímulo (entradas para os DUTs)
    reg clk;
    reg async_reset;

    // Sinais de monitoramento (saídas dos DUTs)
    wire [6:0] count_behav;
    wire [6:0] count_data;
    wire [6:0] count_struct;

    // Variáveis auxiliares para controle do testbench
    integer i;
    integer total_tests;
    integer success_flag;
    integer k;   // usado na tabela didática

    // Gerador de Clock
    // Período = 10ns (Frequência = 100MHz)
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk; // Inverte o clock a cada 5ns
    end

    // Gerador de Reset
    initial begin
        async_reset = 1'b1; // Inicia com reset ativo
        #20;
        async_reset = 1'b0; // Desativa reset após 20ns
        // O pulso de reset intermediário foi removido para permitir
        // a visualização da contagem completa de 0 a 99 na tabela didática.
    end

    // Instanciação do DUT (Device Under Test) - Implementação Behavioral
    count_ascendente_100_behav
    #(
        .WIDTH(7),
        .MAX_COUNT(99)
    ) u_count_ascendente_100_behav (
        .clk        (clk),
        .async_reset(async_reset),
        .count_out  (count_behav)
    );

    // Instanciação do DUT - Implementação Dataflow
    count_ascendente_100_data
    #(
        .WIDTH(7),
        .MAX_COUNT(99)
    ) u_count_ascendente_100_data (
        .clk        (clk),
        .async_reset(async_reset),
        .count_out  (count_data)
    );

    // Instanciação do DUT - Implementação Structural
    count_ascendente_100_struct
    #(
        .WIDTH(7),
        .MAX_COUNT(99)
    ) u_count_ascendente_100_struct (
        .clk        (clk),
        .async_reset(async_reset),
        .count_out  (count_struct)
    );

    // Configuração para geração de arquivo de onda (VCD)
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_count_ascendente_100);
    end

    // Processo principal de verificação (Self-Checking)
    initial begin
        total_tests  = 0;
        success_flag = 1; // Assume sucesso inicialmente

        // Aguarda o fim do reset inicial e a primeira borda de clock
        @(negedge async_reset);
        @(posedge clk);

        // Loop de teste por 300 ciclos de clock
        for (i = 0; i < 300; i = i + 1) begin
            @(posedge clk); // Sincroniza com a borda de subida
            total_tests = total_tests + 1;

            // Compara as saídas das três implementações
            // Se houver qualquer divergência, reporta erro
            if ((count_behav !== count_data) || (count_data !== count_struct)) begin
                $display("ERRO em %0t ns: behav=%0d data=%0d struct=%0d",
                         $time, count_behav, count_data, count_struct);
                success_flag = 0;
            end
        end

        // Relatório final de verificação
        if (success_flag) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes em %0d testes.",
                     total_tests);
        end
        else begin
            $display("FALHA: Inconsistencias encontradas em %0d testes.",
                     total_tests);
        end

        $display("Fim da simulacao.");
        $finish; // Encerra a simulação
    end

    // Processo separado para gerar a Tabela Didática no console
    initial begin
        // Aguarda o reset inicial
        @(negedge async_reset);
        // Removido o wait extra de clock para pegar o valor 0 inicial
        
        $display("========================================================");
        $display(" TABELA DIDATICA - Contador modulo 100 (implement. BEHAV)");
        $display(" tempo(ns) | count_dec | count_bin");
        $display("--------------------------------------------------------");

        // Imprime os valores de 0 a 99 (e o retorno a 0)
        // Loop aumentado para 105 para mostrar o ciclo completo e o wrap-around
        for (k = 0; k < 105; k = k + 1) begin
            @(posedge clk);
            $display("%9t | %9d | %07b",
                     $time, count_behav, count_behav);
        end

        $display("========================================================");
    end

endmodule
