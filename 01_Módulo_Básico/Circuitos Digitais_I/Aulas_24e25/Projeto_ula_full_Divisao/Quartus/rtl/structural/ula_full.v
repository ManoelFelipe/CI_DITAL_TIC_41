// ============================================================================
// Arquivo  : ula_full  (implementacao STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compativel com Quartus e Questa (Verilog 2001)
// Descricao: Implementacao estrutural da ULA_FULL, instanciando um nucleo
//            combinacional reutilizavel. A hierarquia facilita futuras
//            extensoes como pipeline, registradores de entrada/saida e
//            multiplexacao de operandos, mantendo a mesma interface externa.
// Revisao   : v1.0 — criacao inicial
// ============================================================================


// MÓDULO 1: WRAPPER
module ula_full_structural
#(
    parameter WIDTH = 8,
    parameter FRAC  = 4
)(
    input      [WIDTH-1:0] op_a,
    input      [WIDTH-1:0] op_b,
    input      [3:0]       op_sel,
    input      [2:0]       num_mode,
    output     [WIDTH-1:0] result,
    output                 flag_overflow,
    output                 flag_saturate,
    output                 flag_zero,
    output                 flag_negative,
    output                 flag_carry
);
    // Fios de conexão interna
    wire [WIDTH-1:0] core_result;
    wire             core_overflow, core_saturate, core_zero, core_negative, core_carry;

    // Instância do Core
    ula_full_core #(.WIDTH(WIDTH), .FRAC(FRAC)) core_inst (
        .op_a(op_a), .op_b(op_b), .op_sel(op_sel), .num_mode(num_mode),
        .result(core_result), .flag_overflow(core_overflow),
        .flag_saturate(core_saturate), .flag_zero(core_zero),
        .flag_negative(core_negative), .flag_carry(core_carry)
    );

    // Saídas
    assign result        = core_result;
    assign flag_overflow = core_overflow;
    assign flag_saturate = core_saturate;
    assign flag_zero     = core_zero;
    assign flag_negative = core_negative;
    assign flag_carry    = core_carry;
endmodule

// MÓDULO 2: CORE LÓGICO (CORRIGIDO)
module ula_full_core
#(
    parameter WIDTH = 8,
    parameter FRAC  = 4
)(
    input      [WIDTH-1:0] op_a,
    input      [WIDTH-1:0] op_b,
    input      [3:0]       op_sel,
    input      [2:0]       num_mode,
    output reg [WIDTH-1:0] result,
    output reg             flag_overflow,
    output reg             flag_saturate,
    output reg             flag_zero,
    output reg             flag_negative,
    output reg             flag_carry
);
    reg [2*WIDTH-1:0]        tmp_unsigned;
    reg signed [2*WIDTH-1:0] tmp_signed;
    
    reg signed [WIDTH-1:0] a_signed, b_signed;
    reg [WIDTH-1:0]        a_unsigned, b_unsigned;

    localparam SHIFT_BITS = $clog2(WIDTH);

    always @* begin
        result        = {WIDTH{1'b0}};
        flag_overflow = 1'b0; flag_saturate = 1'b0; flag_zero = 1'b0;
        flag_negative = 1'b0; flag_carry    = 1'b0;

        a_unsigned = op_a; b_unsigned = op_b;
        a_signed   = op_a; b_signed   = op_b;

        case (num_mode)
            // UNSIGNED
            3'b000: begin 
                case (op_sel)
                    4'b0000: begin // ADD
                        tmp_unsigned   = {1'b0, a_unsigned} + {1'b0, b_unsigned};
                        result         = tmp_unsigned[WIDTH-1:0];
                        flag_carry     = tmp_unsigned[WIDTH];
                        flag_overflow  = flag_carry;
                    end
                    4'b0001: begin // SUB
                        tmp_unsigned   = {1'b0, a_unsigned} - {1'b0, b_unsigned};
                        result         = tmp_unsigned[WIDTH-1:0];
                        flag_carry     = tmp_unsigned[WIDTH];
                        flag_overflow  = flag_carry;
                    end
                    4'b0010: begin // MUL
                        tmp_unsigned   = a_unsigned * b_unsigned;
                        result         = tmp_unsigned[WIDTH-1:0];
                        flag_overflow  = |tmp_unsigned[2*WIDTH-1:WIDTH];
                    end
                    4'b0011: begin // DIVU
                        if (b_unsigned != 0) begin
                            result        = a_unsigned / b_unsigned;
                            flag_overflow = 1'b0;
                        end else begin
                            result        = {WIDTH{1'b0}};
                            flag_overflow = 1'b1; flag_saturate = 1'b1;
                        end
                    end
                    // Lógicas
                    4'b0110: result = a_unsigned & b_unsigned;
                    4'b0111: result = a_unsigned | b_unsigned;
                    4'b1000: result = a_unsigned ^ b_unsigned;
                    4'b1001: result = ~(a_unsigned & b_unsigned);
                    4'b1010: result = ~(a_unsigned | b_unsigned);
                    4'b1011: result = ~(a_unsigned ^ b_unsigned);
                    // Shifts
                    4'b1100: result = a_unsigned << op_b[SHIFT_BITS-1:0];
                    4'b1101: result = a_unsigned >> op_b[SHIFT_BITS-1:0];
                    4'b1110: result = a_unsigned >> op_b[SHIFT_BITS-1:0];
                    // CMP
                    4'b1111: begin
                        tmp_unsigned   = {1'b0, a_unsigned} - {1'b0, b_unsigned};
                        result         = tmp_unsigned[WIDTH-1:0];
                        flag_carry     = tmp_unsigned[WIDTH];
                        flag_overflow  = flag_carry;
                    end
                    default: result = {WIDTH{1'b0}};
                endcase
            end

            // SIGNED
            3'b001: begin 
                case (op_sel)
                    4'b0000: begin // ADD
                        tmp_signed     = a_signed + b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] == b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0001: begin // SUB
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0010: begin // MUL Signed [CORRIGIDO]
                        tmp_signed     = a_signed * b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        // Canonical check
                        flag_overflow  = (tmp_signed[2*WIDTH-1:WIDTH] != {WIDTH{tmp_signed[WIDTH-1]}});
                    end
                    4'b0100: begin // DIVS
                        if (b_signed != 0) begin
                            tmp_signed    = a_signed / b_signed;
                            result        = tmp_signed[WIDTH-1:0];
                            flag_overflow = 1'b0;
                        end else begin
                            result        = {1'b0, {WIDTH-1{1'b1}}};
                            flag_overflow = 1'b1; flag_saturate = 1'b1;
                        end
                    end
                    // Lógicas
                    4'b0110: result = op_a & op_b;
                    4'b0111: result = op_a | op_b;
                    4'b1000: result = op_a ^ op_b;
                    4'b1001: result = ~(op_a & op_b);
                    4'b1010: result = ~(op_a | op_b);
                    4'b1011: result = ~(op_a ^ op_b);
                    // Shifts
                    4'b1100: result = op_a <<< op_b[SHIFT_BITS-1:0];
                    4'b1101: result = op_a >>> op_b[SHIFT_BITS-1:0];
                    4'b1110: result = op_a >>> op_b[SHIFT_BITS-1:0];
                    // CMP
                    4'b1111: begin
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    default: result = {WIDTH{1'b0}};
                endcase
                flag_negative = result[WIDTH-1];
            end

            // FIXED POINT
            3'b011: begin 
                case (op_sel)
                    4'b0000: begin // ADD
                        tmp_signed     = a_signed + b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] == b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0001: begin // SUB
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0010: begin // MUL Q [CORRIGIDO]
                        tmp_signed     = (a_signed * b_signed) >>> FRAC;
                        result         = tmp_signed[WIDTH-1:0];
                        // Canonical check
                        flag_overflow  = (tmp_signed[2*WIDTH-1:WIDTH] != {WIDTH{tmp_signed[WIDTH-1]}});
                    end
                    4'b0101: begin // DIV Q
                        if (b_signed != 0) begin
                            tmp_signed    = (a_signed <<< FRAC) / b_signed;
                            result        = tmp_signed[WIDTH-1:0];
                            flag_overflow = 1'b0;
                        end else begin
                            result        = {1'b0, {WIDTH-1{1'b1}}};
                            flag_overflow = 1'b1; flag_saturate = 1'b1;
                        end
                    end
                    // Lógicas e Shifts
                    4'b0110: result = op_a & op_b;
                    4'b0111: result = op_a | op_b;
                    4'b1000: result = op_a ^ op_b;
                    4'b1001: result = ~(op_a & op_b);
                    4'b1010: result = ~(op_a | op_b);
                    4'b1011: result = ~(op_a ^ op_b);
                    4'b1100: result = op_a <<< op_b[SHIFT_BITS-1:0];
                    4'b1101: result = op_a >>> op_b[SHIFT_BITS-1:0];
                    4'b1110: result = op_a >>> op_b[SHIFT_BITS-1:0];
                    4'b1111: begin
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    default: result = {WIDTH{1'b0}};
                endcase
                flag_negative = result[WIDTH-1];
            end
            default: result = {WIDTH{1'b0}};
        endcase

        if (result == {WIDTH{1'b0}}) flag_zero = 1'b1;
        else flag_zero = 1'b0;
    end
endmodule