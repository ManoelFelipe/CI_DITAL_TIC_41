// ============================================================================
// Arquivo  : ieee754_subtractor.v  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Fluxo de dados com funções combinacionais para alinhamento,
//            núcleo e normalização/empacotamento.
// Revisão   : v1.0 — criação inicial
// ============================================================================
module ieee754_subtractor (
    input  [31:0] a,
    input  [31:0] b,
    output [31:0] result
);
    wire sa=a[31], sb=b[31];
    wire [7:0] ea=a[30:23], eb=b[30:23];
    wire [22:0] fa=a[22:0], fb=b[22:0];

    function [57:0] do_align; // {emax, ma, mb}
        input [7:0] ea,eb; input [22:0] fa,fb;
        reg [24:0] ma,mb; reg [7:0] e;
        begin
            ma={1'b1,1'b1,fa}; mb={1'b1,1'b1,fb};
            if (ea>=eb) begin e=ea; mb=mb>>(ea-eb); end
            else begin e=eb; ma=ma>>(eb-ea); end
            do_align = {e,ma,mb};
        end
    endfunction

    function [25:0] core_mag; // {sign, mant}
        input sa,sb; input [24:0] ma,mb;
        reg s; reg [24:0] m;
        begin
            if (sa==sb) begin
                if (ma>=mb) begin m=ma-mb; s=sa; end
                else begin m=mb-ma; s=~sa; end
            end else begin m=ma+mb; s=sa; end
            core_mag={s,m};
        end
    endfunction

    function [31:0] norm_pack;
        input [7:0] e; input [25:0] sm;
        reg [7:0] ex; reg [24:0] m; reg s; integer k; reg [31:0] r;
        begin
            s=sm[25]; m=sm[24:0]; ex=e;
            if (m==0) r=32'b0;
            else begin
                if (!m[24]) begin k=0; while(!m[24] && m!=0 && k<24) begin m=m<<1; ex=ex-1; k=k+1; end end
                r={s,ex,m[22:0]};
            end
            norm_pack=r;
        end
    endfunction

    wire [57:0] A = do_align(ea,eb,fa,fb);
    wire [25:0] S = core_mag(sa,sb,A[49:25],A[24:0]);
    assign result = norm_pack(A[57:50], S);
endmodule
