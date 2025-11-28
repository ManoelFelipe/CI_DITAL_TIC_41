// ============================================================================
// Arquivo  : ula_full  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA combinacional parametrizável com suporte a múltiplas
//            representações numéricas (inteiro sem sinal, 2's complement,
//            sinal/magnitude, ponto fixo Q e mini‑float simplificado).
//            Implementa operações aritméticas, lógicas e de deslocamento,
//            com detecção de overflow e saturação opcional por modo.
//            Largura padrão de 8 bits, sem registradores internos (latência 0).
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================================================================
// Módulo: ula_full_behavioral
// Estratégia: descrição puramente comportamental usando always @* e case,
//             centralizando todo o tratamento de modo numérico no mesmo
//             bloco. A ULA é combinacional e gera flags de status.
// ============================================================================
module ula_full_behavioral
#(
    parameter WIDTH = 8,          // Largura do barramento de dados
    parameter FRAC  = 4           // Quantidade de bits fracionários no modo Q
)(
    input      [WIDTH-1:0] op_a,  // Operando A
    input      [WIDTH-1:0] op_b,  // Operando B
    input      [2:0]       op_sel,// Código da operação
    input      [2:0]       num_mode, // Modo numérico da operação
    output reg [WIDTH-1:0] result,   // Resultado da operação
    output reg             flag_overflow,  // Flag de overflow aritmético
    output reg             flag_saturate,  // Flag indicando saturação aplicada
    output reg             flag_zero,      // Flag de resultado zero
    output reg             flag_negative,  // Flag de sinal (para representações com sinal)
    output reg             flag_carry      // Flag de carry/borrow em operações inteiras
);

    // ------------------------------------------------------------------------
    // Convenções de num_mode:
    // 000: inteiro sem sinal (unsigned)
    // 001: inteiro com sinal em 2's complement
    // 010: inteiro sinal/magnitude
    // 011: ponto fixo Q (2's complement com FRAC bits fracionários)
    // 100: mini‑float simplificado (1 bit sinal, 3 bits expoente, resto mantissa)
    // 101–111: reservados para extensões futuras (tratados como unsigned)
    // ------------------------------------------------------------------------

    // ------------------------------------------------------------------------
    // Declarações internas auxiliares usadas no bloco comportamental.
    // ------------------------------------------------------------------------
    reg  [WIDTH:0]   ext_unsigned_sum;   // Soma / sub sem sinal estendida
    reg  [WIDTH:0]   ext_unsigned_sub;   // Subtração sem sinal estendida
    reg  [2*WIDTH:0] ext_mult;           // Produto estendido para verificar overflow
    reg  signed [WIDTH:0]  ext_signed_a; // Versões estendidas com sinal
    reg  signed [WIDTH:0]  ext_signed_b;
    reg  signed [WIDTH:0]  ext_signed_res;
    reg  [WIDTH-1:0]       op_a_mag;     // Magnitude para sinal/magnitude
    reg  [WIDTH-1:0]       op_b_mag;
    reg                    op_a_sign;
    reg                    op_b_sign;
    reg  signed [WIDTH:0]  sm_intermediate;
    reg  [WIDTH-1:0]       fixed_tmp;
    reg  [2*WIDTH-1:0]     fixed_mult_raw;
    reg  [WIDTH-1:0]       fixed_mult_scaled;

    // Campos para mini‑float (só são interpretados quando num_mode == 3'b100)
    reg        mf_sign_a;
    reg [2:0]  mf_exp_a;
    reg [WIDTH-5:0] mf_mant_a;

    reg        mf_sign_b;
    reg [2:0]  mf_exp_b;
    reg [WIDTH-5:0] mf_mant_b;

    reg        mf_sign_res;
    reg [2:0]  mf_exp_res;
    reg [WIDTH-5:0] mf_mant_res;

    integer shift_amt; // quantidade de deslocamento baseada em op_b[2:0]

    // ------------------------------------------------------------------------
    // Bloco combinacional principal da ULA
    // ------------------------------------------------------------------------
    always @* begin
        // --------------------------------------------------------------------
        // Valores padrão para todas as saídas e variáveis internas
        // --------------------------------------------------------------------
        result        = {WIDTH{1'b0}};   // Resultado default: zero
        flag_overflow = 1'b0;            // Overflow inicialmente desligado
        flag_saturate = 1'b0;            // Saturação inicialmente desligada
        flag_zero     = 1'b0;            // Flag de zero default
        flag_negative = 1'b0;            // Flag de negativo default
        flag_carry    = 1'b0;            // Flag de carry default

        ext_unsigned_sum = { (WIDTH+1){1'b0} };
        ext_unsigned_sub = { (WIDTH+1){1'b0} };
        ext_mult         = { (2*WIDTH+1){1'b0} };

        ext_signed_a  = {1'b0, op_a};
        ext_signed_b  = {1'b0, op_b};
        ext_signed_res= { (WIDTH+1){1'b0} };

        op_a_mag      = op_a;
        op_b_mag      = op_b;
        op_a_sign     = 1'b0;
        op_b_sign     = 1'b0;

        sm_intermediate = { (WIDTH+1){1'b0} };

        fixed_tmp          = {WIDTH{1'b0}};
        fixed_mult_raw     = { (2*WIDTH){1'b0} };
        fixed_mult_scaled  = {WIDTH{1'b0}};

        mf_sign_a   = op_a[WIDTH-1];
        mf_exp_a    = op_a[WIDTH-2:WIDTH-4];
        mf_mant_a   = op_a[WIDTH-5:0];

        mf_sign_b   = op_b[WIDTH-1];
        mf_exp_b    = op_b[WIDTH-2:WIDTH-4];
        mf_mant_b   = op_b[WIDTH-5:0];

        mf_sign_res = 1'b0;
        mf_exp_res  = 3'b000;
        mf_mant_res = { (WIDTH-4){1'b0} };

        shift_amt   = op_b[2:0];

        // --------------------------------------------------------------------
        // Decisão principal por modo numérico
        // --------------------------------------------------------------------
        case (num_mode)
            // =============================================================
            // Modo 000: inteiro sem sinal
            // =============================================================
            3'b000: begin
                case (op_sel)
                    3'b000: begin
                        ext_unsigned_sum = {1'b0, op_a} + {1'b0, op_b};
                        result           = ext_unsigned_sum[WIDTH-1:0];
                        flag_carry       = ext_unsigned_sum[WIDTH];
                        flag_overflow    = flag_carry;
                    end
                    3'b001: begin
                        ext_unsigned_sub = {1'b0, op_a} - {1'b0, op_b};
                        result           = ext_unsigned_sub[WIDTH-1:0];
                        flag_carry       = ext_unsigned_sub[WIDTH]; // borrow
                        flag_overflow    = flag_carry;
                    end
                    3'b010: begin
                        ext_mult      = {1'b0, op_a} * {1'b0, op_b};
                        result        = ext_mult[WIDTH-1:0];
                        flag_overflow = |ext_mult[2*WIDTH-1:WIDTH];
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            result        = {WIDTH{1'b1}};
                        end
                    end
                    3'b011: begin
                        result = op_a & op_b;
                    end
                    3'b100: begin
                        result = op_a | op_b;
                    end
                    3'b101: begin
                        result = op_a ^ op_b;
                    end
                    3'b110: begin
                        result = op_a << shift_amt;
                    end
                    3'b111: begin
                        result = op_a >> shift_amt;
                    end
                    default: begin
                        result = {WIDTH{1'b0}};
                    end
                endcase
            end

            // =============================================================
            // Modo 001: inteiro com sinal em 2's complement
            // =============================================================
            3'b001: begin
                ext_signed_a = {op_a[WIDTH-1], op_a};
                ext_signed_b = {op_b[WIDTH-1], op_b};
                case (op_sel)
                    3'b000: begin
                        ext_signed_res = ext_signed_a + ext_signed_b;
                        result         = ext_signed_res[WIDTH-1:0];
                        flag_overflow  = (ext_signed_res[WIDTH] != ext_signed_res[WIDTH-1]);
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            if (ext_signed_res[WIDTH])
                                result = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                result = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b001: begin
                        ext_signed_res = ext_signed_a - ext_signed_b;
                        result         = ext_signed_res[WIDTH-1:0];
                        flag_overflow  = (ext_signed_res[WIDTH] != ext_signed_res[WIDTH-1]);
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            if (ext_signed_res[WIDTH])
                                result = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                result = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b010: begin
                        ext_mult = $signed(op_a) * $signed(op_b);
                        result   = ext_mult[WIDTH-1:0];
                        flag_overflow = |ext_mult[2*WIDTH-1:WIDTH] &
                                        ~{(WIDTH){result[WIDTH-1]}};
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            if (ext_mult[2*WIDTH-1])
                                result = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                result = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b011: begin
                        result = op_a & op_b;
                    end
                    3'b100: begin
                        result = op_a | op_b;
                    end
                    3'b101: begin
                        result = op_a ^ op_b;
                    end
                    3'b110: begin
                        result = $signed(op_a) <<< shift_amt;
                    end
                    3'b111: begin
                        result = $signed(op_a) >>> shift_amt;
                    end
                    default: begin
                        result = {WIDTH{1'b0}};
                    end
                endcase
            end

            // =============================================================
            // Modo 010: sinal/magnitude
            // =============================================================
            3'b010: begin
                op_a_sign = op_a[WIDTH-1];
                op_b_sign = op_b[WIDTH-1];
                op_a_mag  = {1'b0, op_a[WIDTH-2:0]};
                op_b_mag  = {1'b0, op_b[WIDTH-2:0]};
                case (op_sel)
                    3'b000: begin
                        if (op_a_sign == op_b_sign) begin
                            ext_unsigned_sum = {1'b0, op_a_mag} + {1'b0, op_b_mag};
                            flag_overflow    = ext_unsigned_sum[WIDTH] |
                                               ext_unsigned_sum[WIDTH-1];
                            if (flag_overflow) begin
                                flag_saturate = 1'b1;
                                result        = {op_a_sign, {WIDTH-1{1'b1}}};
                            end else begin
                                result = {op_a_sign, ext_unsigned_sum[WIDTH-2:0]};
                            end
                        end else begin
                            if (op_a_mag >= op_b_mag) begin
                                ext_unsigned_sub = {1'b0, op_a_mag} - {1'b0, op_b_mag};
                                result = {op_a_sign, ext_unsigned_sub[WIDTH-2:0]};
                            end else begin
                                ext_unsigned_sub = {1'b0, op_b_mag} - {1'b0, op_a_mag};
                                result = {op_b_sign, ext_unsigned_sub[WIDTH-2:0]};
                            end
                        end
                    end
                    3'b001: begin
                        op_b_sign = ~op_b_sign;
                        if (op_a_sign == op_b_sign) begin
                            ext_unsigned_sum = {1'b0, op_a_mag} + {1'b0, op_b_mag};
                            flag_overflow    = ext_unsigned_sum[WIDTH] |
                                               ext_unsigned_sum[WIDTH-1];
                            if (flag_overflow) begin
                                flag_saturate = 1'b1;
                                result        = {op_a_sign, {WIDTH-1{1'b1}}};
                            end else begin
                                result = {op_a_sign, ext_unsigned_sum[WIDTH-2:0]};
                            end
                        end else begin
                            if (op_a_mag >= op_b_mag) begin
                                ext_unsigned_sub = {1'b0, op_a_mag} - {1'b0, op_b_mag};
                                result = {op_a_sign, ext_unsigned_sub[WIDTH-2:0]};
                            end else begin
                                ext_unsigned_sub = {1'b0, op_b_mag} - {1'b0, op_a_mag};
                                result = {op_b_sign, ext_unsigned_sub[WIDTH-2:0]};
                            end
                        end
                    end
                    3'b010: begin
                        ext_mult = op_a_mag * op_b_mag;
                        mf_sign_res = op_a_sign ^ op_b_sign;
                        flag_overflow = |ext_mult[2*WIDTH-1:WIDTH] |
                                        ext_mult[WIDTH-1];
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            result        = {mf_sign_res, {WIDTH-1{1'b1}}};
                        end else begin
                            result = {mf_sign_res, ext_mult[WIDTH-2:0]};
                        end
                    end
                    3'b011: begin
                        result = {1'b0, op_a[WIDTH-2:0] & op_b[WIDTH-2:0]};
                    end
                    3'b100: begin
                        result = {1'b0, op_a[WIDTH-2:0] | op_b[WIDTH-2:0]};
                    end
                    3'b101: begin
                        result = {1'b0, op_a[WIDTH-2:0] ^ op_b[WIDTH-2:0]};
                    end
                    3'b110: begin
                        result = {op_a_sign, op_a[WIDTH-2:0] << shift_amt};
                    end
                    3'b111: begin
                        result = {op_a_sign, op_a[WIDTH-2:0] >> shift_amt};
                    end
                    default: begin
                        result = {WIDTH{1'b0}};
                    end
                endcase
            end

            // =============================================================
            // Modo 011: ponto fixo Q (2's complement com FRAC bits fracionários)
            // =============================================================
            3'b011: begin
                ext_signed_a = {op_a[WIDTH-1], op_a};
                ext_signed_b = {op_b[WIDTH-1], op_b};
                case (op_sel)
                    3'b000: begin
                        ext_signed_res = ext_signed_a + ext_signed_b;
                        result         = ext_signed_res[WIDTH-1:0];
                        flag_overflow  = (ext_signed_res[WIDTH] != ext_signed_res[WIDTH-1]);
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            if (ext_signed_res[WIDTH])
                                result = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                result = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b001: begin
                        ext_signed_res = ext_signed_a - ext_signed_b;
                        result         = ext_signed_res[WIDTH-1:0];
                        flag_overflow  = (ext_signed_res[WIDTH] != ext_signed_res[WIDTH-1]);
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            if (ext_signed_res[WIDTH])
                                result = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                result = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b010: begin
                        fixed_mult_raw = $signed(op_a) * $signed(op_b);
                        fixed_mult_scaled = fixed_mult_raw[FRAC +: WIDTH];
                        result = fixed_mult_scaled;
                        flag_overflow = |fixed_mult_raw[2*WIDTH-1:FRAC+WIDTH] |
                                        ~&{fixed_mult_raw[2*WIDTH-1], fixed_mult_raw[2*WIDTH-2:FRAC+WIDTH]};
                        if (flag_overflow) begin
                            flag_saturate = 1'b1;
                            if (fixed_mult_raw[2*WIDTH-1])
                                result = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                result = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b011: begin
                        result = op_a & op_b;
                    end
                    3'b100: begin
                        result = op_a | op_b;
                    end
                    3'b101: begin
                        result = op_a ^ op_b;
                    end
                    3'b110: begin
                        result = $signed(op_a) <<< shift_amt;
                    end
                    3'b111: begin
                        result = $signed(op_a) >>> shift_amt;
                    end
                    default: begin
                        result = {WIDTH{1'b0}};
                    end
                endcase
            end

            // =============================================================
            // Modo 100: mini‑float simplificado
            // =============================================================
            3'b100: begin
                case (op_sel)
                    3'b000: begin
                        if (mf_exp_a >= mf_exp_b) begin
                            mf_exp_res = mf_exp_a;
                            mf_mant_res = mf_mant_a +
                                           (mf_mant_b >> (mf_exp_a - mf_exp_b));
                            mf_sign_res = mf_sign_a;
                        end else begin
                            mf_exp_res = mf_exp_b;
                            mf_mant_res = mf_mant_b +
                                           (mf_mant_a >> (mf_exp_b - mf_exp_a));
                            mf_sign_res = mf_sign_b;
                        end
                        result = {mf_sign_res, mf_exp_res, mf_mant_res};
                    end
                    3'b010: begin
                        mf_exp_res  = mf_exp_a + mf_exp_b;
                        mf_mant_res = (mf_mant_a * mf_mant_b) >> (WIDTH-4-1);
                        mf_sign_res = mf_sign_a ^ mf_sign_b;
                        result      = {mf_sign_res, mf_exp_res, mf_mant_res};
                    end
                    default: begin
                        result = {WIDTH{1'b0}};
                    end
                endcase
            end

            // =============================================================
            // Modos não definidos: tratamos como inteiro sem sinal
            // =============================================================
            default: begin
                case (op_sel)
                    3'b000: begin
                        ext_unsigned_sum = {1'b0, op_a} + {1'b0, op_b};
                        result           = ext_unsigned_sum[WIDTH-1:0];
                        flag_carry       = ext_unsigned_sum[WIDTH];
                        flag_overflow    = flag_carry;
                    end
                    3'b001: begin
                        ext_unsigned_sub = {1'b0, op_a} - {1'b0, op_b};
                        result           = ext_unsigned_sub[WIDTH-1:0];
                        flag_carry       = ext_unsigned_sub[WIDTH];
                        flag_overflow    = flag_carry;
                    end
                    default: begin
                        result = {WIDTH{1'b0}};
                    end
                endcase
            end
        endcase

        // ----------------------------------------------------------------
        // Atualização das flags de zero e negativo com base no resultado
        // ----------------------------------------------------------------
        flag_zero     = (result == {WIDTH{1'b0}});
        flag_negative = result[WIDTH-1];
    end

endmodule
