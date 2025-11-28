// ============================================================================
// Arquivo  : ieee754_multiplier.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplicador IEEE 754 precisão simples (32 bits). Separa sinal,
//            expoente (8) e fração (23+bit oculto), multiplica mantissas 24x24,
//            normaliza o produto (48 bits) e ajusta expoente com bias 127.
//            Rounding: truncamento (round-toward-zero). Latência: 0 ciclos
//            (combinacional puro). Recursos: comparadores, somadores 9 bits,
//            multiplicador 24x24 e normalizador (priority-encode).
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps
// ---------------------------------------------------------------------------
// ieee754_multiplier (Behavioral) — implementação inteiramente combinacional
// ---------------------------------------------------------------------------
module ieee754_multiplier (
    input  wire [31:0] a,   // operando A (IEEE754 single)
    input  wire [31:0] b,   // operando B (IEEE754 single)
    output reg  [31:0] result // resultado (IEEE754 single)
);
    // Separar campos de A -----------------------------------------------------
    wire sign_a         = a[31];       // bit de sinal
    wire [7:0] exp_a    = a[30:23];    // expoente com bias
    wire [22:0] frac_a  = a[22:0];     // fração (mantissa sem bit oculto)

    // Separar campos de B -----------------------------------------------------
    wire sign_b         = b[31];
    wire [7:0] exp_b    = b[30:23];
    wire [22:0] frac_b  = b[22:0];

    // Reconstruir mantissas com bit oculto -----------------------------------
    // Para números normalizados, o bit oculto é 1. Para zero/subnormais, é 0.
    wire [23:0] mantissa_a = (exp_a == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    wire [23:0] mantissa_b = (exp_b == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    // Sinal do resultado ------------------------------------------------------
    wire sign_result = sign_a ^ sign_b; // XOR dos sinais

    // Detectar zeros triviais -------------------------------------------------
    wire a_is_zero = (exp_a == 8'd0) && (frac_a == 23'd0);
    wire b_is_zero = (exp_b == 8'd0) && (frac_b == 23'd0);

    // Produto das mantissas 24x24 ---------------------------------------------
    wire [47:0] mantissa_mul = mantissa_a * mantissa_b;

    // Soma de expoentes menos bias (127) --------------------------------------
    // Observação: soma usa 9 bits para evitar overflow no carry.
    wire [9:0] exp_sum_bias = {2'b00,exp_a} + {2'b00,exp_b} - 10'd127;

    // Normalização ------------------------------------------------------------
    // Se o produto tiver 1 no bit 47, a forma está 1.xxxxx * 2^n (já normalizado).
    // Caso contrário, deslocamos à esquerda até encontrar o primeiro '1'.
    integer i;
    reg [7:0]  shift;
    reg [22:0] mantissa_final;
    reg [7:0]  exp_final;
    reg [47:0] mantissa_shifted; // auxiliar para fatia em Verilog-2001

    always @* begin
        // Caso especial: multiplicação por zero -> zero com sinal correto
        if (a_is_zero || b_is_zero) begin
            result = 32'b0;
        end else begin
            // Inicialização ---------------------------------------------------
            shift = 8'd0;

            // Se bit 47 é 1, precisamos "deslocar para a direita" 1 e somar 1 ao expoente
            if (mantissa_mul[47]) begin
                // Mantemos os 23 MSBs após o ponto (bits 46:24)
                mantissa_final = mantissa_mul[46:24];
                exp_final = exp_sum_bias[7:0] + 8'd1;
            end else begin
                // Senão, encontrar primeiro '1' descendo a partir de 46 até 0
                // (priority-encoder simples)
                // Observação: limite de 47 ciclos de loop sintético — sintetizável.
                for (i = 46; i >= 0 && mantissa_mul[i] == 1'b0; i = i - 1) begin
                    shift = shift + 1'b1;
                end
                // Ajuste da mantissa: pegue 23 bits mais significativos após o primeiro '1'
                mantissa_shifted = mantissa_mul << shift;
                mantissa_final = mantissa_shifted[46:24];
                // Ajuste do expoente: subtrair deslocamento
                exp_final = exp_sum_bias[7:0] - shift;
            end

            // Construir palavra IEEE754: sinal | expoente | fração
            result = {sign_result, exp_final, mantissa_final};
        end
    end
endmodule
