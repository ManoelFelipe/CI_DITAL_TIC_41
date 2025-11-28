// -----------------------------------------------------------------------------
// Projeto: Multiplexador 4x1 Parametrizável (N bits)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_4_1_N.v
// Descr. : Seleciona 1 entre 4 entradas de N bits, de acordo com 'sel'.
// -----------------------------------------------------------------------------

module multiplex_4_1_N
#(parameter N = 8)
(
    input  wire [N-1:0] d0,
    input  wire [N-1:0] d1,
    input  wire [N-1:0] d2,
    input  wire [N-1:0] d3,
    input  wire [1:0]   sel,
    output wire [N-1:0] y
);
    assign y = (sel == 2'b00) ? d0 :
               (sel == 2'b01) ? d1 :
               (sel == 2'b10) ? d2 :
                                 d3 ;
endmodule
