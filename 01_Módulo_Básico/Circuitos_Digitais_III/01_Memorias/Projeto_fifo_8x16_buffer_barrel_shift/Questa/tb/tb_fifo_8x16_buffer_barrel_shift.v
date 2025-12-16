`timescale 1ns/1ps // Define a unidade de tempo (1ns) e a precisão (1ps) da simulação
// ============================================================================
// Arquivo  : tb_fifo_8x16_buffer_barrel_shift.v
// Autor    : Manoel Furtado
// Data     : 12/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: Testbench auto-verificante do Exercicio 3.
//            - Instancia simultaneamente 3 DUTs barrel-shift (B/D/S)
//            - Compara saidas a cada ciclo (dout/full/empty/wp_count)
//            - Compara Behavioral barrel-shift com FIFO circular de referencia
//            - Testa full/empty, escrita apos cheia, leitura apos vazia
//            - Valida deslocamento e insercao de zeros na leitura
//            - Gera wave.vcd e tabelas didaticas
// ============================================================================

module tb_fifo_8x16_buffer_barrel_shift; // Declaração do módulo do testbench (sem portas)

    localparam DATA_WIDTH = 16; // Define a largura dos dados como 16 bits
    localparam DEPTH      = 8;  // Define a profundidade da FIFO como 8 palavras
    localparam ADDR_WIDTH = 3;  // Define a largura do endereço (log2 de 8 = 3 bits)

    reg clk; // Declara o sinal de clock como registrador (será gerado aqui)
    reg rst; // Declara o sinal de reset como registrador

    reg                   wr_en;   // Declara o sinal de habilitação de escrita
    reg                   rd_en;   // Declara o sinal de habilitação de leitura
    reg  [DATA_WIDTH-1:0] data_in; // Declara o barramento de entrada de dados

    // Sinais de saída das implementações da FIFO com Barrel Shift:
    wire [DATA_WIDTH-1:0] dout_b, dout_d, dout_s; // Saídas de dados (Behavioral, Dataflow, Structural)
    wire full_b, full_d, full_s;   // Flags de cheio (Behavioral, Dataflow, Structural)
    wire empty_b, empty_d, empty_s; // Flags de vazio (Behavioral, Dataflow, Structural)
    wire [ADDR_WIDTH:0] wp_b, wp_d, wp_s; // Contadores de escrita (Behavioral, Dataflow, Structural)

    // Sinais de saída da FIFO de Referência (Buffer Circular):
    wire [DATA_WIDTH-1:0] dout_ref; // Saída de dados da referência
    wire full_ref, empty_ref;       // Flags de cheio e vazio da referência

    integer test_count;  // Contador de número de testes realizados
    integer error_count; // Contador de número de erros detectados
    reg     ok_all;      // Flag global que indica se todos os testes passaram

    // Geração do sinal de clock
    initial begin
        clk = 1'b0;        // Inicializa o clock em nível baixo
        forever #5 clk = ~clk; // Inverte o clock a cada 5 unidades de tempo (período de 10ns, 100MHz)
    end

    // Configuração para geração de arquivo de onda (VCD)
    initial begin
        $dumpfile("wave.vcd"); // Nome do arquivo de saída vcd
        $dumpvars(0, tb_fifo_8x16_buffer_barrel_shift); // Grava todas as variáveis deste módulo
    end

    // Instanciação da FIFO Barrel Shift - Modelo Comportamental (Behavioral)
    fifo_8x16_buffer_barrel_shift_behavioral #(
        .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)
    ) dut_b (
        .clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en),
        .data_in(data_in),
        .data_out(dout_b),
        .full(full_b), .empty(empty_b), .wp_count(wp_b)
    );

    // Instanciação da FIFO Barrel Shift - Modelo Fluxo de Dados (Dataflow)
    fifo_8x16_buffer_barrel_shift_dataflow #(
        .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)
    ) dut_d (
        .clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en),
        .data_in(data_in),
        .data_out(dout_d),
        .full(full_d), .empty(empty_d), .wp_count(wp_d)
    );

    // Instanciação da FIFO Barrel Shift - Modelo Estrutural (Structural)
    fifo_8x16_buffer_barrel_shift_structural #(
        .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)
    ) dut_s (
        .clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en),
        .data_in(data_in),
        .data_out(dout_s),
        .full(full_s), .empty(empty_s), .wp_count(wp_s)
    );

    // Instanciação da FIFO de Referência - Buffer Circular
    fifo_buffer_circular_behavioral #(
        .DATA_WIDTH(DATA_WIDTH), .DEPTH(DEPTH), .ADDR_WIDTH(ADDR_WIDTH)
    ) dut_ref (
        .clk(clk), .rst(rst), .wr_en(wr_en), .rd_en(rd_en),
        .data_in(data_in),
        .data_out(dout_ref),
        .full(full_ref), .empty(empty_ref)
    );

    // Tarefa auxiliar para executar um ciclo de clock com estímulos definidos
    task step;
        input wr; // Parâmetro: habilita escrita
        input rd; // Parâmetro: habilita leitura
        input [DATA_WIDTH-1:0] din; // Parâmetro: dado de entrada
        begin
            wr_en   = wr;  // Atribui o valor ao sinal de escrita
            rd_en   = rd;  // Atribui o valor ao sinal de leitura
            data_in = din; // Atribui o dado de entrada
            @(posedge clk); // Aguarda a borda de subida do clock
            #1; // Aguarda 1ns após a borda para garantir estabilidade na leitura dos sinais
        end
    endtask

    // Tarefa auxiliar para verificar as saídas dos 4 módulos a cada ciclo
    task check_cycle;
        begin
            test_count = test_count + 1; // Incrementa o contador de testes

            // Verifica consistência entre as 3 implementações Barrel Shift (B, D, S)
            // Se houver qualquer divergência em data_out, full, empty ou wp_count, acusa erro.
            if ((dout_b !== dout_d) || (dout_d !== dout_s) ||
                (full_b !== full_d) || (full_d !== full_s) ||
                (empty_b !== empty_d) || (empty_d !== empty_s) ||
                (wp_b !== wp_d) || (wp_d !== wp_s)) begin

                error_count = error_count + 1; // Incrementa contagem de erros
                ok_all = 1'b0; // Marca que houve falha

                // Imprime mensagem de erro detalhada com os valores divergentes
                $display("ERRO(ABORDAGENS) t=%0t | wr=%0b rd=%0b din=0x%04h | dout(b,d,s)=%04h %04h %04h | wp=%0d %0d %0d | full=%0b %0b %0b | empty=%0b %0b %0b",
                         $time, wr_en, rd_en, data_in,
                         dout_b, dout_d, dout_s,
                         wp_b, wp_d, wp_s,
                         full_b, full_d, full_s,
                         empty_b, empty_d, empty_s);
            end

            // Verifica consistência entre o Barrel Shift (Behavioral) e a FIFO Circular de Referência
            // Verifica dados, flag full e flag empty.
            if ((dout_b !== dout_ref) || (full_b !== full_ref) || (empty_b !== empty_ref)) begin
                error_count = error_count + 1; // Incrementa contagem de erros
                ok_all = 1'b0; // Marca que houve falha

                // Imprime mensagem de erro de referência
                $display("ERRO(REF) t=%0t | wr=%0b rd=%0b din=0x%04h | barrel=%04h ref=%04h | full/empty barrel=%0b/%0b ref=%0b/%0b",
                         $time, wr_en, rd_en, data_in, dout_b, dout_ref, full_b, empty_b, full_ref, empty_ref);
            end
        end
    endtask

    // Tarefa auxiliar para imprimir o cabeçalho das tabelas no console
    task print_header;
        begin
            $display("--------------------------------------------------------------------------------------------");
            $display(" tempo(ns) | wr rd | din(hex) | dout(hex) | wp_count | full empty | Observacao");
            $display("--------------------------------------------------------------------------------------------");
        end
    endtask

    // Tarefa auxiliar para imprimir uma linha formatada na tabela
    task print_row;
        input [8*40-1:0] note; // Parâmetro: string de observação (até 40 caracteres)
        begin
            // Imprime os valores atuais formatados
            $display(" %8d |  %0b  %0b | 0x%04h  | 0x%04h   |   %0d     |  %0b    %0b   | %0s",
                     $time, wr_en, rd_en, data_in, dout_b, wp_b, full_b, empty_b, note);
        end
    endtask

    integer k; // Variável para loops
    reg [DATA_WIDTH-1:0] pattern [0:DEPTH-1]; // Array para armazenar padrão de teste

    // Bloco principal de teste (Initial Block)
    initial begin
        // Inicialização de sinais
        rst        = 1'b1;     // Ativa o reset
        wr_en      = 1'b0;     // Desabilita escrita
        rd_en      = 1'b0;     // Desabilita leitura
        data_in    = 16'h0000; // Zera entrada de dados

        test_count  = 0;       // Zera contador de testes
        error_count = 0;       // Zera contador de erros
        ok_all      = 1'b1;    // Assume sucesso inicialmente

        // Define um padrão de dados para escrever na FIFO
        pattern[0] = 16'h00A1;
        pattern[1] = 16'h00B2;
        pattern[2] = 16'h00C3;
        pattern[3] = 16'h00D4;
        pattern[4] = 16'h00E5;
        pattern[5] = 16'h00F6;
        pattern[6] = 16'h0A07;
        pattern[7] = 16'h0B18;

        // Sequência de Reset
        repeat (3) @(posedge clk); // Aguarda 3 ciclos de clock
        rst = 1'b0;                // Desativa o reset
        @(posedge clk);            // Aguarda mais um ciclo
        #1;                        // Pequeno delay para sincronia

        // --- TESTE 1: Preenchimento até encher (FULL) ---
        $display("\nTABELA 1: Preenchimento ate FULL (e tentativa de escrita apos cheia)");
        print_header(); // Imprime cabeçalho da tabela
        for (k = 0; k < DEPTH; k = k + 1) begin
            step(1'b1, 1'b0, pattern[k]); // Escreve o padrão k na FIFO
            check_cycle();                // Verifica se tudo está correto neste ciclo
            if (k == DEPTH-1) print_row("apos escrita -> FULL=1"); // Comentário para a última escrita
            else              print_row("escrevendo...");          // Comentário para escritas normais
        end
        // Tenta escrever mais um dado (DEAD) com a FIFO já cheia
        step(1'b1, 1'b0, 16'hDEAD);
        check_cycle(); // Verifica se o dado foi ignorado e o estado mantido
        print_row("escrita apos cheia -> ignorada");

        // --- TESTE 2: Leitura até esvaziar (EMPTY) ---
        $display("\nTABELA 2: Leitura ate EMPTY (e tentativa de leitura apos vazia)");
        print_header(); // Imprime cabeçalho
        for (k = 0; k < DEPTH; k = k + 1) begin
            // Faz leitura (wr=0, rd=1), dado de entrada é irrelevante (0x0000)
            step(1'b0, 1'b1, 16'h0000);
            check_cycle(); // Verifica corretude
            if (k == 0) print_row("1a leitura -> esperado 00A1"); // Comentário 1ª leitura
            else        print_row("lendo...");                 // Demaos leituras
        end
        // Tenta ler mais uma vez com a FIFO vazia
        step(1'b0, 1'b1, 16'h0000);
        check_cycle(); // Verifica se leitura foi ignorada
        print_row("leitura apos vazia -> ignorada");

        // --- TESTE 3: Verificação de Deslocamento (Barrel Shift) ---
        $display("\nTABELA 3: Deslocamento e insercao de zeros (barrel-shift)");
        print_header();
        step(1'b1, 1'b0, 16'h1111); check_cycle(); print_row("escreve 1111"); // Escreve 1111
        step(1'b1, 1'b0, 16'h2222); check_cycle(); print_row("escreve 2222"); // Escreve 2222
        step(1'b1, 1'b0, 16'h3333); check_cycle(); print_row("escreve 3333"); // Escreve 3333
        // Agora lê. No barrel shift, ler remove a cabeça (1111) e move o próximo (2222) para a cabeça.
        step(1'b0, 1'b1, 16'h0000); check_cycle(); print_row("le -> esperado 1111; cabeca vira 2222");
        step(1'b0, 1'b1, 16'h0000); check_cycle(); print_row("le -> esperado 2222; cabeca vira 3333");
        step(1'b0, 1'b1, 16'h0000); check_cycle(); print_row("le -> esperado 3333; FIFO esvazia");

        // --- TESTE 4: Tráfego Misto (Escrita e Leitura Simultâneas) ---
        $display("\nTABELA 4: Trafego misto (wr+rd simultaneo) deterministico");
        print_header();
        // Primeiro, carrega parcialmente a FIFO com 4 valores
        for (k = 0; k < 4; k = k + 1) begin
            step(1'b1, 1'b0, 16'h4000 + k);
            check_cycle();
            print_row("pre-carga");
        end
        // Executa escrita e leitura simultâneas (wr=1, rd=1)
        for (k = 0; k < 6; k = k + 1) begin
            step(1'b1, 1'b1, 16'h5000 + k); // Escreve 500x e lê o que estiver na ponta
            check_cycle();
            print_row("wr+rd (ocupacao deve manter)");
        end
        // Drena tudo que sobrou até esvaziar
        while (!empty_b) begin
            step(1'b0, 1'b1, 16'h0000);
            check_cycle();
            print_row("drenando");
        end

        // Relatório Final
        if (ok_all && (error_count == 0)) begin
            // Se nenhum erro ocorreu, imprime SUCESSO com contagem de testes
            $display("\nSUCESSO: Todas as implementacoes estao consistentes em %0d testes.", test_count);
        end else begin
            // Se houve erro, imprime FALHA com contadores
            $display("\nFALHA: inconsistencias detectadas. test_count=%0d error_count=%0d", test_count, error_count);
        end

        $display("Fim da simulacao."); // Mensagem final
        $finish; // Encerra simulação
    end

endmodule
