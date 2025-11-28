// ============================================================================
// Arquivo  : excesso_3.v  (implementacao Structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: Conversor combinacional de codigo BCD 8421 (4 bits) para
//            representacao em Excesso-3. Bloco puramente combinacional,
//            sem registradores, adequado para sintese em FPGAs ou ASICs.
//            Implementacao na abordagem Structural com mesma interface
//            externa entre as versoes para facilitar reutilizacao e testes.
// Revisao   : v1.0 — criacao inicial
// ============================================================================

// Conversor BCD 8421 -> Excesso-3
// Implementacao estrutural com portas logicas primitivas

`timescale 1ns/1ps

module excesso_3_structural (
    input  wire [3:0] bcd_in,      // Entrada BCD 8421 (A B C D)
    output wire [3:0] excess_out   // Saida em codigo Excesso-3
);

    // Sinais internos para cada bit da entrada
    wire a = bcd_in[3];            // Bit A (peso 8)
    wire b = bcd_in[2];            // Bit B (peso 4)
    wire c = bcd_in[1];            // Bit C (peso 2)
    wire d = bcd_in[0];            // Bit D (peso 1)

    // Sinais internos para complementos
    wire na;                        // ~A
    wire nb;                        // ~B
    wire nc;                        // ~C
    wire nd;                        // ~D

    // Inversores
    not u_not_a (na, a);           // na = ~a
    not u_not_b (nb, b);           // nb = ~b
    not u_not_c (nc, c);           // nc = ~c
    not u_not_d (nd, d);           // nd = ~d

    // --------------------------------------------------------------------
    // Bit 0 da saida: y0 = ~D
    // --------------------------------------------------------------------
    assign excess_out[0] = nd;     // Atribuicao direta do complemento de D

    // --------------------------------------------------------------------
    // Bit 1 da saida: y1 = (C & D) | (~C & ~D)
    // --------------------------------------------------------------------
    wire c_and_d;                  // Termo C & D
    wire nc_and_nd;                // Termo ~C & ~D

    and u_and_c_d   (c_and_d,  c,  d);   // c_and_d  = c & d
    and u_and_nc_nd (nc_and_nd, nc, nd); // nc_and_nd = ~c & ~d
    or  u_or_y1     (excess_out[1], c_and_d, nc_and_nd); // y1 = c_and_d | nc_and_nd

    // --------------------------------------------------------------------
    // Bit 2 da saida: y2 = (~B & (C | D)) | (B & ~C & ~D)
    // --------------------------------------------------------------------
    wire c_or_d;                   // Termo (C | D)
    wire nb_and_c_or_d;            // Termo ~B & (C | D)
    wire b_and_nc;                 // Termo B & ~C
    wire b_and_nc_and_nd;          // Termo B & ~C & ~D

    or  u_or_c_d           (c_or_d, c, d);              // c_or_d = c | d
    and u_and_nb_cord      (nb_and_c_or_d, nb, c_or_d); // nb_and_c_or_d = ~b & (c | d)
    and u_and_b_nc         (b_and_nc, b, nc);           // b_and_nc = b & ~c
    and u_and_b_nc_nd      (b_and_nc_and_nd, b_and_nc, nd); // b_and_nc_and_nd = b & ~c & ~d
    or  u_or_y2            (excess_out[2], nb_and_c_or_d, b_and_nc_and_nd); // y2 = termo1 | termo2

    // --------------------------------------------------------------------
    // Bit 3 da saida: y3 = A | (B & C) | (B & D)
    // --------------------------------------------------------------------
    wire b_and_c;                  // Termo B & C
    wire b_and_d;                  // Termo B & D
    wire bc_or_bd;                 // Termo (B & C) | (B & D)

    and u_and_b_c (b_and_c, b, c); // b_and_c = b & c
    and u_and_b_d (b_and_d, b, d); // b_and_d = b & d
    or  u_or_bc_bd (bc_or_bd, b_and_c, b_and_d); // bc_or_bd = (b & c) | (b & d)
    or  u_or_y3    (excess_out[3], a, bc_or_bd); // y3 = a | bc_or_bd

endmodule
