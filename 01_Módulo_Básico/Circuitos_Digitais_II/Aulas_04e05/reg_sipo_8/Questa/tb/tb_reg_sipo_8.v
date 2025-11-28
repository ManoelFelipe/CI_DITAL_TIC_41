// ============================================================================
// Arquivo  : tb_reg_sipo_8.v
// Autor    : Manoel Furtado
// Data     : 25/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench unificado para o Registrador SIPO de 8 bits.
//            Testa simultaneamente as implementações Behavioral, Dataflow e Structural.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_reg_sipo_8;

    // Declaração de sinais
    reg        clk;
    reg        rst;
    reg        din;
    reg        dir;
    
    wire [7:0] q_behav;
    wire [7:0] q_data;
    wire [7:0] q_struct;

    integer erros = 0;
    integer testes = 0;

    // Instanciação dos DUTs (Device Under Test)
    reg_sipo_8_behav dut_behav (
        .clk(clk), .rst(rst), .din(din), .dir(dir), .q(q_behav)
    );

    reg_sipo_8_data dut_data (
        .clk(clk), .rst(rst), .din(din), .dir(dir), .q(q_data)
    );

    reg_sipo_8_struct dut_struct (
        .clk(clk), .rst(rst), .din(din), .dir(dir), .q(q_struct)
    );

    // Geração de Clock (Período = 10ns)
    always #5 clk = ~clk;

    // Monitoramento e Verificação Automática
    always @(negedge clk) begin
        // Verifica na borda de descida para garantir estabilidade após a borda de subida
        if (!rst) begin // Ignora verificação durante reset se as saídas ainda não estabilizaram
            testes = testes + 1;
            if (q_behav !== q_data || q_data !== q_struct) begin
                $display("ERRO no tempo %0t: Inconsistencia detectada!", $time);
                $display("Inputs: rst=%b, din=%b, dir=%b", rst, din, dir);
                $display("Outputs: Behav=%b, Data=%b, Struct=%b", q_behav, q_data, q_struct);
                erros = erros + 1;
            end
        end
    end

    // Procedimento de Teste
    initial begin
        // Configuração de dump para waveform
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_reg_sipo_8);

        // Inicialização
        clk = 0;
        rst = 1;
        din = 0;
        dir = 0; // Começa deslocando à direita

        // Tabela Didática (Baseada na abordagem Behavioral)
        $display("=================================================================================================");
        $display("Tempo | rst | dir | din | q_behav (bin) | q_behav (dec) | Observacoes");
        $display("=================================================================================================");

        // Reset
        #15;
        rst = 0;
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Reset liberado", $time, rst, dir, din, q_behav, q_behav);

        // Teste 1: Deslocamento à Direita (dir=0)
        // Inserindo padrão 10101010 (LSB entra primeiro no shift right? Não, MSB entra primeiro no nosso design)
        // Nosso design: q <= {din, q[7:1]}. din entra no MSB (bit 7).
        
        // Ciclo 1: din=1 -> q deve ser 10000000
        din = 1; #10;
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Shift Right: Entra 1 no MSB", $time, rst, dir, din, q_behav, q_behav);
        
        // Ciclo 2: din=0 -> q deve ser 01000000
        din = 0; #10;
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Shift Right: Entra 0 no MSB", $time, rst, dir, din, q_behav, q_behav);

        // Ciclo 3: din=1 -> q deve ser 10100000
        din = 1; #10;
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Shift Right: Entra 1 no MSB", $time, rst, dir, din, q_behav, q_behav);

        // Teste 2: Mudança de Direção para Esquerda (dir=1)
        // Design: q <= {q[6:0], din}. din entra no LSB (bit 0).
        // Atual q = 10100000.
        dir = 1; 
        din = 1; 
        #10; // Ciclo 4
        // Esperado: 10100000 << 1 | 1 = 01000001
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Shift Left: Entra 1 no LSB", $time, rst, dir, din, q_behav, q_behav);

        din = 1; #10; // Ciclo 5 -> 10000011
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Shift Left: Entra 1 no LSB", $time, rst, dir, din, q_behav, q_behav);

        // Teste 3: Reset durante operação
        rst = 1; #10;
        $display("%5t |  %b  |  %b  |  %b  |   %b  |     %3d     | Reset ativado", $time, rst, dir, din, q_behav, q_behav);
        rst = 0;

        // Finalização
        #20;
        $display("=================================================================================================");
        
        if (erros == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes em %0d testes.", testes);
        end else begin
            $display("FALHA: Foram detectados %0d erros de consistencia.", erros);
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
