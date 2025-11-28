`timescale 1ns/1ps // Define a escala de tempo: unidade 1ns, precisão 1ps

// Módulo de Testbench para o Latch SR NOR
module tb_Latch_SR_NOR;

    // Declaração de sinais para conectar ao DUT (Device Under Test)
    reg S;      // Sinal de estímulo para entrada Set
    reg R;      // Sinal de estímulo para entrada Reset
    reg clock;  // Sinal de estímulo para o Clock
    wire Qa;    // Sinal para monitorar a saída Q
    wire Qb;    // Sinal para monitorar a saída Qb

    // Instanciação da Unidade Sob Teste (UUT - Unit Under Test)
    Latch_SR_NOR uut (
        .S(S),          // Conecta o reg S à entrada S do módulo
        .R(R),          // Conecta o reg R à entrada R do módulo
        .clock(clock),  // Conecta o reg clock à entrada clock do módulo
        .Qa(Qa),        // Conecta a saída Qa do módulo ao wire Qa
        .Qb(Qb)         // Conecta a saída Qb do módulo ao wire Qb
    );

    // Geração de Clock: período de 20ns (10ns alto, 10ns baixo)
    initial begin
        clock = 0;          // Inicializa o clock em 0
        forever #10 clock = ~clock; // Inverte o clock a cada 10ns
    end

    // Geração de Estímulos (Sinais de entrada)
    initial begin
        // Inicializa as entradas
        S = 0;
        R = 0;

        // Aguarda 5ns para o reset global e estabilização inicial
        #5;

        // --- Ciclo 1 ---
        // Borda de subida do clock ocorre em 10ns
        
        // Pulso em S ao redor da primeira borda de clock
        #3 S = 1;  // @8ns: S vai para 1 antes do clock subir
        #6 S = 0;  // @14ns: S volta para 0 depois do clock subir

        // Pulso em R enquanto o clock está baixo (20ns a 30ns)
        #8 R = 1;  // @22ns: R vai para 1
        #4 R = 0;  // @26ns: R volta para 0
        
        // Glitches (ruídos/pulsos rápidos) em R
        #1 R = 1;  // @27ns: R vai para 1
        #1 R = 0;  // @28ns: R volta para 0
        #1 R = 1;  // @29ns: R vai para 1
        #2 R = 0;  // @31ns: R volta para 0 (Logo após a borda de subida em 30ns)

        // --- Ciclo 2 ---
        // Borda de subida do clock ocorre em 30ns
        
        // Glitches em S enquanto o clock está alto (30ns a 40ns)
        #2 S = 1;  // @33ns: S vai para 1
        #1 S = 0;  // @34ns: S volta para 0
        #1 S = 1;  // @35ns: S vai para 1
        #1 S = 0;  // @36ns: S volta para 0

        // --- Ciclo 3 ---
        // Borda de subida do clock ocorre em 50ns
        
        // S vai para nível alto antes da borda
        #12 S = 1; // @48ns: S setado para 1
        
        // R vai para nível alto depois da borda
        #4 R = 1;  // @52ns: R setado para 1 (condição proibida S=1, R=1 se clock=1)
        
        // S vai para nível baixo
        #3 S = 0;  // @55ns: S volta para 0
        
        // R vai para nível baixo
        #3 R = 0;  // @58ns: R volta para 0

        // Aguarda mais 20ns e encerra a simulação
        #20;
        $finish;
    end

    // Monitor de sinais para saída em tabela no console
    initial begin
        // Cabeçalho da tabela
        $display("=================================================================================");
        $display(" Simulação do Latch SR - Monitor de Sinais");
        $display("=================================================================================");
        $display(" Tempo(ns) | CLK | S | R | Qa | Qb | Comentário");
        $display("-----------+-----+---+---+----+----+---------------------------------------------");
        
        // $monitor imprime uma nova linha sempre que algum sinal da lista mudar
        // %9t: tempo com 9 dígitos
        // %b: binário
        $monitor(" %9t |  %b  | %b | %b |  %b |  %b |", $time, clock, S, R, Qa, Qb);
    end

endmodule
