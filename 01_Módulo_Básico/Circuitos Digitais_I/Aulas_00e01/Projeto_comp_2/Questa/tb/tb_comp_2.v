// ============================================================================
// Arquivo  : tb_comp_2_multi.v
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench comparando simultaneamente as três abordagens do módulo
//            comp_2: behavioral, dataflow e structural. Varre todas as
//            combinações das entradas, verifica consistência funcional e entre
//            implementações e imprime um log OK/ERRO por combinação.
// Revisão   : v1.1 — inclusão de mensagens OK por combinação
// ============================================================================
`timescale 1ns/1ps

module tb_comp_2;

    // Entradas de estímulo
    reg [1:0] tb_a;      // Entrada A
    reg [1:0] tb_b;      // Entrada B

    // Saídas das três implementações
    wire out_bhv;        // Saída da versão behavioral
    wire out_df;         // Saída da versão dataflow
    wire out_st;         // Saída da versão structural

    // Referência e auxiliares
    reg     expected;    // Valor esperado (modelo dourado)
    integer i;           // Índice para tb_a
    integer j;           // Índice para tb_b
    integer errors;      // Contador global de erros
    reg     combo_error; // Flag de erro para a combinação atual

    // ========================================================================
    // Instâncias das três implementações do comparador
    // ========================================================================
    comp_2 dut_bhv (
        .a         (tb_a),
        .b         (tb_b),
        .igual_flag(out_bhv)
    );

    comp_2 dut_df (
        .a         (tb_a),
        .b         (tb_b),
        .igual_flag(out_df)
    );

    comp_2 dut_st (
        .a         (tb_a),
        .b         (tb_b),
        .igual_flag(out_st)
    );

    // ========================================================================
    // Geração de arquivo de ondas
    // ========================================================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_comp_2);
    end

    // ========================================================================
    // Bloco principal de estímulos e verificação
    // ========================================================================
    initial begin
        errors = 0;          // Zera contador de erros

        // Varre todas as combinações de 2 bits para A e B (00..11)
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                tb_a = i[1:0];   // Aplica valor em A
                tb_b = j[1:0];   // Aplica valor em B

                #5;              // Tempo de propagação

                // Calcula valor esperado da igualdade
                expected   = (tb_a == tb_b);
                combo_error = 1'b0; // Assume que não há erro na combinação atual

                // ------------------------------------------------------------
                // Verificação funcional: cada abordagem vs modelo esperado
                // ------------------------------------------------------------
                if (out_bhv !== expected ||
                    out_df  !== expected ||
                    out_st  !== expected) begin

                    $display("ERRO FUNCIONAL: a=%b b=%b | bhv=%b df=%b st=%b exp=%b @%0t",
                             tb_a, tb_b, out_bhv, out_df, out_st, expected, $time);
                    errors      = errors + 1;
                    combo_error = 1'b1;
                end

                // ------------------------------------------------------------
                // Verificação de consistência entre implementações
                // ------------------------------------------------------------
                if (out_bhv !== out_df ||
                    out_bhv !== out_st) begin

                    $display("ERRO ENTRE IMPLEMENTACOES: a=%b b=%b | bhv=%b df=%b st=%b @%0t",
                             tb_a, tb_b, out_bhv, out_df, out_st, $time);
                    errors      = errors + 1;
                    combo_error = 1'b1;
                end

                // ------------------------------------------------------------
                // Log de sucesso da combinação (usando behavioral como referência)
                // ------------------------------------------------------------
                if (!combo_error) begin
                    $display("OK  : a=%b b=%b | igual_flag_bhv=%b (DUT) == %b (esperado) @ t=%0t",
                             tb_a, tb_b, out_bhv, expected, $time);
                end

                #5;              // Espaço entre vetores para facilitar visualização
            end
        end

        // Relatório final
        if (errors == 0) begin
            $display("----------------------------------------------------");
            $display("SUCESSO: Todas as implementacoes estao consistentes.");
            $display("----------------------------------------------------");
        end else begin
            $display("----------------------------------------------------");
            $display("TOTAL DE ERROS DETECTADOS: %0d", errors);
            $display("----------------------------------------------------");
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
