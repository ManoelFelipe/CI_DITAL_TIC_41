// -----------------------------------------------------------------------------
// Projeto: Multiplexador 8x1 (três descrições: comportamental, dataflow, estrutural)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_8_1.v
// Descr. : Seleciona 1 entre 8 entradas de 1 bit, de acordo com 'sel' (3 bits).
// -----------------------------------------------------------------------------

module mux2(input wire a, input wire b, input wire s, output wire y);
    assign y = s ? b : a;
endmodule

module mux4_1(input wire [3:0] d, input wire [1:0] sel, output wire y);
    wire lo, hi;
    mux2 m0(d[0], d[1], sel[0], lo);
    mux2 m1(d[2], d[3], sel[0], hi);
    mux2 m2(lo, hi, sel[1], y);
endmodule

module multiplex_8_1(input wire [7:0] d, input wire [2:0] sel, output wire y);
    wire y_lo, y_hi;
    mux4_1 m_lo(.d(d[3:0]), .sel(sel[1:0]), .y(y_lo));
    mux4_1 m_hi(.d(d[7:4]), .sel(sel[1:0]), .y(y_hi));
    mux2   m_top(.a(y_lo), .b(y_hi), .s(sel[2]), .y(y));
endmodule
