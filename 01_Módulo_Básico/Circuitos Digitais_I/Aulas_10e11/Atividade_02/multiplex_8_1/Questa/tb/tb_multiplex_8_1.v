
`timescale 1ns/1ps
module tb_multiplex_8_1;
    reg  [7:0] d;
    reg  [2:0] sel;
    wire y;
    wire y_ref = d[sel];

    multiplex_8_1 DUT(.d(d), .sel(sel), .y(y));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_multiplex_8_1);
    end

    integer i;
    initial begin
        $display(" tempo  sel  d[7:0]   | y y_ref OK");
        d = 8'b1011_0010; sel = 0; #1;
        for (i=0; i<8; i=i+1) begin sel = i[2:0]; #5;
            $display("%5t   %0d   %b | %0d  %0d  %s",
                $time, sel, d, y, y_ref, (y===y_ref)?"OK":"ERRO");
        end
        d = 8'hA5; #5;
        for (i=0; i<8; i=i+1) begin sel = i[2:0]; #5;
            $display("%5t   %0d   %b | %0d  %0d  %s",
                $time, sel, d, y, y_ref, (y===y_ref)?"OK":"ERRO");
        end
        sel = 3'd6; d = 8'b0000_0001;
        repeat (8) begin #5;
            $display("%5t   %0d   %b | %0d  %0d  %s",
                $time, sel, d, y, y_ref, (y===y_ref)?"OK":"ERRO");
            d = {d[6:0], d[7]};
        end
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
