// -----------------------------------------------------------------------------
// Projeto: Multiplexador 8x1 (três descrições: comportamental, dataflow, estrutural)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_8_1.v
// Descr. : Seleciona 1 entre 8 entradas de 1 bit, de acordo com 'sel' (3 bits).
// -----------------------------------------------------------------------------

module multiplex_8_1
(
    input  wire [7:0] d,
    input  wire [2:0] sel,
    output wire       y
);
    assign y =
        (sel == 3'd0) ? d[0] :
        (sel == 3'd1) ? d[1] :
        (sel == 3'd2) ? d[2] :
        (sel == 3'd3) ? d[3] :
        (sel == 3'd4) ? d[4] :
        (sel == 3'd5) ? d[5] :
        (sel == 3'd6) ? d[6] :
                         d[7] ;
endmodule
