// ===============================================================
//  tb_ula_8.v — Testbench da ULA de 8 bits
// ===============================================================
`timescale 1ns/1ps

module tb_ula_8;
    reg  [7:0] A, B;
    reg        carry_in;
    reg  [2:0] seletor;
    wire [7:0] resultado;
    wire       carry_out;
    wire       P_msb, G_msb;

    ula_8 dut (
        .A(A), .B(B), .carry_in(carry_in), .seletor(seletor),
        .resultado(resultado), .carry_out(carry_out),
        .P_msb(P_msb), .G_msb(G_msb)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ula_8);
    end

    task show_hdr;
        begin
            $display("\nTIME  sel  A     B     Cin |  R      Cout | P7 G7");
            $display("-----------------------------------------------------");
        end
    endtask

    function [8:0] ref_add;
        input [7:0] a, b;
        input       cin;
        begin
            ref_add = a + b + cin;
        end
    endfunction

    integer i;
    reg [8:0] ref;

    initial begin
        show_hdr();
        A = 8'h00; B = 8'h00; carry_in = 1'b0; seletor = 3'b000; #5;

        for (i=0; i<8; i=i+1) begin
            A = $random; B = $random; carry_in = i[0];
            seletor = 3'b000; #1;
            ref = ref_add(A,B,carry_in);
            $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                      $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);
            if ({carry_out,resultado} !== ref) begin
                $display("  -> ERRO soma: esperado 0x%03h", ref);
            end
            #9;
        end

        seletor = 3'b001; A=8'h55; B=8'h0F; carry_in=1'b0; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        seletor = 3'b010; A=8'hAA; B=8'h0F; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        seletor = 3'b011; A=8'hAA; B=8'h0F; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        seletor = 3'b100; A=8'hF0; B=8'h0F; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        seletor = 3'b101; A=8'h0C; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        seletor = 3'b110; A=8'hFF; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        seletor = 3'b111; A=8'h00; B=8'hA5; #10;
        $display("%4t  %b  0x%02h 0x%02h  %b  |  0x%02h   %b    |  %b  %b",
                  $time, seletor, A, B, carry_in, resultado, carry_out, P_msb, G_msb);

        $display("Fim da simula_8cao.");
        $finish;
    end
endmodule
