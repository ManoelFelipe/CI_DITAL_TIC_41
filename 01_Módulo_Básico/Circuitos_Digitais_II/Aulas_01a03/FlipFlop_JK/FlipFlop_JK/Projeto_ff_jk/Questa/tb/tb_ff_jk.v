// ============================================================================
// Arquivo  : tb_ff_jk.v
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench para validação do Flip-Flop JK.
//            Gera os estímulos visuais conforme o diagrama do exercício
//            e verifica automaticamente as transições de estado.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_ff_jk;

    // Sinais do Testbench
    reg clk;
    reg j;
    reg k;
    wire q;
    wire q_bar;

    // Instância do DUT (Device Under Test)
    ff_jk u_dut (
        .clk(clk),
        .j(j),
        .k(k),
        .q(q),
        .q_bar(q_bar)
    );

    // Geração de Clock (Período de 20ns -> 10ns high, 10ns low)
    always #10 clk = ~clk;

    // Procedimento de Teste
    initial begin
        // Configuração de Dump para visualização de ondas
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ff_jk);

        // Inicialização
        clk = 0;
        j = 0;
        k = 0;

        $display("Iniciando simulacao do Flip-Flop JK...");
        $display("Tempo\tJ\tK\tQ\tQ_bar\tDescricao");

        // --- Sequência baseada no diagrama visual ---
        // Clock period: 20ns (Edges at 10, 30, 50, 70...)

        // Borda 1 (t=10ns): J=0, K=0 -> Hold (Q=0)
        #15; // Avança para t=15ns (logo após Borda 1)

        // Entre Borda 1 (10ns) e Borda 2 (30ns)
        // Diagrama: K dá um pulso High-Low. J sobe para High.
        k = 1; // K sobe
        #5;    // t=20ns
        k = 0; // K desce
        j = 1; // J sobe
        
        // Borda 2 (t=30ns): J=1, K=0 -> Set (Q=1)
        #11; // Chega em t=31ns (verificação)
        if (q !== 1) $display("ERRO em t=%0t: Esperado Q=1 (Set), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Set funcionou. Q=%b", $time, q);

        // Entre Borda 2 (30ns) e Borda 3 (50ns)
        // Diagrama: J desce. K sobe.
        #4; // t=35ns
        j = 0; 
        #5; // t=40ns
        k = 1;

        // Borda 3 (t=50ns): J=0, K=1 -> Reset (Q=0)
        #11; // Chega em t=51ns (verificação)
        if (q !== 0) $display("ERRO em t=%0t: Esperado Q=0 (Reset), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Reset funcionou. Q=%b", $time, q);

        // Entre Borda 3 (50ns) e Borda 4 (70ns)
        // Diagrama: K desce, depois sobe. J sobe.
        #4; // t=55ns
        k = 0;
        #5; // t=60ns
        j = 1;
        #5; // t=65ns
        k = 1;

        // Borda 4 (t=70ns): J=1, K=1 -> Toggle (Q: 0->1)
        #6; // Chega em t=71ns (verificação)
        if (q !== 1) $display("ERRO em t=%0t: Esperado Q=1 (Toggle 0->1), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Toggle funcionou. Q=%b", $time, q);

        // Entre Borda 4 (70ns) e Borda 5 (90ns)
        // Diagrama: K desce. J mantém 1.
        #4; // t=75ns
        k = 0;
        
        // Borda 5 (t=90ns): J=1, K=0 -> Set/Hold (Q=1)
        #16; // Chega em t=91ns (verificação)
        if (q !== 1) $display("ERRO em t=%0t: Esperado Q=1 (Set/Hold), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Set/Hold funcionou. Q=%b", $time, q);

        // Entre Borda 5 (90ns) e Borda 6 (110ns)
        // Diagrama: J desce. K sobe.
        #4; // t=95ns
        j = 0;
        k = 1;

        // Borda 6 (t=110ns): J=0, K=1 -> Reset (Q=0)
        #16; // Chega em t=111ns (verificação)
        if (q !== 0) $display("ERRO em t=%0t: Esperado Q=0 (Reset), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Reset funcionou. Q=%b", $time, q);

        // Entre Borda 6 (110ns) e Borda 7 (130ns)
        // Diagrama: J sobe. K mantém 1.
        #4; // t=115ns
        j = 1;

        // Borda 7 (t=130ns): J=1, K=1 -> Toggle (Q: 0->1)
        #16; // Chega em t=131ns (verificação)
        if (q !== 1) $display("ERRO em t=%0t: Esperado Q=1 (Toggle 0->1), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Toggle funcionou. Q=%b", $time, q);

        // Entre Borda 7 (130ns) e Borda 8 (150ns)
        // Diagrama: J mantém 1. K mantém 1.
        // Nada muda.

        // Borda 8 (t=150ns): J=1, K=1 -> Toggle (Q: 1->0)
        #20; // Chega em t=151ns (verificação)
        if (q !== 0) $display("ERRO em t=%0t: Esperado Q=0 (Toggle 1->0), Obtido Q=%b", $time, q);
        else $display("OK em t=%0t: Toggle funcionou. Q=%b", $time, q);

        #20;
        $display("Fim da simulacao.");
        $finish;
    end

endmodule
