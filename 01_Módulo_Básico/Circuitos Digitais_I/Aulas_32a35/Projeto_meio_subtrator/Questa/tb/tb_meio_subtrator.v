//==============================================================================
// tb_meio_subtrator.v — Testbench completo
//------------------------------------------------------------------------------
// Objetivo: Exercitar EXAUSTIVAMENTE as entradas (a,b) do meio subtrator para
//           as três abordagens (behavioral, dataflow, structural).
// Estratégia:
//   1) Gerar todos os pares possíveis (a,b) ∈ {0,1} x {0,1};
//   2) Conectar as MESMAS entradas aos três módulos;
//   3) Comparar cada saída com o modelo de referência dentro do TB;
//   4) Exibir uma tabela de resultados e encerrar limpo.
//==============================================================================
`timescale 1ns/1ps

module tb_meio_subtrator;

    // ---------------- Sinais de estímulo ----------------
    reg  a;  // minuendo
    reg  b;  // subtraendo

    // -------------- Sinais das saídas (3 DUTs) ----------
    wire diff_beh, borrow_beh;   // behavioral
    wire diff_dat, borrow_dat;   // dataflow
    wire diff_str, borrow_str;   // structural

    // ----------- Modelo de referência (TB) --------------
    wire exp_diff   = a ^ b;      // equações de ouro
    wire exp_borrow = (~a) & b;

    // --------------- Instâncias dos DUTs ----------------
    meio_subtrator DUT_BEH (
        .a(a), .b(b),
        .diff(diff_beh),
        .borrow(borrow_beh)
    );

    meio_subtrator DUT_DAT (
        .a(a), .b(b),
        .diff(diff_dat),
        .borrow(borrow_dat)
    );

    meio_subtrator DUT_STR (
        .a(a), .b(b),
        .diff(diff_str),
        .borrow(borrow_str)
    );

    // ----------------- Geração de VCD --------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_meio_subtrator);
    end

    // ----------------- Estímulos -------------------------
    integer i;
    initial begin
        $display("========================================================");
        $display(" Tabela – Meio Subtrator (a,b) -> diff, borrow");
        $display("    a b | BEH  | DAT  | STR  | REF");
        $display("--------------------------------------------------------");

        // Varremos todas as combinações de a,b (00,01,10,11)
        for (i = 0; i < 4; i = i + 1) begin
            {a,b} = i[1:0];  // atribuição por concatenação
            #5;              // tempo para propagação
            $display("    %0d %0d | %0d,%0d | %0d,%0d | %0d,%0d | %0d,%0d",
                     a, b,
                     diff_beh, borrow_beh,
                     diff_dat, borrow_dat,
                     diff_str, borrow_str,
                     exp_diff, exp_borrow);

            // Checagens automáticas (assert-like)
            if ((diff_beh !== exp_diff)   || (borrow_beh !== exp_borrow)) $display("ERRO BEH em a=%0d b=%0d", a, b);
            if ((diff_dat !== exp_diff)   || (borrow_dat !== exp_borrow)) $display("ERRO DAT em a=%0d b=%0d", a, b);
            if ((diff_str !== exp_diff)   || (borrow_str !== exp_borrow)) $display("ERRO STR em a=%0d b=%0d", a, b);
        end

        $display("--------------------------------------------------------");
        $display("Fim da simulacao.");
        $finish;
    end

endmodule
