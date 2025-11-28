// ============================================================================
// Arquivo  : somador_carry_look_ahead_param.v  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador parametrizável de N bits (Structural) baseado em carry look-ahead
//            clássico: sinais de geração (G = A&B) e propagação (P = A|B) são
//            calculados em paralelo, e o carry C[i+1] é obtido por C[i+1] =
//            G[i] | (P[i] & C[i]). Largura ajustável via parameter N (padrão 4).
//            Arquitetura combinacional, latência de 0 ciclos e caminho crítico
//            proporcional ao nível de prefixação/encadeamento adotado.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`default_nettype none
module cla_cell_1bit(
    input  wire a_i, b_i, c_i,
    output wire s_i, c_next);
    wire g_i = a_i & b_i;       // geração
    wire p_i = a_i | b_i;       // propagação
    assign c_next = g_i | (p_i & c_i); // look-ahead
    assign s_i    = a_i ^ b_i ^ c_i;   // soma
endmodule

module somador_carry_look_ahead_param
#( parameter integer N = 4 )
( input  wire [N-1:0] a,
  input  wire [N-1:0] b,
  input  wire         c_in,
  output wire [N-1:0] s,
  output wire         c_out );
    wire [N:0] c;
    assign c[0] = c_in;
    genvar k;
    generate
        for (k=0;k<N;k=k+1) begin: gen_cells
            cla_cell_1bit u(.a_i(a[k]), .b_i(b[k]), .c_i(c[k]), .s_i(s[k]), .c_next(c[k+1]));
        end
    endgenerate
    assign c_out = c[N];
endmodule
`default_nettype wire
