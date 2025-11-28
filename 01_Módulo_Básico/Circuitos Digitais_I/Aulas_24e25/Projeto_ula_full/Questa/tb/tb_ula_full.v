// ============================================================================
// Arquivo  : tb_ula_full  (testbench)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Questa (Verilog 2001)
// Descrição: Testbench combinacional para a ULA completa, instanciando as
//            três abordagens (behavioral, dataflow, structural) em paralelo.
//            Gera estímulos pseudo‑exaustivos por loops, compara resultados
//            entre as implementações e produz wave.vcd para análise gráfica.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_ula_full;

    // Parâmetros de largura, idênticos aos módulos de ULA
    localparam WIDTH = 8;
    localparam FRAC  = 4;

    // Declaração dos registradores de estímulo
    reg  [WIDTH-1:0] op_a;
    reg  [WIDTH-1:0] op_b;
    reg  [2:0]       op_sel;
    reg  [2:0]       num_mode;

    // Sinais de saída da implementação behavioral
    wire [WIDTH-1:0] result_beh;
    wire             ov_beh;
    wire             sat_beh;
    wire             zero_beh;
    wire             neg_beh;
    wire             carry_beh;

    // Sinais de saída da implementação dataflow
    wire [WIDTH-1:0] result_df;
    wire             ov_df;
    wire             sat_df;
    wire             zero_df;
    wire             neg_df;
    wire             carry_df;

    // Sinais de saída da implementação structural
    wire [WIDTH-1:0] result_st;
    wire             ov_st;
    wire             sat_st;
    wire             zero_st;
    wire             neg_st;
    wire             carry_st;

    // =====================================================================
    // Instância da ULA behavioral
    // =====================================================================
    ula_full_behavioral
    #(
        .WIDTH(WIDTH),
        .FRAC (FRAC)
    ) dut_behavioral (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result_beh),
        .flag_overflow(ov_beh),
        .flag_saturate(sat_beh),
        .flag_zero    (zero_beh),
        .flag_negative(neg_beh),
        .flag_carry   (carry_beh)
    );

    // =====================================================================
    // Instância da ULA dataflow
    // =====================================================================
    ula_full_dataflow
    #(
        .WIDTH(WIDTH),
        .FRAC (FRAC)
    ) dut_dataflow (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result_df),
        .flag_overflow(ov_df),
        .flag_saturate(sat_df),
        .flag_zero    (zero_df),
        .flag_negative(neg_df),
        .flag_carry   (carry_df)
    );

    // =====================================================================
    // Instância da ULA structural
    // =====================================================================
    ula_full_structural
    #(
        .WIDTH(WIDTH),
        .FRAC (FRAC)
    ) dut_structural (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result_st),
        .flag_overflow(ov_st),
        .flag_saturate(sat_st),
        .flag_zero    (zero_st),
        .flag_negative(neg_st),
        .flag_carry   (carry_st)
    );

    // =====================================================================
    // Geração do VCD de ondas para análise
    // =====================================================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula_full);
    end

    // =====================================================================
    // Geração de estímulos: varredura sobre modos, operações e subset de A/B
    // =====================================================================
    integer i_mode;
    integer i_op;
    integer i_a;
    integer i_b;
    integer total_tests;
    integer error_count;

    initial begin
        op_a        = {WIDTH{1'b0}};
        op_b        = {WIDTH{1'b0}};
        op_sel      = 3'b000;
        num_mode    = 3'b000;
        total_tests = 0;
        error_count = 0;

        // Pequeno atraso inicial para estabilização
        #10;

        // Loop externo: modos numéricos (0 a 4)
        for (i_mode = 0; i_mode <= 4; i_mode = i_mode + 1) begin
            num_mode = i_mode[2:0];
            // Loop de operações (0 a 7)
            for (i_op = 0; i_op < 8; i_op = i_op + 1) begin
                op_sel = i_op[2:0];
                // Subvarredura reduzida de operandos para manter simulação rápida
                for (i_a = 0; i_a < 16; i_a = i_a + 1) begin
                    for (i_b = 0; i_b < 16; i_b = i_b + 1) begin
                        op_a = i_a[WIDTH-1:0];
                        op_b = i_b[WIDTH-1:0];
                        #1;
                        total_tests = total_tests + 1;

                        if ( (result_beh  !== result_df)  ||
                             (result_beh  !== result_st)  ||
                             (ov_beh      !== ov_df)      ||
                             (ov_beh      !== ov_st)      ||
                             (sat_beh     !== sat_df)     ||
                             (sat_beh     !== sat_st)     ||
                             (zero_beh    !== zero_df)    ||
                             (zero_beh    !== zero_st)    ||
                             (neg_beh     !== neg_df)     ||
                             (neg_beh     !== neg_st)     ||
                             (carry_beh   !== carry_df)   ||
                             (carry_beh   !== carry_st) ) begin
                            error_count = error_count + 1;
                            $display("ERRO: modo=%0d op=%0d A=%0d B=%0d | beh=%h df=%h st=%h",
                                     i_mode, i_op, i_a, i_b, result_beh, result_df, result_st);
                        end
                    end
                end
            end
        end

        if (error_count == 0) begin
            $display("SUCESSO: Todas as implementacoes da ULA FULL estao consistentes.");
        end else begin
            $display("FALHAS: %0d discrepancias detectadas em %0d testes.", error_count, total_tests);
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
