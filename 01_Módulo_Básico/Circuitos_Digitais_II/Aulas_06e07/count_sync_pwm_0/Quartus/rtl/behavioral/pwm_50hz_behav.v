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
//            compor um período de 50 Hz. Os limites de comparação para 30%,
//            60% e 100% de duty cycle são calculados com base em COUNTER_MAX.
//            Cuidados de síntese incluem o uso de largura suficiente para o
//            contador (32 bits) e reset assíncrono ativo em nível baixo para
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
    input  wire [1:0]  duty_sel,  // Seleção de duty cycle: 00=30%, 01=60%, 10=100%, 11=0%
    output reg         pwm_out    // Saída PWM conectada (teoricamente) a um LED
);

    // Limite de contador correspondente a 30% do período
    localparam integer DUTY_30  = (COUNTER_MAX * 30) / 100;
    // Limite de contador correspondente a 60% do período
    localparam integer DUTY_60  = (COUNTER_MAX * 60) / 100;
    // Limite de contador correspondente a 100% do período (sempre alto)
    localparam integer DUTY_100 = COUNTER_MAX;

    // Registrador de contador com largura suficiente para COUNTER_MAX
    reg [31:0] counter;

    // Bloco sequencial principal responsável pelo contador e pela saída PWM
    always @(posedge clk or negedge reset_n) begin
        // Tratamento do reset assíncrono ativo em nível baixo
        if (!reset_n) begin
            counter <= 32'd0;      // Zera o contador
            pwm_out <= 1'b0;       // Inicia saída PWM em nível baixo
        end else begin
            // Atualização do contador síncrono
            if (counter >= (COUNTER_MAX - 1)) begin
                counter <= 32'd0;  // Reinicia contador ao atingir o final do período
            end else begin
                counter <= counter + 32'd1; // Incrementa contador a cada ciclo de clock
            end

            // Seleção do duty cycle com base em duty_sel
            case (duty_sel)
                2'b00: begin
                    // Duty cycle de aproximadamente 30%
                    pwm_out <= (counter < DUTY_30) ? 1'b1 : 1'b0;
                end
                2'b01: begin
                    // Duty cycle de aproximadamente 60%
                    pwm_out <= (counter < DUTY_60) ? 1'b1 : 1'b0;
                end
                2'b10: begin
                    // Duty cycle de 100%: saída sempre em nível alto
                    pwm_out <= 1'b1;
                end
                default: begin
                    // Caso reservado: saída em nível baixo (0%)
                    pwm_out <= 1'b0;
                end
            endcase
        end
    end

endmodule
