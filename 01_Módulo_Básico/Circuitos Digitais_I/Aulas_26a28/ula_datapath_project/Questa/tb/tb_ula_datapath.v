
// ============================================================================
// Testbench: tb_ula_datapath
// Autor    : Manoel Furtado
// Data     : 31/10/2025
// ============================================================================
`timescale 1ns/1ps

module tb_ula_datapath;
    reg  [3:0] dados;
    reg        sel21;
    reg        sel12;
    reg        clk;
    reg        reset;
    reg  [2:0] operacao;

    wire [3:0] resultado;
    wire       carry_out;

    ula_datapath DUT (
        .dados(dados),
        .sel21(sel21),
        .sel12(sel12),
        .clk(clk),
        .reset(reset),
        .operacao(operacao),
        .resultado(resultado),
        .carry_out(carry_out)
    );

    // Clock 10ns
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula_datapath);
    end

    // Estímulos
    initial begin
        $display("==== Iniciando simulacao do ULA_DATAPATH ====");

        // Reset
        dados = 4'h0; sel21 = 1'b0; sel12 = 1'b0; operacao = 3'b000;
        reset = 1'b1; @(posedge clk);
        reset = 1'b0; @(posedge clk);

        // Carrega DADOS no registrador (sel21=0)
        dados = 4'h5; sel21 = 1'b0; sel12 = 1'b0;
        @(posedge clk);
        $display("[t=%0t] Carregado 0x%0h no reg; A recebe, B=0", $time, dados);

        // Direciona o mesmo valor para B
        sel12 = 1'b1; @(posedge clk);
        $display("[t=%0t] Demux direcionou reg->B; A=0, B=valor_reg", $time);

        // A+B
        operacao = 3'b000; #1;
        $display("[t=%0t] ADD: resultado=0x%0h carry=%0b", $time, resultado, carry_out);

        // Feedback do resultado para o registrador
        sel21 = 1'b1; @(posedge clk);
        $display("[t=%0t] Feedback: resultado armazenado no reg", $time);

        // INC A
        sel12 = 1'b0; operacao = 3'b110; #1;
        $display("[t=%0t] INC A: resultado=0x%0h carry=%0b", $time, resultado, carry_out);

        // Operações lógicas: carrega novo valor externo -> reg -> B
        sel21 = 1'b0; dados = 4'h3; @(posedge clk);
        sel12 = 1'b1; #1;
        operacao = 3'b010; #1 $display("[t=%0t] AND: 0x%0h", $time, resultado);
        operacao = 3'b011; #1 $display("[t=%0t] OR : 0x%0h", $time, resultado);
        operacao = 3'b100; #1 $display("[t=%0t] XOR: 0x%0h", $time, resultado);

        // SUB
        operacao = 3'b001; #1 $display("[t=%0t] SUB: 0x%0h carry(no-borrow)=%0b", $time, resultado, carry_out);

        #20;
        $display("Fim da simula_datapathcao.");
        $finish;
    end
endmodule
