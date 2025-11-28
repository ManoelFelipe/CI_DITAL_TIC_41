// ============================================================================
// Arquivo  : ieee754_subtractor.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Subtrator IEEE-754 (single). Extrai campos, alinha mantissas,
//            resolve a - b (considerando sinais) e normaliza; truncamento.
// Revisão   : v1.0 — criação inicial
// ============================================================================
module ieee754_subtractor (
    input  [31:0] a,
    input  [31:0] b,
    output reg [31:0] result
);
    // Campos
    wire sign_a = a[31];
    wire [7:0] exp_a = a[30:23];
    wire [22:0] frac_a = a[22:0];
    wire sign_b = b[31];
    wire [7:0] exp_b = b[30:23];
    wire [22:0] frac_b = b[22:0];

    // Mantissas estendidas (25b: 1 implícito + 1 extra + 23 frac)
    reg [24:0] mant_a, mant_b;
    reg [24:0] mant_res;
    reg [7:0]  exp_res;
    reg        sign_res;
    integer sh;

    always @* begin
        // Inserção do 1 implícito e bit extra
        mant_a = {1'b1,1'b1,frac_a};
        mant_b = {1'b1,1'b1,frac_b};

        // Alinhamento por expoente
        if (exp_a >= exp_b) begin
            exp_res = exp_a;
            mant_b = mant_b >> (exp_a - exp_b);
        end else begin
            exp_res = exp_b;
            mant_a = mant_a >> (exp_b - exp_a);
        end

        // Núcleo de magnitudes conforme sinais
        if (sign_a == sign_b) begin
            if (mant_a >= mant_b) begin mant_res = mant_a - mant_b; sign_res = sign_a; end
            else begin mant_res = mant_b - mant_a; sign_res = ~sign_a; end
        end else begin
            mant_res = mant_a + mant_b; sign_res = sign_a;
        end

        // Normalização à esquerda
        if (!mant_res[24]) begin
            sh = 0;
            while (!mant_res[24] && mant_res != 0 && sh < 24) begin
                mant_res = mant_res << 1;
                exp_res  = exp_res - 1;
                sh = sh + 1;
            end
        end

        // Empacotamento
        if (mant_res == 0) result = 32'b0;
        else begin
            result[31]   = sign_res;
            result[30:23]= exp_res;
            result[22:0] = mant_res[22:0];
        end
    end
endmodule
