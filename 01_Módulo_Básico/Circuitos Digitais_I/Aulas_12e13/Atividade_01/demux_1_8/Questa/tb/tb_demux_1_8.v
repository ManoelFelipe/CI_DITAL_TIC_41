// tb_demux_1_8.v — Testbench do demultiplexador 1x8
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatível com Questa e Quartus (Verilog 2001)

`timescale 1ns/1ps

module tb_demux_1_8;
    // Sinais de estímulo
    reg        din;         // Entrada de dados
    reg  [2:0] sel;         // Seleção
    // Sinais monitorados
    wire [7:0] dout;        // Saídas do DUT

    // Escolha aqui qual implementação testar trocando o include de caminho, se desejar.
    // Para rodar via scripts, o compile.do já seleciona a implementação (behavioral/dataflow/structural).
    // A ligação abaixo será resolvida no momento da compilação (um dos demux_1_8 será visto).
    demux_1_8 dut (
        .din (din),         // Conecta entrada de dados
        .sel (sel),         // Conecta seleção
        .dout(dout)         // Conecta saídas
    );

    // Geração de VCD
    initial begin
        $dumpfile("wave.vcd");           // Arquivo de saída de formas de onda
        $dumpvars(0, tb_demux_1_8);      // Exporta todos os sinais do testbench
    end

    // Estímulos
    initial begin
        // Cabeçalho informativo no console
        $display("=== Testbench demux_1_8 ===");
        $display("Tempo | din sel | dout");
        $display("--------------------------");

        // Inicialização
        din = 1'b0;                      // Começa com dado 0
        sel = 3'd0;                      // Seleção inicial 0
        #5;                              // Aguarda 5ns

        // Teste com din=0 (todas as saídas devem permanecer 0)
        repeat (8) begin
            $display("%4t |  %0d   %0d | %b", $time, din, sel, dout);
            #5 sel = sel + 1'b1;         // Varre todas as seleções
        end

        // Volta seleção para 0 e coloca din=1
        sel = 3'd0;                      // Reinicia a seleção
        din = 1'b1;                      // Ativa dado
        #5;                              // Aguarda para estabilizar

        // Teste com din=1 (apenas uma saída alta por seleção)
        repeat (8) begin
            $display("%4t |  %0d   %0d | %b", $time, din, sel, dout);
            #5 sel = sel + 1'b1;         // Varre todas as seleções
        end

        // Encerramento limpo
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
