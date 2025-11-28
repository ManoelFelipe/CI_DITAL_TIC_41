// ============================================================================
//  tb_somador_bcd.v — Testbench com as 3 implementações em paralelo
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Gera VCD, imprime resultados e encerra limpo.
//  Observação: este TB assume que o compile.do criou os módulos
//              somador_bcd_beh, somador_bcd_dat e somador_bcd_str.
// ============================================================================

`timescale 1ns/1ps                 // Unidades/precisão de simulação

module tb_somador_bcd;             // Início do testbench (sem portas)

    // --------------------- Estímulos (entradas comuns) ----------------------
    reg  [3:0] A;                   // Operando A (BCD)
    reg  [3:0] B;                   // Operando B (BCD)

    // --------------------- Sinais de saída de cada DUT ----------------------
    wire [3:0] S_beh;               // Saída (behavioral)
    wire       C_beh;               // Carry  (behavioral)

    wire [3:0] S_dat;               // Saída (dataflow)
    wire       C_dat;               // Carry  (dataflow)

    wire [3:0] S_str;               // Saída (structural)
    wire       C_str;               // Carry  (structural)

    // --------------------- Instâncias dos 3 DUTs ----------------------------
    somador_bcd_beh DUT_BEH (       // Instância da versão behavioral
        .A   (A),                   // Conecta A
        .B   (B),                   // Conecta B
        .S   (S_beh),               // Recebe S
        .Cout(C_beh)                // Recebe Cout
    );

    somador_bcd_dat DUT_DAT (       // Instância da versão dataflow
        .A   (A),                   // Conecta A
        .B   (B),                   // Conecta B
        .S   (S_dat),               // Recebe S
        .Cout(C_dat)                // Recebe Cout
    );

    somador_bcd_str DUT_STR (       // Instância da versão structural
        .A   (A),                   // Conecta A
        .B   (B),                   // Conecta B
        .S   (S_str),               // Recebe S
        .Cout(C_str)                // Recebe Cout
    );

    // --------------------- Dump de formas de onda (VCD) ---------------------
    initial begin                   // Bloco único de inicialização
        $dumpfile("wave.vcd");      // Nome do arquivo VCD
        $dumpvars(0, tb_somador_bcd);// Registra todos os sinais do TB (profundidade 0 = recursivo)
    end

    // --------------------- Tarefa de impressão formatada --------------------
    task mostra(input [3:0] a, input [3:0] b); // Tarefa para exibir comparativo
        begin
            $display("A=%0d B=%0d | BEH S=%0d C=%0d | DAT S=%0d C=%0d | STR S=%0d C=%0d",
                     a, b, S_beh, C_beh, S_dat, C_dat, S_str, C_str);
        end
    endtask

    // --------------------- Sequência de testes ------------------------------
    initial begin                   // Estímulos temporizados
        A = 4'd0; B = 4'd0; #5;     // Inicializa sinais e espera 5ns

        A = 4'd2; B = 4'd3; #5;     // Sem carry: 2+3=5
        mostra(A,B);                // Imprime resultados

        A = 4'd4; B = 4'd5; #5;     // Sem correção: 4+5=9
        mostra(A,B);                // Imprime resultados

        A = 4'd7; B = 4'd6; #5;     // Com correção: 7+6=13 -> S=3, Cout=1
        mostra(A,B);                // Imprime resultados

        A = 4'd9; B = 4'd9; #5;     // Carry alto: 9+9=18 -> S=8, Cout=1
        mostra(A,B);                // Imprime resultados

        A = 4'd0; B = 4'd9; #5;     // Caso extra: 0+9=9 (sem correção)
        mostra(A,B);                // Imprime resultados

        A = 4'd8; B = 4'd1; #5;     // Caso extra: 8+1=9 (sem correção)
        mostra(A,B);                // Imprime resultados

        A = 4'd5; B = 4'd5; #5;     // Caso extra: 5+5=10 -> S=0, Cout=1
        mostra(A,B);                // Imprime resultados

        $display("Fim da simulacao."); // Mensagem final amigável
        $finish;                   // Encerra a simulação (modo CLI/GUI)
    end

endmodule                         // Fim do testbench
