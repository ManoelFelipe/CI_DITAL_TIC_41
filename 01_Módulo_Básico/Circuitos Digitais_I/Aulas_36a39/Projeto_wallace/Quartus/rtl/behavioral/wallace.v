// ============================================================================
// Arquivo  : wallace.v  (implementação Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Multiplicador de 4x4 bits com saída de 8 bits (produto sem sinal).
//            Esta variante "Behavioral" implementa o núcleo de multiplicação
//            equivalente ao arranjo Wallace Tree. Na behavioral usa o operador
//            '*'; na dataflow descreve-se a rede booleana com atribuições
//            contínuas; na estrutural, compõe-se a árvore de redução com
//            Half/Full Adders. Latência combinacional (0 ciclos). Recursos
//            esperados: ~16 ANDs + somadores de 1 bit na estrutural.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// ============================ PORT DECLARATION ===============================
// Módulo principal: entradas A,B (4 bits sem sinal); saída produto (8 bits).
// Comentários linha a linha garantem rastreabilidade didática.
module wallace (
    input  [3:0] a,           // a: multiplicando (4 bits)
    input  [3:0] b,           // b: multiplicador (4 bits)
    output [7:0] produto      // produto: resultado de 8 bits
);
    // ------------------------------------------------------------------------
    // Implementação comportamental: usa diretamente o operador de multiplicação
    // do Verilog para refletir a semântica combinacional do bloco.
    // NOTA: Síntese em FPGA gera rede de ANDs + somadores como Wallace/array.
    // ------------------------------------------------------------------------
    assign produto = a * b;   // atribuição contínua do produto
endmodule
