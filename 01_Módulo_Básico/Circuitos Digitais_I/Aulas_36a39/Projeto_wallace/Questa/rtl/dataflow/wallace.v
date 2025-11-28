// ============================================================================
// Arquivo  : wallace.v  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplicador de 4x4 bits com saída de 8 bits (produto sem sinal).
//            Esta variante "Dataflow" implementa o núcleo de multiplicação
//            equivalente ao arranjo Wallace Tree. Na behavioral usa o operador
//            '*'; na dataflow descreve-se a rede booleana com atribuições
//            contínuas; na estrutural, compõe-se a árvore de redução com
//            Half/Full Adders. Latência combinacional (0 ciclos). Recursos
//            esperados: ~16 ANDs + somadores de 1 bit na estrutural.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================ PORT DECLARATION ===============================
module wallace (
    input  [3:0] a,                 // multiplicando (4 bits)
    input  [3:0] b,                 // multiplicador (4 bits)
    output [7:0] produto            // produto (8 bits)
);
    // ----------------------- GERAÇÃO DE PARCIAIS (AND) ----------------------
    // p_i_j representa a_i & b_j (bit i de 'a' vezes bit j de 'b').
    wire p00 = a[0] & b[0];
    wire p01 = a[1] & b[0];
    wire p02 = a[2] & b[0];
    wire p03 = a[3] & b[0];

    wire p10 = a[0] & b[1];
    wire p11 = a[1] & b[1];
    wire p12 = a[2] & b[1];
    wire p13 = a[3] & b[1];

    wire p20 = a[0] & b[2];
    wire p21 = a[1] & b[2];
    wire p22 = a[2] & b[2];
    wire p23 = a[3] & b[2];

    wire p30 = a[0] & b[3];
    wire p31 = a[1] & b[3];
    wire p32 = a[2] & b[3];
    wire p33 = a[3] & b[3];

    // --------------------------- REDUÇÃO WALLACE ----------------------------
    // Nível 0 (LSB direto)
    assign produto[0] = p00;

    // Nível 1: coluna 1 -> soma p01 ^ p10 com carry p01&p10
    wire s11 = p01 ^ p10;
    wire c11 = p01 & p10;
    assign produto[1] = s11;

    // Coluna 2 inicial: p02, p11, p20 -> soma completa
    wire s21 = p02 ^ p11 ^ p20;
    wire c21 = (p02 & p11) | (p02 & p20) | (p11 & p20);

    // Coluna 3 inicial: p03, p12, p21 -> soma completa
    wire s31 = p03 ^ p12 ^ p21;
    wire c31 = (p03 & p12) | (p03 & p21) | (p12 & p21);

    // Coluna 4 inicial: p13, p22, p31 -> soma completa
    wire s41 = p13 ^ p22 ^ p31;
    wire c41 = (p13 & p22) | (p13 & p31) | (p22 & p31);

    // Coluna 5 inicial: p23, p32 -> half-adder
    wire s51 = p23 ^ p32;
    wire c51 = p23 & p32;

    // Coluna 6 inicial: p33 passa adiante
    wire s61 = p33;
    wire c61 = 1'b0;

    // ---------------------- Propagação de carries (ripple) ------------------
    // Coluna 2 final (produto[2]) = s21 ^ c11, carry = s21&c11
    wire s22 = s21 ^ c11;
    wire c22 = s21 & c11;
    assign produto[2] = s22;

    // Coluna 3 final = s31 ^ c21 ^ c22
    wire s33 = s31 ^ c21 ^ c22;
    wire c33 = (s31 & c21) | (s31 & c22) | (c21 & c22);
    assign produto[3] = s33;

    // Coluna 4 final = s41 ^ c31 ^ c33
    wire s44 = s41 ^ c31 ^ c33;
    wire c44 = (s41 & c31) | (s41 & c33) | (c31 & c33);
    assign produto[4] = s44;

    // Coluna 5 final = s51 ^ c41 ^ c44
    wire s55 = s51 ^ c41 ^ c44;
    wire c55 = (s51 & c41) | (s51 & c44) | (c41 & c44);
    assign produto[5] = s55;

    // Coluna 6 final = s61 ^ c51 ^ c55
    wire s66 = s61 ^ c51 ^ c55;
    wire c66 = (s61 & c51) | (s61 & c55) | (c51 & c55);
    assign produto[6] = s66;

    // Coluna 7 final = c61 ^ c66  (c61 é zero)
    assign produto[7] = c66;
endmodule
