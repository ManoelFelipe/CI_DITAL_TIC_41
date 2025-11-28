// ============================================================================
// Arquivo  : somador_carry_look_ahead_param.v  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador parametrizável de N bits (Dataflow) baseado em carry look-ahead
//            clássico: sinais de geração (G = A&B) e propagação (P = A|B) são
//            calculados em paralelo, e o carry C[i+1] é obtido por C[i+1] =
//            G[i] | (P[i] & C[i]). Largura ajustável via parameter N (padrão 4).
//            Arquitetura combinacional, latência de 0 ciclos e caminho crítico
//            proporcional ao nível de prefixação/encadeamento adotado.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`default_nettype none
module somador_carry_look_ahead_param
#( parameter integer N = 4 )
( input  wire [N-1:0] a,
  input  wire [N-1:0] b,
  input  wire         c_in,
  output wire [N-1:0] s,
  output wire         c_out );
    wire [N-1:0] g = a & b; // geração
    wire [N-1:0] p = a | b; // propagação
    wire [N:0]   c;
    assign c[0] = c_in;
    genvar i;
    generate
        for (i=0;i<N;i=i+1) begin: gen_c
            assign c[i+1] = g[i] | (p[i] & c[i]);
        end
    endgenerate
    assign s = a ^ b ^ c[N-1:0]; // soma
    assign c_out = c[N];         // carry final
endmodule
`default_nettype wire
