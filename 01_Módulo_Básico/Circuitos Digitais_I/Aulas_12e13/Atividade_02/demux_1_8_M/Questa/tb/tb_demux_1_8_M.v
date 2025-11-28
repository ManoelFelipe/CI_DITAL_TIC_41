
// ============================================================================
// Arquivo.....: tb_demux_1_8_M.v
// Testbench...: tb_demux_1_8_M
// Dispositivo.: demux_1_8_M
// Autor.......: Manoel Furtado
// Data........: 31/10/2025
// Descrição...: Gera estímulos automáticos, imprime resultados e exporta VCD.
// ============================================================================
`timescale 1ns/1ps

module tb_demux_1_8_M;
    // Sinais do DUT
    reg        D;         // Entrada de dados
    reg  [2:0] S;         // Seleção
    wire [7:0] Y;         // Saídas

    // Instancia o DUT (pode alternar caminho de compilação para behavioral/dataflow/structural)
    demux_1_8_M dut (
        .D(D),
        .S(S),
        .Y(Y)
    );

    // Geração do VCD para uso em diversas ferramentas
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_demux_1_8_M);
    end

    // Tarefa auxiliar para impressão formatada
    task show;
        begin
            $display("t=%0t ns | D=%0b S=%0d | Y=%0b", $time, D, S, Y);
        end
    endtask

    // Estímulos principais
    initial begin
        $display("Iniciando simulacao do demux 1x8...");
        D = 1'b0; S = 3'd0; #5; show();

        // Varre todas as selecoes com D=1
        D = 1'b1;
        repeat (8) begin
            #10; show();
            S = S + 1'b1;
        end

        // Checagem com D=0 (todas as saidas devem ficar zeradas)
        D = 1'b0; S = 3'd0; #10; show();
        S = 3'd7;            #10; show();

        // Padroes adicionais
        D = 1'b1; S = 3'd4; #10; show();
        D = 1'b1; S = 3'd2; #10; show();

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
