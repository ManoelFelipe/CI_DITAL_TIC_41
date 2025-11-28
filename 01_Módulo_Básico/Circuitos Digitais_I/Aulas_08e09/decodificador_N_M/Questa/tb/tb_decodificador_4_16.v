
// =============================================================
// Testbench: tb_decodificador_N_M (salvo como tb_decodificador_4_16.v)
// =============================================================
`timescale 1ns/1ps

module tb_decodificador_N_M;
    localparam integer N = 4;
    localparam integer M = (1<<N);

    reg  [N-1:0] a;
    wire [M-1:0] y_behav, y_data, y_struct;

    decodificador_N_M_behavioral #(.N(N)) DUT_BEHAV (.a(a), .y(y_behav));
    decodificador_N_M_dataflow   #(.N(N)) DUT_DATA  (.a(a), .y(y_data));
    decodificador_N_M_structural #(.N(N)) DUT_STRUC (.a(a), .y(y_struct));

    integer i, erros;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_decodificador_N_M);
    end

    initial begin
        erros = 0;
        a = {N{1'b0}}; #1;

        $display("=== Teste Paramétrico N=%0d, M=%0d ===", N, M);
        for (i = 0; i < M; i = i + 1) begin
            a = i[N-1:0];
            #5;
            // Largura fixa para N=4 -> M=16
            $display("t=%0t ns | a=%0d | y_behav=%016b | y_data=%016b | y_struct=%016b",
                     $time, a, y_behav, y_data, y_struct);
            if ((y_behav !== y_data) || (y_behav !== y_struct)) begin
                $display("ERRO: divergência em a=%0d", a);
                erros = erros + 1;
            end
        end

        if (erros == 0)
            $display("Resultado: SUCESSO. Implementações equivalentes.");
        else
            $display("Resultado: FALHA. Divergências: %0d", erros);

        $display("Fim da simulacao.");
        $finish;
    end
endmodule

