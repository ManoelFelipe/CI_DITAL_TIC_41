`timescale 1ns/1ps

// ============================================================================
// Testbench: tb_ram_16x8_sync
// Instancia as três abordagens (behavioral, dataflow, structural) e verifica
// automaticamente a consistência. Gera tabela didática baseada na behavioral.
// ============================================================================
module tb_ram_16x8_sync;

    // Sinais de estímulo
    reg         clk;
    reg         we;
    reg  [3:0]  address;
    reg  [7:0]  data_in;

    // Saídas das DUTs
    wire [7:0]  data_out_beh;
    wire [7:0]  data_out_df;
    wire [7:0]  data_out_str;

    // Regs para verificação
    integer i;
    integer erros;
    integer testes;
    reg [7:0] expected_val;

    // ------------------------------------------------------------------------
    // Instanciação das DUTs (Device Under Test)
    // ------------------------------------------------------------------------
    ram_16x8_sync_behavioral u_ram_beh (
        .clk(clk), .we(we), .address(address), .data_in(data_in), .data_out(data_out_beh)
    );

    ram_16x8_sync_dataflow u_ram_df (
        .clk(clk), .we(we), .address(address), .data_in(data_in), .data_out(data_out_df)
    );

    ram_16x8_sync_structural u_ram_str (
        .clk(clk), .we(we), .address(address), .data_in(data_in), .data_out(data_out_str)
    );

    // ------------------------------------------------------------------------
    // Geração de Clock
    // ------------------------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // Período de 10ns
    end

    // ------------------------------------------------------------------------
    // Dump de Ondas
    // ------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ram_16x8_sync);
    end

    // ------------------------------------------------------------------------
    // Estímulos e Verificação
    // ------------------------------------------------------------------------
    initial begin
        // Inicialização
        we      = 0;
        address = 0;
        data_in = 0;
        erros   = 0;
        testes  = 0;

        // Aguarda estabilização
        #20;

        $display("\n=== Fase 1: Escrita em todos os enderecos ===");
        // OBS: Estímulos na borda de DESCIDA para garantir setup time na subida
        for (i = 0; i < 16; i = i + 1) begin
            @(negedge clk);
            we      = 1;
            address = i[3:0];
            data_in = {4'hA, i[3:0]}; // Ex: A0, A1, A2...
        end

        // Desabilita escrita
        @(negedge clk);
        we = 0;

        $display("\n=== Fase 2: Leitura e Verificacao ===");
        // Cabeçalho da tabela didática (focada na behavioral)
        $display("-------------------------------------------------------------------");
        $display("tempo | addr | we | data_in || dout_beh | dout_exp || STATUS");
        $display("-------------------------------------------------------------------");

        for (i = 0; i < 16; i = i + 1) begin
            // 1. Configura endereço de leitura
            @(negedge clk);
            address = i[3:0];
            expected_val = {4'hA, i[3:0]};

            // 2. Aguarda borda de subida (leitura ocorre aqui) + tempo de propagação
            @(posedge clk);
            #1; // Pequeno delay para garantir que saídas atualizaram

            testes = testes + 1;

            // 3. Verificação automática
            if ((data_out_beh !== expected_val) || 
                (data_out_df  !== expected_val) || 
                (data_out_str !== expected_val)) begin
                
                $display("%5t |  %2h  |  %b |   %2h    ||    %2h    |    %2h    || ERRO", 
                         $time, address, we, data_in, data_out_beh, expected_val);
                
                $display("      >> DETALHE: Beh=%h, Df=%h, Str=%h", 
                         data_out_beh, data_out_df, data_out_str);
                erros = erros + 1;
            end else begin
                $display("%5t |  %2h  |  %b |   %2h    ||    %2h    |    %2h    || OK", 
                         $time, address, we, data_in, data_out_beh, expected_val);
            end
        end

        // Resultado Final
        $display("-------------------------------------------------------------------");
        if (erros == 0) begin
            $display("\nSUCESSO: Todas as implementacoes estao consistentes em %0d testes.", testes);
        end else begin
            $display("\nFALHA: Foram encontrados %0d erros em %0d testes.", erros, testes);
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
