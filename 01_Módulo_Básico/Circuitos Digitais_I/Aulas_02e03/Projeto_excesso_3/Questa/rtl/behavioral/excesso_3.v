// ============================================================================
// Arquivo  : excesso_3.v  (implementacao Behavioral)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: Conversor combinacional de codigo BCD 8421 (4 bits) para
//            representacao em Excesso-3. Bloco puramente combinacional,
//            sem registradores, adequado para sintese em FPGAs ou ASICs.
//            Implementacao na abordagem Behavioral com mesma interface
//            externa entre as versoes para facilitar reutilizacao e testes.
// Revisao   : v1.0 — criacao inicial
// ============================================================================

// Conversor BCD 8421 -> Excesso-3
// Implementacao puramente comportamental usando instrucao case

`timescale 1ns/1ps

module excesso_3_behavioral (
    input  wire [3:0] bcd_in,      // Entrada BCD 8421 (A B C D)
    output reg  [3:0] excess_out   // Saida em codigo Excesso-3
);
// Bloco always combinacional sensivel a todas as entradas
always @* begin
    // Selecao do valor de saida com base no digito BCD de 0 a 9
    case (bcd_in)
        4'd0: excess_out = 4'b0011; // 0 -> 3
        4'd1: excess_out = 4'b0100; // 1 -> 4
        4'd2: excess_out = 4'b0101; // 2 -> 5
        4'd3: excess_out = 4'b0110; // 3 -> 6
        4'd4: excess_out = 4'b0111; // 4 -> 7
        4'd5: excess_out = 4'b1000; // 5 -> 8
        4'd6: excess_out = 4'b1001; // 6 -> 9
        4'd7: excess_out = 4'b1010; // 7 -> 10
        4'd8: excess_out = 4'b1011; // 8 -> 11
        4'd9: excess_out = 4'b1100; // 9 -> 12
        default: excess_out = 4'b0000; // Valores invalidos de BCD (10-15)
    endcase
end

endmodule
