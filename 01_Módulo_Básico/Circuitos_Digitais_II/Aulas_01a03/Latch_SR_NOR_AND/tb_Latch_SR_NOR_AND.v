`timescale 1ns/1ps

module tb_Latch_SR_NOR_AND;

    // Estímulos
    reg S;
    reg R;

    // Saídas do latch NOR
    wire Qa_nor;
    wire Qb_nor;

    // Saídas do latch NAND
    wire Qa_nand;
    wire Qb_nand;

    // Instancia latch com NOR
    sr_latch_nor u_nor (
        .S  (S),
        .R  (R),
        .Qa (Qa_nor),
        .Qb (Qb_nor)
    );

    // Instancia latch com NAND
    sr_latch_nand u_nand (
        .S  (S),
        .R  (R),
        .Qa (Qa_nand),
        .Qb (Qb_nand)
    );

    // Geração dos estímulos (formas de onda S e R)
    initial begin
        // Inicialização
        S = 1'b0;
        R = 1'b0;

        // Pequeno tempo inicial em memória (Qa=0 já vem do initial)
        #10;

        // 1º pulso curto de S (SET)
        S = 1'b1; R = 1'b0; #10;
        S = 1'b0;           #10;

        // 1º pulso de R (RESET)
        R = 1'b1;           #20;
        R = 1'b0;           #10;

        // 2º pulso de R (RESET de novo)
        R = 1'b1;           #20;
        R = 1'b0;           #10;

        // Pulso LONGO de S
        S = 1'b1;           #10;

        // Dentro desse pulso longo, sobe R também (S=R=1 → proibido)
        R = 1'b1;           #20;
        R = 1'b0;           #10;

        // Termina o pulso longo de S
        S = 1'b0;           #10;

        // Último pulso curto de S
        S = 1'b1;           #10;
        S = 1'b0;           #20;

        // Fim da simulação
        $finish;
    end

    // Para ver valores no console
    initial begin
        $display("  t    S R | Qa_nor Qb_nor | Qa_nand Qb_nand");
        $monitor("%3t   %b %b |   %b      %b   |    %b       %b",
                 $time, S, R, Qa_nor, Qb_nor, Qa_nand, Qb_nand);
    end

    // Para gerar o .vcd (se usar Icarus) ou só deixar
    // o Questa/ModelSim usar o wave interno.
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_Latch_SR_NOR_AND);
    end

endmodule
