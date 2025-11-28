// ============================================================================
// Arquivo  : tb_carry_look_ahead_adder_4b.v
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Questa (Verilog 2001)
// Descrição: Testbench automatizado para o somador CLA de 4 bits. Gera
//            varredura exaustiva (A,B in 0..15, C_in em 0..1) e checa
//            automaticamente os resultados, emitindo relatório final e VCD.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_carry_look_ahead_adder_4b;
    // Entradas dirigidas ao DUT
    reg  [3:0] a;
    reg  [3:0] b;
    reg        c_in;
    // Saídas observadas do DUT
    wire [3:0] sum;
    wire       c_out;

    // ------------------------- Instância do DUT -----------------------------
    // O script compile.do escolhe qual implementação será compilada.
    carry_look_ahead_adder_4b dut (
        .a(a),
        .b(b),
        .c_in(c_in),
        .sum(sum),
        .c_out(c_out)
    );

    // ------------------------ Infra de VCD/monitor --------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_carry_look_ahead_adder_4b);
    end

    integer i, j, errors;
    reg [4:0] ref;  // {cout,sum} referência com 5 bits

    initial begin
        errors = 0;
        // Casos dirigidos do enunciado
        a=4'b1011; b=4'b1101; c_in=1'b0; #5; check_case;
        a=4'b0101; b=4'b0011; c_in=1'b0; #5; check_case;
        a=4'b1001; b=4'b0110; c_in=1'b1; #5; check_case;
        a=4'b1111; b=4'b1111; c_in=1'b0; #5; check_case;

        // Varredura exaustiva 0..15 x 0..15 x Cin
        for (i=0; i<16; i=i+1) begin
            for (j=0; j<16; j=j+1) begin
                a = i[3:0];
                b = j[3:0];
                c_in = 1'b0; #1; check_case;
                c_in = 1'b1; #1; check_case;
            end
        end

        if (errors==0) begin
            $display("SUCESSO: 512 casos validados sem erros.");
        end else begin
            $display("FALHAS: %0d casos apresentaram divergencia.", errors);
        end

        $display("Fim da simulacao.");
        $finish;
    end

    task check_case;
        begin
            ref = a + b + c_in; // Cálculo de referência em inteiro (5 bits)
            if ({c_out, sum} !== ref[4:0]) begin
                errors = errors + 1;
                $display("ERRO t=%0t | A=%b B=%b Cin=%b -> DUT={Cout=%b Sum=%b} REF=%b",
                         $time, a, b, c_in, c_out, sum, ref);
            end
        end
    endtask
endmodule
