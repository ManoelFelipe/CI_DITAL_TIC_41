
// ============================================================================
// tb_ULA_74181.v — Testbench automático
// Autor: Manoel Furtado   |   Data: 31/10/2025
// ============================================================================
`timescale 1ns/1ps

module tb_ULA_74181;

    // DUT I/O
    reg  [3:0] A, B;
    reg        M;
    reg  [3:0] S;
    reg        Cn;
    wire [3:0] F;
    wire       Cn4, G, T, AeqB;

    // Instanciação: a mesma interface serve para os três estilos
    ULA_74181 dut (
        .A(A), .B(B), .M(M), .S(S), .Cn(Cn),
        .F(F), .Cn4(Cn4), .G(G), .T(T), .AeqB(AeqB)
    );

    // Geração de VCD (Gtkwave)
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ULA_74181);
    end

    // Estímulos
    integer i;
    initial begin
        $display("==== Início da simulação ULA_74181 ====");

        // Vetores básicos
        A  = 4'hA; // 1010
        B  = 4'h6; // 0110

        // Modo lógico: varre S
        M  = 1'b1;
        Cn = 1'b0;
        for (i = 0; i < 16; i = i + 1) begin
            S = i[3:0];
            #5;
            $display("[LOGIC] S=%0h A=%0h B=%0h -> F=%0h | AeqB=%0b", S, A, B, F, AeqB);
        end

        // Modo aritmético: varre S e Cn
        M = 1'b0;
        A = 4'h9; B = 4'h3; // 1001 e 0011

        for (Cn = 0; Cn <= 1; Cn = Cn + 1) begin
            for (i = 0; i < 16; i = i + 1) begin
                S = i[3:0];
                #5;
                $display("[ARIT] Cn=%0b S=%0h  A=%0h B=%0h -> F=%0h Cn4=%0b (G=%0b T=%0b) AeqB=%0b",
                         Cn, S, A, B, F, Cn4, G, T, AeqB);
            end
        end

        // Casos extras (comparação)
        M = 1'b1; S = 4'h6; A = 4'hC; B = 4'hC; #5; // XOR quando A==B => 0, AeqB=1
        $display("[CHK] XOR com A==B: F=%0h AeqB=%0b", F, AeqB);

        $display("Fim da simULA_74181cao.");
        $finish;
    end

endmodule
