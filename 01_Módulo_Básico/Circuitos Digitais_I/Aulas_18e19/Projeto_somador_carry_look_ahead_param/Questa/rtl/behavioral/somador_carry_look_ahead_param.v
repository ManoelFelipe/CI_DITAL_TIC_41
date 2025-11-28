// ============================================================================
// Arquivo  : somador_carry_look_ahead_param.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Somador parametrizável de N bits (Behavioral) baseado em carry look-ahead
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
  output reg  [N-1:0] s,
  output reg          c_out );
    reg [N-1:0] g;   // A & B
    reg [N-1:0] p;   // A | B
    reg [N:0]   c;   // carries (c[0]=c_in)
    integer i;
    always @* begin
        g = a & b;       // calcula G
        p = a | b;       // calcula P
        c[0] = c_in;     // carry inicial
        for (i=0;i<N;i=i+1) begin
            c[i+1] = g[i] | (p[i] & c[i]); // look-ahead
        end
        for (i=0;i<N;i=i+1) begin
            s[i] = a[i] ^ b[i] ^ c[i];     // soma
        end
        c_out = c[N];     // carry final
    end
endmodule
`default_nettype wire
