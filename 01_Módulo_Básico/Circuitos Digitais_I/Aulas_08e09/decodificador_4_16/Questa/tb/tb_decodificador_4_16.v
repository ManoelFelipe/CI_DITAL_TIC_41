
// =============================================================
// Testbench: tb_decodificador_4_16
// Objetivo: Estimular as entradas (0..15), comparar as três
//           abordagens e gerar VCD/prints formatados.
// =============================================================
`timescale 1ns/1ps

module tb_decodificador_4_16;
    // Entrada em comum
    reg  [3:0] a;
    // Saídas dos três DUTs
    wire [15:0] y_behav, y_data, y_struct;

    // Instâncias
    decodificador_4_16 DUT_BEHAV (.a(a), .y(y_behav));  // behavioral (quando compilar a versão da pasta behavioral)
    decodificador_4_16 DUT_DATA  (.a(a), .y(y_data));   // dataflow   (quando compilar a versão da pasta dataflow)
    decodificador_4_16 DUT_STRUC (.a(a), .y(y_struct)); // structural (quando compilar a versão da pasta structural)

    integer i;
    integer erros;

    // VCD (funciona em diversas ferramentas, inclusive GTKWave)
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_decodificador_4_16);
    end

    initial begin
        erros = 0;
        a = 4'd0; // estado inicial
        #1;       // pequena inércia

        $display("=== Teste 4->16 Decoder (0..15) ===");
        for (i = 0; i < 16; i = i + 1) begin
            a = i[3:0];
            #5; // tempo de propagação para observação nas formas de onda

            // Impressão legível
            $display("t=%0t ns | a=%0d | y_behav=%016b | y_data=%016b | y_struct=%016b",
                      $time, a, y_behav, y_data, y_struct);

            // Verificação de equivalência
            if ((y_behav !== y_data) || (y_behav !== y_struct)) begin
                $display("ERRO: Saídas divergentes para a=%0d", a);
                erros = erros + 1;
            end
        end

        if (erros == 0)
            $display("Resultado: SUCESSO. Todas as implementações equivalentes.");
        else
            $display("Resultado: FALHA. Divergências encontradas: %0d", erros);

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
