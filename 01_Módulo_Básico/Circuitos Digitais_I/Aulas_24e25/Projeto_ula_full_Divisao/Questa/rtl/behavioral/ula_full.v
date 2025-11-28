// ============================================================================
// Arquivo  : ula_full  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA parametrizável com suporte a múltiplos modos numéricos,
//            incluindo operações aritméticas, lógicas, shifts e três modos
//            de divisão (inteira sem sinal, inteira com sinal e ponto fixo Q).
//            Implementação combinacional em único bloco always @*, com flags
//            de overflow, saturação, zero, sinal e carry/borrow.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module ula_full_behavioral
#(
    parameter WIDTH = 8,   // Largura dos dados (bits)
    parameter FRAC  = 4    // Bits fracionários para Ponto Fixo (Q)
)(
    // --- Entradas ---
    input      [WIDTH-1:0] op_a,          // Operando A
    input      [WIDTH-1:0] op_b,          // Operando B
    input      [3:0]       op_sel,        // Seletor da Operação (0 a 15)
    input      [2:0]       num_mode,      // Modo Numérico (Unsigned, Signed, Fixed)
    
    // --- Saídas ---
    output reg [WIDTH-1:0] result,        // Resultado principal
    output reg             flag_overflow, // Bandeira de Estouro
    output reg             flag_saturate, // Bandeira de Saturação (div por 0)
    output reg             flag_zero,     // Bandeira de Zero (Resultado == 0)
    output reg             flag_negative, // Bandeira de Negativo (MSB == 1)
    output reg             flag_carry     // Bandeira de Carry (Vai-um)
);

    // ------------------------------------------------------------------------
    // Variáveis Temporárias e Castings
    // ------------------------------------------------------------------------
    // Usamos 2*WIDTH para não perder bits em Somas/Multiplicações antes do check
    reg [2*WIDTH-1:0]        tmp_unsigned; // Temp para aritmética sem sinal
    reg signed [2*WIDTH-1:0] tmp_signed;   // Temp para aritmética com sinal

    // Casting explícito para facilitar operações com/sem sinal
    reg signed [WIDTH-1:0] a_signed;
    reg signed [WIDTH-1:0] b_signed;
    reg [WIDTH-1:0]        a_unsigned;
    reg [WIDTH-1:0]        b_unsigned;

    // Calcula log2(WIDTH) para saber o tamanho do shift (ex: 8 bits -> 3 bits)
    localparam SHIFT_BITS = $clog2(WIDTH);

    // ------------------------------------------------------------------------
    // Bloco Combinacional Único
    // ------------------------------------------------------------------------
    always @* begin
        // 1. Inicialização padrão (Evita latch inferido e estados indesejados)
        result        = {WIDTH{1'b0}};
        flag_overflow = 1'b0;
        flag_saturate = 1'b0;
        flag_zero     = 1'b0;
        flag_negative = 1'b0;
        flag_carry    = 1'b0;

        // 2. Atribuição dos operandos às variáveis locais tipadas
        a_unsigned = op_a;
        b_unsigned = op_b;
        a_signed   = op_a; // Interpretado como complemento de 2
        b_signed   = op_b;

        // 3. Seleção baseada no Modo Numérico
        case (num_mode)
            // ================================================================
            // MODO 0: UNSIGNED (Inteiro Sem Sinal)
            // ================================================================
            3'b000: begin
                case (op_sel)
                    4'b0000: begin // ADD (Soma)
                        // Concatena 0 no MSB para capturar o Carry na posição WIDTH
                        tmp_unsigned   = {1'b0, a_unsigned} + {1'b0, b_unsigned};
                        result         = tmp_unsigned[WIDTH-1:0]; // Resultado truncado
                        flag_carry     = tmp_unsigned[WIDTH];     // Bit extra é o Carry
                        flag_overflow  = flag_carry;              // Em unsigned, Ov = Carry
                    end
                    4'b0001: begin // SUB (Subtração)
                        tmp_unsigned   = {1'b0, a_unsigned} - {1'b0, b_unsigned};
                        result         = tmp_unsigned[WIDTH-1:0];
                        flag_carry     = tmp_unsigned[WIDTH];     // Indica Borrow
                        flag_overflow  = flag_carry;
                    end
                    4'b0010: begin // MUL (Multiplicação)
                        tmp_unsigned   = a_unsigned * b_unsigned;
                        result         = tmp_unsigned[WIDTH-1:0];
                        // Overflow se houver qualquer bit 1 na parte alta (WIDTH até 2*WIDTH-1)
                        flag_overflow  = |tmp_unsigned[2*WIDTH-1:WIDTH];
                    end
                    4'b0011: begin // DIVU (Divisão)
                        if (b_unsigned != 0) begin
                            result        = a_unsigned / b_unsigned;
                            flag_overflow = 1'b0;
                        end else begin
                            result        = {WIDTH{1'b0}}; // Div por 0 retorna 0
                            flag_overflow = 1'b1;          // Erro
                            flag_saturate = 1'b1;          // Saturação
                        end
                    end
                    // Operações Lógicas (Bitwise)
                    4'b0110: result = a_unsigned & b_unsigned;        // AND
                    4'b0111: result = a_unsigned | b_unsigned;        // OR
                    4'b1000: result = a_unsigned ^ b_unsigned;        // XOR
                    4'b1001: result = ~(a_unsigned & b_unsigned);     // NAND
                    4'b1010: result = ~(a_unsigned | b_unsigned);     // NOR
                    4'b1011: result = ~(a_unsigned ^ b_unsigned);     // XNOR
                    
                    // Shifts (Deslocamentos)
                    4'b1100: result = a_unsigned << op_b[SHIFT_BITS-1:0];  // SHL
                    4'b1101: result = a_unsigned >> op_b[SHIFT_BITS-1:0];  // SHR
                    4'b1110: result = a_unsigned >> op_b[SHIFT_BITS-1:0];  // SAR (Unsigned = SHR)
                    
                    4'b1111: begin // CMP (Comparação)
                        // Subtrai mas não grava resultado, apenas flags
                        tmp_unsigned   = {1'b0, a_unsigned} - {1'b0, b_unsigned};
                        result         = tmp_unsigned[WIDTH-1:0]; 
                        flag_carry     = tmp_unsigned[WIDTH];
                        flag_overflow  = flag_carry;
                    end
                    default: result = {WIDTH{1'b0}};
                endcase
            end

            // ================================================================
            // MODO 1: SIGNED (Complemento de 2)
            // ================================================================
            3'b001: begin
                case (op_sel)
                    4'b0000: begin // ADD Signed
                        tmp_signed     = a_signed + b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        // Overflow: (Pos + Pos = Neg) ou (Neg + Neg = Pos)
                        flag_overflow  = (a_signed[WIDTH-1] == b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0001: begin // SUB Signed
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        // Overflow: (Pos - Neg = Neg) ou (Neg - Pos = Pos)
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0010: begin // MUL Signed [CORRIGIDO]
                        tmp_signed     = a_signed * b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        // Correção: Verifica se a parte alta é TODA igual ao bit de sinal do resultado.
                        // Se a parte alta for diferente da extensão de sinal, houve overflow.
                        flag_overflow  = (tmp_signed[2*WIDTH-1:WIDTH] != {WIDTH{tmp_signed[WIDTH-1]}});
                    end
                    4'b0100: begin // DIVS
                        if (b_signed != 0) begin
                            tmp_signed    = a_signed / b_signed;
                            result        = tmp_signed[WIDTH-1:0];
                            flag_overflow = 1'b0;
                        end else begin
                            result        = {1'b0, {WIDTH-1{1'b1}}}; // Max Negativo ou similar
                            flag_overflow = 1'b1;
                            flag_saturate = 1'b1;
                        end
                    end
                    // Lógicas (Igual ao Unsigned)
                    4'b0110: result = op_a & op_b;
                    4'b0111: result = op_a | op_b;
                    4'b1000: result = op_a ^ op_b;
                    4'b1001: result = ~(op_a & op_b);
                    4'b1010: result = ~(op_a | op_b);
                    4'b1011: result = ~(op_a ^ op_b);
                    
                    // Shifts Aritméticos
                    4'b1100: result = op_a <<< op_b[SHIFT_BITS-1:0]; // SHL Arith
                    4'b1101: result = op_a >>> op_b[SHIFT_BITS-1:0]; // SHR Logical
                    4'b1110: result = op_a >>> op_b[SHIFT_BITS-1:0]; // SAR Arith (Sinal preservado)
                    
                    4'b1111: begin // CMP Signed
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    default: result = {WIDTH{1'b0}};
                endcase
                flag_negative = result[WIDTH-1]; // MSB é o sinal
            end

            // ================================================================
            // MODO 3: FIXED POINT (Q)
            // ================================================================
            3'b011: begin
                case (op_sel)
                    // Soma/Sub em Q são idênticas a Signed Inteiro
                    4'b0000: begin // ADD Q
                        tmp_signed     = a_signed + b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] == b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0001: begin // SUB Q
                        tmp_signed     = a_signed - b_signed;
                        result         = tmp_signed[WIDTH-1:0];
                        flag_overflow  = (a_signed[WIDTH-1] != b_signed[WIDTH-1]) &&
                                         (result[WIDTH-1]  != a_signed[WIDTH-1]);
                    end
                    4'b0010: begin // MUL Q [CORRIGIDO]
                        // Multiplica e desloca à direita para restaurar escala
                        tmp_signed     = (a_signed * b_signed) >>> FRAC;
                        result         = tmp_signed[WIDTH-1:0];
                        // Mesma lógica canônica de overflow do signed
                        flag_overflow  = (tmp_signed[2*WIDTH-1:WIDTH] != {WIDTH{tmp_signed[WIDTH-1]}});
                    end
                    4'b0101: begin // DIV Q
                        if (b_signed != 0) begin
                            // Desloca dividendo à esquerda para manter precisão
                            tmp_signed    = (a_signed <<< FRAC) / b_signed;
                            result        = tmp_signed[WIDTH-1:0];
                            flag_overflow = 1'b0;
                        end else begin
                            result        = {1'b0, {WIDTH-1{1'b1}}};
                            flag_overflow = 1'b1;
                            flag_saturate = 1'b1;
                        end
                    end
                    // Lógicas e Shifts (Padrão)
                    4'b0110: result = op_a & op_b;
                    4'b0111: result = op_a | op_b;
                    4'b1000: result = op_a ^ op_b;
                    4'b1001: result = ~(op_a & op_b);
                    4'b1010: result = ~(op_a | op_b);
                    4'b1011: result = ~(op_a ^ op_b);
                    4'b1100: result = op_a <<< op_b[SHIFT_BITS-1:0];
                    4'b1101: result = op_a >>> op_b[SHIFT_BITS-1:0];
                    4'b1110: result = op_a >>> op_b[SHIFT_BITS-1:0];
                    4'b1111: begin // CMP
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

        // Verificação final de Zero (comum a todos os modos)
        if (result == {WIDTH{1'b0}}) flag_zero = 1'b1;
        else flag_zero = 1'b0;
    end
endmodule