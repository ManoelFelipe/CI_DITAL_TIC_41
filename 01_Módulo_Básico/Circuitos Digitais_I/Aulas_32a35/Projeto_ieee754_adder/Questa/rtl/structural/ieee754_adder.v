//------------------------------------------------------------------------------
/* ieee754_adder.v (Structural) — Soma IEEE 754 single precision (positivos)
   Módulos: unpack -> align -> add24 -> normalize -> pack
*/
//------------------------------------------------------------------------------
module ieee754_adder(
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    wire [7:0]  exp_a, exp_b;
    wire [23:0] man_a, man_b;
    wire [7:0]  exp_big;
    wire [23:0] man_as, man_bs;
    wire [24:0] sum_man;
    wire [24:0] norm_man;
    wire [7:0]  exp_out;

    unpack u_unpack_a(.in(a), .exp(exp_a), .man(man_a));
    unpack u_unpack_b(.in(b), .exp(exp_b), .man(man_b));
    align  u_align(.exp_a(exp_a), .exp_b(exp_b), .man_a(man_a), .man_b(man_b),
                   .exp_big(exp_big), .man_as(man_as), .man_bs(man_bs));
    add24  u_add(.a({1'b0,man_as}), .b({1'b0,man_bs}), .s(sum_man));
    normalize u_norm(.sum(sum_man), .exp_in(exp_big), .man_out(norm_man), .exp_out(exp_out));
    pack   u_pack(.sign(1'b0), .exp(exp_out), .man(norm_man[22:0]), .out(result));
endmodule

// Desempacota campos e adiciona bit implícito
module unpack(input [31:0] in, output [7:0] exp, output [23:0] man);
    assign exp = in[30:23];
    assign man = (exp==8'd0) ? {1'b0, in[22:0]} : {1'b1, in[22:0]};
endmodule

// Alinha mantissas ao maior expoente
module align(
    input  [7:0]  exp_a, exp_b,
    input  [23:0] man_a, man_b,
    output [7:0]  exp_big,
    output [23:0] man_as, man_bs
);
    wire a_ge_b = (exp_a >= exp_b);
    wire [7:0] diff = a_ge_b ? (exp_a - exp_b) : (exp_b - exp_a);
    assign exp_big = a_ge_b ? exp_a : exp_b;
    assign man_as  = a_ge_b ? man_a : (man_a >> diff);
    assign man_bs  = a_ge_b ? (man_b >> diff) : man_b;
endmodule

// Soma 25 bits
module add24(input [24:0] a, input [24:0] b, output [24:0] s);
    assign s = a + b;
endmodule

// Normalização simples
module normalize(
    input  [24:0] sum,
    input  [7:0]  exp_in,
    output [24:0] man_out,
    output [7:0]  exp_out
);
    wire carry = sum[24];
    wire [24:0] sh = carry ? (sum >> 1) : sum;
    wire [7:0]  ex = carry ? (exp_in + 8'd1) : exp_in;

    // Priority encoder para leading zeros nos 24 bits altos
    wire [23:0] top = sh[23:0];
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
          top[0]  ? 5'd23 : 5'd24;

    assign man_out = carry ? sh : (sh << lead0);
    assign exp_out = carry ? ex : ((ex > lead0) ? (ex - lead0) : 8'd0);
endmodule

// Empacota resultado final (sinal 0)
module pack(input sign, input [7:0] exp, input [22:0] man, output [31:0] out);
    assign out = {sign, exp, man};
endmodule
