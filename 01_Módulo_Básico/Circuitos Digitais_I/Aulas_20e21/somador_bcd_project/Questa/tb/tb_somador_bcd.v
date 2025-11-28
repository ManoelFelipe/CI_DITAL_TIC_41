`timescale 1ns/1ps
// ============================================================================
//  tb_somador_bcd.v — Testbench unificado para as 3 implementações
//  Autor: Manoel Furtado
//  Data: 31/10/2025
//  Gera VCD, imprime comparações e encerra limpo.
// ============================================================================

module tb_somador_bcd;
    // Estímulos
    reg  [3:0] A, B;
    // Saídas das 3 versões
    wire [3:0] S_beh, S_dat, S_str;
    wire       C_beh, C_dat, C_str;

    // DUTs — supondo que o script compile SOMENTE uma versão dentro de ../rtl/<impl>/
    //       Para rodar todas simultaneamente no Questa, podemos compilar todas
    //       e renomear os módulos, mas aqui manteremos o nome 'somador_bcd' e
    //       instanciamos 3 cópias via 'defparam' de caminhos de biblioteca.
    //       Estratégia: usar três times de compilações diferentes via script.
    //       Como alternativa, incluímos aqui módulos com nomes distintos via `include.
    //       Para simplificar o fluxo do usuário, instanciamos UMA versão visível (work).
    //       Entretanto, também oferecemos comparação (com `ifdefs).

`ifdef HAS_BEHAVIORAL
    somador_bcd DUT_BEH (.A(A), .B(B), .S(S_beh), .Cout(C_beh));
`endif
`ifdef HAS_DATAFLOW
    somador_bcd DUT_DAT (.A(A), .B(B), .S(S_dat), .Cout(C_dat));
`endif
`ifdef HAS_STRUCTURAL
    somador_bcd DUT_STR (.A(A), .B(B), .S(S_str), .Cout(C_str));
`endif

    // VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_somador_bcd);
    end

    // Tarefas auxiliares
    task mostra(input [3:0] a, input [3:0] b);
        begin
`ifdef HAS_BEHAVIORAL
            $display("[BEH] A=%0d B=%0d -> S=%0d Cout=%0d", a, b, S_beh, C_beh);
`endif
`ifdef HAS_DATAFLOW
            $display("[DAT] A=%0d B=%0d -> S=%0d Cout=%0d", a, b, S_dat, C_dat);
`endif
`ifdef HAS_STRUCTURAL
            $display("[STR] A=%0d B=%0d -> S=%0d Cout=%0d", a, b, S_str, C_str);
`endif
        end
    endtask

    // Sequência de testes cobrindo os quatro cenários solicitados:
    // 1) soma sem carry       (ex.: 2 + 3 = 5)
    // 2) soma com carry       (ex.: 9 + 9 = 18 -> 8, carry=1)
    // 3) sem necessidade de correção  (ex.: 4 + 5 = 9)
    // 4) com necessidade de correção  (ex.: 7 + 6 = 13 -> 3, carry=1)
    initial begin
        A=0; B=0;
        #5;

        // 1) Sem carry
        A=4'd2; B=4'd3; #5; mostra(A,B);

        // 3) Sem correção (ainda < 10)
        A=4'd4; B=4'd5; #5; mostra(A,B);

        // 4) Com correção (>=10)
        A=4'd7; B=4'd6; #5; mostra(A,B);

        // 2) Com carry alto
        A=4'd9; B=4'd9; #5; mostra(A,B);

        // Mais alguns casos extras (aleatórios válidos 0..9)
        A=4'd0; B=4'd9; #5; mostra(A,B);
        A=4'd8; B=4'd1; #5; mostra(A,B);
        A=4'd5; B=4'd5; #5; mostra(A,B);

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
