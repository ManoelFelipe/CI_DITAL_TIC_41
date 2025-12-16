// ============================================================================
// Arquivo  : tb_fifo_8x8_buffer_circular
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench unificado da FIFO 8x8 buffer circular. Instancia as três abordagens (behavioral, dataflow e structural), gera estímulos de escrita e leitura, compara automaticamente as saídas e produz arquivo VCD para análise de formas de onda.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_fifo_8x8_buffer_circular;

    // ---------------------------------------------------------------------
    // Sinais de teste compartilhados entre as três implementações.
    // ---------------------------------------------------------------------
    reg clk;
    reg reset;
    reg wr;
    reg rd;
    reg  [7:0] w_data;

    wire [7:0] r_data_beh;
    wire [7:0] r_data_df;
    wire [7:0] r_data_str;

    wire full_beh, empty_beh;
    wire full_df,  empty_df;
    wire full_str, empty_str;

    integer test_counter;
    integer error_counter;

    // ---------------------------------------------------------------------
    // Instâncias das três DUTs.
    // ---------------------------------------------------------------------
    fifo_8x8_buffer_circular_behavioral u_beh (
        .clk   (clk),
        .reset (reset),
        .wr    (wr),
        .rd    (rd),
        .w_data(w_data),
        .r_data(r_data_beh),
        .full  (full_beh),
        .empty (empty_beh)
    );

    fifo_8x8_buffer_circular_dataflow u_df (
        .clk   (clk),
        .reset (reset),
        .wr    (wr),
        .rd    (rd),
        .w_data(w_data),
        .r_data(r_data_df),
        .full  (full_df),
        .empty (empty_df)
    );

    fifo_8x8_buffer_circular_structural u_str (
        .clk   (clk),
        .reset (reset),
        .wr    (wr),
        .rd    (rd),
        .w_data(w_data),
        .r_data(r_data_str),
        .full  (full_str),
        .empty (empty_str)
    );

    // ---------------------------------------------------------------------
    // Geração de clock: 10 ns de período.
    // ---------------------------------------------------------------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------------------------------------------------------------
    // Geração de VCD para visualização de ondas.
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_fifo_8x8_buffer_circular);
    end

    // ---------------------------------------------------------------------
    // Tabela didática baseada na implementação behavioral.
    // Cada linha mostra tempo, sinais de controle e saída da FIFO.
    // ---------------------------------------------------------------------
    task print_header;
        begin
            $display("tempo | wr rd | w_data(dec) | r_data(dec) | full empty");
            $display("-------------------------------------------------------");
        end
    endtask

    task print_line;
        begin
            $display("%5t |  %0d  %0d |     %3d     |     %3d     |  %0d    %0d",
                     $time, wr, rd, w_data, r_data_beh, full_beh, empty_beh);
        end
    endtask

    // ---------------------------------------------------------------------
    // Verificação automática: compara saídas das três abordagens.
    // ---------------------------------------------------------------------
    task check_consistency;
        begin
            test_counter = test_counter + 1;
            if ( (r_data_beh !== r_data_df)  || (r_data_df  !== r_data_str) ||
                 (full_beh    !== full_df)   || (full_df    !== full_str)   ||
                 (empty_beh   !== empty_df)  || (empty_df   !== empty_str) ) begin
                error_counter = error_counter + 1;
                $display("ERRO em t=%0t: BEH(r=%0d,f=%0b,e=%0b) DF(r=%0d,f=%0b,e=%0b) STR(r=%0d,f=%0b,e=%0b)",
                         $time,
                         r_data_beh, full_beh, empty_beh,
                         r_data_df,  full_df,  empty_df,
                         r_data_str, full_str, empty_str);
            end
        end
    endtask

    // ---------------------------------------------------------------------
    // Processo principal de estímulos.
    // ---------------------------------------------------------------------
    initial begin
        test_counter  = 0;
        error_counter = 0;

        // Reset inicial.
        clk    = 1'b0;
        reset  = 1'b1;
        wr     = 1'b0;
        rd     = 1'b0;
        w_data = 8'd0;

        print_header();

        #20;
        reset = 1'b0;

        // -------------------------------------------------------------
        // 1) Preenchimento completo da FIFO até full=1.
        // -------------------------------------------------------------
        repeat (8) begin
            @(negedge clk);
            wr     <= 1'b1;
            rd     <= 1'b0;
            w_data <= w_data + 8'd1;
            @(posedge clk);
            print_line();
            check_consistency();
        end

        // Tentativa de escrita com FIFO cheia.
        @(negedge clk);
        wr     <= 1'b1;
        rd     <= 1'b0;
        w_data <= 8'hFF;
        @(posedge clk);
        print_line();
        check_consistency();

        // -------------------------------------------------------------
        // 2) Esvaziamento completo da FIFO até empty=1.
        // -------------------------------------------------------------
        @(negedge clk);
        wr <= 1'b0;
        rd <= 1'b1;

        repeat (8) begin
            @(posedge clk);
            print_line();
            check_consistency();
        end

        // Tentativa de leitura com FIFO vazia.
        @(negedge clk);
        wr <= 1'b0;
        rd <= 1'b1;
        @(posedge clk);
        print_line();
        check_consistency();

        // -------------------------------------------------------------
        // 3) Operação mista: escrita e leitura alternadas.
        // -------------------------------------------------------------
        w_data <= 8'd10;
        repeat (4) begin
            // Escrita.
            @(negedge clk);
            wr     <= 1'b1;
            rd     <= 1'b0;
            w_data <= w_data + 8'd1;
            @(posedge clk);
            print_line();
            check_consistency();

            // Leitura.
            @(negedge clk);
            wr <= 1'b0;
            rd <= 1'b1;
            @(posedge clk);
            print_line();
            check_consistency();
        end

        // -------------------------------------------------------------
        // Resultado final.
        // -------------------------------------------------------------
        if (error_counter == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes em %0d testes.", test_counter);
        end else begin
            $display("FALHA: Foram encontrados %0d erros em %0d testes.", error_counter, test_counter);
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
