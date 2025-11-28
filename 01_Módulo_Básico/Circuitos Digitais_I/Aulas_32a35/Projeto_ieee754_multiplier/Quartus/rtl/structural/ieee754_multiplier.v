// ============================================================================
// Arquivo  : ieee754_multiplier.v  (implementação Structural)
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
// ieee754_multiplier (Structural) — composição de módulos elementares
// ---------------------------------------------------------------------------
module ieee754_multiplier (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] result
);
    // Campos de entrada
    wire sign_a, sign_b;
    wire [7:0] exp_a, exp_b;
    wire [22:0] frac_a, frac_b;

    assign sign_a = a[31];
    assign exp_a  = a[30:23];
    assign frac_a = a[22:0];
    assign sign_b = b[31];
    assign exp_b  = b[30:23];
    assign frac_b = b[22:0];

    // Mantissas de 24 bits com bit oculto
    wire [23:0] mant_a, mant_b;
    hidden_bit u_hidden_a(.exp(exp_a), .frac(frac_a), .mant(mant_a));
    hidden_bit u_hidden_b(.exp(exp_b), .frac(frac_b), .mant(mant_b));

    // Sinal de saída
    wire sign_result;
    xor2 u_xor (.a(sign_a), .b(sign_b), .y(sign_result));

    // Detectar zeros
    wire a_is_zero = (exp_a == 8'd0) && (frac_a == 23'd0);
    wire b_is_zero = (exp_b == 8'd0) && (frac_b == 23'd0);

    // Produto de mantissas
    wire [47:0] mant_mul;
    mult24x24 u_mul(.a(mant_a), .b(mant_b), .p(mant_mul));

    // Expoente somado com correção do bias
    wire [9:0] exp_sum_bias;
    exp_add_bias u_expadd(.ea(exp_a), .eb(exp_b), .sum_bias(exp_sum_bias));

    // Normalizador: produz expoente e mantissa finais
    wire [7:0] exp_final;
    wire [22:0] mant_final;
    normalizer48 u_norm(.prod(mant_mul), .exp_in(exp_sum_bias[7:0]), .exp_out(exp_final), .mantissa_out(mant_final));

    // Selecionar zero curto-circuito
    assign result = (a_is_zero || b_is_zero) ? 32'b0
                    : {sign_result, exp_final, mant_final};
endmodule

// ----- Submódulos -----------------------------------------------------------

// Adiciona bias (+ea + eb - 127)
module exp_add_bias(input [7:0] ea, input [7:0] eb, output [9:0] sum_bias);
    assign sum_bias = {2'b00,ea} + {2'b00,eb} - 10'd127;
endmodule

// Constrói mantissa com bit oculto
module hidden_bit(input [7:0] exp, input [22:0] frac, output [23:0] mant);
    assign mant = (exp == 8'd0) ? {1'b0, frac} : {1'b1, frac};
endmodule

// XOR de 1 bit
module xor2(input a, input b, output y);
    assign y = a ^ b;
endmodule

// Multiplicador 24x24 (combinacional)
module mult24x24(input [23:0] a, input [23:0] b, output [47:0] p);
    assign p = a * b;
endmodule

// Normalizador 48->(exp,mantissa)
module normalizer48(
    input  [47:0] prod,
    input  [7:0]  exp_in,
    output [7:0]  exp_out,
    output [22:0] mantissa_out
);
    integer i;
    reg [7:0] shift;
    reg [7:0] exp_r;
    reg [22:0] mant_r;

    always @* begin
        shift = 8'd0;
        if (prod[47]) begin
            mant_r = prod[46:24];
            exp_r  = exp_in + 8'd1;
        end else begin
            for (i=46; i>=0 && prod[i]==1'b0; i=i-1) begin
                shift = shift + 1'b1;
            end
            mant_r = (prod << shift)[46:24];
            exp_r  = exp_in - shift;
        end
    end

    assign exp_out = exp_r;
    assign mantissa_out = mant_r;
endmodule
