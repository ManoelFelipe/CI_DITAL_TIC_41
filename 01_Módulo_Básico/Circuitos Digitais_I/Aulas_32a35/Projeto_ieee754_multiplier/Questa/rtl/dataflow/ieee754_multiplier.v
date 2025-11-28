// ============================================================================
// Arquivo  : ieee754_multiplier.v  (implementação Dataflow)
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
/* ieee754_multiplier (Dataflow)
 * Implementação majoritariamente por expressões contínuas (assign) e funções
 * puras combinacionais para normalização. Não utiliza blocos always para o
 * datapath principal.
 */
// ---------------------------------------------------------------------------
module ieee754_multiplier (
    input  wire [31:0] a,
    input  wire [31:0] b,
    output wire [31:0] result
);
    // Extrair campos ----------------------------------------------------------
    wire sign_a = a[31];
    wire [7:0] exp_a = a[30:23];
    wire [22:0] frac_a = a[22:0];
    wire sign_b = b[31];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] frac_b = b[22:0];

    // Mantissas com bit oculto ------------------------------------------------
    wire [23:0] mantissa_a = (exp_a == 8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    wire [23:0] mantissa_b = (exp_b == 8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    // Sinal do resultado ------------------------------------------------------
    wire sign_result = sign_a ^ sign_b;

    // Detectar zeros ----------------------------------------------------------
    wire a_is_zero = (exp_a == 8'd0) && (frac_a == 23'd0);
    wire b_is_zero = (exp_b == 8'd0) && (frac_b == 23'd0);

    // Produto das mantissas e soma de expoentes -------------------------------
    wire [47:0] mantissa_mul = mantissa_a * mantissa_b;
    wire [9:0] exp_sum_bias  = {2'b00,exp_a} + {2'b00,exp_b} - 10'd127;

    // Função de normalização: retorna {exp[7:0], mantissa[22:0]}
    function [31:0] normalize48;
        input [47:0] prod;
        input [9:0]  exp_in;
        integer k;
        reg [7:0] shift;
        reg [7:0] exp_adj;
        reg [22:0] mantissa_adj;
        reg [47:0] prod_shift; // auxiliar para fatia em Verilog-2001
        begin
            shift = 8'd0;
            if (prod[47]) begin
                mantissa_adj = prod[46:24];
                exp_adj = exp_in[7:0] + 8'd1;
            end else begin
                for (k=46; k>=0 && prod[k]==1'b0; k=k-1) begin
                    shift = shift + 1'b1;
                end
                prod_shift = prod << shift;
                mantissa_adj = (prod << shift)[46:24];
                exp_adj = exp_in[7:0] - shift;
            end
            normalize48 = {8'b0, exp_adj, mantissa_adj};
        end
    endfunction

    // Aplicar normalização (combinacional) -----------------------------------
    wire [31:0] norm_pack = normalize48(mantissa_mul, exp_sum_bias);
    wire [7:0]  exp_final = norm_pack[30:23];
    wire [22:0] mantissa_final = norm_pack[22:0];

    // Resultado zero curto-circuito -------------------------------------------
    assign result = (a_is_zero || b_is_zero) ? 32'b0
                    : {sign_result, exp_final, mantissa_final};
endmodule
