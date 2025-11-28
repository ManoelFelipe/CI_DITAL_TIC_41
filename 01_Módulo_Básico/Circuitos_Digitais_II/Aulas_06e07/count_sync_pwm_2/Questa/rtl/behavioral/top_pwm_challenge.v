
`timescale 1ns/1ps

// ============================================================================
// Módulo: top_pwm_challenge
// Descrição: Módulo topo de hierarquia para o desafio extra.
//            Integra o gerador de PWM, o controlador de display e a leitura
//            de botões.
// Funcionalidades:
//   - Leitura de botão com debounce para alterar o duty cycle.
//   - Geração de dois canais PWM sincronizados.
//   - Exibição do valor do duty cycle (25, 50, 75, 100) no display de 7 seg.
// ============================================================================

module top_pwm_challenge #(
    // Frequência do clock de entrada (padrão 100 MHz)
    parameter CLK_FREQ_HZ = 100_000_000,
    // Frequência desejada para o sinal PWM (padrão 50 Hz)
    parameter PWM_FREQ_HZ = 50
) (
    input wire clk,            // Clock do sistema
    input wire reset_n,        // Reset assíncrono ativo em nível baixo
    input wire btn_adjust,     // Botão físico para ajuste do duty cycle
    output wire pwm_out_1,     // Saída PWM Canal 1
    output wire pwm_out_2,     // Saída PWM Canal 2
    output wire [6:0] segments,// Saída para segmentos do display
    output wire [3:0] anodes   // Saída para anodos do display
);

    // --- Sinais Internos ---
    wire btn_debounced; // Sinal do botão após passar pelo debounce
    reg btn_prev;       // Registrador para armazenar o estado anterior do botão (detecção de borda)
    reg [1:0] duty_sel; // Registrador de seleção do duty cycle (00..11)

    // --- Instância do Módulo de Debounce ---
    // Filtra o ruído do botão 'btn_adjust' gerando 'btn_debounced'.
    debounce #(
        .CLK_FREQ(CLK_FREQ_HZ),
        .DEBOUNCE_MS(10) // Configura 10ms de tempo de debounce
    ) u_debounce (
        .clk(clk),
        .reset_n(reset_n),
        .button_in(btn_adjust),
        .button_out(btn_debounced)
    );

    // --- Máquina de Estados para Seleção do Duty Cycle ---
    // Detecta a borda de subida do botão debounced e incrementa a seleção.
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            duty_sel <= 2'b00; // Inicializa com 25% (00)
            btn_prev <= 1'b0;  // Inicializa estado anterior do botão
        end else begin
            // Atualiza o estado anterior para o próximo ciclo
            btn_prev <= btn_debounced;
            
            // Detecção de borda de subida:
            // Se o botão está ALTO agora (btn_debounced) E estava BAIXO antes (!btn_prev)
            if (btn_debounced && !btn_prev) begin
                // Incrementa a seleção ciclicamente (00 -> 01 -> 10 -> 11 -> 00...)
                duty_sel <= duty_sel + 1'b1;
            end
        end
    end

    // --- Canal PWM 1 ---
    // Instância do gerador PWM behavioral.
    pwm_50hz_behav #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .PWM_FREQ_HZ(PWM_FREQ_HZ)
    ) u_pwm_ch1 (
        .clk(clk),
        .reset_n(reset_n),
        .duty_sel(duty_sel), // Recebe a seleção controlada pelo botão
        .pwm_out(pwm_out_1)
    );

    // --- Canal PWM 2 ---
    // Segunda instância do gerador PWM, operando simultaneamente.
    // Como recebem o mesmo clock e reset, estarão sincronizados.
    pwm_50hz_behav #(
        .CLK_FREQ_HZ(CLK_FREQ_HZ),
        .PWM_FREQ_HZ(PWM_FREQ_HZ)
    ) u_pwm_ch2 (
        .clk(clk),
        .reset_n(reset_n),
        .duty_sel(duty_sel), // Recebe a mesma seleção
        .pwm_out(pwm_out_2)
    );

    // --- Driver do Display de 7 Segmentos ---
    // Controla a exibição visual do valor do duty cycle.
    seven_seg_driver #(
        .CLK_FREQ(CLK_FREQ_HZ)
    ) u_display (
        .clk(clk),
        .reset_n(reset_n),
        .duty_sel(duty_sel), // Informa qual valor deve ser exibido
        .segments(segments),
        .anodes(anodes)
    );

endmodule
