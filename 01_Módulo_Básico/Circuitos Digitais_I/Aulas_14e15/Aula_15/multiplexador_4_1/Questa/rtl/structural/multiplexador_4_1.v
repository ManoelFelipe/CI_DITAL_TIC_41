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
// Implementação estrutural com portas primitivas (not/and/or).
module multiplexador_4_1 (
    input  wire d0,  // Entrada 0
    input  wire d1,  // Entrada 1
    input  wire d2,  // Entrada 2
    input  wire d3,  // Entrada 3
    input  wire s1,  // Seleção MSB
    input  wire s0,  // Seleção LSB
    output wire y    // Saída
);
    // Fios internos para complementos e produtos parciais
    wire ns1;    // ~s1
    wire ns0;    // ~s0
    wire t0;     // (~s1 & ~s0 & d0)
    wire t1;     // (~s1 &  s0 & d1)
    wire t2;     // ( s1  & ~s0 & d2)
    wire t3;     // ( s1  &  s0 & d3)

    // Inversores
    not g_ns1(ns1, s1);    // ns1 = ~s1
    not g_ns0(ns0, s0);    // ns0 = ~s0

    // Portas AND para cada produto
    and g_t0(t0, ns1, ns0, d0); // t0 = ~s1 & ~s0 & d0
    and g_t1(t1, ns1, s0,  d1); // t1 = ~s1 &  s0 & d1
    and g_t2(t2, s1,  ns0, d2); // t2 =  s1 & ~s0 & d2
    and g_t3(t3, s1,  s0,  d3); // t3 =  s1 &  s0 & d3

    // Porta OR final para combinar os produtos
    or  g_y(y, t0, t1, t2, t3); // y = t0 | t1 | t2 | t3
endmodule
