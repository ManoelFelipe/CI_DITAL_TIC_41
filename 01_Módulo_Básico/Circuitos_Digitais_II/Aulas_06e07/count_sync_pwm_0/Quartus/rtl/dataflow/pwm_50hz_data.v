// ============================================================================
// Arquivo  : pwm_50hz_data  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 27/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação em estilo dataflow da geração de PWM a 50 Hz.
//            O contador permanece sequencial, mas toda a lógica de seleção
//            de duty cycle e comparação é realizada por meio de atribuições
//            contínuas (assign). Esta abordagem facilita a visualização das
//            relações combinacionais entre sinais, destacando o papel do
//            comparador e da seleção de limiar. Cuidados incluem evitar
//            dependência em valores não inicializados e garantir que o
//            contador seja dimensionado para o maior valor de COUNTER_MAX.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module pwm_50hz_data
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
    output wire        pwm_out    // Saída PWM em estilo dataflow
);

    // Limite de contador correspondente a 30% do período
    localparam integer DUTY_30  = (COUNTER_MAX * 30) / 100;
    // Limite de contador correspondente a 60% do período
    localparam integer DUTY_60  = (COUNTER_MAX * 60) / 100;
    // Limite de contador correspondente a 100% do período
    localparam integer DUTY_100 = COUNTER_MAX;

    // Registrador de contador
    reg [31:0] counter;

    // Limiar de comparação selecionado conforme entrada duty_sel
    wire [31:0] threshold;
    // Sinal intermediário indicando se o contador está abaixo do limiar
    wire        below_threshold;
    // Sinal bruto de PWM antes do tratamento do caso de 100%
    wire        pwm_raw;

    // Contador síncrono responsável por gerar a rampa temporal
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            counter <= 32'd0;        // Zera o contador no reset
        end else begin
            if (counter >= (COUNTER_MAX - 1)) begin
                counter <= 32'd0;    // Reinicia contador ao final do período
            end else begin
                counter <= counter + 32'd1; // Incrementa contador
            end
        end
    end

    // Seleção do limiar de comparação em função de duty_sel
    assign threshold =
        (duty_sel == 2'b00) ? DUTY_30  :   // 30%
        (duty_sel == 2'b01) ? DUTY_60  :   // 60%
        (duty_sel == 2'b10) ? DUTY_100 :   // 100%
                               32'd0;      // 0% (caso default)

    // Comparador: verifica se o contador está abaixo do limiar escolhido
    assign below_threshold = (counter < threshold) ? 1'b1 : 1'b0;

    // Saída PWM bruta baseada no comparador
    assign pwm_raw = below_threshold;

    // Tratamento explícito do caso de 100% para evitar glitches
    assign pwm_out =
        (duty_sel == 2'b10) ? 1'b1 :  // 100% do tempo em nível alto
        (duty_sel == 2'b11) ? 1'b0 :  // 0% do tempo em nível alto
                              pwm_raw; // Demais casos utilizam comparador

endmodule
