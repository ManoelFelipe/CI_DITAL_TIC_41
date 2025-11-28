// ============================================================================
// Arquivo  : ff_jk.v  (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Flip-Flop JK Mestre-Escravo implementado estruturalmente.
//            Instancia portas primitivas (nand, not) para formar a topologia
//            Mestre-Escravo, garantindo operação por borda e estabilidade.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module ff_jk (
    input  wire clk,
    input  wire j,
    input  wire k,
    output wire q,
    output wire q_bar
);

    // Fios internos
    wire clk_inv;
    wire nand1_out, nand2_out;
    wire q_m, q_bar_m;
    wire nand3_out, nand4_out;

    // Inversor para o clock (usado no escravo)
    not u_not_clk (clk_inv, clk);

    // --- Estágio Mestre (Habilitado com CLK = 1) ---
    // Portas de entrada do Mestre (feedback de q e q_bar do escravo)
    // NAND1: J, Clock, Q_bar (feedback)
    nand u_nand1 (nand1_out, j, clk, q_bar);
    // NAND2: K, Clock, Q (feedback)
    nand u_nand2 (nand2_out, k, clk, q);

    // Latch SR do Mestre (formado por NANDs cruzadas)
    nand u_nand_m1 (q_m, nand1_out, q_bar_m);
    nand u_nand_m2 (q_bar_m, nand2_out, q_m);

    // --- Estágio Escravo (Habilitado com CLK = 0 -> clk_inv = 1) ---
    // Portas de entrada do Escravo
    nand u_nand3 (nand3_out, q_m, clk_inv);
    nand u_nand4 (nand4_out, q_bar_m, clk_inv);

    // Latch SR do Escravo
    nand u_nand_s1 (q, nand3_out, q_bar);
    nand u_nand_s2 (q_bar, nand4_out, q);

endmodule
