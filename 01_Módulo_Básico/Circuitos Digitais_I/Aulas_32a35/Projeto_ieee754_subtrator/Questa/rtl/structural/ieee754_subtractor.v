// ============================================================================
// Arquivo  : ieee754_subtractor.v  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Estrutural com módulos: extractor, aligner, core, normalizer.
// Revisão   : v1.0 — criação inicial
// ============================================================================
module extractor(input [31:0] x, output sx, output [7:0] ex, output [22:0] fx);
    assign sx=x[31]; assign ex=x[30:23]; assign fx=x[22:0];
endmodule

module aligner(input [7:0] ea,eb, input [22:0] fa,fb,
               output [7:0] emax, output [24:0] ma,mb);
    reg [24:0] rma,rmb; reg [7:0] re;
    always @* begin
        rma={1'b1,1'b1,fa}; rmb={1'b1,1'b1,fb};
        if (ea>=eb) begin re=ea; rmb=rmb>>(ea-eb); end
        else begin re=eb; rma=rma>>(eb-ea); end
    end
    assign ma=rma; assign mb=rmb; assign emax=re;
endmodule

module core_sub(input sa,sb, input [24:0] ma,mb, output s, output [24:0] mr);
    reg sr; reg [24:0] m;
    always @* begin
        if (sa==sb) begin
            if (ma>=mb) begin m=ma-mb; sr=sa; end else begin m=mb-ma; sr=~sa; end
        end else begin m=ma+mb; sr=sa; end
    end
    assign s=sr; assign mr=m;
endmodule

module normalizer(input s, input [7:0] emax, input [24:0] m, output [31:0] y);
    reg [7:0] e; reg [24:0] mm; integer k; reg [31:0] r;
    always @* begin
        e=emax; mm=m;
        if (mm==0) r=32'b0;
        else begin
            if (!mm[24]) begin k=0; while(!mm[24] && mm!=0 && k<24) begin mm=mm<<1; e=e-1; k=k+1; end end
            r={s,e,mm[22:0]};
        end
    end
    assign y=r;
endmodule

module ieee754_subtractor(input [31:0] a,b, output [31:0] result);
    wire sa,sb; wire [7:0] ea,eb,emax; wire [22:0] fa,fb; wire [24:0] mr; wire s;
    wire [24:0] ma,mb;
    extractor EA(a,sa,ea,fa);
    extractor EB(b,sb,eb,fb);
    aligner   AL(ea,eb,fa,fb,emax,ma,mb);
    core_sub  CO(sa,sb,ma,mb,s,mr);
    normalizer NO(s,emax,mr,result);
endmodule
