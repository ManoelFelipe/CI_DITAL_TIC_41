// ============================================================================
// Arquivo  : ieee754_divider.v  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Fluxo de dados com função combinacional que realiza a divisão
//            das mantissas usando operador '/' e normalização.
// Revisão   : v1.0 — criação inicial
// ============================================================================
module ieee754_divider (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    wire sa=a[31], sb=b[31];
    wire [7:0] ea=a[30:23], eb=b[30:23];
    wire [22:0] fa=a[22:0], fb=b[22:0];

    function [31:0] core;
        input sa,sb; input [7:0] ea,eb; input [22:0] fa,fb;
        reg [47:0] dividend; reg [23:0] divisor; reg [23:0] q; reg [7:0] e; reg s; integer k;
        begin
            if ({eb,fb}==0) core = 32'h7F800000;
            else if ({ea,fa}==0) core = 32'b0;
            else begin
                s = sa ^ sb; e = ea - eb + 8'd127;
                dividend = {1'b0,1'b1,fa} << 24;
                divisor  = {1'b1,fb};
                q = dividend / divisor;
                if (!q[23]) begin k=0; while(!q[23] && q!=0 && k<23) begin q=q<<1; e=e-1; k=k+1; end end
                core = {s,e,q[22:0]};
            end
        end
    endfunction

    assign result = core(sa,sb,ea,eb,fa,fb);
endmodule
