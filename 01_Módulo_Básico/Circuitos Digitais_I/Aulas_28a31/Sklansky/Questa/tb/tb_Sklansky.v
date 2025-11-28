// ============================================================================
// Arquivo : tb_Sklansky.v  — Testbench completo (corrigido)
// Nota: Algumas ferramentas não permitem fatiar diretamente (A+B+Cin)[3:0].
//       Usamos um wire temporário 'exp' para evitar erro de sintaxe.
// ============================================================================

`timescale 1ns/1ps

module tb_Sklansky;
    // Sinais de estímulo
    reg  [3:0] A, B;
    reg        Cin;
    // Sinais de resposta do DUT
    wire [3:0] Sum;
    wire       Cout;

    // Valor esperado
    wire [4:0] exp;           // [4] = carry esperado, [3:0] = soma esperada
    assign exp = A + B + Cin; // evita usar (A+B+Cin)[i]

    // Instanciação do DUT
    Sklansky dut (
        .A   (A),
        .B   (B),
        .Cin (Cin),
        .Sum (Sum),
        .Cout(Cout)
    );

    // VCD para visualização
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_Sklansky);
    end

    // Monitor amigável
    initial begin
        $display("=== Testbench Sklansky 4-bit ===");
        $display("Tempo |   A    B   Cin  |  Sum Cout  |  Esperado");
        $monitor("%4t  | %b %b  %b   |  %b    %b   |  %b %b",
                 $time, A, B, Cin, Sum, Cout, exp[3:0], exp[4]);
    end

    // Vetores da tabela fornecida
    integer i;
    reg [3:0] vecA [0:5];
    reg [3:0] vecB [0:5];
    reg       vecCin [0:5];

    initial begin
        // Inicializa vetores
        vecA[0]=4'b1101; vecB[0]=4'b1011; vecCin[0]=1'b0;
        vecA[1]=4'b0110; vecB[1]=4'b1001; vecCin[1]=1'b0;
        vecA[2]=4'b1111; vecB[2]=4'b0001; vecCin[2]=1'b0;
        vecA[3]=4'b0101; vecB[3]=4'b0011; vecCin[3]=1'b0;
        vecA[4]=4'b1010; vecB[4]=4'b0101; vecCin[4]=1'b0;
        vecA[5]=4'b1111; vecB[5]=4'b1111; vecCin[5]=1'b1;

        // Estímulo sequencial com #delay
        for (i=0; i<6; i=i+1) begin
            A   = vecA[i];
            B   = vecB[i];
            Cin = vecCin[i];
            #10; // espera propagação
            // Checagem automática
            if ({Cout,Sum} !== exp) begin
                $display("ERRO no caso %0d: A=%b B=%b Cin=%b -> DUT=%b_%b, EXP=%b_%b",
                         i+1, A, B, Cin, Cout, Sum, exp[4], exp[3:0]);
            end else begin
                $display("OK   no caso %0d", i+1);
            end
        end

        $display("Fim da simSklanskycao.");
        $finish;
    end
endmodule
