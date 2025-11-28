// ============================================================================
// Arquivo  : ula_full  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA parametrizável descrita de forma estrutural, compondo a
//            funcionalidade a partir de submódulos: núcleo aritmético‑lógico,
//            adaptadores de modo numérico e multiplexação de resultados.
//            Mantém equivalência funcional com as versões behavioral/dataflow.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================================================================
// Módulo: ula_full_structural
// Estratégia: interligar blocos menores em estilo estrutural, separando a
//             decodificação de modo numérico do núcleo de operações.
// ============================================================================
module ula_full_structural
#(
    parameter WIDTH = 8,          // Largura de dados
    parameter FRAC  = 4           // Bits fracionários p/ modo Q
)(
    input      [WIDTH-1:0] op_a,  // Operando A
    input      [WIDTH-1:0] op_b,  // Operando B
    input      [2:0]       op_sel,// Seleção de operação
    input      [2:0]       num_mode, // Modo numérico
    output     [WIDTH-1:0] result,   // Resultado final
    output                  flag_overflow, // Overflow
    output                  flag_saturate, // Saturação
    output                  flag_zero,     // Resultado zero
    output                  flag_negative, // Bit de sinal
    output                  flag_carry     // Carry/borrow
);

    // Wires entre os blocos estruturais
    wire [WIDTH-1:0] core_op_a;
    wire [WIDTH-1:0] core_op_b;
    wire [WIDTH-1:0] core_result;
    wire             core_overflow;
    wire             core_saturate;
    wire             core_zero;
    wire             core_negative;
    wire             core_carry;

    // Adaptador de entrada de modo numérico
    ula_mode_pre
    #(
        .WIDTH(WIDTH)
    ) u_mode_pre (
        .op_a_in   (op_a),
        .op_b_in   (op_b),
        .num_mode  (num_mode),
        .op_a_core (core_op_a),
        .op_b_core (core_op_b)
    );

    // Núcleo aritmético‑lógico genérico (utiliza implementação behavioral)
    ula_core_arith
    #(
        .WIDTH(WIDTH),
        .FRAC (FRAC)
    ) u_core (
        .op_a        (core_op_a),
        .op_b        (core_op_b),
        .op_sel      (op_sel),
        .num_mode    (num_mode),
        .result      (core_result),
        .flag_overflow (core_overflow),
        .flag_saturate (core_saturate),
        .flag_zero     (core_zero),
        .flag_negative (core_negative),
        .flag_carry    (core_carry)
    );

    // Adaptador de saída (permite extensões futuras, aqui é pass‑through)
    ula_mode_post
    #(
        .WIDTH(WIDTH)
    ) u_mode_post (
        .result_core   (core_result),
        .num_mode      (num_mode),
        .result_effective (result)
    );

    // Exposição direta das flags do núcleo
    assign flag_overflow = core_overflow;
    assign flag_saturate = core_saturate;
    assign flag_zero     = core_zero;
    assign flag_negative = core_negative;
    assign flag_carry    = core_carry;

endmodule

// ============================================================================
// Submódulo: ula_mode_pre
// Função: ajustar ou pré‑processar os operandos de acordo com o modo numérico.
//         Nesta versão, ele apenas encaminha os valores originais, mas
//         mantém ponto de extensão para cenários em que seja necessário
//         mascarar sinais, normalizar magnitudes, etc.
// ============================================================================
module ula_mode_pre
#(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] op_a_in,
    input  [WIDTH-1:0] op_b_in,
    input  [2:0]       num_mode,
    output [WIDTH-1:0] op_a_core,
    output [WIDTH-1:0] op_b_core
);
    assign op_a_core = op_a_in;
    assign op_b_core = op_b_in;
endmodule

// ============================================================================
// Submódulo: ula_mode_post
// Função: permitir pós‑processamento de saída por modo numérico. Aqui é um
//         simples pass‑through, mas pode ser usado para mapear saturações,
//         compactar flags ou recodificar formato de saída.
// ============================================================================
module ula_mode_post
#(
    parameter WIDTH = 8
)(
    input  [WIDTH-1:0] result_core,
    input  [2:0]       num_mode,
    output [WIDTH-1:0] result_effective
);
    assign result_effective = result_core;
endmodule

// ============================================================================
// Submódulo: ula_core_arith
// Função: encapsular a lógica aritmética/ lógica principal. Utiliza a mesma
//         implementação da ULA behavioral, porém instanciada como "core"
//         para facilitar a composição estrutural.
// ============================================================================
module ula_core_arith
#(
    parameter WIDTH = 8,
    parameter FRAC  = 4
)(
    input      [WIDTH-1:0] op_a,
    input      [WIDTH-1:0] op_b,
    input      [2:0]       op_sel,
    input      [2:0]       num_mode,
    output     [WIDTH-1:0] result,
    output                  flag_overflow,
    output                  flag_saturate,
    output                  flag_zero,
    output                  flag_negative,
    output                  flag_carry
);

    // Instanciamos diretamente a versão behavioral como núcleo combinacional.
    ula_full_behavioral
    #(
        .WIDTH(WIDTH),
        .FRAC (FRAC)
    ) u_behavioral_core (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result),
        .flag_overflow(flag_overflow),
        .flag_saturate(flag_saturate),
        .flag_zero    (flag_zero),
        .flag_negative(flag_negative),
        .flag_carry   (flag_carry)
    );

endmodule
