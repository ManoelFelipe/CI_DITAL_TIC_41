// ============================================================================
// Arquivo  : pwm_50hz_struct  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 27/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação estrutural da geração de PWM a 50 Hz. O módulo
//            principal instancia três blocos: um contador síncrono, um
//            seletor de limiar de duty cycle e um comparador. Cada bloco
//            é descrito como submódulo separado, evidenciando a composição
//            hierárquica do circuito. Essa abordagem facilita a reutilização
//            de componentes e a verificação modular, ao custo de maior
//            verbosidade na descrição. A largura do contador e dos limiares
//            é parametrizável para acomodar diferentes frequências de clock.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo top-level estrutural do PWM de 50 Hz
// --------------------------------------------------------------------------
module pwm_50hz_struct
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
    input  wire [1:0]  duty_sel,  // Seleção de duty cycle
    output wire        pwm_out    // Saída PWM estrutural
);

    // Sinal interno do contador
    wire [31:0] counter;
    // Limiar selecionado para o duty cycle
    wire [31:0] threshold;
    // Sinal PWM intermediário vindo do comparador
    wire        pwm_raw;

    // Instância do contador síncrono parametrizável
    pwm_counter_struct
    #(
        .COUNTER_MAX (COUNTER_MAX)
    ) u_counter (
        .clk      (clk),
        .reset_n  (reset_n),
        .count_q  (counter)
    );

    // Instância do seletor de limiar de duty cycle
    pwm_duty_selector_struct
    #(
        .COUNTER_MAX (COUNTER_MAX)
    ) u_duty_selector (
        .duty_sel  (duty_sel),
        .threshold (threshold)
    );

    // Instância do comparador PWM
    pwm_comparator_struct u_comparator (
        .counter   (counter),
        .threshold (threshold),
        .pwm_raw   (pwm_raw)
    );

    // Tratamento do caso especial de 100% e 0% na saída final
    assign pwm_out =
        (duty_sel == 2'b10) ? 1'b1 :  // 100% em nível alto
        (duty_sel == 2'b11) ? 1'b0 :  // 0% em nível alto
                              pwm_raw; // Casos 30% e 60% usam comparador

endmodule

// --------------------------------------------------------------------------
// Submódulo: pwm_counter_struct
// Contador síncrono parametrizável
// --------------------------------------------------------------------------
module pwm_counter_struct
#(
    parameter integer COUNTER_MAX = 2_000_000
)
(
    input  wire       clk,      // Clock de 100 MHz
    input  wire       reset_n,  // Reset assíncrono ativo em nível baixo
    output reg [31:0] count_q   // Saída do valor atual do contador
);

    // Bloco sequencial do contador
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            count_q <= 32'd0;                // Zera contador no reset
        end else begin
            if (count_q >= (COUNTER_MAX - 1)) begin
                count_q <= 32'd0;            // Reinicia quando atinge limite
            end else begin
                count_q <= count_q + 32'd1;  // Incrementa contador
            end
        end
    end

endmodule

// --------------------------------------------------------------------------
// Submódulo: pwm_duty_selector_struct
// Seleciona limiar de duty cycle com base em duty_sel
// --------------------------------------------------------------------------
module pwm_duty_selector_struct
#(
    parameter integer COUNTER_MAX = 2_000_000
)
(
    input  wire [1:0]  duty_sel,   // Seleção de duty cycle
    output reg  [31:0] threshold   // Limiar correspondente
);

    // Cálculo local dos limiares de 30%, 60% e 100%
    localparam integer DUTY_30  = (COUNTER_MAX * 30) / 100;
    localparam integer DUTY_60  = (COUNTER_MAX * 60) / 100;
    localparam integer DUTY_100 = COUNTER_MAX;

    // Lógica combinacional de seleção do limiar
    always @* begin
        case (duty_sel)
            2'b00: threshold = DUTY_30;   // 30%
            2'b01: threshold = DUTY_60;   // 60%
            2'b10: threshold = DUTY_100;  // 100%
            default: threshold = 32'd0;   // 0%
        endcase
    end

endmodule

// --------------------------------------------------------------------------
// Submódulo: pwm_comparator_struct
// Compara contador com limiar para gerar PWM bruto
// --------------------------------------------------------------------------
module pwm_comparator_struct
(
    input  wire [31:0] counter,    // Valor atual do contador
    input  wire [31:0] threshold,  // Limiar de duty cycle
    output wire        pwm_raw     // Saída PWM bruta
);

    // Saída em nível alto enquanto contador for menor que o limiar
    assign pwm_raw = (counter < threshold) ? 1'b1 : 1'b0;

endmodule
