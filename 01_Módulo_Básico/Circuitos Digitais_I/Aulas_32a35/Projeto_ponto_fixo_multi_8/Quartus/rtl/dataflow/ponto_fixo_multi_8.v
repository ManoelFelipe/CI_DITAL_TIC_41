
// -----------------------------------------------------------------------------
/* ponto_fixo_multi_8.v (Dataflow)
   Implementação dataflow do multiplicador Qm.n (parametrizável, sem sinal).
   A lógica é descrita com atribuições contínuas (assign). */
// -----------------------------------------------------------------------------
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
    // Produto inteiro
    wire [2*N-1:0] mult_full = a * b;
    assign p_raw = mult_full;

    // Arredondamento e reescala
    wire [2*N-1:0] rounded = mult_full + (NFRAC==0 ? {2*N{1'b0}} : {{(2*N-(NFRAC)){1'b0}}, { {(NFRAC-1){1'b0}}, 1'b1 }});
    wire [2*N-1:0] scaled  = (NFRAC==0) ? rounded : (rounded >> NFRAC);

    // Overflow ao reduzir para N bits
    wire sat_needed = |scaled[2*N-1:N];
    assign overflow = sat_needed;

    // Saturação condicional
    assign p_qm_n = (sat_needed && SATURATE) ? {N{1'b1}} : scaled[N-1:0];
endmodule
