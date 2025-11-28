// ============================================================================
// tb_csa_parameterized.v — Testbench
// Autor: Manoel Furtado
// Data: 10/11/2025
// Objetivo: Verificar o CSA parametrizado em três aspectos:
//  1) Função por bit: Sum[i]=A^B^Cin, Cout[i]=majoritário(A,B,Cin).
//  2) Invariância de carry-save: A+B+Cin == Sum + (Cout << 1).
//  3) Parametrização: testar diferentes larguras.
// ============================================================================
`timescale 1ns/1ps

module tb_csa_parameterized;
    // ---------- Parâmetro principal (pode ser sobrescrito via +define+ ou vlog) -----
    parameter integer WIDTH = 4;

    // ---------- Sinais de estímulo e observação -------------------------------------
    reg  [WIDTH-1:0] A;
    reg  [WIDTH-1:0] B;
    reg  [WIDTH-1:0] Cin;
    wire [WIDTH-1:0] Sum;
    wire [WIDTH-1:0] Cout;

    // ---------- DUT: selecione a pasta correspondente no compile.do -----------------
    csa_parameterized #(.WIDTH(WIDTH)) dut (
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum), .Cout(Cout)
    );

    // ---------- Variáveis auxiliares para checagem ----------------------------------
    integer i;
    reg success;
    reg [WIDTH:0] expected_bitwise; // não usado diretamente, apenas referência
    reg [WIDTH:0] recomposed;       // Sum + (Cout << 1)
    reg [WIDTH:0] gold;             // A + B + Cin (soma aritmética)

    // ---------- Estímulos ------------------------------------------------------------
    initial begin
        $display("===============================================================");
        $display(" Testbench: CSA parametrizado  WIDTH=%0d", WIDTH);
        $display(" Autor: Manoel Furtado   Data: 10/11/2025");
        $display("===============================================================");
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_csa_parameterized);

        // Cabeçalho de impressão
        $display("      A        B       Cin   |    Sum     Cout   |  Recompose  Gold ");
        $display("---------------------------------------------------------------------");

        success = 1'b1;

        // ---------- Casos dirigidos -------------------------------------------------
        // Vetores de exemplo (do enunciado/imagens) e adicionais
        A   = 'b1011;  B = 'b1101;  Cin = 'b0110; #10;
        print_and_check();

        A   = 'b1111;  B = 'b1111;  Cin = 'b0111; #10;
        print_and_check();

        A   = 'b0001;  B = 'b0010;  Cin = 'b0001; #10;
        print_and_check();

        A   = 'b0101;  B = 'b0110;  Cin = 'b0110; #10;
        print_and_check();

        A   = 'b1111;  B = 'b1111;  Cin = 'b1111; #10;
        print_and_check();

        // ---------- Varredura parcial/aleatória ------------------------------------
        // Alguns padrões pseudo-aleatórios para aumentar cobertura
        for (i = 0; i < 20; i = i + 1) begin
            A   = $random;
            B   = $random;
            Cin = $random;
            #10;
            print_and_check();
        end

        // ---------- Resultados ------------------------------------------------------
        if (success) begin
            $display(">>> Teste final: SUCESSO. Todas as asserções passaram.");
        end else begin
            $display(">>> Teste final: FALHAS detectadas. Verifique mensagens acima.");
        end
        $display("Fim da simcsa_parameterizedcao.");
        $finish;
    end

    // ---------- Tarefa de impressão/checagem ---------------------------------------
    task print_and_check;
        begin
            // Recombinação carry-save
            recomposed = {1'b0, Sum} + ({1'b0, Cout} << 1);
            gold       = {1'b0, A} + {1'b0, B} + {1'b0, Cin};

            // Impressão formatada
            $display("%b  %b  %b  |  %b   %b  |   %b     %b",
                     A, B, Cin, Sum, Cout, recomposed, gold);

            // Checagem 1: identidade carry-save
            if (recomposed !== gold) begin
                $display("ERRO[CS-ID]: A+B+Cin != Sum + (Cout<<1).");
                success = 1'b0;
            end

            // Checagem 2: bitwise (somente para diagnóstico)
            if (Sum !== (A ^ B ^ Cin)) begin
                $display("ERRO[SUM]: Sum diferente de XOR bit a bit.");
                success = 1'b0;
            end
            if (Cout !== ((A & B) | (B & Cin) | (A & Cin))) begin
                $display("ERRO[COUT]: Cout diferente da função majoritária.");
                success = 1'b0;
            end
        end
    endtask
endmodule
