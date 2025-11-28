// ============================================================================
// Arquivo  : tb_pwm_50hz
// Autor    : Manoel Furtado
// Data     : 27/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench unificado para as três implementações do módulo
//            pwm_50hz (behavioral, dataflow e structural). Nesta versão,
//            o valor de COUNTER_MAX é REDUZIDO apenas para simulação, de
//            modo a evitar tempos de simulação excessivamente longos.
//            As DUTs continuam parametrizáveis para síntese real.
// Revisão   : v1.1 — redução de COUNTER_MAX no testbench
// ============================================================================

`timescale 1ns/1ps

module tb_pwm_50hz;

    // ---------------------------------------------------------------------
    // Parâmetros de configuração GENERICOS
    // ---------------------------------------------------------------------
    // Frequência do clock de entrada em Hz (mantida para referência)
    localparam integer CLK_FREQ_HZ     = 100_000_000;
    // Frequência desejada do PWM em Hz (conceitual)
    localparam integer PWM_FREQ_HZ     = 50;

    // *** IMPORTANTE ***
    // Para uma síntese real, COUNTER_MAX deveria ser CLK_FREQ_HZ / PWM_FREQ_HZ
    // = 2_000_000 ciclos. Isso torna a simulação muito lenta.
    // Aqui, usamos um valor REDUZIDO apenas no testbench para acelerar a simulação.
    localparam integer TB_COUNTER_MAX  = 2000;  // valor reduzido para simulação

    // Período do clock em nanosegundos (10 ns para 100 MHz)
    localparam real    CLK_PERIOD_NS   = 10.0;

    // ---------------------------------------------------------------------
    // Sinais do testbench
    // ---------------------------------------------------------------------
    reg         clk;          // Clock de 100 MHz
    reg         reset_n;      // Reset assíncrono ativo em nível baixo
    reg  [1:0]  duty_sel;     // Seleção de duty cycle
    wire        pwm_behav;    // Saída da implementação behavioral
    wire        pwm_data;     // Saída da implementação dataflow
    wire        pwm_struct;   // Saída da implementação structural

    // Contadores auxiliares para avaliação numérica
    integer     high_behav;   // Contagem de ciclos em nível alto (behavioral)
    integer     high_data;    // Contagem de ciclos em nível alto (dataflow)
    integer     high_struct;  // Contagem de ciclos em nível alto (structural)
    integer     total_cycles; // Número total de ciclos avaliados
    integer     total_tests;  // Número acumulado de ciclos testados
    integer     error_flag;   // Indicador de inconsistência entre abordagens
    integer     i;            // Índice genérico de laços

    // ---------------------------------------------------------------------
    // Instâncias das três DUTs com COUNTER_MAX reduzido APENAS para simulação
    // ---------------------------------------------------------------------
    pwm_50hz_behav #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .PWM_FREQ_HZ (PWM_FREQ_HZ),
        .COUNTER_MAX (TB_COUNTER_MAX)
    ) u_pwm_behav (
        .clk      (clk),
        .reset_n  (reset_n),
        .duty_sel (duty_sel),
        .pwm_out  (pwm_behav)
    );

    pwm_50hz_data #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .PWM_FREQ_HZ (PWM_FREQ_HZ),
        .COUNTER_MAX (TB_COUNTER_MAX)
    ) u_pwm_data (
        .clk      (clk),
        .reset_n  (reset_n),
        .duty_sel (duty_sel),
        .pwm_out  (pwm_data)
    );

    pwm_50hz_struct #(
        .CLK_FREQ_HZ (CLK_FREQ_HZ),
        .PWM_FREQ_HZ (PWM_FREQ_HZ),
        .COUNTER_MAX (TB_COUNTER_MAX)
    ) u_pwm_struct (
        .clk      (clk),
        .reset_n  (reset_n),
        .duty_sel (duty_sel),
        .pwm_out  (pwm_struct)
    );

    // ---------------------------------------------------------------------
    // Geração do clock de 100 MHz (período de 10 ns)
    // ---------------------------------------------------------------------
    initial begin
        clk = 1'b0;                           // Inicializa clock em 0
        forever #(CLK_PERIOD_NS/2.0) clk = ~clk; // Inverte clock a cada 5 ns
    end

    // ---------------------------------------------------------------------
    // Geração de arquivo de ondas (VCD)
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");                // Nome do arquivo de ondas
        $dumpvars(0, tb_pwm_50hz);            // Salva todos os sinais do TB
    end

    // ---------------------------------------------------------------------
    // Tarefa: executa uma medição completa para um duty_sel específico
    // ---------------------------------------------------------------------
    task automatic run_case;
        input [1:0] duty_sel_in;              // Valor de entrada de duty_sel
        input integer expected_percent;       // Duty cycle esperado em %
        integer meas_behav;                   // Duty medido (behavioral)
        integer meas_data;                    // Duty medido (dataflow)
        integer meas_struct;                  // Duty medido (structural)
        integer cycle;                        // Índice de ciclos
    begin
        // Aplica seleção de duty cycle
        duty_sel = duty_sel_in;

        // Aguarda um período completo para estabilização após mudança
        repeat (TB_COUNTER_MAX) @(posedge clk);

        // Zera contadores para nova janela de medição
        high_behav   = 0;
        high_data    = 0;
        high_struct  = 0;
        total_cycles = 0;

        // Mede o duty cycle efetivo ao longo de um período
        for (cycle = 0; cycle < TB_COUNTER_MAX; cycle = cycle + 1) begin
                @(posedge clk);
            total_cycles = total_cycles + 1;

            // Contadores de ciclos em nível alto
            if (pwm_behav)   high_behav  = high_behav  + 1;
            if (pwm_data)    high_data   = high_data   + 1;
            if (pwm_struct)  high_struct = high_struct + 1;

            // Comparação automática das três implementações
            if ((pwm_behav !== pwm_data) || (pwm_behav !== pwm_struct)) begin
                $display("ERRO: implementacoes divergentes em t=%0t ns. behav=%b data=%b struct=%b",
                         $time, pwm_behav, pwm_data, pwm_struct);
                error_flag = 1;
            end
        end

        // Acumula número total de testes realizados
        total_tests = total_tests + total_cycles;

        // Cálculo aproximado do duty cycle em porcentagem
        meas_behav  = (high_behav  * 100) / total_cycles;
        meas_data   = (high_data   * 100) / total_cycles;
        meas_struct = (high_struct * 100) / total_cycles;

        // Impressão de resumo numérico da medição
        $display("Resumo DUTY esperado = %0d%%", expected_percent);
        $display("  Behavioral: %0d%% (high=%0d de %0d ciclos)",
                 meas_behav, high_behav, total_cycles);
        $display("  Dataflow  : %0d%% (high=%0d de %0d ciclos)",
                 meas_data,  high_data,  total_cycles);
        $display("  Structural: %0d%% (high=%0d de %0d ciclos)",
                 meas_struct, high_struct, total_cycles);
        $display("----------------------------------------------------");

    end
    endtask

    // ---------------------------------------------------------------------
    // Tabela didática baseada na implementação behavioral
    // Mostra os primeiros 16 ciclos após mudança de duty_sel
    // ---------------------------------------------------------------------
    task automatic tabela_didatica;
        input [1:0] duty_sel_in; // Valor de duty_sel usado na tabela
        integer k;               // Índice de ciclos
    begin
        duty_sel = duty_sel_in;  // Aplica seleção de duty

        // Aguarda borda de clock para alinhar a observação
        @(posedge clk);

        $display("Tabela didatica (baseada em pwm_behav):");
        $display("linha | tempo(ns) | duty_sel | pwm_behav");
        $display("------+-----------+----------+----------");

        // Captura 16 amostras sequenciais
        for (k = 0; k < 16; k = k + 1) begin
            @(posedge clk);
            $display("%4d | %9t |    %b    |     %b",
                     k, $time, duty_sel, pwm_behav);
        end

        $display("====================================================");
    end
    endtask

    // ---------------------------------------------------------------------
    // Bloco principal de estímulos
    // ---------------------------------------------------------------------
    initial begin
        // Inicialização dos sinais
        reset_n     = 1'b0;      // Aplica reset
        duty_sel    = 2'b00;     // Duty inicial de 30%
        error_flag  = 0;         // Nenhum erro no início
        total_tests = 0;         // Zera contador de testes

        // Mantém reset ativo por alguns ciclos
        repeat (5) @(posedge clk);
        reset_n = 1'b1;          // Libera reset

        // Executa casos de teste para 30%, 60% e 100%
        run_case(2'b00, 30);     // Caso duty = 30%
        tabela_didatica(2'b00);  // Tabela didática para duty 30%

        run_case(2'b01, 60);     // Caso duty = 60%
        tabela_didatica(2'b01);  // Tabela didática para duty 60%

        run_case(2'b10, 100);    // Caso duty = 100%
        tabela_didatica(2'b10);  // Tabela didática para duty 100%

        // Mensagem final de sucesso ou falha
        if (error_flag == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes em %0d testes.",
                     total_tests);
        end else begin
            $display("FALHA: Foram detectadas divergencias entre as implementacoes.");
        end

        // Finalização da simulação
        $display("Fim da simulacao.");
        $finish;
    end

endmodule
