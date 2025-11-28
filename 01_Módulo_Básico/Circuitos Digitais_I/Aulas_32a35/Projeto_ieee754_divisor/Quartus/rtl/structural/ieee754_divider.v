// ============================================================================
// Arquivo  : ieee754_divider.v  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Estrutural com extractor + núcleo de divisão + empacotamento.
// Revisão   : v1.0 — criação inicial
// ============================================================================
module extractor_f(input [31:0] x, output sx, output [7:0] ex, output [22:0] fx);
    assign sx=x[31]; assign ex=x[30:23]; assign fx=x[22:0];
endmodule

module core_div(input sx,sy, input [7:0] ex,ey, input [22:0] fx,fy, output [31:0] raw);
    reg [47:0] dividend; reg [23:0] divisor; reg [23:0] q; reg [7:0] e; reg s; integer k; reg [31:0] r;
    always @* begin
        if ({ey,fy}==0) r = 32'h7F800000;
        else if ({ex,fx}==0) r = 32'b0;
        else begin
            s = sx ^ sy; e = ex - ey + 8'd127;
            dividend = {1'b0,1'b1,fx} << 24;
            divisor  = {1'b1,fy};
            q = dividend / divisor;
            if (!q[23]) begin k=0; while(!q[23] && q!=0 && k<23) begin q=q<<1; e=e-1; k=k+1; end end
            r = {s,e,q[22:0]};
        end
    end
    assign raw = r;
endmodule

module ieee754_divider(input [31:0] a,b, output [31:0] result);
    wire sa,sb; wire [7:0] ea,eb; wire [22:0] fa,fb; wire [31:0] raw;
    extractor_f EA(a,sa,ea,fa);
    extractor_f EB(b,sb,eb,fb);
    core_div    CD(sa,sb,ea,eb,fa,fb,raw);
    assign result = raw;
endmodule
