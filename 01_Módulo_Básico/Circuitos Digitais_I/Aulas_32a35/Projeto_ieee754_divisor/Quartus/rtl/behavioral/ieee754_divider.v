// ============================================================================
// Arquivo  : ieee754_divider.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Divisor IEEE-754 single. Calcula sinal XOR, diferença de
//            expoentes (+bias) e usa divisão inteira das mantissas (24b).
//            Normaliza e empacota; truncamento; sem NaN/Inf completos.
// Revisão   : v1.0 — criação inicial
// ============================================================================
module ieee754_divider (
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] result
);
    wire sa=a[31], sb=b[31];
    wire [7:0] ea=a[30:23], eb=b[30:23];
    wire [22:0] fa=a[22:0], fb=b[22:0];

    reg [47:0] dividend;
    reg [23:0] divisor;
    reg [23:0] q;
    reg [7:0]  e;
    reg        s;
    integer k;

    always @* begin
        if ({eb,fb}==0) begin
            result = 32'h7F800000; // aproximação de Inf
        end else if ({ea,fa}==0) begin
            result = 32'b0;
        end else begin
            s = sa ^ sb;
            e = ea - eb + 8'd127;
            dividend = {1'b0,1'b1,fa} << 24; // 24.24
            divisor  = {1'b1,fb};            // 24.0
            q = dividend / divisor;          // truncamento

            if (!q[23]) begin
                k=0; while(!q[23] && q!=0 && k<23) begin q=q<<1; e=e-1; k=k+1; end
            end

            result = {s, e, q[22:0]};
        end
    end
endmodule
