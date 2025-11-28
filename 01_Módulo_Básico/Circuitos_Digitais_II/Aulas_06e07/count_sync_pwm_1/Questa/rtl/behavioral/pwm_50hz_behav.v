// ============================================================================
// Arquivo  : pwm_50hz_behav  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 27/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo de geração de PWM a 50 Hz com seleção de duty cycle via
//            entrada de 2 bits. Implementação em estilo behavioral, utilizando
//            um contador síncrono e lógica sequencial dentro de um único bloco
//            always sensível à borda de subida do clock. O parâmetro
//            COUNTER_MAX define o número de ciclos do clock de 100 MHz para
//            compor um período de 50 Hz. Os limites de comparação para 25%,
//            50%, 75% e 100% de duty cycle são calculados com base em COUNTER_MAX.
//            Cuidados de síntese incluem o uso de largura suficiente para o
//            contador (21 bits) e reset assíncrono ativo em nível baixo para
//            garantir inicialização conhecida do circuito.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module pwm_50hz_behav
#(
    // Frequência do clock de entrada em Hz
    parameter integer CLK_FREQ_HZ = 100_000_000,
    // Frequência desejada do PWM em Hz
    parameter integer PWM_FREQ_HZ = 50,
    // Número de ciclos de clock para completar um período de PWM
    parameter integer COUNTER_MAX = CLK_FREQ_HZ / PWM_FREQ_HZ
)
(
    input  wire        clk,       // Clock de 100 MHz
    input  wire        reset_n,   // Reset assíncrono ativo em nível baixo
    input  wire [1:0]  duty_sel,  // Seleção de duty cycle: 00=25%, 01=50%, 10=75%, 11=100%
    output reg         pwm_out    // Saída PWM conectada (teoricamente) a um LED
);

    // Limite de contador correspondente a 25% do período
    localparam integer DUTY_25  = (COUNTER_MAX * 25) / 100;
    // Limite de contador correspondente a 50% do período
    localparam integer DUTY_50  = (COUNTER_MAX * 50) / 100;
    // Limite de contador correspondente a 75% do período
    localparam integer DUTY_75  = (COUNTER_MAX * 75) / 100;
    // Limite de contador correspondente a 100% do período (sempre alto)
    localparam integer DUTY_100 = COUNTER_MAX;

    // Registrador de contador com largura suficiente para COUNTER_MAX (21 bits)
    reg [20:0] counter;

    // Bloco sequencial: apenas o contador
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 21'd0;
        end else begin
            if (counter >= (COUNTER_MAX - 1)) begin
                counter <= 21'd0;
            end else begin
                counter <= counter + 21'd1;
            end
        end
    end

    // Bloco combinacional: saída PWM
    always @* begin
        case (duty_sel)
            2'b00: begin
                // Duty cycle de 25%
                pwm_out = (counter < DUTY_25) ? 1'b1 : 1'b0;
            end
            2'b01: begin
                // Duty cycle de 50%
                pwm_out = (counter < DUTY_50) ? 1'b1 : 1'b0;
            end
            2'b10: begin
                // Duty cycle de 75%
                pwm_out = (counter < DUTY_75) ? 1'b1 : 1'b0;
            end
            2'b11: begin
                // Duty cycle de 100%
                pwm_out = 1'b1;
            end
            default: begin
                pwm_out = 1'b0;
            end
        endcase
    end

endmodule
