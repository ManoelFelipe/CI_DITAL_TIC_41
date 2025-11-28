// ============================================================================
// Arquivo  : ULA_LSL_LSR_mod.v  (implementação structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: ULA de 4 bits construída em estilo estrutural, compondo blocos
//            elementares (operadores lógicos, somador, subtrator, deslocadores
//            e multiplexador 8:1) interconectados explicitamente. O fator de
//            deslocamento LSL/LSR é derivado de B e saturado em até 4 posições,
//            permitindo exploração de hierarquia e reuso em síntese lógica.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// ---------------------------------------------------------------------------
// Topo estrutural da ULA
// ---------------------------------------------------------------------------
module ULA_LSL_LSR_mod (
    input  wire [3:0] a_in,          // Operando A de 4 bits
    input  wire [3:0] b_in,          // Operando B de 4 bits
    input  wire [2:0] op_sel,        // Código da operação
    output wire [3:0] resultado_out  // Saída combinacional da ULA
);
    // -----------------------------------------------------------------------
    // Sinal interno: fator de deslocamento saturado
    // -----------------------------------------------------------------------
    wire [2:0] shift_amt;            // Fator de deslocamento (0..4)

    // -----------------------------------------------------------------------
    // Sinais internos para cada operação elementar
    // -----------------------------------------------------------------------
    wire [3:0] and_res;              // Saída da operação AND
    wire [3:0] or_res;               // Saída da operação OR
    wire [3:0] not_res;              // Saída da operação NOT(A)
    wire [3:0] nand_res;             // Saída da operação NAND
    wire [3:0] add_res;              // Saída da soma A + B
    wire [3:0] sub_res;              // Saída da subtração A - B
    wire [3:0] lsl_res;              // Saída do deslocamento lógico esq.
    wire [3:0] lsr_res;              // Saída do deslocamento lógico dir.

    // -----------------------------------------------------------------------
    // Instâncias dos blocos elementares
    // -----------------------------------------------------------------------
    ula_shift_saturator u_sat (
        .b_in      (b_in),           // Conecta operando B
        .shift_amt (shift_amt)       // Fator de deslocamento saturado
    );

    ula_and4 u_and4 (
        .a_in (a_in),                // Entrada A
        .b_in (b_in),                // Entrada B
        .y_out(and_res)              // Saída AND
    );

    ula_or4 u_or4 (
        .a_in (a_in),                // Entrada A
        .b_in (b_in),                // Entrada B
        .y_out(or_res)               // Saída OR
    );

    ula_not4 u_not4 (
        .a_in (a_in),                // Entrada A
        .y_out(not_res)              // Saída NOT(A)
    );

    ula_nand4 u_nand4 (
        .a_in (a_in),                // Entrada A
        .b_in (b_in),                // Entrada B
        .y_out(nand_res)             // Saída NAND
    );

    ula_add4 u_add4 (
        .a_in (a_in),                // Entrada A
        .b_in (b_in),                // Entrada B
        .y_out(add_res)              // Saída soma
    );

    ula_sub4 u_sub4 (
        .a_in (a_in),                // Entrada A
        .b_in (b_in),                // Entrada B
        .y_out(sub_res)              // Saída subtração
    );

    ula_lsl4 u_lsl4 (
        .a_in      (a_in),           // Entrada A
        .shift_amt (shift_amt),      // Fator de deslocamento
        .y_out     (lsl_res)         // Saída deslocamento lógico à esquerda
    );

    ula_lsr4 u_lsr4 (
        .a_in      (a_in),           // Entrada A
        .shift_amt (shift_amt),      // Fator de deslocamento
        .y_out     (lsr_res)         // Saída deslocamento lógico à direita
    );

    // -----------------------------------------------------------------------
    // Multiplexador 8:1 de 4 bits para selecionar a operação final
    // -----------------------------------------------------------------------
    ula_mux8_1_4 u_mux (
        .d0(and_res),                // Código 000
        .d1(or_res),                 // Código 001
        .d2(not_res),                // Código 010
        .d3(nand_res),               // Código 011
        .d4(add_res),                // Código 100
        .d5(sub_res),                // Código 101
        .d6(lsl_res),                // Código 110
        .d7(lsr_res),                // Código 111
        .sel(op_sel),                // Seletor de operação
        .y_out(resultado_out)        // Saída final da ULA
    );
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_shift_saturator
//   - Calcula o fator de deslocamento saturado (0..4) a partir de b_in.
// ---------------------------------------------------------------------------
module ula_shift_saturator (
    input  wire [3:0] b_in,          // Operando B original
    output wire [2:0] shift_amt      // Fator de deslocamento saturado
);
    assign shift_amt = (b_in > 4'd4) ? 3'd4 : b_in[2:0];
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_and4 — AND bit a bit de 4 bits
// ---------------------------------------------------------------------------
module ula_and4 (
    input  wire [3:0] a_in,
    input  wire [3:0] b_in,
    output wire [3:0] y_out
);
    assign y_out = a_in & b_in;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_or4 — OR bit a bit de 4 bits
// ---------------------------------------------------------------------------
module ula_or4 (
    input  wire [3:0] a_in,
    input  wire [3:0] b_in,
    output wire [3:0] y_out
);
    assign y_out = a_in | b_in;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_not4 — NOT de A (4 bits)
// ---------------------------------------------------------------------------
module ula_not4 (
    input  wire [3:0] a_in,
    output wire [3:0] y_out
);
    assign y_out = ~a_in;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_nand4 — NAND bit a bit de 4 bits
// ---------------------------------------------------------------------------
module ula_nand4 (
    input  wire [3:0] a_in,
    input  wire [3:0] b_in,
    output wire [3:0] y_out
);
    assign y_out = ~(a_in & b_in);
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_add4 — somador de 4 bits (sem carry out)
// ---------------------------------------------------------------------------
module ula_add4 (
    input  wire [3:0] a_in,
    input  wire [3:0] b_in,
    output wire [3:0] y_out
);
    assign y_out = a_in + b_in;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_sub4 — subtrator de 4 bits (A - B, sem borrow out)
// ---------------------------------------------------------------------------
module ula_sub4 (
    input  wire [3:0] a_in,
    input  wire [3:0] b_in,
    output wire [3:0] y_out
);
    assign y_out = a_in - b_in;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_lsl4 — deslocamento lógico à esquerda com fator variável
// ---------------------------------------------------------------------------
module ula_lsl4 (
    input  wire [3:0] a_in,
    input  wire [2:0] shift_amt,
    output wire [3:0] y_out
);
    assign y_out = a_in << shift_amt;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_lsr4 — deslocamento lógico à direita com fator variável
// ---------------------------------------------------------------------------
module ula_lsr4 (
    input  wire [3:0] a_in,
    input  wire [2:0] shift_amt,
    output wire [3:0] y_out
);
    assign y_out = a_in >> shift_amt;
endmodule

// ---------------------------------------------------------------------------
// Módulo: ula_mux8_1_4 — multiplexador 8:1 de 4 bits
// ---------------------------------------------------------------------------
module ula_mux8_1_4 (
    input  wire [3:0] d0,
    input  wire [3:0] d1,
    input  wire [3:0] d2,
    input  wire [3:0] d3,
    input  wire [3:0] d4,
    input  wire [3:0] d5,
    input  wire [3:0] d6,
    input  wire [3:0] d7,
    input  wire [2:0] sel,
    output reg  [3:0] y_out
);
    always @(*) begin
        case (sel)
            3'b000: y_out = d0;
            3'b001: y_out = d1;
            3'b010: y_out = d2;
            3'b011: y_out = d3;
            3'b100: y_out = d4;
            3'b101: y_out = d5;
            3'b110: y_out = d6;
            3'b111: y_out = d7;
            default: y_out = 4'b0000;
        endcase
    end
endmodule
