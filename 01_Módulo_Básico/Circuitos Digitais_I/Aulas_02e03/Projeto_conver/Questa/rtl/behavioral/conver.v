// ============================================================================
// Arquivo  : conver.v  (implementação BEHAVIORAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Conversor combinacional de código BCD 5311 (entradas H,G,F,E)
//            para BCD 8421 (saídas D,C,B,A). Implementação em estilo
//            behavioral utilizando um bloco case para mapear explicitamente
//            os 10 dígitos válidos. Largura fixa de 4 bits por código,
//            sem registros internos, com latência puramente combinacional
//            (0 ciclos de clock). Espera-se baixa utilização de recursos,
//            com lógica de decodificação simples e boa portabilidade
//            para síntese em FPGAs de pequeno porte.
// Revisão  : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo behavioral: conver_behavioral
// Implementa o mapeamento direto entre os códigos BCD 5311 e 8421 usando
// um bloco case sensível às entradas H,G,F,E.
// --------------------------------------------------------------------------
module conver_behavioral (
    input  wire h,  // bit mais significativo do código 5311
    input  wire g,  // segundo bit do código 5311
    input  wire f,  // terceiro bit do código 5311
    input  wire e,  // bit menos significativo do código 5311
    output reg  d,  // bit mais significativo do código 8421
    output reg  c,  // segundo bit do código 8421
    output reg  b,  // terceiro bit do código 8421
    output reg  a   // bit menos significativo do código 8421
);

    // ----------------------------------------------------------------------
    // Bloco always combinacional: mapeia {h,g,f,e} -> {d,c,b,a}
    // Usamos um case completo para evitar inferência de latches e garantir
    // que todas as combinações possíveis sejam tratadas.
    // ----------------------------------------------------------------------
    always @* begin
        // Inicializa as saídas com zero para evitar valores indefinidos.
        d = 1'b0;
        c = 1'b0;
        b = 1'b0;
        a = 1'b0;

        // Seleciona o código de entrada em 5311.
        case ({h, g, f, e})
            // decimal 0: 5311 = 0000 -> 8421 = 0000
            4'b0000: begin d = 1'b0; c = 1'b0; b = 1'b0; a = 1'b0; end
            // decimal 1: 5311 = 0001 -> 8421 = 0001
            4'b0001: begin d = 1'b0; c = 1'b0; b = 1'b0; a = 1'b1; end
            // decimal 2: 5311 = 0011 -> 8421 = 0010
            4'b0011: begin d = 1'b0; c = 1'b0; b = 1'b1; a = 1'b0; end
            // decimal 3: 5311 = 0100 -> 8421 = 0011
            4'b0100: begin d = 1'b0; c = 1'b0; b = 1'b1; a = 1'b1; end
            // decimal 4: 5311 = 0101 -> 8421 = 0100
            4'b0101: begin d = 1'b0; c = 1'b1; b = 1'b0; a = 1'b0; end
            // decimal 5: 5311 = 0111 -> 8421 = 0101
            4'b0111: begin d = 1'b0; c = 1'b1; b = 1'b0; a = 1'b1; end
            // decimal 6: 5311 = 1001 -> 8421 = 0110
            4'b1001: begin d = 1'b0; c = 1'b1; b = 1'b1; a = 1'b0; end
            // decimal 7: 5311 = 1011 -> 8421 = 0111
            4'b1011: begin d = 1'b0; c = 1'b1; b = 1'b1; a = 1'b1; end
            // decimal 8: 5311 = 1100 -> 8421 = 1000
            4'b1100: begin d = 1'b1; c = 1'b0; b = 1'b0; a = 1'b0; end
            // decimal 9: 5311 = 1101 -> 8421 = 1001
            4'b1101: begin d = 1'b1; c = 1'b0; b = 1'b0; a = 1'b1; end

            // Demais combinações não utilizáveis em BCD 5311:
            // mantemos a saída em zero por segurança.
            default: begin
                d = 1'b0;
                c = 1'b0;
                b = 1'b0;
                a = 1'b0;
            end
        endcase
    end

endmodule
