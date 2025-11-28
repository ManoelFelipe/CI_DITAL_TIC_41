
// =============================================================
// Testbench: tb_decodificador_4_16
// Varre entradas 0..15 e compara as três abordagens (ativo-baixo)
// Gera VCD e imprime resultados formatados.
// =============================================================
`timescale 1ns/1ps

module tb_decodificador_4_16;
    reg  [3:0] a;
    wire [15:0] y_behav_n, y_data_n, y_struct_n;

    // Instâncias com nomes distintos
    decodificador_4_16_behavioral DUT_BEHAV (.a(a), .y_n(y_behav_n));
    decodificador_4_16_dataflow   DUT_DATA  (.a(a), .y_n(y_data_n));
    decodificador_4_16_structural DUT_STRUC (.a(a), .y_n(y_struct_n));

    integer i, erros;

    // VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_decodificador_4_16);
    end

    initial begin
        erros = 0;
        a = 4'd0; #1;

        $display("=== Teste 4->16 ativo-BAIXO (one-cold) ===");
        for (i = 0; i < 16; i = i + 1) begin
            a = i[3:0];
            #5;
            $display("t=%0t ns | a=%0d | y_behav_n=%016b | y_data_n=%016b | y_struct_n=%016b",
                      $time, a, y_behav_n, y_data_n, y_struct_n);
            if ((y_behav_n !== y_data_n) || (y_behav_n !== y_struct_n)) begin
                $display("ERRO: divergência em a=%0d", a);
                erros = erros + 1;
            end
        end

        if (erros == 0)
            $display("Resultado: SUCESSO. Três abordagens equivalentes (ativo-BAIXO).");
        else
            $display("Resultado: FALHA. Divergências: %0d", erros);

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
