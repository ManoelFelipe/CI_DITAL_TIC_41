// -------------------------------------------------------------
// Dataflow IEEE754 Exploração — Encaminhamento por expressões
// e instanciamento de submódulos simples (didáticos).
// -------------------------------------------------------------

module ieee754_exploracao(
    input  [31:0] a, b,
    input  [1:0]  op_sel,     // 00=add, 01=sub, 10=mul, 11=div
    output [31:0] result
);
    wire [31:0] add_out, sub_out, mul_out, div_out;

    ieee754_adder       u_add (.a(a), .b(b), .result(add_out));
    ieee754_subtractor  u_sub (.a(a), .b(b), .result(sub_out));
    ieee754_multiplier  u_mul (.a(a), .b(b), .result(mul_out));
    ieee754_divider     u_div (.a(a), .b(b), .result(div_out));

    assign result = (op_sel == 2'b00) ? add_out :
                    (op_sel == 2'b01) ? sub_out :
                    (op_sel == 2'b10) ? mul_out :
                    div_out;
endmodule

// ---------------- Submódulos didáticos ----------------

// Somador simples (operandos positivos e normais)
module ieee754_adder(input [31:0] a, input [31:0] b, output [31:0] result);
    wire [7:0] exp_a = a[30:23], exp_b = b[30:23];
    wire [23:0] ma0 = {1'b1, a[22:0]};
    wire [23:0] mb0 = {1'b1, b[22:0]};
    wire [7:0] exp_max   = (exp_a >= exp_b) ? exp_a : exp_b;
    wire [7:0] exp_diff  = (exp_a >= exp_b) ? (exp_a - exp_b) : (exp_b - exp_a);
    wire [23:0] ma = (exp_a >= exp_b) ? ma0 : (ma0 >> exp_diff);
    wire [23:0] mb = (exp_a >= exp_b) ? (mb0 >> exp_diff) : mb0;
    wire [24:0] sum = ma + mb;
    wire [7:0]  exp_res = sum[24] ? (exp_max + 8'd1) : exp_max;
    wire [22:0] mant_res = sum[24] ? sum[23:1] : sum[22:0];
    assign result = {1'b0, exp_res, mant_res};
endmodule

// Subtrator simples (A - B), assumindo A >= B após alinhamento
module ieee754_subtractor(input [31:0] a, input [31:0] b, output [31:0] result);
    wire [7:0] exp_a = a[30:23], exp_b = b[30:23];
    reg [23:0] ma, mb;
    reg [7:0]  e;
    reg [23:0] d;
    always @(*) begin
        ma = {1'b1, a[22:0]};
        mb = {1'b1, b[22:0]};
        if (exp_a >= exp_b) begin
            mb = mb >> (exp_a - exp_b);
            e = exp_a;
        end else begin
            ma = ma >> (exp_b - exp_a);
            e = exp_b;
        end
        d = (ma >= mb) ? (ma - mb) : (mb - ma);
        if (d != 0) begin
            while (d[23] == 1'b0 && e > 0) begin
                d = d << 1;
                e = e - 1;
            end
        end
    end
    assign result = {1'b0, e, d[22:0]};
endmodule

// Multiplicador
module ieee754_multiplier(input [31:0] a, input [31:0] b, output [31:0] result);
    wire [23:0] ma = {1'b1, a[22:0]};
    wire [23:0] mb = {1'b1, b[22:0]};
    wire [47:0] p  = ma * mb;
    wire [7:0]  e0 = (a[30:23] + b[30:23]) - 8'd127;
    wire [7:0]  e1 = p[47] ? (e0 + 8'd1) : e0;
    wire [22:0] m1 = p[47] ? p[45:23]   : p[44:22];
    assign result = {a[31]^b[31], e1, m1};
endmodule

// Divisor simples
module ieee754_divider(input [31:0] a, input [31:0] b, output [31:0] result);
    wire [23:0] ma = {1'b1, a[22:0]};
    wire [23:0] mb = {1'b1, b[22:0]};
    wire [46:0] q  = ({ma, 23'd0}) / mb;   // (ma << 23) / mb
    reg  [7:0]  e;
    reg  [22:0] m;
    always @(*) begin
        e = (a[30:23] - b[30:23]) + 8'd127;
        m = q[22:0];
        if (q[23] == 1'b0 && q != 0) begin
            // renormaliza à esquerda
            reg [46:0] t; t = q;
            while (t[23] == 1'b0 && e > 0) begin
                t = t << 1; e = e - 1;
            end
            m = t[22:0];
        end
    end
    assign result = {a[31]^b[31], e, m};
endmodule
