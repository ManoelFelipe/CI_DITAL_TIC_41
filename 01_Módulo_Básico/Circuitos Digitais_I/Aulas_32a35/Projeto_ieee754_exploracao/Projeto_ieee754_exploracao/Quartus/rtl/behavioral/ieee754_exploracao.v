// -------------------------------------------------------------
// Módulo: ieee754_exploracao.v (Behavioral)
// Descrição: Operações básicas IEEE 754 (single-precision) — SOMA,
// SUBTRAÇÃO, MULTIPLICAÇÃO e DIVISÃO. Implementação didática,
// assumindo operandos finitos e não-denormalizados.
// -------------------------------------------------------------
module ieee754_exploracao(
    input  [31:0] a,           // operando A (IEEE754)
    input  [31:0] b,           // operando B (IEEE754)
    input  [1:0]  op_sel,      // 00=Soma | 01=Sub | 10=Mul | 11=Div
    output reg [31:0] result   // resultado IEEE754
);

    // Campos IEEE754
    reg        sign_a, sign_b, sign_res;
    reg [7:0]  exp_a, exp_b, exp_res;
    reg [23:0] mant_a, mant_b;      // inclui o 1 implícito
    reg [47:0] mant_tmp;            // acumulador/normalização

    // Função auxiliar: empacotar campos em palavra IEEE754
    function [31:0] pack;
        input s;
        input [7:0] e;
        input [22:0] m;
        begin
            pack = {s, e, m};
        end
    endfunction

    // Implementação didática (assume números positivos e normais)
    always @(*) begin
        // extração dos campos
        sign_a = a[31];
        sign_b = b[31];
        exp_a  = a[30:23];
        exp_b  = b[30:23];
        mant_a = {1'b1, a[22:0]};   // acrescenta 1 implícito
        mant_b = {1'b1, b[22:0]};
        sign_res = 1'b0;
        exp_res  = 8'd0;
        mant_tmp = 48'd0;
        result   = 32'd0;

        case (op_sel)
            // ------------------ SOMA ------------------
            2'b00: begin
                if (exp_a > exp_b) begin
                    mant_b = mant_b >> (exp_a - exp_b);
                    exp_res = exp_a;
                end else begin
                    mant_a = mant_a >> (exp_b - exp_a);
                    exp_res = exp_b;
                end
                mant_tmp = mant_a + mant_b;      // soma das mantissas (24 bits)
                if (mant_tmp[24]) begin          // carry => normaliza para 1.x
                    mant_tmp = mant_tmp >> 1;
                    exp_res  = exp_res + 1;
                end
                result = pack(sign_res, exp_res, mant_tmp[22:0]);
            end

            // ---------------- SUBTRAÇÃO ----------------
            2'b01: begin
                if (exp_a > exp_b) begin
                    mant_b = mant_b >> (exp_a - exp_b);
                    exp_res = exp_a;
                end else begin
                    mant_a = mant_a >> (exp_b - exp_a);
                    exp_res = exp_b;
                end
                // subtração sem sinal (didática)
                mant_tmp = (mant_a >= mant_b) ? (mant_a - mant_b) : (mant_b - mant_a);
                // normalização à esquerda até obter 1.x
                if (mant_tmp != 0) begin
                    while (mant_tmp[23] == 1'b0 && exp_res > 0) begin
                        mant_tmp = mant_tmp << 1;
                        exp_res  = exp_res - 1;
                    end
                end
                result = pack(sign_res, exp_res, mant_tmp[22:0]);
            end

            // --------------- MULTIPLICAÇÃO --------------
            2'b10: begin
                sign_res = sign_a ^ sign_b;
                mant_tmp = mant_a * mant_b;              // 24x24 = 48b
                exp_res  = (exp_a + exp_b) - 8'd127;     // remove bias
                // normalizar: resultado fica em [46:23] ou [47:24]
                if (mant_tmp[47]) begin
                    mant_tmp = mant_tmp >> 1;
                    exp_res  = exp_res + 1;
                end
                result = pack(sign_res, exp_res, mant_tmp[45:23]);
            end

            // ------------------ DIVISÃO -----------------
            2'b11: begin
                sign_res = sign_a ^ sign_b;
                // escala mant_a para preservar precisão antes da divisão
                mant_tmp = ( {mant_a, 23'd0} / mant_b ); // (mant_a << 23) / mant_b
                exp_res  = (exp_a - exp_b) + 8'd127;     // recoloca bias
                // garantir 1.x
                if (mant_tmp[23] == 1'b0 && mant_tmp != 0) begin
                    while (mant_tmp[23] == 1'b0 && exp_res > 0) begin
                        mant_tmp = mant_tmp << 1;
                        exp_res  = exp_res - 1;
                    end
                end
                result = pack(sign_res, exp_res, mant_tmp[22:0]);
            end
        endcase
    end
endmodule
