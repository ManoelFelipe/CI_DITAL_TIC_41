// tb_BrentKungAdder8.v — Testbench completo
// Autor: Manoel Furtado
// Data : 10/11/2025
`timescale 1ns/1ps
`default_nettype none

module tb_BrentKungAdder8;
    // Estímulos
    reg  [7:0] A;
    reg  [7:0] B;
    reg        Cin;
    // Respostas
    wire [7:0] Sum;
    wire       Cout;

    // UUT — o compile.do seleciona QUAL implementação compilar
    BrentKungAdder8 uut (
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum), .Cout(Cout)
    );

    // Geração de VCD para GTKWave
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_BrentKungAdder8);
    end

    // Monitoramento formatado
    initial begin
        $display("   Tempo   |           Entradas           |        Saídas");
        $display("-----------+------------------------------+-------------------");
        $display("   t(ns)   |      A       B    Cin        |   Cout     Sum");
        $monitor("%8t | %b %b  %b |    %b   %b",
                 $time, A, B, Cin, Cout, Sum);
    end

    // Bateria de testes (inclui os casos da Tabela do enunciado)
    integer i,j;
    reg [8:0] expected;
    initial begin
        // Casos específicos sugeridos (Tabela 1 do enunciado):
        A=8'b00001101; B=8'b10110000; Cin=1'b0; #10;
        A=8'b00000110; B=8'b10011001; Cin=1'b0; #10;
        A=8'b11111111; B=8'b11111111; Cin=1'b1; #10;
        A=8'b11000101; B=8'b11110011; Cin=1'b0; #10;
        A=8'b01111010; B=8'b10100101; Cin=1'b1; #10;

        // Varredura automática (amostragem pseudo‑exaustiva)
        for (i=0; i<16; i=i+1) begin
            for (j=0; j<16; j=j+1) begin
                A   = {4'b0000, i[3:0]};
                B   = {4'b0000, j[3:0]};
                Cin = (i^j) & 1'b1;
                #5;
                expected = A + B + Cin;
                if ({{Cout,Sum}} !== expected) begin
                    $display("ERRO: A=%b B=%b Cin=%b => Sum=%b Cout=%b (esperado=%b)",
                              A,B,Cin,Sum,Cout,expected);
                end
                #5;
            end
        end

        $display("Fim da simBrentKungAdder8cao.");
        $finish;
    end
endmodule

`default_nettype wire
