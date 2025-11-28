// ============================================================================
// Arquivo  : wallace.v  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplicador de 4x4 bits com saída de 8 bits (produto sem sinal).
//            Esta variante "Structural" implementa o núcleo de multiplicação
//            equivalente ao arranjo Wallace Tree. Na behavioral usa o operador
//            '*'; na dataflow descreve-se a rede booleana com atribuições
//            contínuas; na estrutural, compõe-se a árvore de redução com
//            Half/Full Adders. Latência combinacional (0 ciclos). Recursos
//            esperados: ~16 ANDs + somadores de 1 bit na estrutural.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================ PORT DECLARATION ===============================
// Implementação estrutural com instâncias de half_adder e full_adder.
module wallace (
    input  [3:0] a,                   // multiplicando
    input  [3:0] b,                   // multiplicador
    output [7:0] produto              // resultado
);
    // ----------------------- PARCIAIS (AND LÓGICAS) -------------------------
    wire a0b0 = a[0] & b[0];
    wire a1b0 = a[1] & b[0];
    wire a2b0 = a[2] & b[0];
    wire a3b0 = a[3] & b[0];

    wire a0b1 = a[0] & b[1];
    wire a1b1 = a[1] & b[1];
    wire a2b1 = a[2] & b[1];
    wire a3b1 = a[3] & b[1];

    wire a0b2 = a[0] & b[2];
    wire a1b2 = a[1] & b[2];
    wire a2b2 = a[2] & b[2];
    wire a3b2 = a[3] & b[2];

    wire a0b3 = a[0] & b[3];
    wire a1b3 = a[1] & b[3];
    wire a2b3 = a[2] & b[3];
    wire a3b3 = a[3] & b[3];

    // -------------------------- REDUÇÃO EM NÍVEIS ---------------------------
    // Produto[0] direto
    assign produto[0] = a0b0;

    // Estágio 1
    wire s11, c11;
    half_adder ha11 (.data_in_a(a1b0), .data_in_b(a0b1), .data_out_sum(s11), .data_out_carry(c11));
    assign produto[1] = s11;

    wire s21, c21;
    full_adder fa21 (.data_in_a(a2b0), .data_in_b(a1b1), .data_in_c(a0b2), .data_out_sum(s21), .data_out_carry(c21));

    wire s31, c31;
    full_adder fa31 (.data_in_a(a3b0), .data_in_b(a2b1), .data_in_c(a1b2), .data_out_sum(s31), .data_out_carry(c31));

    wire s41, c41;
    full_adder fa41 (.data_in_a(a3b1), .data_in_b(a2b2), .data_in_c(a1b3), .data_out_sum(s41), .data_out_carry(c41));

    wire s51, c51;
    half_adder ha51 (.data_in_a(a2b3), .data_in_b(a3b2), .data_out_sum(s51), .data_out_carry(c51));

    // Estágio 2 (propagação de carries)
    wire s22, c22;
    half_adder ha22 (.data_in_a(s21), .data_in_b(c11), .data_out_sum(s22), .data_out_carry(c22));
    assign produto[2] = s22;

    wire s33, c33;
    full_adder fa33 (.data_in_a(s31), .data_in_b(c21), .data_in_c(c22), .data_out_sum(s33), .data_out_carry(c33));
    assign produto[3] = s33;

    wire s44, c44;
    full_adder fa44 (.data_in_a(s41), .data_in_b(c31), .data_in_c(c33), .data_out_sum(s44), .data_out_carry(c44));
    assign produto[4] = s44;

    wire s55, c55;
    full_adder fa55 (.data_in_a(s51), .data_in_b(c41), .data_in_c(c44), .data_out_sum(s55), .data_out_carry(c55));
    assign produto[5] = s55;

    wire s66, c66;
    full_adder fa66 (.data_in_a(a3b3), .data_in_b(c51), .data_in_c(c55), .data_out_sum(s66), .data_out_carry(c66));
    assign produto[6] = s66;
    assign produto[7] = c66;
endmodule

// ============================ HALF ADDER ====================================
module half_adder (
    input  data_in_a,                 // bit A
    input  data_in_b,                 // bit B
    output data_out_sum,              // soma
    output data_out_carry             // carry
);
    assign data_out_sum   = data_in_a ^ data_in_b;  // XOR para soma
    assign data_out_carry = data_in_a & data_in_b;  // AND para carry
endmodule

// ============================ FULL ADDER ====================================
module full_adder (
    input  data_in_a,                 // bit A
    input  data_in_b,                 // bit B
    input  data_in_c,                 // carry in
    output data_out_sum,              // soma
    output data_out_carry             // carry out
);
    wire s1, c1, c2;                  // sinais internos
    assign s1 = data_in_a ^ data_in_b;
    assign c1 = data_in_a & data_in_b;
    assign data_out_sum = s1 ^ data_in_c;
    assign c2 = s1 & data_in_c;
    assign data_out_carry = c1 | c2;
endmodule
