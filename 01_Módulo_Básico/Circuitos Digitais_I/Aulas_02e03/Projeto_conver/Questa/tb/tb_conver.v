// ============================================================================
// Arquivo  : tb_conver.v  (testbench para as três abordagens)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench auto-checável para o conversor BCD 5311 -> BCD 8421.
//            Instancia simultaneamente as três implementações
//            (behavioral, dataflow e structural) e aplica todos os 10
//            códigos válidos do padrão 5311, comparando as saídas com o
//            código 8421 esperado. Gera arquivo VCD para análise de formas
//            de onda e encerra a simulação com mensagem de sucesso ou de
//            erro conforme o resultado dos testes.
// Revisão  : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Testbench: tb_conver
// --------------------------------------------------------------------------
module tb_conver;

    // Registradores para as entradas do código 5311.
    reg h;
    reg g;
    reg f;
    reg e;

    // Fios para as saídas de cada implementação (behavioral, dataflow, structural).
    wire d_beh, c_beh, b_beh, a_beh;
    wire d_df,  c_df,  b_df,  a_df;
    wire d_st,  c_st,  b_st,  a_st;

    // Vetores auxiliares para facilitar comparações.
    wire [3:0] out_beh = {d_beh, c_beh, b_beh, a_beh};
    wire [3:0] out_df  = {d_df,  c_df,  b_df,  a_df};
    wire [3:0] out_st  = {d_st,  c_st,  b_st,  a_st};
    wire [3:0] in_5311 = {h, g, f, e};

    // Memórias para os padrões de teste.
    reg [3:0] vec_in_5311   [0:9];  // códigos em 5311 (H,G,F,E)
    reg [3:0] vec_exp_8421  [0:9];  // códigos esperados em 8421 (D,C,B,A)

    integer i;
    integer error_count;

    // ----------------------------------------------------------------------
    // Instancia as três abordagens do conversor.
    // ----------------------------------------------------------------------

    // Implementação behavioral.
    conver_behavioral u_conver_behavioral (
        .h (h),
        .g (g),
        .f (f),
        .e (e),
        .d (d_beh),
        .c (c_beh),
        .b (b_beh),
        .a (a_beh)
    );

    // Implementação dataflow.
    conver_dataflow u_conver_dataflow (
        .h (h),
        .g (g),
        .f (f),
        .e (e),
        .d (d_df),
        .c (c_df),
        .b (b_df),
        .a (a_df)
    );

    // Implementação estrutural.
    conver_structural u_conver_structural (
        .h (h),
        .g (g),
        .f (f),
        .e (e),
        .d (d_st),
        .c (c_st),
        .b (b_st),
        .a (a_st)
    );

    // ----------------------------------------------------------------------
    // Geração do arquivo VCD para visualização de formas de onda.
    // ----------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_conver);
    end

    // ----------------------------------------------------------------------
    // Bloco inicial: preenchimento dos vetores de teste e aplicação dos
    // estímulos às três implementações simultaneamente.
// ----------------------------------------------------------------------
    initial begin
        // Inicializa contador de erros.
        error_count = 0;

        // --------------------------------------------------------------
        // Preenche os vetores com a tabela fornecida:
        // Decimal | BCD 5311 (H,G,F,E) | BCD 8421 (D,C,B,A)
        // 0 -> 0000 | 0000
        // 1 -> 0001 | 0001
        // 2 -> 0011 | 0010
        // 3 -> 0100 | 0011
        // 4 -> 0101 | 0100
        // 5 -> 0111 | 0101
        // 6 -> 1001 | 0110
        // 7 -> 1011 | 0111
        // 8 -> 1100 | 1000
        // 9 -> 1101 | 1001
        // --------------------------------------------------------------
        vec_in_5311[0]  = 4'b0000; vec_exp_8421[0] = 4'b0000;
        vec_in_5311[1]  = 4'b0001; vec_exp_8421[1] = 4'b0001;
        vec_in_5311[2]  = 4'b0011; vec_exp_8421[2] = 4'b0010;
        vec_in_5311[3]  = 4'b0100; vec_exp_8421[3] = 4'b0011;
        vec_in_5311[4]  = 4'b0101; vec_exp_8421[4] = 4'b0100;
        vec_in_5311[5]  = 4'b0111; vec_exp_8421[5] = 4'b0101;
        vec_in_5311[6]  = 4'b1001; vec_exp_8421[6] = 4'b0110;
        vec_in_5311[7]  = 4'b1011; vec_exp_8421[7] = 4'b0111;
        vec_in_5311[8]  = 4'b1100; vec_exp_8421[8] = 4'b1000;
        vec_in_5311[9]  = 4'b1101; vec_exp_8421[9] = 4'b1001;

        // Inicializa entradas.
        {h, g, f, e} = 4'b0000;

        // Pequeno atraso inicial para estabilização.
        #5;

        // --------------------------------------------------------------
        // Loop principal de teste: percorre todos os dígitos de 0 a 9.
        // --------------------------------------------------------------
        for (i = 0; i < 10; i = i + 1) begin
            // Aplica o próximo código 5311 às entradas.
            {h, g, f, e} = vec_in_5311[i];

            // Aguarda tempo de propagação da lógica combinacional.
            #10;

            // Verifica se cada implementação produziu o código 8421 esperado.
            if (out_beh !== vec_exp_8421[i]) begin
                $display("ERRO (behavioral) no indice %0d: entrada 5311 = %b, esperado 8421 = %b, obtido = %b",
                         i, in_5311, vec_exp_8421[i], out_beh);
                error_count = error_count + 1;
            end

            if (out_df !== vec_exp_8421[i]) begin
                $display("ERRO (dataflow) no indice %0d: entrada 5311 = %b, esperado 8421 = %b, obtido = %b",
                         i, in_5311, vec_exp_8421[i], out_df);
                error_count = error_count + 1;
            end

            if (out_st !== vec_exp_8421[i]) begin
                $display("ERRO (structural) no indice %0d: entrada 5311 = %b, esperado 8421 = %b, obtido = %b",
                         i, in_5311, vec_exp_8421[i], out_st);
                error_count = error_count + 1;
            end

            // Exibe informação de depuração a cada vetor aplicado.
            $display("Teste %0d: IN(5311)=%b | OUT_BEH=%b OUT_DF=%b OUT_ST=%b | EXP(8421)=%b",
                     i, in_5311, out_beh, out_df, out_st, vec_exp_8421[i]);
        end

        // --------------------------------------------------------------
        // Resumo final: imprime sucesso ou número de erros encontrados.
        // --------------------------------------------------------------
        if (error_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes com a tabela BCD 5311 -> 8421.");
        end else begin
            $display("FALHA: Foram encontrados %0d erros durante os testes.", error_count);
        end

        // Mensagem de término e finalização da simulação.
        $display("Fim da simulacao.");
        $finish;
    end

endmodule
