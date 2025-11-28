// ============================================================================
// Arquivo  : ula.v  (implementacao Structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Comatível com Quartus e Questa (Verilog 2001)
// Descricao: ULA de 4 bits estruturada a partir de modulos menores de operacao
//            (AND, OR, NOT, NAND, soma, subtracao, multiplicacao e divisao) e
//            um multiplexador 8:1 de 8 bits. O objetivo e evidenciar a
//            decomposicao em blocos reutilizaveis, aproximando-se de um
//            arranjo de componentes em hardware discreto.
// Revisao  : v1.0 — criacao inicial
// ============================================================================

// -------------------------------------------------------------------------
// Modulos basicos de operacao logica e aritmetica (4 bits)
// -------------------------------------------------------------------------

// AND de 4 bits
module and4 (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] y
);
    assign y = a & b; // Operacao AND bit a bit
endmodule

// OR de 4 bits
module or4 (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] y
);
    assign y = a | b; // Operacao OR bit a bit
endmodule

// NOT de 4 bits (apenas sobre 'a')
module not4 (
    input  [3:0] a,
    output [3:0] y
);
    assign y = ~a; // Inversao bit a bit
endmodule

// NAND de 4 bits
module nand4 (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] y
);
    assign y = ~(a & b); // NAND: NOT do AND
endmodule

// Somador de 4 bits (com truncamento natural)
module add4 (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] y
);
    assign y = a + b; // Soma com descartar de carry mais significativo
endmodule

// Subtrator de 4 bits
module sub4 (
    input  [3:0] a,
    input  [3:0] b,
    output [3:0] y
);
    assign y = a - b; // Subtracao com truncamento
endmodule

// Multiplicador 4x4 com produto de 8 bits
module mul4x4 (
    input  [3:0] a,
    input  [3:0] b,
    output [7:0] y
);
    assign y = a * b; // Produto completo 4x4=8 bits
endmodule

// Divisor inteiro 4 bits com quociente+resto compactados
module div4x4 (
    input  [3:0] a,     // Dividendo
    input  [3:0] b,     // Divisor
    output [7:0] y      // {resto, quociente}
);
    // Registradores internos para quociente e resto
    reg [3:0] q;        // Quociente
    reg [3:0] r;        // Resto

    // Logica combinacional de divisao com protecao divisor zero
    always @* begin
        if (b == 4'b0000) begin
            // Convencao: quociente = 0 e resto = dividendo quando b = 0
            q = 4'b0000;
            r = a;
        end else begin
            // Divisao inteira normal
            q = a / b;
            r = a % b;
        end
    end

    // Compactacao das duas saidas em um unico barramento
    assign y = {r, q};
endmodule

// -------------------------------------------------------------------------
// Multiplexador 8:1 de 8 bits
// -------------------------------------------------------------------------
module mux8_1_8bit (
    input  [7:0] d0, // Entrada para seletor 000
    input  [7:0] d1, // Entrada para seletor 001
    input  [7:0] d2, // Entrada para seletor 010
    input  [7:0] d3, // Entrada para seletor 011
    input  [7:0] d4, // Entrada para seletor 100
    input  [7:0] d5, // Entrada para seletor 101
    input  [7:0] d6, // Entrada para seletor 110
    input  [7:0] d7, // Entrada para seletor 111
    input  [2:0] sel,// Codigo de selecao
    output [7:0] y   // Saida multiplexada
);
    reg [7:0] y_reg;  // Registrador combinacional interno

    // Mapeia a saida de acordo com o seletor
    always @* begin
        case (sel)
            3'b000: y_reg = d0; // AND
            3'b001: y_reg = d1; // OR
            3'b010: y_reg = d2; // NOT
            3'b011: y_reg = d3; // NAND
            3'b100: y_reg = d4; // Soma
            3'b101: y_reg = d5; // Subtracao
            3'b110: y_reg = d6; // Multiplicacao
            3'b111: y_reg = d7; // Divisao
            default: y_reg = 8'b0000_0000; // Default defensivo
        endcase
    end

    assign y = y_reg; // Conecta registrador interno a saida
endmodule

// -------------------------------------------------------------------------
// Modulo de ULA estrutural: instancia blocos basicos + multiplexador
// -------------------------------------------------------------------------
module ula_structural (
    input  [3:0] op_a,      // Operando A (4 bits)
    input  [3:0] op_b,      // Operando B (4 bits)
    input  [2:0] seletor,   // Codigo de operacao
    output [7:0] resultado  // Barramento de saida (8 bits)
);
    // Fios para as saidas dos blocos de 4 bits
    wire [3:0] and_out;    // Resultado do AND
    wire [3:0] or_out;     // Resultado do OR
    wire [3:0] not_out;    // Resultado do NOT
    wire [3:0] nand_out;   // Resultado do NAND
    wire [3:0] add_out;    // Resultado da soma
    wire [3:0] sub_out;    // Resultado da subtracao

    // Fios para as operacoes que ja produzem 8 bits
    wire [7:0] mul_out;    // Resultado da multiplicacao
    wire [7:0] div_out;    // Resultado da divisao (resto+quociente)

    // Conversao das operacoes de 4 bits para barramentos de 8 bits
    wire [7:0] and_ext = {4'b0000, and_out};   // AND estendido
    wire [7:0] or_ext  = {4'b0000, or_out};    // OR estendido
    wire [7:0] not_ext = {4'b0000, not_out};   // NOT estendido
    wire [7:0] nand_ext= {4'b0000, nand_out};  // NAND estendido
    wire [7:0] add_ext = {4'b0000, add_out};   // Soma estendida
    wire [7:0] sub_ext = {4'b0000, sub_out};   // Subtracao estendida

    // -----------------------------------------------------------------
    // Instancias dos blocos elementares com ligacoes explicitas
    // -----------------------------------------------------------------
    and4 u_and4 (
        .a (op_a),      // Conecta op_a na entrada a
        .b (op_b),      // Conecta op_b na entrada b
        .y (and_out)    // Saida AND em and_out
    );

    or4 u_or4 (
        .a (op_a),      // Conecta op_a na entrada a
        .b (op_b),      // Conecta op_b na entrada b
        .y (or_out)     // Saida OR em or_out
    );

    not4 u_not4 (
        .a (op_a),      // Operando a a ser invertido
        .y (not_out)    // Saida invertida
    );

    nand4 u_nand4 (
        .a (op_a),      // Entrada a
        .b (op_b),      // Entrada b
        .y (nand_out)   // Saida NAND
    );

    add4 u_add4 (
        .a (op_a),      // Entrada a para soma
        .b (op_b),      // Entrada b para soma
        .y (add_out)    // Saida soma
    );

    sub4 u_sub4 (
        .a (op_a),      // Minuendo
        .b (op_b),      // Subtraendo
        .y (sub_out)    // Resultado da subtracao
    );

    mul4x4 u_mul4x4 (
        .a (op_a),      // Operando a da multiplicacao
        .b (op_b),      // Operando b da multiplicacao
        .y (mul_out)    // Resultado 8 bits
    );

    div4x4 u_div4x4 (
        .a (op_a),      // Dividendo da divisao
        .b (op_b),      // Divisor da divisao
        .y (div_out)    // Resultado 8 bits {resto, quociente}
    );

    // -----------------------------------------------------------------
    // Instancia do multiplexador 8:1 de 8 bits para selecionar a operacao
    // -----------------------------------------------------------------
    mux8_1_8bit u_mux8_1_8bit (
        .d0 (and_ext),   // Codigo 000 -> AND
        .d1 (or_ext),    // Codigo 001 -> OR
        .d2 (not_ext),   // Codigo 010 -> NOT
        .d3 (nand_ext),  // Codigo 011 -> NAND
        .d4 (add_ext),   // Codigo 100 -> Soma
        .d5 (sub_ext),   // Codigo 101 -> Subtracao
        .d6 (mul_out),   // Codigo 110 -> Multiplicacao
        .d7 (div_out),   // Codigo 111 -> Divisao
        .sel (seletor),  // Seletor compartilhado da ULA
        .y   (resultado) // Saida final da ULA
    );
endmodule
