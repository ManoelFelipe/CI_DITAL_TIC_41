// =============================================================
// Arquivo   : tb_KoggeStone.v
// Autor     : Manoel Furtado
// Data      : 10/11/2025
// Descrição : Testbench completo para o somador Kogge-Stone 4 bits.
//             - Usa tabela de vetores fornecida no enunciado
//             - Acrescenta varredura exaustiva (A,B,Cin)
//             - Gera VCD e imprime resultados formatados
// =============================================================
`timescale 1ns/1ps

module tb_KoggeStone;
    // Estímulos
    reg  [3:0] A, B;
    reg        Cin;
    // Saídas do DUT
    wire [3:0] Sum;
    wire       Cout;

    // Unidade sob teste: selecione a implementação na etapa de compilação
    // (compile.do ajusta automaticamente o arquivo de RTL usado).
    KoggeStone dut (
        .A(A), .B(B), .Cin(Cin),
        .Sum(Sum), .Cout(Cout)
    );

    // Geração do VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_KoggeStone);
    end

    // Impressão de cabeçalho
    initial begin
        $display("=== Testbench Kogge-Stone 4b ===");
        $display("Autor: Manoel Furtado | Data: 10/11/2025");
        $display(" A     B    Cin |  Sum  Cout |  Esperado ");
        $display("----------------------------------------");
    end

    // Rotina de checagem
    task check(input [3:0] a, input [3:0] b, input cin);
        reg [4:0] expected;
        begin
            A=a; B=b; Cin=cin;
            #10; // delay simples de observação
            expected = a + b + cin;
            if ({Cout,Sum} !== expected) begin
                $display("ERRO: %b %b  %b  |  %b   %b  |  %b (tempo=%0t)",
                         a,b,cin,Sum,Cout,expected,$time);
            end else begin
                $display("OK  : %b %b  %b  |  %b   %b  |  %b",
                         a,b,cin,Sum,Cout,expected);
            end
        end
    endtask

    integer i,j;

    initial begin
        // ---------------- Vetores da Tabela do enunciado (Cin=0) ----------------
        check(4'b1101, 4'b1011, 1'b0);
        check(4'b0110, 4'b1001, 1'b0);
        check(4'b1111, 4'b0001, 1'b0);
        check(4'b0101, 4'b0011, 1'b0);
        check(4'b1010, 4'b0101, 1'b0);

        // ---------------- Varredura exaustiva pequena (Cin=0 e Cin=1) -----------
        for (i=0; i<16; i=i+1) begin
            for (j=0; j<16; j=j+1) begin
                check(i[3:0], j[3:0], 1'b0);
                check(i[3:0], j[3:0], 1'b1);
            end
        end

        // Encerramento limpo
        $display("Fim da simKoggeStonecao.");
        $finish;
    end
endmodule