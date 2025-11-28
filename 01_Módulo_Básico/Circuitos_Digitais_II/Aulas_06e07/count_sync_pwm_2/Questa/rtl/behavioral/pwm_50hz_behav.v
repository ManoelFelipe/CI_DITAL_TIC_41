
// ============================================================================
// Arquivo  : pwm_50hz_behav.v (Implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 27/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo de geração de PWM a 50 Hz com seleção de duty cycle via
//            entrada de 2 bits. Implementação em estilo behavioral, utilizando
//            um contador síncrono e lógica sequencial dentro de um único bloco
//            always sensível à borda de subida do clock.
// ============================================================================

`timescale 1ns/1ps

module pwm_50hz_behav
#(
    // Parâmetro: Frequência do clock de entrada em Hz (padrão 100 MHz)
    parameter integer CLK_FREQ_HZ = 100_000_000,
    // Parâmetro: Frequência desejada do PWM em Hz (padrão 50 Hz)
    parameter integer PWM_FREQ_HZ = 50,
    // Parâmetro calculado: Número total de ciclos de clock em um período PWM.
    // Ex: 100.000.000 / 50 = 2.000.000 ciclos.
    parameter integer COUNTER_MAX = CLK_FREQ_HZ / PWM_FREQ_HZ
)
(
    input  wire        clk,       // Sinal de clock de 100 MHz
    input  wire        reset_n,   // Reset assíncrono ativo em nível baixo (0 reinicia)
    input  wire [1:0]  duty_sel,  // Seleção de duty cycle: 00=25%, 01=50%, 10=75%, 11=100%
    output reg         pwm_out    // Saída do sinal PWM gerado
);

    // --- Definição dos Limites de Comparação (Thresholds) ---
    // Calculamos os valores do contador onde o sinal deve mudar de nível
    // para atingir a porcentagem desejada.
    
    // Limite para 25% do período: (2.000.000 * 25) / 100 = 500.000
    localparam integer DUTY_25  = (COUNTER_MAX * 25) / 100;
    
    // Limite para 50% do período: (2.000.000 * 50) / 100 = 1.000.000
    localparam integer DUTY_50  = (COUNTER_MAX * 50) / 100;
    
    // Limite para 75% do período: (2.000.000 * 75) / 100 = 1.500.000
    localparam integer DUTY_75  = (COUNTER_MAX * 75) / 100;
    
    // Limite para 100% do período: Igual ao máximo (sinal sempre alto)
    localparam integer DUTY_100 = COUNTER_MAX;

    // --- Contador Principal ---
    // Registrador de 21 bits é suficiente para contar até 2.000.000 (2^21 = 2.097.152)
    reg [20:0] counter;

    // --- Lógica Sequencial do Contador ---
    // Bloco always sensível à borda de subida do clock ou borda de descida do reset
    always @(posedge clk or negedge reset_n) begin
        // Verifica se o reset está ativo (nível baixo)
        if (!reset_n) begin
            // Reinicia o contador para 0
            counter <= 21'd0;
        end else begin
            // Se o contador atingiu o valor máximo do período (menos 1, pois começa em 0)
            if (counter >= (COUNTER_MAX - 1)) begin
                // Reinicia o ciclo do PWM
                counter <= 21'd0;
            end else begin
                // Incrementa o contador em cada ciclo de clock
                counter <= counter + 21'd1;
            end
        end
    end

    // --- Lógica Combinacional de Saída (Comparador) ---
    // Define o valor da saída pwm_out com base no valor atual do contador
    // e na seleção de duty cycle (duty_sel).
    always @* begin
        case (duty_sel)
            2'b00: begin
                // Caso 25%: Saída ALTA se contador < DUTY_25, senão BAIXA
                pwm_out = (counter < DUTY_25) ? 1'b1 : 1'b0;
            end
            2'b01: begin
                // Caso 50%: Saída ALTA se contador < DUTY_50, senão BAIXA
                pwm_out = (counter < DUTY_50) ? 1'b1 : 1'b0;
            end
            2'b10: begin
                // Caso 75%: Saída ALTA se contador < DUTY_75, senão BAIXA
                pwm_out = (counter < DUTY_75) ? 1'b1 : 1'b0;
            end
            2'b11: begin
                // Caso 100%: Saída sempre ALTA
                pwm_out = 1'b1;
            end
            default: begin
                // Caso padrão (segurança): Saída BAIXA
                pwm_out = 1'b0;
            end
        endcase
    end

endmodule
