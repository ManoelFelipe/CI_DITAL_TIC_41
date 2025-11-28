// ============================================================================
// Arquivo  : conver.v  (implementação STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Conversor estrutural de código BCD 5311 (H,G,F,E) para
//            BCD 8421 (D,C,B,A). A saída de cada bit (D,C,B,A) é gerada
//            por um módulo dedicado, implementado exclusivamente com
//            primitivas lógicas (and, or, not). O módulo topo instancia
//            os quatro blocos, resultando em uma arquitetura modular,
//            totalmente combinacional, com latência zero em ciclos de
//            clock e granularidade adequada para estudos de síntese.
// Revisão  : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo de saída D (bit mais significativo do código 8421).
// Implementa a função: D = H & G.
// --------------------------------------------------------------------------
module conver_d_struct (
    input  wire h,
    input  wire g,
    output wire d
);
    // Fio interno para a saída do AND.
    wire d_and;

    // Porta AND que realiza a conjunção entre H e G.
    and and_d (d_and, h, g);

    // Conecta o fio interno à saída do módulo.
    assign d = d_and;
endmodule

// --------------------------------------------------------------------------
// Módulo de saída C.
// Implementa a função: C = (!H & G & E) | (H & !G).
// --------------------------------------------------------------------------
module conver_c_struct (
    input  wire h,
    input  wire g,
    input  wire e,
    output wire c
);
    // Fios internos para sinais negados e termos intermediários.
    wire h_not;
    wire g_not;
    wire term1;
    wire term2;

    // Inversões necessárias.
    not not_h (h_not, h);
    not not_g (g_not, g);

    // Termo 1: !H & G & E
    wire t1_and1;
    and and_t1_1 (t1_and1, h_not, g);
    and and_t1_2 (term1, t1_and1, e);

    // Termo 2: H & !G
    and and_t2 (term2, h, g_not);

    // Combinação por OR dos dois termos.
    or or_c (c, term1, term2);
endmodule

// --------------------------------------------------------------------------
// Módulo de saída B.
// Implementa a função: B = (!H & G & !E) | (!G & F) | (H & !G).
// --------------------------------------------------------------------------
module conver_b_struct (
    input  wire h,
    input  wire g,
    input  wire f,
    input  wire e,
    output wire b
);
    // Fios internos para inversões.
    wire h_not;
    wire g_not;
    wire e_not;

    // Fios para termos intermediários.
    wire term1;
    wire term2;
    wire term3;

    // Inversões.
    not not_h (h_not, h);
    not not_g (g_not, g);
    not not_e (e_not, e);

    // Termo 1: !H & G & !E
    wire t1_and1;
    and and_t1_1 (t1_and1, h_not, g);
    and and_t1_2 (term1, t1_and1, e_not);

    // Termo 2: !G & F
    and and_t2 (term2, g_not, f);

    // Termo 3: H & !G
    and and_t3 (term3, h, g_not);

    // Combinação final via OR de três entradas.
    or or_b (b, term1, term2, term3);
endmodule

// --------------------------------------------------------------------------
// Módulo de saída A.
// Implementa a função:
// A = (!H & !G & !F & E) |
//     (!H & G  & !E)     |
//     (G  & F)           |
//     (H & G & E)        |
//     (H & F)
// --------------------------------------------------------------------------
module conver_a_struct (
    input  wire h,
    input  wire g,
    input  wire f,
    input  wire e,
    output wire a
);
    // Fios internos para inversões dos sinais de entrada.
    wire h_not;
    wire g_not;
    wire f_not;
    wire e_not;

    // Fios para cada termo da expressão.
    wire term1;
    wire term2;
    wire term3;
    wire term4;
    wire term5;

    // Inversões básicas.
    not not_h (h_not, h);
    not not_g (g_not, g);
    not not_f (f_not, f);
    not not_e (e_not, e);

    // Termo 1: !H & !G & !F & E
    wire t1_and1;
    wire t1_and2;
    and and_t1_1 (t1_and1, h_not, g_not);
    and and_t1_2 (t1_and2, t1_and1, f_not);
    and and_t1_3 (term1, t1_and2, e);

    // Termo 2: !H & G & !E
    wire t2_and1;
    and and_t2_1 (t2_and1, h_not, g);
    and and_t2_2 (term2, t2_and1, e_not);

    // Termo 3: G & F
    and and_t3 (term3, g, f);

    // Termo 4: H & G & E
    wire t4_and1;
    and and_t4_1 (t4_and1, h, g);
    and and_t4_2 (term4, t4_and1, e);

    // Termo 5: H & F
    and and_t5 (term5, h, f);

    // Combinação final por OR de cinco termos.
    or or_a (a, term1, term2, term3, term4, term5);
endmodule

// --------------------------------------------------------------------------
// Módulo topo estrutural: conver_structural
// Instancia os quatro módulos anteriores para gerar o vetor BCD 8421.
// --------------------------------------------------------------------------
module conver_structural (
    input  wire h,
    input  wire g,
    input  wire f,
    input  wire e,
    output wire d,
    output wire c,
    output wire b,
    output wire a
);
    // Instancia o módulo responsável pelo bit D.
    conver_d_struct u_d (
        .h (h),
        .g (g),
        .d (d)
    );

    // Instancia o módulo responsável pelo bit C.
    conver_c_struct u_c (
        .h (h),
        .g (g),
        .e (e),
        .c (c)
    );

    // Instancia o módulo responsável pelo bit B.
    conver_b_struct u_b (
        .h (h),
        .g (g),
        .f (f),
        .e (e),
        .b (b)
    );

    // Instancia o módulo responsável pelo bit A.
    conver_a_struct u_a (
        .h (h),
        .g (g),
        .f (f),
        .e (e),
        .a (a)
    );
endmodule
