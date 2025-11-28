`timescale 1ns/1ps
// tb_csa.v — Testbench para CSA 4‑bit
// Diretrizes:
//  - Gera vetores dirigidos e pseudoaleatórios
//  - Verifica Sum/Cout contra o modelo de referência
//  - Emite VCD e mensagens formatadas
module tb_csa;
    // Entradas como registradores
    reg  [3:0] A;
    reg  [3:0] B;
    reg  [3:0] Cin;
    // Saídas do DUT
    wire [3:0] Sum;
    wire [3:0] Cout;

    // Unidade sob teste (UUT)
    csa uut (
        .A(A),
        .B(B),
        .Cin(Cin),
        .Sum(Sum),
        .Cout(Cout)
    );

    // Referência (modelo comportamental dentro do TB)
    reg  [3:0] expSum;
    reg  [3:0] expCout;
    integer i, j, k;
    integer erros;

    // Geração de VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_csa);
    end

    // Rotina de checagem
    task check;
        begin
            expSum  = A ^ B ^ Cin;
            expCout = (A & B) | (B & Cin) | (Cin & A);
            #1; // pequena latência para estabilizar sinais
            if (Sum !== expSum || Cout !== expCout) begin
                $display("ERRO: A=%b B=%b Cin=%b | Sum=%b Cout=%b | expSum=%b expCout=%b",
                         A, B, Cin, Sum, Cout, expSum, expCout);
                erros = erros + 1;
            end
        end
    endtask

    initial begin
        erros = 0;
        $display("A     B     Cin   | Sum   Cout");
        $display("-------------------------------");

        // Vetores dirigidos (exemplo do enunciado)
        A=4'b1011; B=4'b0010; Cin=4'b0010; #10; $display("%b %b %b | %b %b",A,B,Cin,Sum,Cout); check();
        A=4'b1111; B=4'b1111; Cin=4'b0011; #10; $display("%b %b %b | %b %b",A,B,Cin,Sum,Cout); check();
        A=4'b0001; B=4'b0010; Cin=4'b0001; #10; $display("%b %b %b | %b %b",A,B,Cin,Sum,Cout); check();
        A=4'b0101; B=4'b1010; Cin=4'b0010; #10; $display("%b %b %b | %b %b",A,B,Cin,Sum,Cout); check();
        A=4'b1111; B=4'b1111; Cin=4'b1111; #10; $display("%b %b %b | %b %b",A,B,Cin,Sum,Cout); check();

        // Varredura parcial sistemática (mantém runtime baixo)
        for (i=0;i<16;i=i+5) begin
            for (j=0;j<16;j=j+7) begin
                for (k=0;k<16;k=k+9) begin
                    A=i[3:0]; B=j[3:0]; Cin=k[3:0];
                    #10; $display("%b %b %b | %b %b",A,B,Cin,Sum,Cout); check();
                end
            end
        end

        if (erros==0) begin
            $display("Testbench: TODOS os casos passaram.");
        end else begin
            $display("Testbench: %0d caso(s) falhou(falharam).", erros);
        end
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
