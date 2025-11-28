//------------------------------------------------------------------------------
// ieee754_adder.v (Dataflow) — Soma IEEE 754 precisão simples (positivos)
//------------------------------------------------------------------------------
module ieee754_adder (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    // Campos básicos
    wire [7:0]  exp_a   = a[30:23];
    wire [7:0]  exp_b   = b[30:23];
    wire [22:0] frac_a  = a[22:0];
    wire [22:0] frac_b  = b[22:0];

    // Mantissas com bit implícito (normais) ou zero (subnormais)
    wire [23:0] man_a = (exp_a==8'd0) ? {1'b0, frac_a} : {1'b1, frac_a};
    wire [23:0] man_b = (exp_b==8'd0) ? {1'b0, frac_b} : {1'b1, frac_b};

    // Seleção do expoente maior e alinhamento (via operadores)
    wire        a_ge_b  = (exp_a >= exp_b);
    wire [7:0]  exp_big = a_ge_b ? exp_a : exp_b;
    wire [7:0]  diff    = a_ge_b ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [23:0] man_as  = a_ge_b ? man_a : (man_a >> diff);
    wire [23:0] man_bs  = a_ge_b ? (man_b >> diff) : man_b;

    // Soma estendida e detecção de carry
    wire [24:0] sum_man = {1'b0, man_as} + {1'b0, man_bs};
    wire        carry   = sum_man[24];

    // Normalização via condicionais contínuos
    wire [24:0] sum_shifted = carry ? (sum_man >> 1) : sum_man;
    wire [7:0]  exp_tmp     = carry ? (exp_big + 8'd1) : exp_big;

    // Caso não haja carry, pode ser necessário deslocar à esquerda;
    // Implementamos um "leading zero count" simples com função combinacional.
    function [4:0] lzc24;
        input [24:0] x;
        integer k;
        begin
            lzc24 = 0;
            for (k=23; k>=0; k=k-1) begin
                if (x[k] == 1'b0) lzc24 = lzc24 + 1;
                else begin
                    // Encontrado primeiro 1 a partir do topo
                    disable for_loop;
                end
            end
        end
    endfunction

    // Work-around: Verilog-2001 doesn't support named disable for for-loop in function.
    // So we implement a simpler deterministic version using a chain.
    // Here we provide a compact combinational priority encode for top 24 bits:
    wire [23:0] top = sum_shifted[23:0];
    wire [4:0] lead0 =
          top[23] ? 5'd0  :
          top[22] ? 5'd1  :
          top[21] ? 5'd2  :
          top[20] ? 5'd3  :
          top[19] ? 5'd4  :
          top[18] ? 5'd5  :
          top[17] ? 5'd6  :
          top[16] ? 5'd7  :
          top[15] ? 5'd8  :
          top[14] ? 5'd9  :
          top[13] ? 5'd10 :
          top[12] ? 5'd11 :
          top[11] ? 5'd12 :
          top[10] ? 5'd13 :
          top[9]  ? 5'd14 :
          top[8]  ? 5'd15 :
          top[7]  ? 5'd16 :
          top[6]  ? 5'd17 :
          top[5]  ? 5'd18 :
          top[4]  ? 5'd19 :
          top[3]  ? 5'd20 :
          top[2]  ? 5'd21 :
          top[1]  ? 5'd22 :
          top[0]  ? 5'd23 : 5'd24; // tudo zero

    wire [24:0] norm_man = carry ? sum_shifted : (sum_shifted << lead0);
    wire [7:0]  exp_out  = carry ? exp_tmp     : ((exp_tmp > lead0) ? (exp_tmp - lead0) : 8'd0);

    // Montagem (sinal 0)
    assign result = {1'b0, exp_out, norm_man[22:0]};
endmodule
