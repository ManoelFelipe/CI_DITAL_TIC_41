// ============================================================================
// Arquivo  : ula_full  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA parametrizavel com suporte a multiplos modos numericos,
//            descrita em estilo dataflow por meio de uma funcao combinacional
//            que retorna resultado e flags empacotados em um unico vetor.
//            Adequada para reutilizacao de nucleo combinacional em pipelines.
// Revisao   : v1.0 — criacao inicial
// ============================================================================

module ula_full_dataflow
#(
    parameter WIDTH = 8,   // Largura de bits
    parameter FRAC  = 4    // Bits fracionários (Ponto Fixo)
)(
    // --- Interface ---
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

    // Constante calculada para slices de shift
    localparam SHIFT_BITS = $clog2(WIDTH);

    // Vetor empacotado para receber retorno da função
    // Formato: {Result, Ov, Sat, Zero, Neg, Car}
    wire [WIDTH+4:0] packed;
    
    // Chamada da Função Principal
    assign packed = ula_core_dataflow(op_a, op_b, op_sel, num_mode);

    // Desempacotamento para as saídas
    assign result        = packed[WIDTH+4:5];
    assign flag_overflow = packed[4];
    assign flag_saturate = packed[3];
    assign flag_zero     = packed[2];
    assign flag_negative = packed[1];
    assign flag_carry    = packed[0];

    // ========================================================================
    // FUNÇÃO LÓGICA (CORE)
    // ========================================================================
    function [WIDTH+4:0] ula_core_dataflow;
        input [WIDTH-1:0] f_op_a;
        input [WIDTH-1:0] f_op_b;
        input [3:0]       f_op_sel;
        input [2:0]       f_num_mode;

        // Variáveis locais da função
        reg [WIDTH-1:0] f_result;
        reg             f_overflow, f_saturate, f_zero, f_negative, f_carry;

        // Temporários expandidos
        reg [2*WIDTH-1:0]          tmp_unsigned;
        reg signed [2*WIDTH-1:0]   tmp_signed;
        
        // Castings
        reg signed [WIDTH-1:0] a_signed, b_signed;
        reg [WIDTH-1:0]        a_unsigned, b_unsigned;
        
        begin
            // Inicialização
            f_result   = {WIDTH{1'b0}};
            f_overflow = 1'b0; f_saturate = 1'b0; f_zero = 1'b0; 
            f_negative = 1'b0; f_carry    = 1'b0;
            
            // Atribuições
            a_unsigned = f_op_a; b_unsigned = f_op_b;
            a_signed   = f_op_a; b_signed   = f_op_b;

            case (f_num_mode)
                // ------------------------------------------------------------
                // Modo 0: UNSIGNED
                // ------------------------------------------------------------
                3'b000: begin 
                    case (f_op_sel)
                        4'b0000: begin // ADD
                            tmp_unsigned = {1'b0, a_unsigned} + {1'b0, b_unsigned};
                            f_result     = tmp_unsigned[WIDTH-1:0];
                            f_carry      = tmp_unsigned[WIDTH];
                            f_overflow   = f_carry;
                        end
                        4'b0001: begin // SUB
                            tmp_unsigned = {1'b0, a_unsigned} - {1'b0, b_unsigned};
                            f_result     = tmp_unsigned[WIDTH-1:0];
                            f_carry      = tmp_unsigned[WIDTH];
                            f_overflow   = f_carry;
                        end
                        4'b0010: begin // MUL
                            tmp_unsigned = a_unsigned * b_unsigned;
                            f_result     = tmp_unsigned[WIDTH-1:0];
                            f_overflow   = |tmp_unsigned[2*WIDTH-1:WIDTH];
                        end
                        4'b0011: begin // DIVU
                            if (b_unsigned != 0) begin
                                f_result   = a_unsigned / b_unsigned;
                                f_overflow = 1'b0;
                            end else begin
                                f_result   = {WIDTH{1'b0}};
                                f_overflow = 1'b1; f_saturate = 1'b1;
                            end
                        end
                        // Lógicas
                        4'b0110: f_result = a_unsigned & b_unsigned;
                        4'b0111: f_result = a_unsigned | b_unsigned;
                        4'b1000: f_result = a_unsigned ^ b_unsigned;
                        4'b1001: f_result = ~(a_unsigned & b_unsigned);
                        4'b1010: f_result = ~(a_unsigned | b_unsigned);
                        4'b1011: f_result = ~(a_unsigned ^ b_unsigned);
                        // Shifts
                        4'b1100: f_result = a_unsigned << f_op_b[SHIFT_BITS-1:0];
                        4'b1101: f_result = a_unsigned >> f_op_b[SHIFT_BITS-1:0];
                        4'b1110: f_result = a_unsigned >> f_op_b[SHIFT_BITS-1:0];
                        // CMP
                        4'b1111: begin
                            tmp_unsigned = {1'b0, a_unsigned} - {1'b0, b_unsigned};
                            f_result     = tmp_unsigned[WIDTH-1:0];
                            f_carry      = tmp_unsigned[WIDTH];
                            f_overflow   = f_carry;
                        end
                        default: f_result = {WIDTH{1'b0}};
                    endcase
                end

                // ------------------------------------------------------------
                // Modo 1: SIGNED
                // ------------------------------------------------------------
                3'b001: begin 
                    case (f_op_sel)
                        4'b0000: begin // ADD
                            tmp_signed   = a_signed + b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            f_overflow   = (a_signed[WIDTH-1] == b_signed[WIDTH-1]) &&
                                           (f_result[WIDTH-1]  != a_signed[WIDTH-1]);
                        end
                        4'b0001: begin // SUB
                            tmp_signed   = a_signed - b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            f_overflow   = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                           (f_result[WIDTH-1]  != a_signed[WIDTH-1]);
                        end
                        4'b0010: begin // MUL Signed [CORRIGIDO]
                            tmp_signed   = a_signed * b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            // Canonical overflow check:
                            f_overflow   = (tmp_signed[2*WIDTH-1:WIDTH] != {WIDTH{tmp_signed[WIDTH-1]}});
                        end
                        4'b0100: begin // DIVS
                            if (b_signed != 0) begin
                                tmp_signed = a_signed / b_signed;
                                f_result   = tmp_signed[WIDTH-1:0];
                                f_overflow = 1'b0;
                            end else begin
                                f_result   = {1'b0, {WIDTH-1{1'b1}}};
                                f_overflow = 1'b1; f_saturate = 1'b1;
                            end
                        end
                        // Lógicas
                        4'b0110: f_result = f_op_a & f_op_b;
                        4'b0111: f_result = f_op_a | f_op_b;
                        4'b1000: f_result = f_op_a ^ f_op_b;
                        4'b1001: f_result = ~(f_op_a & f_op_b);
                        4'b1010: f_result = ~(f_op_a | f_op_b);
                        4'b1011: f_result = ~(f_op_a ^ f_op_b);
                        // Shifts
                        4'b1100: f_result = f_op_a <<< f_op_b[SHIFT_BITS-1:0];
                        4'b1101: f_result = f_op_a >>> f_op_b[SHIFT_BITS-1:0];
                        4'b1110: f_result = f_op_a >>> f_op_b[SHIFT_BITS-1:0];
                        // CMP
                        4'b1111: begin
                            tmp_signed   = a_signed - b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            f_overflow   = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                           (f_result[WIDTH-1]  != a_signed[WIDTH-1]);
                        end
                        default: f_result = {WIDTH{1'b0}};
                    endcase
                    f_negative = f_result[WIDTH-1];
                end

                // ------------------------------------------------------------
                // Modo 3: FIXED POINT
                // ------------------------------------------------------------
                3'b011: begin 
                    case (f_op_sel)
                        4'b0000: begin // ADD
                            tmp_signed   = a_signed + b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            f_overflow   = (a_signed[WIDTH-1] == b_signed[WIDTH-1]) &&
                                           (f_result[WIDTH-1]  != a_signed[WIDTH-1]);
                        end
                        4'b0001: begin // SUB
                            tmp_signed   = a_signed - b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            f_overflow   = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                           (f_result[WIDTH-1]  != a_signed[WIDTH-1]);
                        end
                        4'b0010: begin // MUL Q [CORRIGIDO]
                            tmp_signed   = (a_signed * b_signed) >>> FRAC;
                            f_result     = tmp_signed[WIDTH-1:0];
                            // Canonical overflow check:
                            f_overflow   = (tmp_signed[2*WIDTH-1:WIDTH] != {WIDTH{tmp_signed[WIDTH-1]}});
                        end
                        4'b0101: begin // DIV Q
                            if (b_signed != 0) begin
                                tmp_signed = (a_signed <<< FRAC) / b_signed;
                                f_result   = tmp_signed[WIDTH-1:0];
                                f_overflow = 1'b0;
                            end else begin
                                f_result   = {1'b0, {WIDTH-1{1'b1}}};
                                f_overflow = 1'b1; f_saturate = 1'b1;
                            end
                        end
                        // Lógicas e Shifts (repetidos para integridade do case)
                        4'b0110: f_result = f_op_a & f_op_b;
                        4'b0111: f_result = f_op_a | f_op_b;
                        4'b1000: f_result = f_op_a ^ f_op_b;
                        4'b1001: f_result = ~(f_op_a & f_op_b);
                        4'b1010: f_result = ~(f_op_a | f_op_b);
                        4'b1011: f_result = ~(f_op_a ^ f_op_b);
                        4'b1100: f_result = f_op_a <<< f_op_b[SHIFT_BITS-1:0];
                        4'b1101: f_result = f_op_a >>> f_op_b[SHIFT_BITS-1:0];
                        4'b1110: f_result = f_op_a >>> f_op_b[SHIFT_BITS-1:0];
                        4'b1111: begin
                            tmp_signed   = a_signed - b_signed;
                            f_result     = tmp_signed[WIDTH-1:0];
                            f_overflow   = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                           (f_result[WIDTH-1]  != a_signed[WIDTH-1]);
                        end
                        default: f_result = {WIDTH{1'b0}};
                    endcase
                    f_negative = f_result[WIDTH-1];
                end
                
                default: f_result = {WIDTH{1'b0}};
            endcase

            if (f_result == {WIDTH{1'b0}}) f_zero = 1'b1;
            else f_zero = 1'b0;
            
            ula_core_dataflow = {f_result, f_overflow, f_saturate, f_zero, f_negative, f_carry};
        end
    endfunction

endmodule