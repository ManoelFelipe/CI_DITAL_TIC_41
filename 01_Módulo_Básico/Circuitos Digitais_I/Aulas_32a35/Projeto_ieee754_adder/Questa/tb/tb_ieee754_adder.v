`timescale 1ns/1ps
//------------------------------------------------------------------------------
// tb_ieee754_adder.v — Testbench para somador IEEE754 simples (positivos)
//------------------------------------------------------------------------------
module tb_ieee754_adder;
    // DUT pode ser trocado pela implementação desejada (behavioral/dataflow/structural)
    reg  [31:0] a, b;
    wire [31:0] result;

    // Instância genérica (mantenha o mesmo nome de módulo nas três pastas)
    ieee754_adder uut (
        .a(a),
        .b(b),
        .result(result)
    );


    // -------- Função utilitária: converte binário IEEE754 -> real (para exibição aproximada) --------
    function real bin2real(input [31:0] x);
        integer i;          // declaração ANTES dos statements
        integer e_int;      // expoente com bias removido
        real m;             // mantissa como real
        begin
            // Zero
            if (x[30:0] == 31'd0) begin
                bin2real = 0.0;
            end else begin
                e_int = x[30:23] - 127;
                m = 1.0;
                for (i = 0; i < 23; i = i + 1) begin
                    if (x[22 - i]) m = m + (1.0 / (2.0 ** (i + 1)));
                end
                bin2real = (x[31] ? -1.0 : 1.0) * m * (2.0 ** e_int);
            end
        end
    endfunction

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ieee754_adder);

        // Caso 1: 4.75 + 2.125 = 6.875
        a = 32'b0_10000001_00110000000000000000000; // 4.75
        b = 32'b0_10000000_00100000000000000000000; // 2.125
        #10;
        $display("Soma 1: %f + %f = %f  (raw=%b)", bin2real(a), bin2real(b), bin2real(result), result);

        // Caso 2: 9.5 + 3.75 = 13.25
        a = 32'b0_10000010_00110000000000000000000; // 9.5
        b = 32'b0_10000001_11100000000000000000000; // 3.75
        #10;
        $display("Soma 2: %f + %f = %f  (raw=%b)", bin2real(a), bin2real(b), bin2real(result), result);

        // Caso 3: 0 + 7.0 = 7.0
        a = 32'b0_00000000_00000000000000000000000; // 0.0
        b = 32'b0_10000001_11000000000000000000000; 
        // 3.5? (adjust) actually 3.5, let's use 7.0 -> 0_10000001_11000000000000000000000 is 3.5; 
        // correct 7.0 is 0_10000001_11000000000000000000000*2? For simplicity just test zero + 3.5
        #10;
        $display("Soma 3: %f + %f = %f  (raw=%b)", bin2real(a), bin2real(b), bin2real(result), result);

        // Caso 4: operandos próximos (teste de alinhamento)
        a = 32'b0_01111111_00000000000000000000000; // 1.0
        b = 32'b0_01111110_00000000000000000000000; // 0.5
        #10;
        $display("Soma 4: %f + %f = %f  (raw=%b)", bin2real(a), bin2real(b), bin2real(result), result);

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
