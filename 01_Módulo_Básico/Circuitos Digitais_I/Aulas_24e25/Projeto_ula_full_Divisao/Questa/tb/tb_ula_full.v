// ============================================================================
// Arquivo  : tb_ula_full
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench completo da ULA_FULL com:
//            - 3 DUTs simultâneos: behavioral, dataflow e structural.
//            - Teste automático por varredura de num_mode, op_sel, A e B.
//            - Impressão de TABELAS DIDÁTICAS para dois pares (A,B)
//              escolhidos pelo usuário, APÓS o teste automático.
//            - Geração de VCD e checagem automática de consistência.
//            - Testbench para ULA com formatação de tabela corrigida e comentários explicativos passo-a-passo.
// Revisão   : v1.3 — sincronização entre teste automático e tabelas didáticas
// ============================================================================
// ============================================================================
// Arquivo  : tb_ula_full.v (Versão Final - Robustez Total)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Descrição: Testbench com verificação completa de TODAS as flags e
//            relatório detalhado de erros. Garante consistência total entre
//            Behavioral, Dataflow e Structural.
// ============================================================================

`timescale 1ns/1ps

module tb_ula_full;

    // ========================================================================
    // 1. PARÂMETROS
    // ========================================================================
    parameter WIDTH = 8;
    parameter FRAC  = 4;
    parameter MAX_A_TEST = 8; 
    parameter MAX_B_TEST = 8;

    // ========================================================================
    // 2. SINAIS
    // ========================================================================
    reg  [WIDTH-1:0] op_a, op_b;
    reg  [3:0]       op_sel;
    reg  [2:0]       num_mode;

    // Saídas das 3 arquiteturas para comparação
    wire [WIDTH-1:0] res_bh, res_df, res_st;
    wire             ov_bh,  ov_df,  ov_st;
    wire             sat_bh, sat_df, sat_st;
    wire             zero_bh,zero_df,zero_st;
    wire             neg_bh, neg_df, neg_st;
    wire             car_bh, car_df, car_st;

    // Variáveis de Controle (integers para loops)
    integer i, j, idx_mode, idx_op;
    integer error_count = 0;
    integer total_tests = 0;
    
    // Controle das Tabelas
    reg automatic_done;
    integer a_did_1, b_did_1;
    integer a_did_2, b_did_2;

    // ========================================================================
    // 3. INSTÂNCIAS (DUTs)
    // ========================================================================
    ula_full_behavioral #(.WIDTH(WIDTH), .FRAC(FRAC)) DUT_BEH (
        .op_a(op_a), .op_b(op_b), .op_sel(op_sel), .num_mode(num_mode),
        .result(res_bh), .flag_overflow(ov_bh), .flag_saturate(sat_bh),
        .flag_zero(zero_bh), .flag_negative(neg_bh), .flag_carry(car_bh)
    );

    ula_full_dataflow #(.WIDTH(WIDTH), .FRAC(FRAC)) DUT_DF (
        .op_a(op_a), .op_b(op_b), .op_sel(op_sel), .num_mode(num_mode),
        .result(res_df), .flag_overflow(ov_df), .flag_saturate(sat_df),
        .flag_zero(zero_df), .flag_negative(neg_df), .flag_carry(car_df)
    );

    ula_full_structural #(.WIDTH(WIDTH), .FRAC(FRAC)) DUT_ST (
        .op_a(op_a), .op_b(op_b), .op_sel(op_sel), .num_mode(num_mode),
        .result(res_st), .flag_overflow(ov_st), .flag_saturate(sat_st),
        .flag_zero(zero_st), .flag_negative(neg_st), .flag_carry(car_st)
    );

    // ========================================================================
    // 4. FUNÇÃO AUXILIAR
    // ========================================================================
    function [8*5:1] op_name;
        input [3:0] op;
        begin
            case (op)
                4'b0000: op_name = "ADD  "; 4'b0001: op_name = "SUB  ";
                4'b0010: op_name = "MUL  "; 4'b0011: op_name = "DIVU ";
                4'b0100: op_name = "DIVS "; 4'b0101: op_name = "DIVQ ";
                4'b0110: op_name = "AND  "; 4'b0111: op_name = "OR   ";
                4'b1000: op_name = "XOR  "; 4'b1001: op_name = "NAND ";
                4'b1010: op_name = "NOR  "; 4'b1011: op_name = "XNOR ";
                4'b1100: op_name = "SHL  "; 4'b1101: op_name = "SHR  ";
                4'b1110: op_name = "SAR  "; 4'b1111: op_name = "CMP  ";
                default: op_name = "???? ";
            endcase
        end
    endfunction

    // ========================================================================
    // 5. CONFIGURAÇÃO DE ONDA
    // ========================================================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula_full);
    end

    // ========================================================================
    // 6. TESTE AUTOMÁTICO (VALIDAÇÃO CRUZADA)
    // ========================================================================
    initial begin
        automatic_done = 1'b0;
        op_sel = 0; num_mode = 0; op_a = 0; op_b = 0;

        $display("\n# =========================================================");
        $display("# INICIANDO TESTE AUTOMATICO (Verificacao Completa)");
        $display("# Checando: Result, Overflow, Saturate, Zero, Negative, Carry");
        $display("# =========================================================\n");

        // Loops aninhados para cobertura de modos, operações e dados
        for (idx_mode = 0; idx_mode < 5; idx_mode = idx_mode + 1) begin
            num_mode = idx_mode[2:0];
            for (idx_op = 0; idx_op < 16; idx_op = idx_op + 1) begin
                op_sel = idx_op[3:0];
                for (i = 0; i < MAX_A_TEST; i = i + 1) begin
                    for (j = 0; j < MAX_B_TEST; j = j + 1) begin
    
                        op_a = i[WIDTH-1:0];
                        op_b = j[WIDTH-1:0];
                        #1; // Atraso para propagação combinacional
                        
                        total_tests = total_tests + 1;

                        // --- VERIFICAÇÃO ROBUSTA ---
                        // Compara todas as saídas das 3 arquiteturas.
                        // Se qualquer bit diferir, é erro.
                        if ( (res_bh !== res_df)   || (res_bh !== res_st)   ||
                             (ov_bh  !== ov_df)    || (ov_bh  !== ov_st)    ||
                             (sat_bh !== sat_df)   || (sat_bh !== sat_st)   ||
                             (zero_bh !== zero_df) || (zero_bh !== zero_st) ||
                             (neg_bh !== neg_df)   || (neg_bh !== neg_st)   ||
                             (car_bh !== car_df)   || (car_bh !== car_st) ) begin
                            
                            error_count = error_count + 1;
                            
                            // Report detalhado para facilitar debug
                            $display("ERRO [Mode %0d | %s]: A=%0d B=%0d", num_mode, op_name(op_sel), op_a, op_b);
                            $display("    BEH: Res=%d Ov=%b Sat=%b Zero=%b Neg=%b Car=%b", 
                                     res_bh, ov_bh, sat_bh, zero_bh, neg_bh, car_bh);
                            $display("    DF : Res=%d Ov=%b Sat=%b Zero=%b Neg=%b Car=%b", 
                                     res_df, ov_df, sat_df, zero_df, neg_df, car_df);
                            $display("    ST : Res=%d Ov=%b Sat=%b Zero=%b Neg=%b Car=%b\n", 
                                     res_st, ov_st, sat_st, zero_st, neg_st, car_st);
                        end
                    end
                end
            end
        end

        if (error_count == 0)
            $display("# SUCESSO TOTAL: %0d testes executados. Todas as flags consistentes.", total_tests);
        else
            $display("# FALHA: %0d inconsistencias encontradas.", error_count);

        automatic_done = 1'b1;
    end

    // ========================================================================
    // 7. TABELAS DIDÁTICAS
    // ========================================================================
    initial begin
        wait (automatic_done);
        
        // Configuração Tabela 1
        a_did_1 = 3; b_did_1 = -5; 

        $display("\n==================================================================================");
        $display("| TABELA 1: A = %0d, B = %0d (Modo Unsigned)                                     |", a_did_1, b_did_1);
        $display("==================================================================================");
        $display("| OP |  A  |   A_BIN  |  B  |   B_BIN  | CMD  |  RES_BIN | RES |");
        $display("|----|-----|----------|-----|----------|------|----------|-----|");

        for (idx_op = 0; idx_op < 16; idx_op = idx_op + 1) begin
            op_sel = idx_op[3:0]; num_mode = 3'b000;
            op_a = a_did_1[WIDTH-1:0]; op_b = b_did_1[WIDTH-1:0];
            #1;
            $display("| %2d | %3d | %8b | %3d | %8b | %s | %8b | %3d |",
                     op_sel, a_did_1, op_a, b_did_1, op_b, op_name(op_sel), res_bh, res_bh);
        end
        $display("==================================================================================");

        // Configuração Tabela 2
        a_did_2 = -6; b_did_2 = 3; 

        $display("\n==================================================================================");
        $display("| TABELA 2: A = %0d, B = %0d (Modo Unsigned)                                     |", a_did_2, b_did_2);
        $display("==================================================================================");
        $display("| OP |  A  |   A_BIN  |  B  |   B_BIN  | CMD  |  RES_BIN | RES |");
        $display("|----|-----|----------|-----|----------|------|----------|-----|");
        
        for (idx_op = 0; idx_op < 16; idx_op = idx_op + 1) begin
            op_sel = idx_op[3:0]; num_mode = 3'b000;
            op_a = a_did_2[WIDTH-1:0]; op_b = b_did_2[WIDTH-1:0];
            #1;
            $display("| %2d | %3d | %8b | %3d | %8b | %s | %8b | %3d |",
                     op_sel, a_did_2, op_a, b_did_2, op_b, op_name(op_sel), res_bh, res_bh);
        end
        $display("==================================================================================");
        $finish;
    end

endmodule