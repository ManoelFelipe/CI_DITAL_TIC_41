`timescale 1ns/1ps

// ============================================================================
// Arquivo  : tb_fifo_16_buffer_circular.v
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: Testbench auto-verificante para a FIFO parametrizavel com
//            buffer circular. Instancia simultaneamente as tres
//            abordagens (Behavioral, Dataflow e Structural) e aplica
//            estimulos de escrita e leitura para uma configuracao de
//            16 palavras de 16 bits. As saidas sao comparadas ciclo a
//            ciclo; qualquer divergencia gera mensagem de erro. Ao
//            final, caso nenhuma discrepancia seja detectada, e exibida
//            a mensagem de sucesso exigida no enunciado.
// Revisao  : v1.0 — criacao inicial
//            v1.1 — Adicao de tabelas detalhadas no log de simulacao
// ============================================================================

module tb_fifo_16_buffer_circular;

    // --------------------------------------------------------------------
    // Parametros de configuracao especificos do exercicio
    // --------------------------------------------------------------------
    // Define a largura da palavra de dados em bits (16 bits conforme enunciado)
    localparam DATA_WIDTH = 16;
    // Define a profundidade da FIFO, ou seja, quantos elementos ela armazena
    localparam DEPTH      = 16;
    // Define a largura do barramento de endereco necessaria (log2(16) = 4 bits)
    localparam ADDR_WIDTH = 4;

    // --------------------------------------------------------------------
    // Sinais de estimulo (entradas para as FIFOs)
    // --------------------------------------------------------------------
   
    reg                     clk;        // Clock principal da simulacao
    reg                     rst;        // Sinal de Reset (ativo em nivel alto)
    reg                     wr_en;      // Habilita escrita na FIFO (Write Enable)
    reg                     rd_en;      // Habilita leitura na FIFO (Read Enable)
    reg  [DATA_WIDTH-1:0]   data_in;    // Barramento de entrada de dados

    // --------------------------------------------------------------------
    // Sinais de saida das tres implementacoes (para comparacao)
    // --------------------------------------------------------------------
    // Saida de dados da implementacao Comportamental (Behavioral)
    wire [DATA_WIDTH-1:0]   data_out_beh;
    // Saida de dados da implementacao Fluxo de Dados (Dataflow)
    wire [DATA_WIDTH-1:0]   data_out_df;
    // Saida de dados da implementacao Estrutural (Structural)
    wire [DATA_WIDTH-1:0]   data_out_str;

    // Flags de 'Cheio' (Full) para cada implementacao
    wire                    full_beh;
    wire                    full_df;
    wire                    full_str;

    // Flags de 'Vazio' (Empty) para cada implementacao
    wire                    empty_beh;
    wire                    empty_df;
    wire                    empty_str;

    // --------------------------------------------------------------------
    // Instancia da FIFO Behavioral (Modelo de Referencia)
    // --------------------------------------------------------------------
    fifo_buffer_circular_behavioral
    #(
        .DATA_WIDTH(DATA_WIDTH),    // Passa parametro de largura
        .DEPTH     (DEPTH),         // Passa parametro de profundidade
        .ADDR_WIDTH(ADDR_WIDTH)     // Passa parametro de enderecamento
    )
    u_fifo_behavioral
    (
        .clk     (clk),             // Conecta clock
        .rst     (rst),             // Conecta reset
        .wr_en   (wr_en),           // Conecta enable de escrita
        .rd_en   (rd_en),           // Conecta enable de leitura
        .data_in (data_in),         // Conecta dados de entrada
        .data_out(data_out_beh),    // Recebe dados de saida
        .full    (full_beh),        // Recebe flag full
        .empty   (empty_beh)        // Recebe flag empty
    );

    // --------------------------------------------------------------------
    // Instancia da FIFO Dataflow
    // --------------------------------------------------------------------
    fifo_buffer_circular_dataflow
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    u_fifo_dataflow
    (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .data_in (data_in),
        .data_out(data_out_df),
        .full    (full_df),
        .empty   (empty_df)
    );

    // --------------------------------------------------------------------
    // Instancia da FIFO Structural
    // --------------------------------------------------------------------
    fifo_buffer_circular_structural
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    u_fifo_structural
    (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (wr_en),
        .rd_en   (rd_en),
        .data_in (data_in),
        .data_out(data_out_str),
        .full    (full_str),
        .empty   (empty_str)
    );

    // --------------------------------------------------------------------
    // Geracao de clock: periodo de 10 ns (Frequencia de 100 MHz)
    // --------------------------------------------------------------------
    initial begin
        clk = 1'b0;                 // Valor inicial do clock
        forever #5 clk = ~clk;      // Inverte o clock a cada 5 unidades de tempo (5ns)
    end

    // --------------------------------------------------------------------
    // Configuracao para visualizacao de ondas (VCD)
    // --------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");                      // Define arquivo de saida
        $dumpvars(0, tb_fifo_16_buffer_circular);   // Dump de todas as variaveis do modulo
    end

    // --------------------------------------------------------------------
    // Variaveis auxiliares para controle do teste e tabelas
    // --------------------------------------------------------------------
    integer ciclo;          // Contador de ciclos/valores de teste
    integer erros;          // Contador acumulado de erros encontrados
    integer total_testes;   // Contador total de verificacoes realizadas

    // --------------------------------------------------------------------
    // Processo principal de estimulos (Main Stimulus Process)
    // --------------------------------------------------------------------
    initial begin
        // Inicializacao das variaveis no tempo zero
        rst          = 1'b1;        // Inicia com Reset ativado
        wr_en        = 1'b0;        // Escrita desativada
        rd_en        = 1'b0;        // Leitura desativada
        data_in      = {DATA_WIDTH{1'b0}}; // Dados zerados
        ciclo        = 0;
        erros        = 0;
        total_testes = 0;

        // Aguarda 20ns mantendo o reset, garantindo estabilidade inicial
        #20;
        rst = 1'b0; // Desativa o Reset (nivel baixo)

        // ----------------------------------------------------------------
        // Exibicao: Log detalhado e tabelas de documentacao
        // ----------------------------------------------------------------
        $display("\n========================================================");
        $display("       SIMULACAO: FIFO 16 BUFFER CIRCULAR");
        $display("========================================================\n");

        // Tabela 1: Especificacao do projeto (Requisitos vs Parametros)
        $display("### Tabela 1: Mapeamento de Parametros (Especificacao)");
        $display("| Requisito | Parametro | Configurado |");
        $display("| :--- | :--- | :---: |");
        $display("| Tamanho da palavra | DATA_WIDTH | %d bits |", DATA_WIDTH);
        $display("| Quantidade de palavras | DEPTH | %d palavras |", DEPTH);
        $display("| Enderecamento | ADDR_WIDTH | %d bits |", ADDR_WIDTH);
        $display("");

        // Tabela 2: Plano de Testes (Cenarios previstos)
        $display("### Tabela 2: Cenarios de Teste Planejados");
        $display("| Fase | Operacao | Comportamento Esperado |");
        $display("| :--- | :--- | :--- |");
        $display("| 1. Enchimento | Write (x16) | Preencher FIFO. Full=1 no final. |");
        $display("| 2. Pipeline   | Rd + Wr (x16) | Manter ocupacao. Dados entram/saem. |");
        $display("| 3. Esvaziamento | Read (x16) | Esvaziar FIFO. Empty=1 no final. |");
        $display("");

        // Tabela 3: Cabecalho para os resultados detalhados
        $display("### Tabela 3: Configuracao do Teste (Instancia)");
        $display("| Parametro  | Valor | Descricao |");
        $display("| :--- | :---: | :--- |");
        $display("| DATA_WIDTH | %d | Largura da palavra (bits) |", DATA_WIDTH);
        $display("| DEPTH      | %d | Profundidade da FIFO (palavras) |", DEPTH);
        $display("| ADDR_WIDTH | %d | Largura do endereco (bits) |", ADDR_WIDTH);
        $display("\n### Resultados da Simulacao Detalhados");

        // ------------------------------------------------------------
        // FASE 1: Enchimento (Fill)
        // Objetivo: Escrever 16 valores consecutivos sem ler.
        // ------------------------------------------------------------
        $display("\n**Fase 1: Enchimento (Fill)**");
        $display("| Tempo | wr_en | rd_en | data_in | data_out | Full | Empty |");
        $display("| :---: | :---: | :---: | :---: | :---: | :---: | :---: |");
        
        repeat (16) begin
            @(negedge clk);             // Aplica estimulo na borda de descida
            wr_en   = 1'b1;             // Habilita escrita
            rd_en   = 1'b0;             // Desabilita leitura
            data_in = ciclo;            // Dado = valor do contador 'ciclo'
            @(posedge clk);             // Aguarda borda de subida (captura)
            ciclo = ciclo + 1;          // Incrementa contador para proximo dado
            total_testes = total_testes + 1;
            // Imprime estado atual formatado como linha da tabela
            $display("| %4t | %b | %b | %5d | %5d | %b | %b |",
                     $time, wr_en, rd_en, data_in, data_out_beh, full_beh, empty_beh);
        end

        // ------------------------------------------------------------
        // FASE 2: Pipeline (Read + Write)
        // Objetivo: Realizar leitura e escrita simultaneas.
        // A FIFO deve manter-se cheia/estavel e permitir fluxo.
        // ------------------------------------------------------------
        $display("\n**Fase 2: Pipeline (Read+Write)**");
        $display("| Tempo | wr_en | rd_en | data_in | data_out | Full | Empty |");
        $display("| :---: | :---: | :---: | :---: | :---: | :---: | :---: |");

        repeat (16) begin
            @(negedge clk);
            wr_en   = 1'b1;             // Habilita escrita
            rd_en   = 1'b1;             // Habilita leitura
            data_in = ciclo + 100;      // Novo dado distinto (offset 100)
            @(posedge clk);
            ciclo = ciclo + 1;
            total_testes = total_testes + 1;
            $display("| %4t | %b | %b | %5d | %5d | %b | %b |",
                     $time, wr_en, rd_en, data_in, data_out_beh, full_beh, empty_beh);
        end

        // ------------------------------------------------------------
        // FASE 3: Esvaziamento (Drain)
        // Objetivo: Apenas ler ate esvaziar a FIFO.
        // ------------------------------------------------------------
        $display("\n**Fase 3: Esvaziamento (Drain)**");
        $display("| Tempo | wr_en | rd_en | data_in | data_out | Full | Empty |");
        $display("| :---: | :---: | :---: | :---: | :---: | :---: | :---: |");

        repeat (16) begin
            @(negedge clk);
            wr_en   = 1'b0;             // Desabilita escrita
            rd_en   = 1'b1;             // Habilita leitura
            @(posedge clk);
            total_testes = total_testes + 1;
            $display("| %4t | %b | %b | %5d | %5d | %b | %b |",
                     $time, wr_en, rd_en, data_in, data_out_beh, full_beh, empty_beh);
        end

        // ------------------------------------------------------------
        // Finalizacao e Relatorio
        // ------------------------------------------------------------
        @(negedge clk);
        wr_en = 1'b0;   // Garante sinais limpos no final
        rd_en = 1'b0;
        #20;            // Aguarda um tempo de margem

        $display("\n### Conclusao dos Testes");
        // Verifica se contador de erros permaneceu zero
        if (erros == 0) begin
            $display("| Status | Total Testes | Erros |");
            $display("| :---: | :---: | :---: |");
            $display("| **SUCESSO** | %0d | %0d |", total_testes, erros);
        end else begin
            $display("FALHA: Foram encontrados %0d erros em %0d testes.", erros, total_testes);
        end

        $display("Fim da simulacao.");
        $finish; // Encerra a simulacao
    end

    // --------------------------------------------------------------------
    // Bloco de verificacao automatica (Scoreboard)
    // Executado a cada borda de subida do clock para comparar saidas.
    // --------------------------------------------------------------------
    always @(posedge clk) begin
        // Verifica apenas se nao estiver em reset
        if (!rst) begin
            // Compara as saidas das tres implementacoes
            if ((data_out_beh !== data_out_df) || // Beh vs Dataflow (Dados)
                (data_out_beh !== data_out_str) || // Beh vs Structural (Dados)
                (full_beh     !== full_df    ) || // Flags Full
                (full_beh     !== full_str   ) ||
                (empty_beh    !== empty_df   ) || // Flags Empty
                (empty_beh    !== empty_str  )) begin
                
                // Se houver qualquer diferenca, imprime erro detalhado
                $display("ERRO em %0t: Divergencia entre implementacoes.", $time);
                $display("  Dados: Beh=%0d, DF=%0d, Str=%0d",
                         data_out_beh, data_out_df, data_out_str);
                $display("  Cheio: Beh=%b, DF=%b, Str=%b",
                         full_beh, full_df, full_str);
                $display("  Vazio: Beh=%b, DF=%b, Str=%b",
                         empty_beh, empty_df, empty_str);
                erros = erros + 1; // Incrementa contador de erros
            end
        end
    end

endmodule
