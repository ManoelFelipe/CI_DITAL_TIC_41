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
    output reg        y
);
    always @(*) begin
        y = d[sel];
    end
endmodule
