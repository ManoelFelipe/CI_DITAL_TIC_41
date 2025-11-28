// -----------------------------------------------------------------------------
// Projeto: Multiplexador 4x1 Parametrizável (N bits)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_4_1_N.v
// Descr. : Seleciona 1 entre 4 entradas de N bits, de acordo com 'sel'.
// -----------------------------------------------------------------------------

module mux2_N
#(parameter N = 8)
(
    input  wire [N-1:0] a, b,
    input  wire         s,
    output wire [N-1:0] y
);
    assign y = s ? b : a;
endmodule

module multiplex_4_1_N
#(parameter N = 8)
(
    input  wire [N-1:0] d0, d1, d2, d3,
    input  wire [1:0]   sel,
    output wire [N-1:0] y
);
    wire [N-1:0] y_lo, y_hi;
    mux2_N #(.N(N)) m0(.a(d0), .b(d1), .s(sel[0]), .y(y_lo));
    mux2_N #(.N(N)) m1(.a(d2), .b(d3), .s(sel[0]), .y(y_hi));
    mux2_N #(.N(N)) m2(.a(y_lo), .b(y_hi), .s(sel[1]), .y(y));
endmodule
