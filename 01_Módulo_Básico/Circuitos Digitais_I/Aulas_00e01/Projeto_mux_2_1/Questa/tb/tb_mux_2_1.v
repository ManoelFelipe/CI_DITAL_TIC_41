// ============================================================================
// Arquivo  : tb_mux_2_1.v  (testbench)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench auto-verificante para o mux 2:1 com entradas d[1:0] e sel.
//            Varre exaustivamente todas as combinações de d e sel, compara a saída
//            com o valor esperado (d[sel]) e sinaliza erros na simulação. Gera
//            arquivo VCD para análise de formas de onda em ferramentas externas.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// Testbench para o módulo mux_2_1.
// Não possui portas, pois é o bloco de topo da simulação.
module tb_mux_2_1;

    // Registradores para estimular as entradas do DUT (Device Under Test)
    reg  [1:0] d;     // d[1:0] : vetor de entradas do multiplexador
    reg        sel;   // sel    : linha de seleção do mux

    // Fio para observar a saída do DUT
    wire       y;     // y      : saída produzida pelo multiplexador

    // Contadores auxiliares para estatística dos testes
    integer i;              // i : índice para varrer as combinações de d
    integer j;              // j : índice para varrer os valores de sel
    integer error_count;    // error_count : número de falhas detectadas
    integer total_tests;    // total_tests : número total de vetores de teste aplicados

    // Instancia o DUT (Device Under Test).
    // O nome do módulo mux_2_1 será resolvido de acordo com a implementação
    // compilada (behavioral, dataflow ou structural) via script compile.do.
    mux_2_1 dut_mux_2_1 (
        .d   (d),   // Conecta o vetor de entradas do testbench ao DUT
        .sel (sel), // Conecta o sinal de seleção do testbench ao DUT
        .y   (y)    // Conecta a saída do DUT ao fio observado no testbench
    );

    // Bloco inicial responsável por configurar o dump de formas de onda em VCD.
    initial begin
        // Define o nome do arquivo VCD a ser gerado
        $dumpfile("wave.vcd");
        // Solicita o registro de todas as variáveis dentro do escopo tb_mux_2_1
        $dumpvars(0, tb_mux_2_1);
    end

    // Bloco inicial com a sequência de estímulos e verificações automáticas.
    initial begin
        // Inicializa os sinais de entrada com zero
        d           = 2'b00;
        sel         = 1'b0;
        // Inicializa contadores de erros e testes
        error_count = 0;
        total_tests = 0;

        // Pequeno atraso inicial para estabilização
        #5;

        // Varre todas as combinações possíveis das entradas d[1:0]
        for (i = 0; i < 4; i = i + 1) begin
            // Atribui à entrada d o valor do índice i (nos dois bits menos significativos)
            d = i[1:0];

            // Para cada valor de d, varre todos os valores de sel (0 e 1)
            for (j = 0; j < 2; j = j + 1) begin
                // Atribui o valor j ao sinal de seleção sel
                sel = j[0];

                // Aguarda um tempo de propagação antes de verificar a saída
                #10;

                // Incrementa o contador de testes aplicados
                total_tests = total_tests + 1;

                // Verifica se a saída y coincide com o bit selecionado de d
                if (y !== d[sel]) begin
                    // Em caso de discrepância, incrementa o contador de erros
                    error_count = error_count + 1;
                    // Exibe mensagem detalhada indicando a falha encontrada
                    $display("ERRO: d=%b sel=%b -> y=%b (esperado=%b) no tempo %0t",
                             d, sel, y, d[sel], $time);
                end else begin
                    // Em caso de sucesso, pode-se opcionalmente registrar a passagem
                    $display("OK  : d=%b sel=%b -> y=%b no tempo %0t",
                             d, sel, y, $time);
                end
            end
        end

        // Após aplicar todos os vetores, apresenta um resumo dos resultados
        $display("------------------------------------------------------------");
        $display("Resumo dos testes do mux_2_1:");
        $display("  Total de vetores aplicados : %0d", total_tests);
        $display("  Numero total de erros      : %0d", error_count);
        $display("------------------------------------------------------------");

        // Se nenhum erro foi encontrado, indica sucesso global da simulação
        if (error_count == 0) begin
            $display("TESTE CONCLUIDO SEM ERROS.");
        end else begin
            $display("FORAM ENCONTRADAS FALHAS NO DUT. VERIFICAR IMPLEMENTACAO.");
        end

        // Mensagem final antes do término da simulação
        $display("Fim da simulacao.");
        // Encerra a simulação de forma limpa
        $finish;
    end

endmodule
