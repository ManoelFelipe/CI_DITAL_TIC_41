// ============================================================================
// Arquivo  : rom_16x8_async  (testbench)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench que instancia três implementações (behavioral,
//            dataflow e structural) da ROM assíncrona 16x8. Varre todos
//            os 16 endereços, compara automaticamente as saídas entre si
//            e também contra uma tabela de referência. Gera tabela didática
//            com o comportamento da implementação behavioral e produz
//            arquivo VCD para análise de formas de onda. No final, exibe
//            mensagem de sucesso ou erro com o total de testes realizados.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps

module tb_rom_16x8_async;

    // ----------------------------------------------------------------------
    // Parâmetros gerais
    // ----------------------------------------------------------------------
    localparam ADDR_WIDTH = 4;                     // Largura de endereço (4 bits)
    localparam DATA_WIDTH = 8;                     // Largura de dados (8 bits)
    localparam DEPTH      = 1 << ADDR_WIDTH;       // Número de palavras (16)

    // ----------------------------------------------------------------------
    // Sinais de estímulo e monitoramento
    // ----------------------------------------------------------------------
    reg  [ADDR_WIDTH-1:0] address;                 // Endereço aplicado às DUTs

    wire [DATA_WIDTH-1:0] data_out_behavioral;     // Saída da ROM behavioral
    wire [DATA_WIDTH-1:0] data_out_dataflow;       // Saída da ROM dataflow
    wire [DATA_WIDTH-1:0] data_out_structural;     // Saída da ROM structural

    // Tabela de referência com os valores esperados para cada endereço
    reg [DATA_WIDTH-1:0] expected_rom [0:DEPTH-1]; // Conteúdo ideal da ROM

    integer i;                                     // Índice de laço
    integer total_tests;                           // Contador de testes
    integer error_count;                           // Contador de erros

    // ----------------------------------------------------------------------
    // Instanciação das três implementações da ROM 16x8 assíncrona
    // ----------------------------------------------------------------------

    // Implementação behavioral (case)
    rom_16x8_async_behavioral #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rom_behavioral (
        .address (address),
        .data_out(data_out_behavioral)
    );

    // Implementação dataflow (array + assign)
    rom_16x8_async_dataflow #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rom_dataflow (
        .address (address),
        .data_out(data_out_dataflow)
    );

    // Implementação estrutural (constantes + mux16x1_8bit)
    rom_16x8_async_structural #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_rom_structural (
        .address (address),
        .data_out(data_out_structural)
    );

    // ----------------------------------------------------------------------
    // Geração de VCD para observação das formas de onda
    // ----------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");                     // Nome do arquivo VCD
        $dumpvars(0, tb_rom_16x8_async);           // Registra todos os sinais do TB
    end

    // ----------------------------------------------------------------------
    // Bloco principal de estímulos e verificação
    // ----------------------------------------------------------------------
    initial begin
        // Inicializa tabela de referência com os mesmos valores da ROM
        expected_rom[ 0] = 8'h00;
        expected_rom[ 1] = 8'h11;
        expected_rom[ 2] = 8'h22;
        expected_rom[ 3] = 8'h33;
        expected_rom[ 4] = 8'h44;
        expected_rom[ 5] = 8'h55;
        expected_rom[ 6] = 8'h66;
        expected_rom[ 7] = 8'h77;
        expected_rom[ 8] = 8'h88;
        expected_rom[ 9] = 8'h99;
        expected_rom[10] = 8'hAA;
        expected_rom[11] = 8'hBB;
        expected_rom[12] = 8'hCC;
        expected_rom[13] = 8'hDD;
        expected_rom[14] = 8'hEE;
        expected_rom[15] = 8'hFF;

        // Inicializa variáveis de controle
        address      = {ADDR_WIDTH{1'b0}};     // Começa no endereço 0
        total_tests  = 0;                          // Zera contador de testes
        error_count  = 0;                          // Zera contador de erros

        // Cabeçalho da tabela didática baseada na implementação behavioral
        $display("====================================================================");
        $display(" Tabela didática - Implementação Behavioral da ROM 16x8 Assíncrona");
        $display(" tempo(ns) | addr_dec | addr_bin | data_hex | data_bin ");
        $display("--------------------------------------------------------------------");

        // Varre todos os endereços possíveis da ROM
        for (i = 0; i < DEPTH; i = i + 1) begin
            address = i[ADDR_WIDTH-1:0];           // Aplica endereço i
            #10;                                   // Aguarda tempo para propagação

            // Incrementa o número total de testes
            total_tests = total_tests + 1;

            // Checagem automática entre as três implementações
            if ((data_out_behavioral !== data_out_dataflow) ||
                (data_out_dataflow   !== data_out_structural)) begin
                error_count = error_count + 1;
                $display("ERRO: Inconsistência entre implementações no endereço %0d", i);
                $display("       behavioral=%h dataflow=%h structural=%h",
                         data_out_behavioral, data_out_dataflow, data_out_structural);
            end

            // Checagem contra valor esperado
            if (data_out_behavioral !== expected_rom[i]) begin
                error_count = error_count + 1;
                $display("ERRO: Conteúdo inesperado no endereço %0d", i);
                $display("       esperado=%h obtido=%h", expected_rom[i], data_out_behavioral);
            end

            // Impressão de linha da tabela didática usando a abordagem behavioral
            $display(" %8t | %7d | %8b |   0x%2h | %8b ",
                     $time, i, address, data_out_behavioral, data_out_behavioral);
        end

        // ----------------------------------------------------------------------
        // Geração da Tabela Dataflow
        // ----------------------------------------------------------------------
        $display("====================================================================");
        $display(" Tabela didática - Implementação Dataflow da ROM 16x8 Assíncrona");
        $display(" tempo(ns) | addr_dec | addr_bin | data_hex | data_bin ");
        $display("--------------------------------------------------------------------");

        for (i = 0; i < DEPTH; i = i + 1) begin
            address = i[ADDR_WIDTH-1:0];           // Aplica endereço i
            #10;                                   // Aguarda tempo para propagação
            $display(" %8t | %7d | %8b |   0x%2h | %8b ",
                     $time, i, address, data_out_dataflow, data_out_dataflow);
        end

        // ----------------------------------------------------------------------
        // Geração da Tabela Structural
        // ----------------------------------------------------------------------
        $display("====================================================================");
        $display(" Tabela didática - Implementação Structural da ROM 16x8 Assíncrona");
        $display(" tempo(ns) | addr_dec | addr_bin | data_hex | data_bin ");
        $display("--------------------------------------------------------------------");

        for (i = 0; i < DEPTH; i = i + 1) begin
            address = i[ADDR_WIDTH-1:0];           // Aplica endereço i
            #10;                                   // Aguarda tempo para propagação
            $display(" %8t | %7d | %8b |   0x%2h | %8b ",
                     $time, i, address, data_out_structural, data_out_structural);
        end

        $display("====================================================================");

        // Mensagem final obrigatória de sucesso ou falha
        if (error_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes em %0d testes.",
                     total_tests);
        end else begin
            $display("FALHA: Foram encontrados %0d erros em %0d testes.",
                     error_count, total_tests);
        end

        // Mensagem de encerramento da simulação
        $display("Fim da simulacao.");
        $finish;                                   // Finaliza a simulação
    end

endmodule
