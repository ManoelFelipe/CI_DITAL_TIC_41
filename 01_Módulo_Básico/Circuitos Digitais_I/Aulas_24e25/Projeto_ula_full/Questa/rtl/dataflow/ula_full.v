// ============================================================================
// Arquivo  : ula_full  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA combinacional parametrizável com múltiplos modos numéricos
//            descrita em estilo predominantemente dataflow. A lógica é
//            fatorada em funções combinacionais e atribuída via assigns,
//            mantendo equivalência funcional com a versão behavioral.
//            Largura padrão de 8 bits, ponto fixo Q e mini‑float simplificado.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================================================================
// Módulo: ula_full_dataflow
// Estratégia: descrever a ULA como composição de funções combinacionais
//             e wires intermediários, evitando always sempre que possível.
// ============================================================================
module ula_full_dataflow
#(
    parameter WIDTH = 8,          // Largura do barramento
    parameter FRAC  = 4           // Bits fracionários para modo Q
)(
    input      [WIDTH-1:0] op_a,  // Operando A
    input      [WIDTH-1:0] op_b,  // Operando B
    input      [2:0]       op_sel,// Código da operação
    input      [2:0]       num_mode, // Modo numérico
    output     [WIDTH-1:0] result,   // Resultado da operação
    output                  flag_overflow, // Overflow aritmético
    output                  flag_saturate, // Saturação aplicada
    output                  flag_zero,     // Resultado zero
    output                  flag_negative, // Bit de sinal do resultado
    output                  flag_carry     // Carry/borrow em inteiros
);

    // ------------------------------------------------------------------------
    // Wires internos que recebem o resultado e flags de uma função central.
    // ------------------------------------------------------------------------
    wire [WIDTH-1:0] w_result;
    wire             w_overflow;
    wire             w_saturate;
    wire             w_zero;
    wire             w_negative;
    wire             w_carry;

    // ------------------------------------------------------------------------
    // Atribuições contínuas para expor os sinais internos como saídas
    // ------------------------------------------------------------------------
    assign result        = w_result;
    assign flag_overflow = w_overflow;
    assign flag_saturate = w_saturate;
    assign flag_zero     = w_zero;
    assign flag_negative = w_negative;
    assign flag_carry    = w_carry;

    // ------------------------------------------------------------------------
    // Função combinacional que implementa a ULA em estilo dataflow.
    // A função é pura (sem estados) e recebe todos os sinais de controle.
    // ------------------------------------------------------------------------
    function [WIDTH+4:0] ula_core;
        input [WIDTH-1:0] f_op_a;
        input [WIDTH-1:0] f_op_b;
        input [2:0]       f_op_sel;
        input [2:0]       f_num_mode;
        integer           shift_amt;
        reg [WIDTH-1:0]   res_local;
        reg               ov_local;
        reg               sat_local;
        reg               z_local;
        reg               neg_local;
        reg               carry_local;

        reg [WIDTH:0]     ext_sum;
        reg [WIDTH:0]     ext_sub;
        reg [2*WIDTH:0]   ext_mul;

        reg signed [WIDTH:0] s_a;
        reg signed [WIDTH:0] s_b;
        reg signed [WIDTH:0] s_res;

        reg        sm_sign_a;
        reg        sm_sign_b;
        reg [WIDTH-1:0] sm_mag_a;
        reg [WIDTH-1:0] sm_mag_b;

        reg [2*WIDTH-1:0] fixed_mult_raw;
        reg [WIDTH-1:0]   fixed_mult_scaled;

        reg        mf_sign_a;
        reg [2:0]  mf_exp_a;
        reg [WIDTH-5:0] mf_mant_a;

        reg        mf_sign_b;
        reg [2:0]  mf_exp_b;
        reg [WIDTH-5:0] mf_mant_b;

        reg        mf_sign_res;
        reg [2:0]  mf_exp_res;
        reg [WIDTH-5:0] mf_mant_res;
    begin
        // Inicialização padrão dos sinais locais
        res_local  = {WIDTH{1'b0}};
        ov_local   = 1'b0;
        sat_local  = 1'b0;
        z_local    = 1'b0;
        neg_local  = 1'b0;
        carry_local= 1'b0;

        ext_sum    = { (WIDTH+1){1'b0} };
        ext_sub    = { (WIDTH+1){1'b0} };
        ext_mul    = { (2*WIDTH+1){1'b0} };

        s_a        = {f_op_a[WIDTH-1], f_op_a};
        s_b        = {f_op_b[WIDTH-1], f_op_b};
        s_res      = { (WIDTH+1){1'b0} };

        sm_sign_a  = f_op_a[WIDTH-1];
        sm_sign_b  = f_op_b[WIDTH-1];
        sm_mag_a   = {1'b0, f_op_a[WIDTH-2:0]};
        sm_mag_b   = {1'b0, f_op_b[WIDTH-2:0]};

        fixed_mult_raw    = { (2*WIDTH){1'b0} };
        fixed_mult_scaled = {WIDTH{1'b0}};

        mf_sign_a   = f_op_a[WIDTH-1];
        mf_exp_a    = f_op_a[WIDTH-2:WIDTH-4];
        mf_mant_a   = f_op_a[WIDTH-5:0];

        mf_sign_b   = f_op_b[WIDTH-1];
        mf_exp_b    = f_op_b[WIDTH-2:WIDTH-4];
        mf_mant_b   = f_op_b[WIDTH-5:0];

        mf_sign_res = 1'b0;
        mf_exp_res  = 3'b000;
        mf_mant_res = { (WIDTH-4){1'b0} };

        shift_amt   = f_op_b[2:0];

        // Seleção por modo numérico com case aninhado em f_op_sel
        case (f_num_mode)
            3'b000: begin
                case (f_op_sel)
                    3'b000: begin
                        ext_sum   = {1'b0, f_op_a} + {1'b0, f_op_b};
                        res_local = ext_sum[WIDTH-1:0];
                        carry_local = ext_sum[WIDTH];
                        ov_local    = carry_local;
                    end
                    3'b001: begin
                        ext_sub   = {1'b0, f_op_a} - {1'b0, f_op_b};
                        res_local = ext_sub[WIDTH-1:0];
                        carry_local = ext_sub[WIDTH];
                        ov_local    = carry_local;
                    end
                    3'b010: begin
                        ext_mul   = {1'b0, f_op_a} * {1'b0, f_op_b};
                        res_local = ext_mul[WIDTH-1:0];
                        ov_local  = |ext_mul[2*WIDTH-1:WIDTH];
                        if (ov_local) begin
                            sat_local = 1'b1;
                            res_local = {WIDTH{1'b1}};
                        end
                    end
                    3'b011: res_local = f_op_a & f_op_b;
                    3'b100: res_local = f_op_a | f_op_b;
                    3'b101: res_local = f_op_a ^ f_op_b;
                    3'b110: res_local = f_op_a << shift_amt;
                    3'b111: res_local = f_op_a >> shift_amt;
                    default: res_local = {WIDTH{1'b0}};
                endcase
            end
            3'b001: begin
                case (f_op_sel)
                    3'b000: begin
                        s_res    = s_a + s_b;
                        res_local= s_res[WIDTH-1:0];
                        ov_local = (s_res[WIDTH] != s_res[WIDTH-1]);
                        if (ov_local) begin
                            sat_local = 1'b1;
                            if (s_res[WIDTH])
                                res_local = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                res_local = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b001: begin
                        s_res    = s_a - s_b;
                        res_local= s_res[WIDTH-1:0];
                        ov_local = (s_res[WIDTH] != s_res[WIDTH-1]);
                        if (ov_local) begin
                            sat_local = 1'b1;
                            if (s_res[WIDTH])
                                res_local = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                res_local = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b010: begin
                        ext_mul = $signed(f_op_a) * $signed(f_op_b);
                        res_local = ext_mul[WIDTH-1:0];
                        ov_local = |ext_mul[2*WIDTH-1:WIDTH] &
                                   ~{(WIDTH){res_local[WIDTH-1]}};
                        if (ov_local) begin
                            sat_local = 1'b1;
                            if (ext_mul[2*WIDTH-1])
                                res_local = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                res_local = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b011: res_local = f_op_a & f_op_b;
                    3'b100: res_local = f_op_a | f_op_b;
                    3'b101: res_local = f_op_a ^ f_op_b;
                    3'b110: res_local = $signed(f_op_a) <<< shift_amt;
                    3'b111: res_local = $signed(f_op_a) >>> shift_amt;
                    default: res_local = {WIDTH{1'b0}};
                endcase
            end
            3'b010: begin
                case (f_op_sel)
                    3'b000: begin
                        if (sm_sign_a == sm_sign_b) begin
                            ext_sum   = {1'b0, sm_mag_a} + {1'b0, sm_mag_b};
                            ov_local  = ext_sum[WIDTH] | ext_sum[WIDTH-1];
                            if (ov_local) begin
                                sat_local = 1'b1;
                                res_local = {sm_sign_a, {WIDTH-1{1'b1}}};
                            end else begin
                                res_local = {sm_sign_a, ext_sum[WIDTH-2:0]};
                            end
                        end else begin
                            if (sm_mag_a >= sm_mag_b) begin
                                ext_sub = {1'b0, sm_mag_a} - {1'b0, sm_mag_b};
                                res_local = {sm_sign_a, ext_sub[WIDTH-2:0]};
                            end else begin
                                ext_sub = {1'b0, sm_mag_b} - {1'b0, sm_mag_a};
                                res_local = {sm_sign_b, ext_sub[WIDTH-2:0]};
                            end
                        end
                    end
                    3'b001: begin
                        sm_sign_b = ~sm_sign_b;
                        if (sm_sign_a == sm_sign_b) begin
                            ext_sum   = {1'b0, sm_mag_a} + {1'b0, sm_mag_b};
                            ov_local  = ext_sum[WIDTH] | ext_sum[WIDTH-1];
                            if (ov_local) begin
                                sat_local = 1'b1;
                                res_local = {sm_sign_a, {WIDTH-1{1'b1}}};
                            end else begin
                                res_local = {sm_sign_a, ext_sum[WIDTH-2:0]};
                            end
                        end else begin
                            if (sm_mag_a >= sm_mag_b) begin
                                ext_sub = {1'b0, sm_mag_a} - {1'b0, sm_mag_b};
                                res_local = {sm_sign_a, ext_sub[WIDTH-2:0]};
                            end else begin
                                ext_sub = {1'b0, sm_mag_b} - {1'b0, sm_mag_a};
                                res_local = {sm_sign_b, ext_sub[WIDTH-2:0]};
                            end
                        end
                    end
                    3'b010: begin
                        ext_mul = sm_mag_a * sm_mag_b;
                        mf_sign_res = sm_sign_a ^ sm_sign_b;
                        ov_local = |ext_mul[2*WIDTH-1:WIDTH] | ext_mul[WIDTH-1];
                        if (ov_local) begin
                            sat_local = 1'b1;
                            res_local = {mf_sign_res, {WIDTH-1{1'b1}}};
                        end else begin
                            res_local = {mf_sign_res, ext_mul[WIDTH-2:0]};
                        end
                    end
                    3'b011: res_local = {1'b0, f_op_a[WIDTH-2:0] & f_op_b[WIDTH-2:0]};
                    3'b100: res_local = {1'b0, f_op_a[WIDTH-2:0] | f_op_b[WIDTH-2:0]};
                    3'b101: res_local = {1'b0, f_op_a[WIDTH-2:0] ^ f_op_b[WIDTH-2:0]};
                    3'b110: res_local = {sm_sign_a, f_op_a[WIDTH-2:0] << shift_amt};
                    3'b111: res_local = {sm_sign_a, f_op_a[WIDTH-2:0] >> shift_amt};
                    default: res_local = {WIDTH{1'b0}};
                endcase
            end
            3'b011: begin
                case (f_op_sel)
                    3'b000: begin
                        s_res    = s_a + s_b;
                        res_local= s_res[WIDTH-1:0];
                        ov_local = (s_res[WIDTH] != s_res[WIDTH-1]);
                        if (ov_local) begin
                            sat_local = 1'b1;
                            if (s_res[WIDTH])
                                res_local = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                res_local = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b001: begin
                        s_res    = s_a - s_b;
                        res_local= s_res[WIDTH-1:0];
                        ov_local = (s_res[WIDTH] != s_res[WIDTH-1]);
                        if (ov_local) begin
                            sat_local = 1'b1;
                            if (s_res[WIDTH])
                                res_local = {1'b1, {WIDTH-1{1'b0}}};
                            else
                                res_local = {1'b0, {WIDTH-1{1'b1}}};
                        end
                    end
                    3'b010: begin
                        fixed_mult_raw    = $signed(f_op_a) * $signed(f_op_b);
                        fixed_mult_scaled = fixed_mult_raw[FRAC +: WIDTH];
                        res_local         = fixed_mult_scaled;
                    end
                    3'b011: res_local = f_op_a & f_op_b;
                    3'b100: res_local = f_op_a | f_op_b;
                    3'b101: res_local = f_op_a ^ f_op_b;
                    3'b110: res_local = $signed(f_op_a) <<< shift_amt;
                    3'b111: res_local = $signed(f_op_a) >>> shift_amt;
                    default: res_local = {WIDTH{1'b0}};
                endcase
            end
            3'b100: begin
                case (f_op_sel)
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
                        res_local = {mf_sign_res, mf_exp_res, mf_mant_res};
                    end
                    3'b010: begin
                        mf_exp_res  = mf_exp_a + mf_exp_b;
                        mf_mant_res = (mf_mant_a * mf_mant_b) >> (WIDTH-4-1);
                        mf_sign_res = mf_sign_a ^ mf_sign_b;
                        res_local   = {mf_sign_res, mf_exp_res, mf_mant_res};
                    end
                    default: res_local = {WIDTH{1'b0}};
                endcase
            end
            default: begin
                case (f_op_sel)
                    3'b000: begin
                        ext_sum   = {1'b0, f_op_a} + {1'b0, f_op_b};
                        res_local = ext_sum[WIDTH-1:0];
                        carry_local = ext_sum[WIDTH];
                        ov_local    = carry_local;
                    end
                    3'b001: begin
                        ext_sub   = {1'b0, f_op_a} - {1'b0, f_op_b};
                        res_local = ext_sub[WIDTH-1:0];
                        carry_local = ext_sub[WIDTH];
                        ov_local    = carry_local;
                    end
                    default: res_local = {WIDTH{1'b0}};
                endcase
            end
        endcase

        z_local   = (res_local == {WIDTH{1'b0}});
        neg_local = res_local[WIDTH-1];

        ula_core = {res_local, ov_local, sat_local, z_local, neg_local, carry_local};
    end
    endfunction

    // Chamada da função central
    wire [WIDTH+4:0] w_packed;
    assign w_packed = ula_core(op_a, op_b, op_sel, num_mode);

    // Desempacotamento do vetor retornado em resultado e flags
    assign w_result    = w_packed[WIDTH+4:5];
    assign w_overflow  = w_packed[4];
    assign w_saturate  = w_packed[3];
    assign w_zero      = w_packed[2];
    assign w_negative  = w_packed[1];
    assign w_carry     = w_packed[0];

endmodule
