
// -----------------------------------------------------------------------------
/* ponto_fixo_multi_8.v (Structural)
   Implementação estrutural baseada em multiplicador por somas de parciais
   (array multiplier) + somadores ripple-carry. O ajuste de ponto fixo é feito
   por deslocamento e corte/ saturação ao final.
*/
// -----------------------------------------------------------------------------

module rc_adder #(parameter W=16) (
    input  wire [W-1:0] x,
    input  wire [W-1:0] y,
    output wire [W-1:0] s
);
    wire [W:0] c;
    assign c[0] = 1'b0;
    genvar i;
    generate
        for (i=0; i<W; i=i+1) begin: FA
            wire p = x[i] ^ y[i];
            wire g = x[i] & y[i];
            assign s[i]   = p ^ c[i];
            assign c[i+1] = g | (p & c[i]);
        end
    endgenerate
endmodule

module ponto_fixo_multi_8
#(
    parameter integer N      = 8,
    parameter integer NFRAC  = 3,
    parameter         SATURATE = 1
)
(
    input  wire [N-1:0]        a,
    input  wire [N-1:0]        b,
    output wire [2*N-1:0]      p_raw,
    output wire [N-1:0]        p_qm_n,
    output wire                overflow
);
    // Parciais (AND + shifts)
    wire [2*N-1:0] partial [N-1:0];
    genvar i;
    generate
        for (i=0; i<N; i=i+1) begin: PARTS
            assign partial[i] = b[i] ? ( { {N{1'b0}}, a } << i ) : {2*N{1'b0}};
        end
    endgenerate

    // Soma das parciais com árvore linear de somadores ripple
    wire [2*N-1:0] sum [N:0];
    assign sum[0] = {2*N{1'b0}};
    generate
        for (i=0; i<N; i=i+1) begin: SUMS
            rc_adder #(.W(2*N)) ADD (.x(sum[i]), .y(partial[i]), .s(sum[i+1]));
        end
    endgenerate

    assign p_raw = sum[N];

    // Arredondamento simples: + 2^(NFRAC-1) antes do shift
    wire [2*N-1:0] rounded = sum[N] + (NFRAC==0 ? {2*N{1'b0}} : {{(2*N-NFRAC){1'b0}}, { {(NFRAC-1){1'b0}}, 1'b1 }});
    wire [2*N-1:0] scaled  = (NFRAC==0) ? rounded : (rounded >> NFRAC);

    // Overflow ao reduzir
    wire sat_needed = |scaled[2*N-1:N];
    assign overflow = sat_needed;
    assign p_qm_n   = (sat_needed && SATURATE) ? {N{1'b1}} : scaled[N-1:0];
endmodule
