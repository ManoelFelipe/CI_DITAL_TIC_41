// -----------------------------------------------------------------------------
// Projeto: Multiplexador 16x1 (três descrições: comportamental, dataflow, estrutural)
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Compat.: Verilog-2001 | Quartus & Questa
// Arquivo: multiplex_16_1.v
// Descr. : Este arquivo implementa um mux 16:1 que seleciona 1 entre 16 entradas
//          de um bit cada, de acordo com 'sel' (4 bits).
// -----------------------------------------------------------------------------

// ===============================
// MÓDULO DATAFLOW (Fluxo de Dados)
// ===============================
module multiplex_16_1
(
    input  wire [15:0] d,   // [Linha 1] 16 entradas de 1 bit
    input  wire [3:0]  sel, // [Linha 2] Seleção
    output wire        y    // [Linha 3] Saída
);
    // [Linha 4] "assign" com operador condicional em cascata (?:) descrevendo o caminho de dados.
    //           É equivalente ao mux 16:1 e sintetiza como multiplexadores.
    assign y =
        (sel == 4'd0 ) ? d[0 ] :
        (sel == 4'd1 ) ? d[1 ] :
        (sel == 4'd2 ) ? d[2 ] :
        (sel == 4'd3 ) ? d[3 ] :
        (sel == 4'd4 ) ? d[4 ] :
        (sel == 4'd5 ) ? d[5 ] :
        (sel == 4'd6 ) ? d[6 ] :
        (sel == 4'd7 ) ? d[7 ] :
        (sel == 4'd8 ) ? d[8 ] :
        (sel == 4'd9 ) ? d[9 ] :
        (sel == 4'd10) ? d[10] :
        (sel == 4'd11) ? d[11] :
        (sel == 4'd12) ? d[12] :
        (sel == 4'd13) ? d[13] :
        (sel == 4'd14) ? d[14] :
                         d[15] ; // [Linha 5] Caso "default": sel==15
endmodule
