


//==============================================================
//  tb_latch_d_nand.v
//  Testbench para validação do Latch D
//
//  Objetivo:
//  Simular o comportamento do Latch D sob diversas condições de
//  estímulo, replicando o diagrama de tempos do exercício.
//
//  Cenários Testados:
//  1. Transparência (Q segue D com CLK=1)
//  2. Estabilidade em 0 (D=0 com CLK=1)
//  3. Glitches (Oscilações rápidas em D com CLK=1)
//  4. Latch em Nível Alto (D=1 quando CLK desce)
//  5. Latch em Nível Baixo (D=0 quando CLK desce)
//==============================================================

`timescale 1ns/1ps
module tb_latch_d_nand;

    reg CLK;
    reg D;
    wire Q;
    wire Qb;

    // Instanciação do DUT (Device Under Test)
    latch_d_nand dut (
        .D   (D),
        .CLK (CLK),
        .Q   (Q),
        .Qb  (Qb)
    );

    // ---------------------------------------------------------
    // Geração de Estímulos
    // ---------------------------------------------------------
    initial begin
        // Inicialização das entradas
        CLK = 1'b0;
        D   = 1'b0;

        // Aguarda estabilização inicial
        #20;

        // -----------------------------------------------------
        // CENÁRIO 1: Transparência Básica
        // Objetivo: Verificar se Q sobe e desce junto com D
        // enquanto o Clock está ALTO.
        // -----------------------------------------------------
        CLK = 1'b1;      // Clock sobe (Habilita o Latch)
        #5  D   = 1'b1;  // D sobe -> Q deve subir imediatamente
        #10 D   = 1'b0;  // D desce -> Q deve descer imediatamente
        #5  CLK = 1'b0;  // Clock desce (Desabilita/Trava)

        // Intervalo com Clock Baixo (Q deve manter o valor 0)
        #20;

        // -----------------------------------------------------
        // CENÁRIO 2: Linha de Base (D constante em 0)
        // Objetivo: Verificar se Q permanece em 0 quando D não muda.
        // -----------------------------------------------------
        CLK = 1'b1;      // Clock sobe
        #20 CLK = 1'b0;  // Clock desce (D permaneceu 0 o tempo todo)

        // Intervalo
        #20;

        // -----------------------------------------------------
        // CENÁRIO 3: Glitches / Ruído
        // Objetivo: Verificar a resposta a múltiplas transições rápidas.
        // Como é um Latch, Q deve seguir todas as mudanças de D.
        // -----------------------------------------------------
        CLK = 1'b1;      // Clock sobe
        #3  D   = 1'b1;  // Glitch 1 (Sobe)
        #3  D   = 1'b0;  // Glitch 1 (Desce)
        #3  D   = 1'b1;  // Glitch 2 (Sobe)
        #3  D   = 1'b0;  // Glitch 2 (Desce)
        #8  CLK = 1'b0;  // Clock desce

        // Intervalo
        #20;

        // -----------------------------------------------------
        // CENÁRIO 4: Latch em Nível Alto (Memória de 1)
        // Objetivo: Verificar se o Latch armazena o valor 1.
        // D está em 1 no momento que o Clock desce (borda de descida).
        // -----------------------------------------------------
        CLK = 1'b1;      // Clock sobe
        #5  D   = 1'b1;  // D sobe
        #15 CLK = 1'b0;  // Clock desce! (D=1 neste instante -> Q deve travar em 1)
        #10 D   = 1'b0;  // D muda para 0, mas como CLK=0, Q deve IGNORAR e manter 1.

        // Intervalo (Q deve continuar em 1)
        #10;

        // -----------------------------------------------------
        // CENÁRIO 5: Latch em Nível Baixo (Memória de 0)
        // Objetivo: Verificar se o Latch armazena o valor 0.
        // D volta a 0 ANTES do Clock descer.
        // -----------------------------------------------------
        CLK = 1'b1;      // Clock sobe (Q ainda é 1 do ciclo anterior, mas D=0 -> Q vai pra 0)
        #5  D   = 1'b1;  // D sobe -> Q sobe
        #10 D   = 1'b0;  // D desce -> Q desce
        #5  CLK = 1'b0;  // Clock desce! (D=0 neste instante -> Q deve travar em 0)

        // Finalização da simulação
        #20 $finish;
    end

    // ---------------------------------------------------------
    // Monitoramento (Console)
    // ---------------------------------------------------------
    initial begin
        $display("==================================================");
        $display("   Simulação do Latch D - Monitor de Sinais");
        $display("==================================================");
        $display(" Tempo(ns) | CLK | D | Q | Qb | Comentário");
        $display("-----------+-----+---+---+----+-------------------");
        $monitor("%9t  |  %b  | %b | %b | %b  |", $time, CLK, D, Q, Qb);
    end

    // ---------------------------------------------------------
    // Geração de Arquivo VCD (Waveform)
    // ---------------------------------------------------------
    initial begin
        $dumpfile("latch_d_nand.vcd");
        $dumpvars(0, tb_latch_d_nand);
    end

endmodule
