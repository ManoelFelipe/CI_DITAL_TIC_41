// ============================================================================
// Arquivo  : tb_ula_full  (testbench para ULA_FULL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compativel com Quartus e Questa (Verilog 2001)
// Descricao: Testbench combinacional que instancia simultaneamente as tres
//            abordagens da ULA_FULL (behavioral, dataflow e structural),
//            aplicando um conjunto sistematico de estimulos e verificando a
//            consistencia entre resultados e flags. Gera wave.vcd para analise.
// Revisao   : v1.0 — criacao inicial
// ============================================================================

`timescale 1ns/1ps

module tb_ula_full;

    // ------------------------------------------------------------------------
    // Parametros de largura e ponto fixo
    // ------------------------------------------------------------------------
    localparam WIDTH = 8;
    localparam FRAC  = 4;

    // ------------------------------------------------------------------------
    // Sinais de estimulo (entradas comuns a todas as implementacoes)
    // ------------------------------------------------------------------------
    reg  [WIDTH-1:0] op_a;
    reg  [WIDTH-1:0] op_b;
    reg  [3:0]       op_sel;
    reg  [2:0]       num_mode;

    // ------------------------------------------------------------------------
    // Sinais de saida para cada implementacao
    // ------------------------------------------------------------------------
    wire [WIDTH-1:0] result_beh;
    wire             ovf_beh;
    wire             sat_beh;
    wire             zero_beh;
    wire             neg_beh;
    wire             carry_beh;

    wire [WIDTH-1:0] result_df;
    wire             ovf_df;
    wire             sat_df;
    wire             zero_df;
    wire             neg_df;
    wire             carry_df;

    wire [WIDTH-1:0] result_str;
    wire             ovf_str;
    wire             sat_str;
    wire             zero_str;
    wire             neg_str;
    wire             carry_str;

    // ------------------------------------------------------------------------
    // Contador de erros
    // ------------------------------------------------------------------------
    integer error_count;
    integer i_mode, i_op, i_a, i_b;

    // ------------------------------------------------------------------------
    // Instancias das tres abordagens da ULA
    // ------------------------------------------------------------------------
    ula_full_behavioral
    #(
        .WIDTH (WIDTH),
        .FRAC  (FRAC)
    ) dut_behavioral (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result_beh),
        .flag_overflow(ovf_beh),
        .flag_saturate(sat_beh),
        .flag_zero    (zero_beh),
        .flag_negative(neg_beh),
        .flag_carry   (carry_beh)
    );

    ula_full_dataflow
    #(
        .WIDTH (WIDTH),
        .FRAC  (FRAC)
    ) dut_dataflow (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result_df),
        .flag_overflow(ovf_df),
        .flag_saturate(sat_df),
        .flag_zero    (zero_df),
        .flag_negative(neg_df),
        .flag_carry   (carry_df)
    );

    ula_full_structural
    #(
        .WIDTH (WIDTH),
        .FRAC  (FRAC)
    ) dut_structural (
        .op_a         (op_a),
        .op_b         (op_b),
        .op_sel       (op_sel),
        .num_mode     (num_mode),
        .result       (result_str),
        .flag_overflow(ovf_str),
        .flag_saturate(sat_str),
        .flag_zero    (zero_str),
        .flag_negative(neg_str),
        .flag_carry   (carry_str)
    );

    // ------------------------------------------------------------------------
    // Geracao de arquivo de ondas VCD
    // ------------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula_full);
    end

    // ------------------------------------------------------------------------
    // Processo principal de estimulo e verificacao
    // ------------------------------------------------------------------------
    initial begin
        error_count = 0;

        // Inicializa entradas
        op_a     = {WIDTH{1'b0}};
        op_b     = {WIDTH{1'b0}};
        op_sel   = 4'b0000;
        num_mode = 3'b000;

        #5;

        // Varre alguns modos numericos: unsigned, signed, Q
        for (i_mode = 0; i_mode < 3; i_mode = i_mode + 1) begin
            num_mode = (i_mode == 0) ? 3'b000 :
                       (i_mode == 1) ? 3'b001 :
                                       3'b011;

            // Varre todas as operacoes possiveis
            for (i_op = 0; i_op < 16; i_op = i_op + 1) begin
                op_sel = i_op[3:0];

                // Varre subconjunto de operandos
                for (i_a = 0; i_a < 8; i_a = i_a + 1) begin
                    for (i_b = 0; i_b < 8; i_b = i_b + 1) begin
                        op_a = i_a[WIDTH-1:0];
                        op_b = i_b[WIDTH-1:0];

                        #2;

                        // Compara resultados das tres implementacoes
                        if ( (result_beh !== result_df) ||
                             (result_beh !== result_str) ||
                             (ovf_beh   !== ovf_df)   ||
                             (ovf_beh   !== ovf_str)  ||
                             (sat_beh   !== sat_df)   ||
                             (sat_beh   !== sat_str)  ||
                             (zero_beh  !== zero_df)  ||
                             (zero_beh  !== zero_str) ||
                             (neg_beh   !== neg_df)   ||
                             (neg_beh   !== neg_str)  ||
                             (carry_beh !== carry_df) ||
                             (carry_beh !== carry_str) ) begin
                            error_count = error_count + 1;
                            $display("ERRO: modo=%0b op_sel=%0b A=%0d B=%0d | ",
                                     num_mode, op_sel, op_a, op_b);
                            $display("  BEH: res=%0d ovf=%b sat=%b z=%b n=%b c=%b",
                                     result_beh, ovf_beh, sat_beh, zero_beh, neg_beh, carry_beh);
                            $display("  DF : res=%0d ovf=%b sat=%b z=%b n=%b c=%b",
                                     result_df, ovf_df, sat_df, zero_df, neg_df, carry_df);
                            $display("  STR: res=%0d ovf=%b sat=%b z=%b n=%b c=%b",
                                     result_str, ovf_str, sat_str, zero_str, neg_str, carry_str);
                        end
                    end
                end
            end
        end

        if (error_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes para o conjunto de testes.");
        end else begin
            $display("FALHA: Foram encontrados %0d casos de divergencia.", error_count);
        end

        $display("Fim da simulacao.");
        $finish;
    end

endmodule
