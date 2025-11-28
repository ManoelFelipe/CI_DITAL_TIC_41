// ================================================================
// Arquivo : multiplexador_4_1.v
// Projeto : MUX 4x1 — três abordagens (Behavioral/Dataflow/Structural)
// Autor   : Manoel Furtado
// Data    : 31/10/2025
// Ferramentas: Compatível com Verilog‑2001 (Quartus/Questa)
// Descrição: Multiplexador 4:1 com sinais escalares (duas seleções e
//            quatro entradas de dados). Nome do módulo e do arquivo
//            coincidem exatamente: multiplexador_4_1.
// ================================================================
// Observação de estilo: todos os sinais são escalares, conforme solicitado.
//           s1 s0 selecionam uma (e apenas uma) das entradas d0..d3.
//           y é a saída.
module multiplexador_4_1 (
    input  wire d0,  // Entrada de dados 0
    input  wire d1,  // Entrada de dados 1
    input  wire d2,  // Entrada de dados 2
    input  wire d3,  // Entrada de dados 3
    input  wire s1,  // Seleção mais significativa
    input  wire s0,  // Seleção menos significativa
    output reg  y    // Saída do multiplexador
);
    // Lógica comportamental: escolhe uma entrada conforme {s1,s0}
    always @* begin
        // Início do bloco combinacional
        case ({s1, s0})       // Seleciona com base no vetor de seleção
            2'b00: y = d0;    // Quando s1s0 = 00 => repassa d0
            2'b01: y = d1;    // Quando s1s0 = 01 => repassa d1
            2'b10: y = d2;    // Quando s1s0 = 10 => repassa d2
            2'b11: y = d3;    // Quando s1s0 = 11 => repassa d3
            default: y = 1'b0;// Segurança (não deve ocorrer) — define 0
        endcase               // Fim do case
    end                        // Fim do bloco combinacional
endmodule                       // Fim do módulo
