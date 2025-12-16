// ============================================================================
// Arquivo  : tb_regfile8x16c.v
// Autor    : Manoel Furtado
// Data     : 2025-12-16
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench determinístico que instancia e compara 3 DUTs (beh/dat/str)
//            para um regfile 8x16 (1W/2R). Escreve em todos os registradores e
//            lê A e B em direções opostas, com checagem automática e VCD.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Define a unidade de tempo da simulação (1ns) e a precisão (1ps)
`timescale 1ns/1ps

module tb_regfile8x16c;
    // Sinais para estímulos do DUT 
    // (marcados como reg pois são controlados dentro de blocos initial/always)
    reg clk;
    reg reset;
    reg write;
    reg [2:0]  wr_addr;
    reg [15:0] wr_data;
    reg [2:0]  rd_addr_a;
    reg [2:0]  rd_addr_b;

    // Fios para coletar as saídas das 3 implementações (DUTs)
    wire [15:0] rd_a_beh, rd_b_beh; // Saídas do Behavioral
    wire [15:0] rd_a_dat, rd_b_dat; // Saídas do Dataflow
    wire [15:0] rd_a_str, rd_b_str; // Saídas do Structural

    // Instanciação da unidade sob teste (DUT) - Implementação Behavioral
    regfile8x16c_beh u_beh(
        .clk(clk),
        .reset(reset),
        .write(write),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr_a(rd_addr_a),
        .rd_data_a(rd_a_beh),
        .rd_addr_b(rd_addr_b),
        .rd_data_b(rd_b_beh)
    );

    // Instanciação da unidade sob teste (DUT) - Implementação Dataflow
    regfile8x16c_dat u_dat(
        .clk(clk),
        .reset(reset),
        .write(write),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr_a(rd_addr_a),
        .rd_data_a(rd_a_dat),
        .rd_addr_b(rd_addr_b),
        .rd_data_b(rd_b_dat)
    );

    // Instanciação da unidade sob teste (DUT) - Implementação Structural
    regfile8x16c_str u_str(
        .clk(clk),
        .reset(reset),
        .write(write),
        .wr_addr(wr_addr),
        .wr_data(wr_data),
        .rd_addr_a(rd_addr_a),
        .rd_data_a(rd_a_str),
        .rd_addr_b(rd_addr_b),
        .rd_data_b(rd_b_str)
    );

    // Array interno para armazenar os valores esperados (reference model do testbench)
    reg [15:0] exp [0:7];
    
    // Variáveis auxiliares para controle do testbench
    integer i;              // Iterador de loops
    integer tests_total;    // Contador de testes realizados
    integer errors_total;   // Contador de erros encontrados
    reg success;            // Flag booleana de sucesso geral

    // Geração do Clock: período de 10ns (f = 100MHz)
    initial begin
        clk = 1'b0;      // Valor inicial
        forever #5 clk = ~clk; // Inverte a cada 5ns
    end

    // Configuração para geração de arquivo de onda (VCD)
    initial begin
        $dumpfile("wave.vcd");         // Nome do arquivo de saída
        $dumpvars(0, tb_regfile8x16c); // Dumpar todas as variáveis do testbench
    end

    // Tarefa para verificar se as saídas dos DUTs correspondem aos valores esperados
    // Compara Beh vs Dat, Dat vs Str e Beh vs Esperado
    task check_all;
        input [15:0] exp_a; // Valor esperado para a porta A
        input [15:0] exp_b; // Valor esperado para a porta B
        begin
            tests_total = tests_total + 1; // Incrementa contador de testes

            // Verifica consistência entre as 3 implementações
            if ((rd_a_beh !== rd_a_dat) || (rd_a_dat !== rd_a_str) ||
                (rd_b_beh !== rd_b_dat) || (rd_b_dat !== rd_b_str)) begin
                errors_total = errors_total + 1;
                success = 1'b0;
                $display("ERRO(DUT mismatch) t=%0t | A beh=%h dat=%h str=%h | B beh=%h dat=%h str=%h",
                    $time, rd_a_beh, rd_a_dat, rd_a_str, rd_b_beh, rd_b_dat, rd_b_str);
            end

            // Verifica se a saída (Behavioral como referência) bate com o modelo esperado
            if ((rd_a_beh !== exp_a) || (rd_b_beh !== exp_b)) begin
                errors_total = errors_total + 1;
                success = 1'b0;
                $display("ERRO(esperado) t=%0t | expA=%h gotA=%h | expB=%h gotB=%h",
                    $time, exp_a, rd_a_beh, exp_b, rd_b_beh);
            end
        end
    endtask

    // Bloco principal de estímulos (TEST CASE principal)
    initial begin
        // Inicialização dos sinais
        reset=0; write=0; wr_addr=0; wr_data=0; rd_addr_a=0; rd_addr_b=0;
        
        // Inicializa o array de valores esperados com 0 (estado pós-reset)
        for (i=0;i<8;i=i+1) exp[i]=16'h0000;
        
        // Zera contadores
        tests_total=0; errors_total=0; success=1'b1;

        // Sequência de Reset
        @(negedge clk); reset=1; // Ativa reset na borda de descida
        @(posedge clk);          // Espera uma borda de subida (para o reset síncrono atuar)
        @(negedge clk); reset=0; // Desativa reset

        // Teste de leitura pós-reset (deve ler 0 em tudo)
        rd_addr_a=0; rd_addr_b=7; #1; check_all(exp[0],exp[7]);

        // ==== CENÁRIO 1: Escrita em todos os registradores ====
        $display("\n==== Escrita em todos os registradores ====");
        for (i=0;i<8;i=i+1) begin
            @(negedge clk); // Configura dados na borda de descida para setup time
            write=1; 
            wr_addr=i[2:0]; // Define endereço
            wr_data=((i*16'h1111)^16'h00F0); // Gera um padrão de dados determinístico
            @(posedge clk); // Borda de subida realiza a escrita
            exp[i]=wr_data; // Atualiza o modelo esperado
            @(negedge clk);
            write=0;        // Desabilita escrita
        end

        // ==== CENÁRIO 2: Leitura Direções Opostas ====
        // Lê A de 0->7 e B de 7->0
        $display("\n==== Leitura A 0->7 e B 7->0 ====");
        $display("tempo | rdA | A(hex) | A(dec) | rdB | B(hex) | B(dec)");
        $display("----------------------------------------------------");
        for (i=0;i<8;i=i+1) begin
            @(negedge clk);
            rd_addr_a=i[2:0];      // Incrementa endereço A
            rd_addr_b=(7-i);       // Decrementa endereço B
            #1; // Pequeno delay para propagação combinacional
            
            // Imprime status na tela
            $display("%0t | %0d | %h | %0d | %0d | %h | %0d",
                $time, rd_addr_a, rd_a_beh, rd_a_beh, rd_addr_b, rd_b_beh, rd_b_beh);
            
            // Verifica os resultados
            check_all(exp[rd_addr_a], exp[rd_addr_b]);
        end

        // ==== CENÁRIO 3: Leitura Aleatória/Tabela Extra ====
        // Gera mais 16 amostras com padrões variados de endereçamento
        $display("\n==== Tabela adicional (16 amostras) ====");
        $display("idx | rdA | rdB | A(hex) | B(hex)");
        $display("--------------------------------");
        for (i=0;i<16;i=i+1) begin
            @(negedge clk);
            rd_addr_a=(i%8);       // Padrão Cíclico
            rd_addr_b=((i+5)%8);   // Padrão Deslocado
            #1;
            $display("%0d | %0d | %0d | %h | %h", i, rd_addr_a, rd_addr_b, rd_a_beh, rd_b_beh);
            check_all(exp[rd_addr_a], exp[rd_addr_b]);
        end

        // ==== CENÁRIO 4: Leitura e Escrita Simultânea (Didático) ====
        // Demonstra que a leitura vê o valor ANTIGO até a borda de subida do clock
        $display("\n==== Tabela Didatica: Escrita Sincrona vs Leitura ====");
        $display("Evento          | Tempo | WR_EN | WR_Addr | WR_Data | RD_AddrA | RD_DataA (Valor)");
        $display("-----------------------------------------------------------------------------");
        
        // 1. Preparação: Escreve valor inicial (AAAA) no Reg 5
        @(negedge clk); write=1; wr_addr=5; wr_data=16'hAAAA; @(posedge clk); 
        exp[5] = 16'hAAAA;

        // 2. Setup para o conflito: Vai escrever 5555 no Reg 5, mas ler ao mesmo tempo
        @(negedge clk); 
        write=1; 
        wr_addr=5; 
        wr_data=16'h5555; // Novo valor
        rd_addr_a=5;      // Lê o mesmo endereço
        #1; // Propagação combinacional

        // Mostra valor ANTES do clock (deve ser AAAA - valor antigo)
        $display("Antes do Clock  | %0t  |   %b   |    %0d    |  %h   |    %0d     |   %h   (Antigo)", 
            $time, write, wr_addr, wr_data, rd_addr_a, rd_a_beh);
        
        // 3. Borda de Clock (Escrita acontece aqui)
        @(posedge clk); 
        #1; // Delay para leitura assíncrona atualizar
        exp[5] = 16'h5555;

        // Mostra valor DEPOIS do clock (deve ser 5555 - valor novo)
        $display("Depois do Clock | %0t  |   %b   |    %0d    |  %h   |    %0d     |   %h   (Novo)  ", 
            $time, write, wr_addr, wr_data, rd_addr_a, rd_a_beh);
        
        $display("-----------------------------------------------------------------------------");

        // Limpeza
         @(negedge clk); write=0;

        // Relatório Final
        if (success && (errors_total==0))
            $display("\nSUCESSO: Todas as implementacoes estao consistentes em %0d testes.", tests_total);
        else
            $display("\nFALHA: Foram encontrados %0d erros em %0d testes.", errors_total, tests_total);

        $display("Fim da simulacao.");
        $finish; // Encerra a simulação
    end
endmodule
