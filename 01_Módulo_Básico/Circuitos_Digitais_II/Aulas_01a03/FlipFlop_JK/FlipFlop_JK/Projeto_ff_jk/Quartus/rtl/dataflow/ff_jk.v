// ============================================================================
// Arquivo  : ff_jk.v  (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Flip-Flop JK Mestre-Escravo implementado com fluxo de dados (assign).
//            Utiliza equações booleanas para modelar dois latches SR controlados
//            (Mestre ativo em nível alto, Escravo ativo em nível baixo do clock)
//            para emular o comportamento de borda.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module ff_jk (
    input  wire clk,
    input  wire j,
    input  wire k,
    output wire q,
    output wire q_bar
);

    // Sinais internos para o Latch Mestre
    wire q_m, q_bar_m;
    // Sinais de controle do Mestre
    wire s_m, r_m;
    
    // Lógica do Mestre (Habilitado quando clk = 1)
    // S = (J & Q_bar_slave) & clk
    // R = (K & Q_slave) & clk
    assign s_m = ~(j & q_bar & clk); // NAND logic equivalent inputs for SR Latch constructed with NANDs
    assign r_m = ~(k & q & clk);
    
    // Latch SR com NANDs (Mestre)
    // Q = ~(S & Q_bar)
    // Q_bar = ~(R & Q)
    assign q_m = ~(s_m & q_bar_m);
    assign q_bar_m = ~(r_m & q_m);

    // Sinais de controle do Escravo (Habilitado quando clk = 0 -> inversor implícito ou gate logic)
    // O escravo deve capturar a saída do mestre quando o clock desce.
    // Usando estrutura clássica Mestre-Escravo com NANDs:
    // O clock é invertido para o escravo? Na verdade, na estrutura NAND pura:
    // O mestre é habilitado por CLK. O escravo é habilitado por ~CLK (ou controlado pelas saídas do mestre).
    
    wire s_s, r_s;
    
    // Na topologia clássica, as saídas do mestre alimentam o escravo, travadas pelo clock invertido.
    // S_slave = ~(Q_m & ~clk)
    // R_slave = ~(Q_bar_m & ~clk)
    assign s_s = ~(q_m & ~clk);
    assign r_s = ~(q_bar_m & ~clk);
    
    // Latch SR com NANDs (Escravo)
    assign q = ~(s_s & q_bar);
    assign q_bar = ~(r_s & q);

endmodule
