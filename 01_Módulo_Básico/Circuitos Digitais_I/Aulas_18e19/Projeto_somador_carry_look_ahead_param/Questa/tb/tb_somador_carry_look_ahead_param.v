// ============================================================================
// Arquivo  : tb_somador_carry_look_ahead_param.v
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench self-checking com varredura exaustiva para N<=5 e
//            sequência pseudoaleatória para N>5. Gera wave.vcd e imprime
//            flag de sucesso/erros.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps
`default_nettype none
module tb_somador_carry_look_ahead_param;
    localparam integer N = 8;
    reg  [N-1:0] a, b;
    reg          c_in;
    wire [N-1:0] s;
    wire         c_out;

    somador_carry_look_ahead_param #(.N(N)) dut(.a(a), .b(b), .c_in(c_in), .s(s), .c_out(c_out));

    integer i, errors; reg [N:0] golden;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_somador_carry_look_ahead_param);
    end

    initial begin
        errors = 0;

        if (N <= 5) begin
            for (i = 0; i < (1<<(2*N+1)); i = i + 1) begin
                {c_in, a, b} = i[2*N:0];
                #1; golden = a + b + c_in;
                if ({c_out, s} !== golden) begin
                    $display("[ERRO] t=%0t A=%0h B=%0h Cin=%0b -> got {%0b,%0h} exp %0h",
                             $time, a, b, c_in, c_out, s, golden);
                    errors = errors + 1;
                end
                #9;
            end
        end else begin
            a=0; b=0; c_in=0; #10;
            a={N{1'b1}}; b='h01; c_in=0; #10;
            a={N{1'b1}}; b={N{1'b1}}; c_in=0; #10;
            a='hA5; b='h5A; c_in=1'b0; #10;
            for (i=0;i<500;i=i+1) begin
                a = $random; b = $random; c_in = $random;
                #1; golden = a + b + c_in;
                if ({c_out, s} !== golden) begin
                    $display("[ERRO] t=%0t A=%0h B=%0h Cin=%0b -> got {%0b,%0h} exp %0h",
                             $time, a, b, c_in, c_out, s, golden);
                    errors = errors + 1;
                end
                #9;
            end
        end

        if (errors==0) $display(">> TESTE OK");
        else           $display(">> TESTE FALHOU: %0d erro(s)", errors);
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
`default_nettype wire
