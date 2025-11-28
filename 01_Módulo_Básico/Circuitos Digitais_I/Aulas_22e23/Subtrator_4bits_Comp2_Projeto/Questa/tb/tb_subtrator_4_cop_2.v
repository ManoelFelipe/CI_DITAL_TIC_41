`timescale 1ns/1ps
// tb_subtrator_4_cop_2.v — Testbench para o subtrator de 4 bits (complemento de 2)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Requisitos: Geração de VCD, impressão formatada e simulação automática.

module tb_subtrator_4_cop_2;
    // Estímulos
    reg  [3:0] A;
    reg  [3:0] B;

    // Saídas do DUT
    wire [3:0] diff_b, diff_d, diff_s;
    wire       borrow_b, borrow_d, borrow_s;

    // Instâncias DUT — três implementações para comparar
    subtrator_4_cop_2 DUT_behavioral (.A(A), .B(B), .diff(diff_b), .borrow(borrow_b));
    subtrator_4_cop_2 DUT_dataflow   (.A(A), .B(B), .diff(diff_d), .borrow(borrow_d));
    subtrator_4_cop_2 DUT_structural (.A(A), .B(B), .diff(diff_s), .borrow(borrow_s));

    // Gerar VCD para inspeção no GTKWave/Questa
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_subtrator_4_cop_2);
    end

    // Processo de varredura automática
    integer ia, ib;
    reg [4:0] soma_ext;
    reg [3:0] exp_diff;
    reg       exp_borrow;

    initial begin
        $display("==== Iniciando simulacao do subtrator 4 bits (C2) ====");
        // Varre todos os pares (A,B) em 4 bits
        for (ia = 0; ia < 16; ia = ia + 1) begin
            for (ib = 0; ib < 16; ib = ib + 1) begin
                A = ia[3:0];
                B = ib[3:0];
                // Valor esperado usando a mesma lógica de referência
                soma_ext  = {1'b0, A} + {1'b0, (~B) + 4'b0001};
                exp_diff  = soma_ext[3:0];
                exp_borrow= ~soma_ext[4];

                #5; // tempo para propagação

                // Log formatado
                $display("A=%0d (0x%0h)  B=%0d (0x%0h)  | diff_b=%0d diff_d=%0d diff_s=%0d  | borrow(b,d,s)=%b,%b,%b  | exp=%0d borrow_exp=%b",
                         A, A, B, B, diff_b, diff_d, diff_s, borrow_b, borrow_d, borrow_s, exp_diff, exp_borrow);

                // Checagens simples
                if (diff_b !== exp_diff || diff_d !== exp_diff || diff_s !== exp_diff ||
                    borrow_b !== exp_borrow || borrow_d !== exp_borrow || borrow_s !== exp_borrow) begin
                    $display("** ERRO: Divergencia detectada em A=%0d B=%0d", A, B);
                end

                #5;
            end
        end

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
