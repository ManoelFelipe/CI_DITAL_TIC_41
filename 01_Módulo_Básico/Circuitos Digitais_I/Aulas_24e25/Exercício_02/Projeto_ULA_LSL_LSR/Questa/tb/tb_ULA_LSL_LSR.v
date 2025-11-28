// ============================================================================
// Arquivo  : tb_ULA_LSL_LSR.v  — Testbench para ULA_LSL_LSR
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Questa (Verilog 2001)
// Descrição: Testbench combinacional para validar as três implementações da
//            ULA_LSL_LSR (behavioral, dataflow e structural). Gera vetores de
//            estímulo para diferentes combinações de A e B, varre todos os
//            códigos de operação do seletor e compara o resultado da ULA com
//            um modelo de referência calculado dentro do próprio testbench.
//            Inclui geração de VCD, checagem automática e mensagem final de
//            sucesso ou falha.
// Revisão   : v1.1 — correção do laço for (uso de índice inteiro)
// ============================================================================

`timescale 1ns/1ps

module tb_ULA_LSL_LSR;
    reg  [3:0] A;                // Operando A
    reg  [3:0] B;                // Operando B
    reg  [2:0] seletor;          // Código da operação
    wire [3:0] resultado;        // Resultado produzido pela ULA

    reg  [3:0] esperado;         // Resultado de referência (modelo dourado)
    integer    erros;            // Contador de discrepâncias
    integer    i;                // Índice auxiliar para laços for

    // DUT
    ULA_LSL_LSR dut (
        .A        (A),
        .B        (B),
        .seletor  (seletor),
        .resultado(resultado)
    );

    // VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ULA_LSL_LSR);
    end

    // Tarefa de impressão
    task show_vector;
        input [2:0] op;
        begin
            $display("t=%0t ns | A=%b B=%b seletor=%03b | resultado=%b esperado=%b",
                     $time, A, B, op, resultado, esperado);
        end
    endtask

    // Modelo de referência
    task calcula_esperado;
        input  [3:0] a_in;
        input  [3:0] b_in;
        input  [2:0] sel_in;
        output [3:0] exp_out;
        reg    [3:0] tmp;
        begin
            case (sel_in)
                3'b000: tmp = (a_in & b_in);
                3'b001: tmp = (a_in | b_in);
                3'b010: tmp = (~a_in);
                3'b011: tmp = ~(a_in & b_in);
                3'b100: tmp = (a_in + b_in);
                3'b101: tmp = (a_in - b_in);
                3'b110: tmp = {a_in[2:0], 1'b0};
                3'b111: tmp = {1'b0, a_in[3:1]};
                default: tmp = 4'b0000;
            endcase
            exp_out = tmp;
        end
    endtask

    // Estímulos principais
    initial begin
        erros   = 0;
        A       = 4'b0000;
        B       = 4'b0000;
        seletor = 3'b000;

        #5;

        // ---------------- Vetor 1 ----------------
        A = 4'b0101;   // 5
        B = 4'b0011;   // 3
        for (i = 0; i < 8; i = i + 1) begin
            seletor = i[2:0];    // converte índice para 3 bits
            #5;
            calcula_esperado(A, B, seletor, esperado);
            show_vector(seletor);
            if (resultado !== esperado) begin
                $display("ERRO: mismatch no vetor 1 para seletor=%03b", seletor);
                erros = erros + 1;
            end
        end

        // ---------------- Vetor 2 ----------------
        A = 4'b1101;   // 13
        B = 4'b1010;   // 10
        for (i = 0; i < 8; i = i + 1) begin
            seletor = i[2:0];
            #5;
            calcula_esperado(A, B, seletor, esperado);
            show_vector(seletor);
            if (resultado !== esperado) begin
                $display("ERRO: mismatch no vetor 2 para seletor=%03b", seletor);
                erros = erros + 1;
            end
        end

        // ---------------- Vetor 3: foco em LSL/LSR ----------------
        A = 4'b1001;   // 9
        B = 4'b0000;

        seletor = 3'b110;  // LSL
        #5;
        calcula_esperado(A, B, seletor, esperado);
        show_vector(seletor);
        if (resultado !== esperado) begin
            $display("ERRO: LSL(A) incorreto no vetor 3.");
            erros = erros + 1;
        end

        seletor = 3'b111;  // LSR
        #5;
        calcula_esperado(A, B, seletor, esperado);
        show_vector(seletor);
        if (resultado !== esperado) begin
            $display("ERRO: LSR(A) incorreto no vetor 3.");
            erros = erros + 1;
        end

        // ---------------- Relatório final ----------------
        if (erros == 0) begin
            $display("====================================================");
            $display(" Testbench tb_ULA_LSL_LSR: TODOS OS TESTES PASSARAM ");
            $display("====================================================");
        end else begin
            $display("====================================================");
            $display(" Testbench tb_ULA_LSL_LSR: %0d ERRO(S) ENCONTRADO(S)", erros);
            $display("====================================================");
        end

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
