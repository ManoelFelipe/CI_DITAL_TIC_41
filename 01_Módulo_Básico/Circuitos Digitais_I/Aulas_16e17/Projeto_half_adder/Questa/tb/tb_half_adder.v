// ============================================================================
// Arquivo  : tb_half_adder.v
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench autochecado para quatro descrições de meio-somador:
//            behavioral (always), behavioral (soma/concat), dataflow (assign)
//            e structural (primitivas). Estímulos cobrem todas as combinações
//            possíveis de {a,b} em 1 bit. Gera VCD e sinaliza PASS/FAIL.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_half_adder;
    // -------------------------------
    // Entradas dirigidas pelo TB
    // -------------------------------
    reg a;                    // bit A de estímulo
    reg b;                    // bit B de estímulo

    // -------------------------------
    // Sinais de saída de cada DUT
    // -------------------------------
    wire sum_beh,  carry_beh;
    wire sum_beh2, carry_beh2;
    wire sum_df,   carry_df;
    wire sum_st,   carry_st;

    // -------------------------------
    // Instâncias (4 DUTs)
    // -------------------------------
    half_adder_beh        dut_beh   (.a(a), .b(b), .sum_o(sum_beh),  .carry_o(carry_beh));
    half_adder_beh_sumop  dut_beh2  (.a(a), .b(b), .sum_o(sum_beh2), .carry_o(carry_beh2));
    half_adder_dataflow   dut_df    (.a(a), .b(b), .sum_o(sum_df),   .carry_o(carry_df));
    half_adder_struct     dut_st    (.a(a), .b(b), .sum_o(sum_st),   .carry_o(carry_st));

    // -------------------------------
    // Geração de VCD
    // -------------------------------
    initial begin
        $dumpfile("wave.vcd");       // arquivo de ondas
        $dumpvars(0, tb_half_adder); // hierarquia completa do TB
    end

    // -------------------------------
    // Flag de sucesso e contadores
    // -------------------------------
    integer pass_count = 0;          // nº de vetores corretos
    integer fail_count = 0;          // nº de falhas
    reg     success    = 1'b1;       // flag geral de sucesso

    // -------------------------------
    // Estímulos e verificação
    // -------------------------------
    integer vec;
    reg exp_sum, exp_carry;          // expectativas calculadas localmente

    initial begin
        $display("=== Iniciando tb_half_adder ===");
        a = 1'b0; b = 1'b0;          // inicialização
        #1;                          // delta para estabilidade

        // Loop cobre as 4 combinações de {a,b} de 0 a 3 (2 bits)
        for (vec = 0; vec < 4; vec = vec + 1) begin
            {a, b} = vec[1:0];      // aplica par de bits
            #5;                     // tempo para propagação

            // Cálculo da referência: XOR e AND
            exp_sum   = a ^ b;      // soma esperada
            exp_carry = a & b;      // carry esperado

            // Verifica todos os DUTs em paralelo
            if (sum_beh !== exp_sum || carry_beh !== exp_carry ||
                sum_beh2 !== exp_sum || carry_beh2 !== exp_carry ||
                sum_df  !== exp_sum || carry_df  !== exp_carry ||
                sum_st  !== exp_sum || carry_st  !== exp_carry) begin
                $display("ERRO em vec=%0d A=%0b B=%0b | Esperado S=%0b C=%0b | beh S=%0b C=%0b | beh2 S=%0b C=%0b | df S=%0b C=%0b | st S=%0b C=%0b",
                         vec, a, b, exp_sum, exp_carry,
                         sum_beh, carry_beh, sum_beh2, carry_beh2, sum_df, carry_df, sum_st, carry_st);
                fail_count = fail_count + 1;
                success = 1'b0;
            end else begin
                $display("OK   em vec=%0d A=%0b B=%0b => S=%0b C=%0b", vec, a, b, exp_sum, exp_carry);
                pass_count = pass_count + 1;
            end
        end

        // Resumo
        #5;
        if (success) $display("RESULTADO: PASS (pass=%0d, fail=%0d)", pass_count, fail_count);
        else         $display("RESULTADO: FAIL (pass=%0d, fail=%0d)", pass_count, fail_count);

        $display("Fim da simulacao.");
        $finish;                    // encerramento limpo
    end
endmodule
