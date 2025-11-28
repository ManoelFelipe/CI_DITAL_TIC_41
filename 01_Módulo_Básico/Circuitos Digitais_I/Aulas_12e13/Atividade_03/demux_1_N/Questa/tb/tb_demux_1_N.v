// -----------------------------------------------------------------------------
//  Testbench: tb_demux_1_N
//  Autor    : Manoel Furtado
//  Data     : 31/10/2025
//  Objetivo : Estimular e verificar as três implementações do demux 1xN
//             usando N=8 por padrão, com geração de VCD.
// -----------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_demux_1_N;

    // ----------------------
    // Parâmetros de simulação
    // ----------------------
    parameter integer N = 8;                       // Número de saídas para o teste
    function integer clog2;                        // Função para calcular a largura de sel
        input integer value;
        integer i;
        begin
            value = value - 1;
            for (i = 0; value > 0; i = i + 1)
                value = value >> 1;
            clog2 = i;
        end
    endfunction
    localparam integer W = clog2(N);               // Largura do seletor

    // -------------
    // Sinais comuns
    // -------------
    reg                   din;                     // Estímulo de entrada
    reg  [W-1:0]          sel;                     // Estímulo de seleção
    wire [N-1:0]          y_beh, y_dfw, y_str;     // Saídas das três abordagens

    // ----------------------------------------------
    // Instâncias (uma para cada estilo de implementação)
    // ----------------------------------------------
    demux_1_N #(.N(N)) DUT_BEH (.din(din), .sel(sel), .y(y_beh));
    demux_1_N #(.N(N)) DUT_DFW (.din(din), .sel(sel), .y(y_dfw));
    demux_1_N #(.N(N)) DUT_STR (.din(din), .sel(sel), .y(y_str));

    // ------------------
    // Geração de VCD
    // ------------------
    initial begin
        $dumpfile("wave.vcd");                      // Nome do arquivo VCD
        $dumpvars(0, tb_demux_1_N);                // Exporta todos os sinais do TB
    end

    // ----------------------
    // Estímulos e verificação
    // ----------------------
    integer i;                                     // Índice para iteração
    initial begin
        $display("\n--- Início da simulação do demux 1x%0d ---\n", N);
        din = 1'b0;                                // Inicializa entrada
        sel = {W{1'b0}};                       // Inicializa seleção
        #5;                                        // Aguardar algum tempo

        // Teste com din=0 (todas as saídas devem ser 0)
        din = 1'b0;
        for (i = 0; i < N; i = i + 1) begin
            sel = i[W-1:0];                        // Define seleção
            #5;                                    // Tempo para propagação
            $display("t=%0t | din=%b sel=%0d | y_beh=%b y_dfw=%b y_str=%b",
                     $time, din, sel, y_beh, y_dfw, y_str);
            if (y_beh !== {N{1'b0}} || y_dfw !== {N{1'b0}} || y_str !== {N{1'b0}}) begin
                $display("**ERRO**: Saídas devem ser zero quando din=0.");
            end
        end

        // Teste com din=1 (deve existir um único '1' na posição 'sel')
        din = 1'b1;
        for (i = 0; i < N; i = i + 1) begin
            sel = i[W-1:0];                        // Define seleção
            #5;                                    // Tempo para propagação
            $display("t=%0t | din=%b sel=%0d | y_beh=%b y_dfw=%b y_str=%b",
                     $time, din, sel, y_beh, y_dfw, y_str);
            if (y_beh !== (1'b1 << sel)) $display("**ERRO (BEH)** esperado %b", (1'b1 << sel));
            if (y_dfw !== (1'b1 << sel)) $display("**ERRO (DFW)** esperado %b", (1'b1 << sel));
            if (y_str !== (1'b1 << sel)) $display("**ERRO (STR)** esperado %b", (1'b1 << sel));
        end

        // Encerramento limpo
        $display("\nFim da simulacao.");
        $finish;
    end

endmodule
