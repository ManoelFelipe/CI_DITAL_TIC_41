// ============================================================================
// Arquivo  : tb_ULA_LSL_LSR_mod.v  — Testbench para ULA_LSL_LSR_mod
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Questa (Verilog 2001)
// Descrição: Testbench combinacional para validar a ULA_LSL_LSR_mod nas três
//            abordagens (behavioral, dataflow, structural). Gera varredura
//            exaustiva de vetores para A, B e op_sel, utilizando B como fator
//            de deslocamento para LSL/LSR com saturação em 4 posições. Inclui
//            geração de VCD, checagem automática e relatório de sucesso/falha.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_ULA_LSL_LSR_mod;
    // -----------------------------------------------------------------------
    // Declaração das entradas de estímulo e da saída monitorada
    // -----------------------------------------------------------------------
    reg  [3:0] a_in;                // Operando A
    reg  [3:0] b_in;                // Operando B (inclui fator de deslocamento)
    reg  [2:0] op_sel;              // Código da operação
    wire [3:0] resultado_out;       // Resultado produzido pela ULA

    reg  [3:0] esperado;            // Resultado de referência (modelo dourado)
    integer    erros;               // Contador de discrepâncias
    integer    ia;                  // Índice para laço em A
    integer    ib;                  // Índice para laço em B
    integer    is;                  // Índice para laço em op_sel

    // -----------------------------------------------------------------------
    // Instancia o DUT (implementação selecionada via compile.do)
    // -----------------------------------------------------------------------
    ULA_LSL_LSR_mod dut (
        .a_in         (a_in),
        .b_in         (b_in),
        .op_sel       (op_sel),
        .resultado_out(resultado_out)
    );

    // -----------------------------------------------------------------------
    // Geração de VCD para visualização de formas de onda
    // -----------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ULA_LSL_LSR_mod);
    end

    // -----------------------------------------------------------------------
    // Tarefa auxiliar para imprimir o vetor de teste atual
    // -----------------------------------------------------------------------
    task show_vector;
        input [2:0] op;
        begin
            $display("t=%0t ns | A=%b B=%b op_sel=%03b | resultado=%b esperado=%b",
                     $time, a_in, b_in, op, resultado_out, esperado);
        end
    endtask

    // -----------------------------------------------------------------------
    // Modelo de referência com LSL/LSR variáveis e saturação em 4 deslocamentos
    // -----------------------------------------------------------------------
    task calcula_esperado;
        input  [3:0] a_ref;
        input  [3:0] b_ref;
        input  [2:0] sel_ref;
        output [3:0] exp_out;
        reg    [3:0] tmp;
        reg    [2:0] shift_amt;
        begin
            // Calcula fator de deslocamento saturado (0..4)
            if (b_ref > 4'd4) begin
                shift_amt = 3'd4;
            end else begin
                shift_amt = b_ref[2:0];
            end

            // Seleciona a operação
            case (sel_ref)
                3'b000: tmp = (a_ref & b_ref);
                3'b001: tmp = (a_ref | b_ref);
                3'b010: tmp = (~a_ref);
                3'b011: tmp = ~(a_ref & b_ref);
                3'b100: tmp = (a_ref + b_ref);
                3'b101: tmp = (a_ref - b_ref);
                3'b110: tmp = (a_ref << shift_amt);
                3'b111: tmp = (a_ref >> shift_amt);
                default: tmp = 4'b0000;
            endcase

            exp_out = tmp;
        end
    endtask

    // -----------------------------------------------------------------------
    // Estímulos principais: varredura exaustiva dos vetores válidos
    // -----------------------------------------------------------------------
    initial begin
        erros   = 0;
        a_in    = 4'b0000;
        b_in    = 4'b0000;
        op_sel  = 3'b000;

        // Varre todos os códigos de operação
        for (is = 0; is < 8; is = is + 1) begin
            op_sel = is[2:0];

            // Varre todas as combinações de A e B (4 bits cada)
            for (ia = 0; ia < 16; ia = ia + 1) begin
                for (ib = 0; ib < 16; ib = ib + 1) begin
                    a_in = ia[3:0];
                    b_in = ib[3:0];

                    #2; // Pequeno atraso para estabilização da lógica

                    calcula_esperado(a_in, b_in, op_sel, esperado);
                    show_vector(op_sel);

                    if (resultado_out !== esperado) begin
                        $display("ERRO: mismatch A=%b B=%b op_sel=%03b => DUT=%b REF=%b",
                                 a_in, b_in, op_sel, resultado_out, esperado);
                        erros = erros + 1;
                    end
                end
            end
        end

        // Vetores específicos focando saturação do deslocamento
        op_sel = 3'b110;            // LSL
        a_in   = 4'b1010;
        b_in   = 4'b1001;           // 9 -> deve saturar para shift_amt=4
        #2;
        calcula_esperado(a_in, b_in, op_sel, esperado);
        show_vector(op_sel);
        if (resultado_out !== esperado) begin
            $display("ERRO: saturacao incorreta em LSL.");
            erros = erros + 1;
        end

        op_sel = 3'b111;            // LSR
        a_in   = 4'b0110;
        b_in   = 4'b1110;           // 14 -> deve saturar para shift_amt=4
        #2;
        calcula_esperado(a_in, b_in, op_sel, esperado);
        show_vector(op_sel);
        if (resultado_out !== esperado) begin
            $display("ERRO: saturacao incorreta em LSR.");
            erros = erros + 1;
        end

        // Relatório final
        if (erros == 0) begin
            $display("====================================================");
            $display(" tb_ULA_LSL_LSR_mod: TODOS OS TESTES PASSARAM ");
            $display("====================================================");
        end else begin
            $display("====================================================");
            $display(" tb_ULA_LSL_LSR_mod: %0d ERRO(S) ENCONTRADO(S)", erros);
            $display("====================================================");
        end

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
