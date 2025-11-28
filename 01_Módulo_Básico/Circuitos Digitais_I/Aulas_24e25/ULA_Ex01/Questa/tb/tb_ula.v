// =============================================================
// tb_ula.v — Testbench para ULA (instancia somente a versão comportamental)
// Autor: Manoel Furtado | Data: 31/10/2025
// =============================================================
`timescale 1ns/1ps

module tb_ula;
    // Sinais de estímulo
    reg  [3:0] A;
    reg  [3:0] B;
    reg  [2:0] seletor;
    wire [3:0] resultado;

    // DUT — Device Under Test (Behavioral)
    ula dut (
        .A(A),
        .B(B),
        .seletor(seletor),
        .resultado(resultado)
    );

    // Dump VCD
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula);
    end

    // Tabela de operações para impressão amigável
    task show;
        input [2:0] s;
        begin
            case (s)
                3'b000: $display("[%0t] AND     A=%b B=%b -> R=%b", $time, A,B,resultado);
                3'b001: $display("[%0t] OR      A=%b B=%b -> R=%b", $time, A,B,resultado);
                3'b010: $display("[%0t] NOT(A)  A=%b B=%b -> R=%b", $time, A,B,resultado);
                3'b011: $display("[%0t] NAND    A=%b B=%b -> R=%b", $time, A,B,resultado);
                3'b100: $display("[%0t] SOMA    A=%b B=%b -> R=%b", $time, A,B,resultado);
                3'b101: $display("[%0t] SUB     A=%b B=%b -> R=%b", $time, A,B,resultado);
                default:$display("[%0t] DEFAULT A=%b B=%b -> R=%b", $time, A,B,resultado);
            endcase
        end
    endtask

    // Geração de estímulos
    initial begin
        // Vetor 1
        A = 4'b1010; B = 4'b0110;
        for (seletor = 0; seletor < 6; seletor = seletor + 1) begin
            #5; show(seletor);
        end
        // Vetor 2
        A = 4'b1111; B = 4'b0001;
        for (seletor = 0; seletor < 6; seletor = seletor + 1) begin
            #5; show(seletor);
        end
        // Vetor 3 (caso com carry/borrow, mas saída é truncada)
        A = 4'b0011; B = 4'b1101;
        for (seletor = 0; seletor < 6; seletor = seletor + 1) begin
            #5; show(seletor);
        end

        // Encerramento limpo
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
