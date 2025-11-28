
`timescale 1ns/1ps

// ============================================================================
// Módulo: tb_top_pwm_challenge
// Descrição: Testbench para verificar o funcionamento do desafio extra.
//            Simula o pressionamento do botão e observa as saídas PWM e do display.
// ============================================================================

module tb_top_pwm_challenge;

    // --- Parâmetros de Simulação ---
    // Frequência de clock "real" do sistema
    localparam CLK_FREQ_HZ = 100_000_000;
    // Frequência desejada do PWM
    localparam PWM_FREQ_HZ = 50;
    // Período do clock em nanosegundos (10ns para 100MHz)
    localparam CLK_PERIOD_NS = 10.0;

    // --- Sinais do Testbench ---
    reg clk;            // Clock gerado pelo TB
    reg reset_n;        // Reset controlado pelo TB
    reg btn_adjust;     // Botão simulado
    wire pwm_out_1;     // Saída monitorada do Canal 1
    wire pwm_out_2;     // Saída monitorada do Canal 2
    wire [6:0] segments;// Saída monitorada dos segmentos
    wire [3:0] anodes;  // Saída monitorada dos anodos

    // --- Instanciação do DUT (Device Under Test) ---
    // Instanciamos o módulo principal do desafio.
    // NOTA: Reduzimos CLK_FREQ_HZ para 100 kHz APENAS PARA SIMULAÇÃO.
    // Isso faz com que os contadores internos (debounce e PWM) sejam menores,
    // permitindo simular vários ciclos de PWM e eventos de botão em menos tempo.
    // Se usássemos 100 MHz, a simulação demoraria muito para processar 10ms de debounce.
    top_pwm_challenge #(
        .CLK_FREQ_HZ(100_000), // Clock reduzido para acelerar simulação (100 kHz)
        .PWM_FREQ_HZ(50)       // Mantém 50 Hz alvo
    ) u_top (
        .clk(clk),
        .reset_n(reset_n),
        .btn_adjust(btn_adjust),
        .pwm_out_1(pwm_out_1),
        .pwm_out_2(pwm_out_2),
        .segments(segments),
        .anodes(anodes)
    );

    // --- Geração de Clock ---
    // Gera um clock perpétuo com período definido.
    initial begin
        clk = 0;
        // Inverte o clock a cada metade do período
        forever #(CLK_PERIOD_NS/2) clk = ~clk;
    end

    // --- Procedimento de Teste ---
    initial begin
        // Configura arquivo de saída para visualização de ondas (GTKWave/ModelSim)
        $dumpfile("wave_challenge.vcd");
        $dumpvars(0, tb_top_pwm_challenge);

        // --- Inicialização ---
        reset_n = 0;    // Mantém em reset
        btn_adjust = 0; // Botão solto
        
        // Aguarda 10 ciclos de clock
        repeat(10) @(posedge clk);
        reset_n = 1;    // Libera o reset
        
        $display("Iniciando Simulacao...");
        
        // --- Estado Inicial (Duty 25%) ---
        // Aguarda um tempo para estabilização e observação inicial
        repeat(5000) @(posedge clk); 
        
        // --- Teste 1: Mudar para 50% ---
        $display("Pressionando Botao (Mudar para 50%)...");
        btn_adjust = 1; // Pressiona botão
        // Mantém pressionado por tempo suficiente para vencer o debounce.
        // Com clock de 100kHz, 10ms seriam 1000 ciclos.
        // Seguramos por 2000 ciclos para garantir.
        repeat(2000) @(posedge clk); 
        btn_adjust = 0; // Solta botão
        // Aguarda para observar o novo duty cycle
        repeat(5000) @(posedge clk);
        
        // --- Teste 2: Mudar para 75% ---
        $display("Pressionando Botao (Mudar para 75%)...");
        btn_adjust = 1;
        repeat(2000) @(posedge clk);
        btn_adjust = 0;
        repeat(5000) @(posedge clk);

        // --- Teste 3: Mudar para 100% ---
        $display("Pressionando Botao (Mudar para 100%)...");
        btn_adjust = 1;
        repeat(2000) @(posedge clk);
        btn_adjust = 0;
        repeat(5000) @(posedge clk);

        // --- Teste 4: Ciclar de volta para 25% ---
        $display("Pressionando Botao (Voltar para 25%)...");
        btn_adjust = 1;
        repeat(2000) @(posedge clk);
        btn_adjust = 0;
        repeat(5000) @(posedge clk);
        
        $display("Simulacao Finalizada.");
        $finish; // Encerra a simulação
    end

endmodule
