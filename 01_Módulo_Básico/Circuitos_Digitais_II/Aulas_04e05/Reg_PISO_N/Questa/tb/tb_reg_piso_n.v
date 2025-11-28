// ============================================================================
// Arquivo  : tb_reg_piso_n.v
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench para verificar o funcionamento do registrador PISO.
//            Instancia dois módulos: um com deslocamento à direita e outro à esquerda.
//            Verifica carga paralela e deslocamento serial bit a bit.
// Revisão  : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_reg_piso_n;

    // Parâmetros
    parameter N = 8;

    // Sinais do Testbench
    reg          clk;
    reg          rst_n;
    reg          load;
    reg  [N-1:0] din;
    wire         dout_right;
    wire         dout_left;

    // Variáveis auxiliares para verificação
    integer i;
    reg [N-1:0] expected_right;
    reg [N-1:0] expected_left;
    integer errors;

    // Instância 1: Deslocamento para DIREITA (DIR=0)
    reg_piso_n #(.N(N), .DIR(0)) u_right (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .din(din),
        .dout(dout_right)
    );

    // Instância 2: Deslocamento para ESQUERDA (DIR=1)
    reg_piso_n #(.N(N), .DIR(1)) u_left (
        .clk(clk),
        .rst_n(rst_n),
        .load(load),
        .din(din),
        .dout(dout_left)
    );

    // Geração de Clock (Período = 10ns)
    always #5 clk = ~clk;

    // Procedimento de Teste
    initial begin
        // Configuração de dump para ondas
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_reg_piso_n);

        // Inicialização
        clk = 0;
        rst_n = 0;
        load = 0;
        din = 0;
        errors = 0;

        $display("Iniciando simulacao do PISO N=%0d...", N);

        // Reset
        #12 rst_n = 1;
        $display("Reset liberado.");

        // --------------------------------------------------------------------
        // Caso de Teste 1: Carregar 0xA5 (10100101)
        // --------------------------------------------------------------------
        @(negedge clk);
        load = 1;
        din = 8'hA5; // 10100101
        $display("Carregando valor: %h (10100101)", din);
        
        @(negedge clk);
        load = 0; // Inicia deslocamento
        
        // Preparar valores esperados
        expected_right = din;
        expected_left  = din;

        // Verificar deslocamento por N ciclos
        for (i = 0; i < N; i = i + 1) begin
            // Verificar saídas ANTES da borda de subida (dados estáveis)
            // Nota: dout é combinacional do registrador. O registrador atualizou na borda anterior.
            
            // Verificação Direita (LSB sai primeiro)
            if (dout_right !== expected_right[0]) begin
                $display("ERRO [Right] Ciclo %0d: Esperado %b, Obtido %b", i, expected_right[0], dout_right);
                errors = errors + 1;
            end

            // Verificação Esquerda (MSB sai primeiro)
            if (dout_left !== expected_left[N-1]) begin
                $display("ERRO [Left]  Ciclo %0d: Esperado %b, Obtido %b", i, expected_left[N-1], dout_left);
                errors = errors + 1;
            end

            // Atualizar valores esperados para o próximo ciclo (simulando o shift)
            expected_right = expected_right >> 1;
            expected_left  = expected_left << 1;

            @(negedge clk); // Aguardar próximo ciclo
        end

        // --------------------------------------------------------------------
        // Caso de Teste 2: Carregar 0xF0 (11110000)
        // --------------------------------------------------------------------
        @(negedge clk);
        load = 1;
        din = 8'hF0;
        $display("Carregando valor: %h (11110000)", din);

        @(negedge clk);
        load = 0;

        expected_right = din;
        expected_left  = din;

        for (i = 0; i < N; i = i + 1) begin
            if (dout_right !== expected_right[0]) begin
                $display("ERRO [Right] Ciclo %0d: Esperado %b, Obtido %b", i+N, expected_right[0], dout_right);
                errors = errors + 1;
            end

            if (dout_left !== expected_left[N-1]) begin
                $display("ERRO [Left]  Ciclo %0d: Esperado %b, Obtido %b", i+N, expected_left[N-1], dout_left);
                errors = errors + 1;
            end

            expected_right = expected_right >> 1;
            expected_left  = expected_left << 1;

            @(negedge clk);
        end

        // Finalização
        if (errors == 0) begin
            $display("========================================");
            $display("SIMULATION SUCCESS: Todos os testes passaram!");
            $display("========================================");
        end else begin
            $display("========================================");
            $display("SIMULATION FAILED: %0d erros encontrados.", errors);
            $display("========================================");
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
