`timescale 1ns/1ps
// ============================================================
// Testbench comparativo: Algoritmo de divisão com restauração
// (RDA) x Algoritmo de divisão não restaurador (NRDA).
//
// Verifica a funcionalidade de ambos os módulos com vetores de teste
// e compara os resultados.
// ============================================================
module tb_compare_RDA_NRDA;

    // Parâmetro de largura de bits (deve corresponder aos módulos)
    parameter N = 8;

    // Sinais de controle e dados para os módulos
    reg clk, reset, start;
    reg [N-1:0] dividend, divisor;

    // Sinais de saída (Quociente, Resto, Ready) para RDA
    wire [N-1:0] q_rda, r_rda;
    wire ready_rda;
    
    // Sinais de saída para NRDA
    wire [N-1:0] q_nrda, r_nrda;
    wire ready_nrda;

    // Instanciação do Device Under Test (DUT) - RDA
    divRDA_FSM #(N) dut_rda (
        .clk(clk),
        .reset(reset),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(q_rda),
        .remainder(r_rda),
        .ready(ready_rda)
    );

    // Instanciação do Device Under Test (DUT) - NRDA
    divNRDA_FSM #(N) dut_nrda (
        .clk(clk),
        .reset(reset),
        .start(start),
        .dividend(dividend),
        .divisor(divisor),
        .quotient(q_nrda),
        .remainder(r_nrda),
        .ready(ready_nrda)
    );

    // Geração de Clock: 100 MHz (período de 10 ns)
    // Toggled a cada 5 ns
    always #5 clk = ~clk;

    // Contadores de ciclos de clock para medição de performance
    integer cycles_rda;
    integer cycles_nrda;

    // Flags para indicar conclusão independente de cada módulo
    reg done_rda, done_nrda;

    // ----------------------------------------------------------------
    // Task para executar um caso de teste individual
    // Entradas: A (Dividendo), B (Divisor)
    // ----------------------------------------------------------------
    task run_test(input [N-1:0] A, input [N-1:0] B);
    begin
        // Exibe cabeçalho do teste
        $display("\n==================================");
        $display(" Teste: dividend = %0d ; divisor = %0d", A, B);
        $display("==================================");

        // Configura entradas
        dividend = A;
        divisor  = B;

        // Reseta contadores e flags
        cycles_rda  = 0;
        cycles_nrda = 0;
        done_rda    = 0;
        done_nrda   = 0;

        // Gera o pulso de start (ativo por 1 ciclo)
        start = 1'b1;
        @(posedge clk);
        start = 1'b0;

        // Loop de espera até que AMBAS as máquinas terminem
        // As máquinas podem terminar em tempos diferentes.
        while (!(done_rda && done_nrda)) begin
            @(posedge clk); // Aguarda borda de subida
            
            // Verifica se RDA ficou pronto
            if (ready_rda) done_rda = 1'b1;
            // Verifica se NRDA ficou pronto
            if (ready_nrda) done_nrda = 1'b1;

            // Incrementa contadores de ciclo se ainda não terminou
            if (!done_rda)  cycles_rda  = cycles_rda  + 1;
            if (!done_nrda) cycles_nrda = cycles_nrda + 1;
            
            // Timeout de segurança para evitar loop infinito
            if (cycles_rda > 1000 || cycles_nrda > 1000) begin
                $display("Timeout! Execução demorou demais ou travou.");
                done_rda = 1'b1;
                done_nrda = 1'b1;
            end
        end

        // Exibe os resultados finais
        $display(" RDA : Q=%0d R=%0d  ciclos=%0d", q_rda,  r_rda,  cycles_rda);
        $display(" NRDA: Q=%0d R=%0d  ciclos=%0d", q_nrda, r_nrda, cycles_nrda);
    end
    endtask

    // ----------------------------------------------------------------
    // Bloco inicial de execução
    // ----------------------------------------------------------------
    initial begin
        // Configura arquivo para visualização de ondas (GTKWave)
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_compare_RDA_NRDA);

        // Inicialização de sinais
        clk   = 1'b0;
        reset = 1'b1;
        start = 1'b0;
        dividend = 0;
        divisor  = 0;

        // Aplica reset por 20ns
        #20;
        reset = 1'b0;

        // --- Casos de Teste ---
        
        // 1. Teste simples sem resto (11 / 3 = 3, resto 2)
        run_test(8'd11 , 8'd3 );
        
        // 2. Teste que causou erro no RDA anteriormente (115 / 7 = 16, resto 3)
        run_test(8'd115, 8'd7 );
        
        // 3. Outros testes aleatórios
        run_test(8'd113, 8'd19);
        run_test(8'd200, 8'd13);

        // Finaliza simulação
        $display("\nFim da simulacao.");
        $finish;
    end

endmodule
