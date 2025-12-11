`timescale 1ns/1ps

// -------------------------------------------------------------
// Testbench: tb_mult2c_frac_4bit
// Arquivo: simula/tb_mult2c_frac_4bit.v
//
// Descrição:
// Módulo de teste para verificar o funcionamento do multiplicador
// de frações com sinal de 4 bits. Aplica vetores de teste e
// compara a saída do DUT com o resultado esperado (modelo gold).
// -------------------------------------------------------------

module tb_mult2c_frac_4bit;

    // ---------------------------------------------------------
    // Declaração de Sinais
    // ---------------------------------------------------------
    // Sinais do tipo 'reg' são usados para estimular as entradas do DUT
    reg        clk;      // Clock do sistema (gerado no TB)
    reg        st;       // Sinal de Start
    reg  [3:0] mplier;   // Operando Multiplicador
    reg  [3:0] mcand;    // Operando Multiplicando

    // Sinais do tipo 'wire' capturam as saídas do DUT
    wire [6:0] product;  // Resultado da multiplicação
    wire       done;     // Sinal de conclusão

    // ---------------------------------------------------------
    // Instanciação do DUT (Design Under Test)
    // ---------------------------------------------------------
    mult2c_frac_4bit dut (
        .clk     (clk),     // Conecta clock
        .st      (st),      // Conecta start
        .mplier  (mplier),  // Conecta entrada mplier
        .mcand   (mcand),   // Conecta entrada mcand
        .product (product), // Conecta saída product
        .done    (done)     // Conecta saída done
    );

    // ---------------------------------------------------------
    // Geração de Clock
    // ---------------------------------------------------------
    // Define o estado inicial do clock
    initial clk = 1'b0;
    
    // Inverte o clock a cada 5ns. Período total = 10ns (f = 100MHz)
    always #5 clk = ~clk;

    // ---------------------------------------------------------
    // Tarefa: run_case
    // Descrição: Executa um único caso de teste automatizado.
    // ---------------------------------------------------------
    task automatic run_case;
        input  [3:0] t_mcand;   // Valor do multiplicando para o teste
        input  [3:0] t_mplier;  // Valor do multiplicador para o teste
        input  [31:0] name;     // Nome/String para identificar o teste no log
        
        // Variáveis locais para verificação em 'signed' arithmetic
        reg   signed [3:0]  A_signed;     // Versão com sinal do multiplicando
        reg   signed [3:0]  B_signed;     // Versão com sinal do multiplicador
        reg   signed [7:0]  ref_product;  // Resultado esperado (Referência) de 8 bits
        reg   signed [7:0]  dut_ext;      // Resultado do DUT estendido para 8 bits para comparação
    begin
        // 1. Aplica os valores nas entradas do DUT
        mcand  = t_mcand;
        mplier = t_mplier;

        // 2. Gera o pulso de Start
        // Usa atribuição não-bloqueante (<=) para evitar clock race condition
        st <= 1'b1;         
        @(posedge clk);     // Espera uma borda de subida
        st <= 1'b0;         // Baixa o start

        // 3. Aguarda o DUT terminar
        // Fica parado aqui até o sinal 'done' ir para 1
        @(posedge done);

        // 4. Verificação de Resultados (Self-Checking)
        // Converte as entradas bit-vector para 'signed' para o Verilog fazer a conta matemática correta
        A_signed = t_mcand;
        B_signed = t_mplier;

        // Calcula o produto de referência usando operadpr '*' nativo do Verilog
        ref_product = A_signed * B_signed;

        // Estende o sinal do produto do DUT (de 7 para 8 bits) para comparar tamanhos iguais
        // { product[6], product } repete o bit de sinal
        dut_ext = { product[6], product };

        // 5. Exibe Relatório no Terminal
        $display("=== Caso %0s ===", name);
        $display("  mcand  = %b (signed = %0d)", t_mcand, A_signed);
        $display("  mplier = %b (signed = %0d)", t_mplier, B_signed);
        $display("  DUT product = %b (signed_ext = %0d)", product, dut_ext);
        $display("  REF product = %b (signed = %0d)\n", ref_product, ref_product);

        // 6. Compara resultados
        if (dut_ext === ref_product)
            $display("  -> OK: DUT == REF\n");
        else
            $display("  -> ERRO: DUT != REF\n");
            
        // 7. Espera a FSM voltar ao repouso (IDLE) antes do próximo teste
        repeat(2) @(posedge clk);
    end
    endtask

    // ---------------------------------------------------------
    // Bloco Principal de Testes (Estímulos)
    // ---------------------------------------------------------
    initial begin
        // Configura arquivo para visualização de ondas (GTKWave)
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_mult2c_frac_4bit);

        // Inicialização dos sinais
        st     = 1'b0;
        mcand  = 4'b0000;
        mplier = 4'b0000;

        // Bloco fork-join_any para gerenciar Timeout
        fork
            // Thread 1: Sequência de Testes
            begin
                // Pequena espera antes de começar
                #12;

                // Teste 1: Positivo x Positivo (+5/8 * +5/8)
                // 5/8 = 0.101 (bin) = 5 (dec representação Q1.3)
                run_case(4'b0101, 4'b0101, " +5/8  x  +5/8 ");

                // Teste 2: Negativo x Positivo (-3/8 * +5/8)
                // -3/8 = 1.101 (bin)
                run_case(4'b1101, 4'b0101, " -3/8  x  +5/8 ");

                // Teste 3: Positivo x Negativo (+5/8 * -3/8)
                run_case(4'b0101, 4'b1101, " +5/8  x  -3/8 ");

                // Teste 4: Negativo x Negativo (-3/8 * -3/8)
                run_case(4'b1101, 4'b1101, " -3/8  x  -3/8 ");

                // Teste 5: Caso Extra (+7/8 * +5/8)
                run_case(4'b0111, 4'b0101, " +7/8  x  +5/8 ");

                // Finalização
                #50;
                $display("All cases completed.");
                $finish; // Encerra a simulação com sucesso
            end

            // Thread 2: Watchdog Timer (Timeout)
            begin
                #2000; // Se a simulação passar de 2000ns, algo travou
                $display("ERROR: Simulation timed out!");
                $finish; // Força encerramento
            end
        join_any
    end

endmodule
