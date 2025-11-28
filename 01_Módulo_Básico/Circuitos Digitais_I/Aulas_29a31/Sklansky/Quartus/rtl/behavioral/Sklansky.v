// ============================================================================
// Arquivo  : Sklansky.v  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 10/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Modelagem comportamental do somador prefixado de Sklansky (4 bits).
//            Nesta abordagem, usamos o operador de soma do Verilog como uma
//            especificação de alto nível. O sintetizador infere a lógica.
// ============================================================================

`timescale 1ns/1ps

module Sklansky (
    input  wire [3:0] A,   // Entradas A[3:0]
    input  wire [3:0] B,   // Entradas B[3:0]
    input  wire       Cin, // Carry-in
    output reg  [3:0] Sum, // Saída de soma
    output reg        Cout // Carry-out
);
    // ------------------------------------------------------------------------
    // A modelagem comportamental permite descrever o comportamento desejado
    // diretamente. O operador de soma trata do "carry" automaticamente.
    // ------------------------------------------------------------------------
    always @* begin
        // {Cout, Sum} recebe a soma completa de A + B + Cin
        {Cout, Sum} = A + B + Cin;
        // A estrutura interna de Sklansky não é explicitada aqui; esta versão
        // serve como referência funcional e de validação.
    end

endmodule
