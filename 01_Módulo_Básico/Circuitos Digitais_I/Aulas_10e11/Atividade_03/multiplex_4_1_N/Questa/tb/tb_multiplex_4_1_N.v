
`timescale 1ns/1ps
module tb_multiplex_4_1_N;
    localparam N = 3;

    reg  [N-1:0] d0, d1, d2, d3;
    reg  [1:0]   sel;
    wire [N-1:0] y;

    wire [N-1:0] y_ref = (sel==2'b00)?d0:(sel==2'b01)?d1:(sel==2'b10)?d2:d3;

    multiplex_4_1_N #(.N(N)) DUT (.d0(d0), .d1(d1), .d2(d2), .d3(d3), .sel(sel), .y(y));

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_multiplex_4_1_N);
    end

    integer i;
    initial begin
        $display(" tempo   sel   d0 d1 d2 d3  |  y  y_ref  OK");
        d0=3'b001; d1=3'b010; d2=3'b101; d3=3'b111;
        for (i=0;i<4;i=i+1) begin sel=i[1:0]; #5;
            $display("%5t   %02b   %03b %03b %03b %03b  |  %03b  %03b   %s",
                $time, sel, d0, d1, d2, d3, y, y_ref, (y===y_ref)? "OK":"ERRO");
        end
        d0=3'b000; d1=3'b100; d2=3'b011; d3=3'b110;
        for (i=0;i<4;i=i+1) begin sel=i[1:0]; #5;
            $display("%5t   %02b   %03b %03b %03b %03b  |  %03b  %03b   %s",
                $time, sel, d0, d1, d2, d3, y, y_ref, (y===y_ref)? "OK":"ERRO");
        end
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
