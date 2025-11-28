
// ============================================================================
// ULA_74181.v  —  Modelo comportamental "compatível 74181 (lógica positiva)"
// Autor: Manoel Furtado   |   Data: 31/10/2025
// Padrão: Verilog-2001 (compatível Quartus/Questa)
// Descrição:
//   Implementa 16 funções lógicas (M=1) e 16 aritméticas (M=0) inspiradas
//   na tabela do CI 74181 (ativo‑alto). Para fins didáticos, mapeamos as
//   operações de forma clara usando case. O sinal Cn é o carry‑in (ativo‑alto).
//   Saídas: F[3:0], Cn4 (carry‑out), G (Generate), T (Propagate), AeqB.
//   Observação: G e T aqui são calculados como sinais de grupo para soma
//   (A+B), úteis com look‑ahead; nas outras funções eles são apenas indicativos.
//
//   Seleção (S3..S0) — lógica (M=1):
//     0000: ~A                 1000:  A & ~B
//     0001: ~(A | B)  (NOR)    1001:  ~(A ^ B) (XNOR)
//     0010: (~A) & B           1010:  B
//     0011: 4'b0000            1011:  A | ~B
//     0100: ~(A & B) (NAND)    1100:  A
//     0101: ~B                 1101:  A | B
//     0110:  A ^ B             1110: 4'b1111
//     0111: (~A) & (~B)        1111:  A
//
//   Seleção (S3..S0) — aritmética (M=0):
//     Implementa as expressões usuais do 74181 em lógica positiva com Cn.
//     Algumas linhas equivalem a somas/subtrações com constantes/termos AB.
//     O carry‑out (Cn4) é produzido pela soma binária quando aplicável.
//
// Licença: uso educacional.
// ============================================================================

`timescale 1ns/1ps

module ULA_74181 #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] A,      // Operando A (4 bits)
    input  wire [WIDTH-1:0] B,      // Operando B (4 bits)
    input  wire             M,      // Modo: 1=lógico, 0=aritmético
    input  wire [3:0]       S,      // Seleção S3..S0
    input  wire             Cn,     // Carry-in (ativo alto)
    output reg  [WIDTH-1:0] F,      // Resultado
    output reg              Cn4,    // Carry-out (vai-um do grupo)
    output wire             G,      // Generate (grupo) para soma
    output wire             T,      // Propagate (grupo) para soma
    output wire             AeqB    // A == B (comparador)
);

    // --------------------------------------------------------------------
    // Comparador A==B (a nota do material sugere A-B-1 com Cn=1; aqui
    // simplificamos com igualdade bit a bit, equivalente para comparação)
    // --------------------------------------------------------------------
    assign AeqB = (A == B);

    // --------------------------------------------------------------------
    // Sinais de grupo para look-ahead (considerando apenas A+B):
    // p_i = A_i ^ B_i (propaga) / g_i = A_i & B_i (gera)
    // T = p3 & p2 & p1 & p0
    // G = g3 | (p3&g2) | (p3&p2&g1) | (p3&p2&p1&g0)
    // --------------------------------------------------------------------
    wire [WIDTH-1:0] p = A ^ B;
    wire [WIDTH-1:0] g = A & B;
    assign T = &p;
    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

    // Utilitários locais para aritmética
    reg [WIDTH:0] acc;  // acumula soma com carry extra

    always @* begin
        // Valores padrão
        F   = {{WIDTH{{1'b0}}}};
        Cn4 = 1'b0;

        if (M) begin
            // ==============================
            // Modo LÓGICO
            // ==============================
            case (S)
                4'b0000: F = ~A;                // NOT A
                4'b0001: F = ~(A | B);          // NOR
                4'b0010: F = (~A) & B;          // (~A) AND B
                4'b0011: F = 4'b0000;           // 0
                4'b0100: F = ~(A & B);          // NAND
                4'b0101: F = ~B;                // NOT B
                4'b0110: F = (A ^ B);           // XOR
                4'b0111: F = (~A) & (~B);       // (~A) & (~B)
                4'b1000: F =  A & (~B);         // A & ~B
                4'b1001: F = ~(A ^ B);          // XNOR
                4'b1010: F =  B;                // MOVE B
                4'b1011: F =  A | (~B);         // A OR ~B
                4'b1100: F =  A;                // MOVE A
                4'b1101: F =  A | B;            // OR
                4'b1110: F = 4'b1111;           // 1
                4'b1111: F =  A;                // (mantido como A)
                default: F = 4'b0000;
            endcase
            Cn4 = 1'b0; // em modo lógico não há carry significativo
        end else begin
            // ==============================
            // Modo ARITMÉTICO
            // ==============================
            case (S)
                4'b0000: begin acc = {{1'b0, A}} + {{WIDTH{{1'b0}}}} + (Cn ? 1'b0 : 1'b1); end // A (Cn=1) / A-1 (Cn=0)
                4'b0001: begin acc = {{1'b0, A}} + {{1'b0, B}} + (Cn ? 1'b0 : 1'b1);      end // A+B (Cn=1) / A+B-1 (Cn=0)
                4'b0010: begin acc = {{1'b0, (A & B)}} + {{WIDTH{{1'b0}}}} + (Cn ? 1'b0 : 1'b1); end // AB / AB-1
                4'b0011: begin acc = {{1'b0, 4'b0000}} + {{WIDTH{{1'b0}}}} + (Cn ? 1'b0 : 1'b1); end // 0 / -1
                4'b0100: begin acc = {{1'b0, A}} + {{1'b0, (A | B)}} + (Cn ? 1'b0 : 1'b1);      end // A + (A|B)
                4'b0101: begin acc = {{1'b0, B}} + {{1'b0, (A | B)}} + (Cn ? 1'b0 : 1'b1);      end // B + (A|B)
                4'b0110: begin acc = {{1'b0, A}} - {{1'b0, B}} + (Cn ? 1'b0 : -1);              end // A-B (Cn=1) / A-B-1 (Cn=0)
                4'b0111: begin acc = {{1'b0, (A | B)}} + {{1'b0, (A & B)}} + (Cn ? 1'b0 : 1'b1);end // (A|B)+AB
                4'b1000: begin acc = {{1'b0, A}} + {{1'b0, B}} + (Cn ? 1'b0 : 1'b1);            end // A+B
                4'b1001: begin acc = {{1'b0, A}} + {{1'b0, B}} + (Cn ? 1'b1 : 1'b0);            end // A+B+1 (aprox.)
                4'b1010: begin acc = {{1'b0, B}};                                              end // B
                4'b1011: begin acc = {{1'b0, (A | B)}} + {{1'b0, (A & B)}} + (Cn ? 1'b0 : 1'b1);end // (A|B)+AB
                4'b1100: begin acc = {{1'b0, A}} + {{1'b0, A}} + (Cn ? 1'b0 : 1'b1);            end // A+A
                4'b1101: begin acc = {{1'b0, (A | B)}} + {{1'b0, A}} + (Cn ? 1'b0 : 1'b1);      end // (A|B)+A
                4'b1110: begin acc = {{1'b0, (A | B)}} + {{1'b0, A}} + (Cn ? 1'b0 : 1'b1);      end // (A|B)+A
                4'b1111: begin acc = {{1'b0, A}} + {{WIDTH{{1'b0}}}} + (Cn ? -1 : 0);           end // A-1 (Cn=1) / A (Cn=0)
                default: begin acc = 0; end
            endcase

            F   = acc[WIDTH-1:0];
            Cn4 = acc[WIDTH];
        end
    end

endmodule
