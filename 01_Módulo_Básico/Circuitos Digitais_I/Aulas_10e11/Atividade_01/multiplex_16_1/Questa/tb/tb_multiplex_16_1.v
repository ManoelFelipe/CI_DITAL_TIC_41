
`timescale 1ns/1ps
// -----------------------------------------------------------------------------
// Testbench: tb_multiplex_16_1
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Objetivo: Exercitar o mux 16:1 com padrões variados de dados e de seleção.
// -----------------------------------------------------------------------------
module tb_multiplex_16_1;

    // [Linha 1] Sinais dirigidos ao DUT (Device Under Test)
    reg  [15:0] d;    // entradas
    reg  [3:0]  sel;  // seleção
    wire        y;    // saída do DUT

    // [Linha 2] Referência comportamental dentro do TB para verificação
    wire y_ref;
    assign y_ref = d[sel]; // [Linha 3] Cálculo esperado

    // [Linha 4] Inclua exatamente UM dos RTLs no fluxo de compilação (compile.do).
    // O TB só instancia o nome genérico 'multiplex_16_1'.
    multiplex_16_1 DUT (
        .d  (d),
        .sel(sel),
        .y  (y)
    );

    // [Linha 5] Geração de VCD (útil para GTKWave/Icarus; o Questa ignora sem erro)
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_multiplex_16_1);
    end

    // [Linha 6] Rotina de estimulação
    integer i;
    initial begin
        // Cabeçalho de impressão
        $display("=== Início da simulação (mux 16x1) ===");
        $display("  tempo  sel  d[15:0]               | y  y_ref  OK");
        $display("---------------------------------------------------");

        // Padrão 1: caminhar por 'sel' com 'd' fixo
        d   = 16'b1010_1100_1111_0001;  // [Linha 7] Padrão arbitrário
        sel = 0;
        #1; // [Linha 8] Aguardar avaliação combinacional
        for (i=0; i<16; i=i+1) begin
            sel = i[3:0];
            #5; // [Linha 9] Espaçar as amostras
            $display("%6t  %2d   %b |  %0d   %0d    %s",
                     $time, sel, d, y, y_ref, (y===y_ref) ? "OK" : "ERRO");
        end

        // Padrão 2: variar 'd' e repetir varredura de 'sel'
        d = 16'hA55A; // [Linha 10] Outro padrão
        #5;
        for (i=0; i<16; i=i+1) begin
            sel = i[3:0];
            #5;
            $display("%6t  %2d   %b |  %0d   %0d    %s",
                     $time, sel, d, y, y_ref, (y===y_ref) ? "OK" : "ERRO");
        end

        // Padrão 3: "walking one" sobre d com sel fixo
        sel = 4'd9; // [Linha 11] Selecionar uma posição e deslocar '1' por 'd'
        d   = 16'b0;
        repeat (16) begin
            #5;
            $display("%6t  %2d   %b |  %0d   %0d    %s",
                     $time, sel, d, y, y_ref, (y===y_ref) ? "OK" : "ERRO");
            d = (d << 1) | 16'b1;
        end

        // Encerramento limpo
        $display("Fim da simulacao.");
        $finish;
    end

endmodule
