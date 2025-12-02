`timescale 1ns / 1ps

/*
 * Módulo: tb_moore_laser
 * Descrição: Testbench para verificar o funcionamento do módulo moore_laser.
 *            Gera sinais de clock, reset e estímulos de entrada (botão) e monitora a saída.
 */
module tb_moore_laser;

    // Entradas (reg porque são dirigidas pelo testbench)
    reg clk; // Sinal de clock
    reg rst; // Sinal de reset
    reg b;   // Sinal de botão

    // Saídas (wire porque são dirigidas pelo módulo instanciado)
    wire x;  // Sinal de saída do laser

    // Instanciação da Unidade Sob Teste (UUT)
    moore_laser uut (
        .clk(clk), 
        .rst(rst), 
        .b(b), 
        .x(x)
    );

    // Geração de Clock
    initial begin
        clk = 0; // Inicializa clock em 0
        forever #5 clk = ~clk; // Inverte o clock a cada 5ns (período de 10ns)
    end

    // Estímulos de teste
    initial begin
        // Inicializa Entradas
        rst = 1; // Começa com reset ativado
        b = 0;   // Botão solto

        // Espera 100 ns para o reset global terminar (embora aqui usemos rst síncrono/assíncrono controlado)
        #20;
        rst = 0; // Desativa reset
        #20;

        // Caso de Teste 1: Pulsar o botão
        $display("Test 1: Press button");
        b = 1;   // Pressiona botão
        #10;     // Segura por 1 ciclo de clock
        b = 0;   // Solta botão
        
        // Espera a operação completar (deve ser 3 ciclos = 30ns)
        #50;

        // Caso de Teste 2: Segurar o botão
        $display("Test 2: Hold button");
        b = 1;   // Pressiona botão
        #50;     // Segura por mais de 3 ciclos
        b = 0;   // Solta botão
        #50;

        $finish; // Encerra simulação
    end
    
    // Monitoramento
    initial begin
        // Imprime mudanças nos sinais
        $monitor("Time=%t | rst=%b | b=%b | State=%b | x=%b", $time, rst, b, uut.current_state, x);
    end

    // Geração de arquivo de onda (VCD)
    initial begin
        $dumpfile("moore_wave.vcd"); // Nome do arquivo de saída
        $dumpvars(0, tb_moore_laser); // Variáveis a serem gravadas
    end

endmodule
