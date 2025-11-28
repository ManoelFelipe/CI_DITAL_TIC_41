`timescale 1ns/1ps

// ============================================================================
// Arquivo  : tb_conv_4_gray.v  (testbench para 3 abordagens)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Questa (Verilog 2001)
// Descrição: Testbench auto-verificante para o conversor binário -> Gray de
//            4 bits. Instancia simultaneamente as implementações behavioral,
//            dataflow e estrutural, aplica todos os 16 padrões de entrada
//            possíveis e compara as saídas com o valor esperado calculado
//            em tempo de simulação. Gera arquivo VCD para análise de ondas
//            e exibe mensagem de sucesso em caso de equivalência total.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module tb_conv_4_gray;
    // ------------------------------------------------------------------------
    // Declaração de sinais de estímulo e de observação
    // ------------------------------------------------------------------------
    reg  [3:0] bin_in;                 // Entrada em código binário aplicada às três abordagens
    wire [3:0] gray_behavioral;        // Saída da implementação behavioral
    wire [3:0] gray_dataflow;          // Saída da implementação dataflow
    wire [3:0] gray_structural;        // Saída da implementação estrutural

    reg  [3:0] gray_expected;          // Valor de referência calculado no testbench
    integer i;                         // Índice de iteração para o laço de estímulos
    integer error_count;               // Contador de discrepâncias entre DUTs e referência

    // ------------------------------------------------------------------------
    // Instanciações das três implementações do conversor binário -> Gray
    // ------------------------------------------------------------------------
    conv_4_gray_behavioral u_conv_behavioral (
        .bin_in   (bin_in),            // Conecta a entrada binária compartilhada
        .gray_out (gray_behavioral)    // Recebe a saída em código Gray behavioral
    );

    conv_4_gray_dataflow u_conv_dataflow (
        .bin_in   (bin_in),            // Conecta a mesma entrada binária
        .gray_out (gray_dataflow)      // Recebe a saída em código Gray dataflow
    );

    conv_4_gray_structural u_conv_structural (
        .bin_in   (bin_in),            // Conecta a mesma entrada binária
        .gray_out (gray_structural)    // Recebe a saída em código Gray estrutural
    );

    // ------------------------------------------------------------------------
    // Geração de arquivo de ondas no formato VCD
    // ------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");         // Nome do arquivo de saída VCD
        $dumpvars(0, tb_conv_4_gray);  // Salva todos os sinais hierárquicos do testbench
    end

    // ------------------------------------------------------------------------
    // Bloco principal de estímulos e verificação automática
    // ------------------------------------------------------------------------
    initial begin
        error_count   = 0;             // Inicializa o contador de erros
        bin_in        = 4'b0000;       // Inicializa a entrada binária com zero
        gray_expected = 4'b0000;       // Inicializa o valor esperado

        // Pequeno atraso inicial para estabilização
        #5;

        // Laço para aplicar todos os 16 padrões de entrada possíveis
        for (i = 0; i < 16; i = i + 1) begin
            bin_in = i[3:0];           // Atribui o valor do índice à entrada binária
            #5;                        // Aguarda propagação combinacional dos DUTs

            // Cálculo da referência diretamente no testbench
            gray_expected[3] = bin_in[3];                  // G3 esperado = B3
            gray_expected[2] = bin_in[3] ^ bin_in[2];      // G2 esperado = B3 ^ B2
            gray_expected[1] = bin_in[2] ^ bin_in[1];      // G1 esperado = B2 ^ B1
            gray_expected[0] = bin_in[1] ^ bin_in[0];      // G0 esperado = B1 ^ B0

            #1;                        // Atraso curto para uso dos sinais atualizados

            // Verifica implementação behavioral
            if (gray_behavioral !== gray_expected) begin
                $display("ERRO (behavioral) em bin_in=%b: esperado=%b, obtido=%b",
                         bin_in, gray_expected, gray_behavioral);
                error_count = error_count + 1;
            end

            // Verifica implementação dataflow
            if (gray_dataflow !== gray_expected) begin
                $display("ERRO (dataflow) em bin_in=%b: esperado=%b, obtido=%b",
                         bin_in, gray_expected, gray_dataflow);
                error_count = error_count + 1;
            end

            // Verifica implementação estrutural
            if (gray_structural !== gray_expected) begin
                $display("ERRO (structural) em bin_in=%b: esperado=%b, obtido=%b",
                         bin_in, gray_expected, gray_structural);
                error_count = error_count + 1;
            end

            // Monitora o trio de saídas a cada passo de teste
            $display("INFO: bin_in=%b | gray_beh=%b gray_df=%b gray_str=%b",
                     bin_in, gray_behavioral, gray_dataflow, gray_structural);

            #5;                        // Intervalo entre vetores de teste
        end

        // Ao final da varredura, verifica se houve algum erro
        if (error_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes com a referencia.");
        end else begin
            $display("FALHA: Foram detectados %0d erro(s) nas comparacoes.", error_count);
        end

        $display("Fim da simulacao."); // Mensagem final da simulação
        $finish;                       // Encerramento limpo do simulador
    end

endmodule
