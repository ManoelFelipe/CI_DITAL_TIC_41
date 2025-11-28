// ===============================================================
//  ula_8.v (Behavioral) — ULA de 8 bits com soma via Carry Look-Ahead
//  Autor: Manoel Furtado
//  Data:  31/10/2025
//  Compatibilidade: Verilog 2001 (Questa / Quartus)
// ---------------------------------------------------------------
//  Descrição:
//  - Implementa uma ULA com 8 operações selecionadas por 'seletor'.
//  - A operação de soma (seletor=3'b000) usa um CLA de 8 bits (equações
//    internas, porém descritas de forma comportamental).
//  - Expõe os sinais P (propagado) e G (gerado) do bit mais significativo.
// ===============================================================

module ula_8 (
    input  wire [7:0] A,          // Operando A
    input  wire [7:0] B,          // Operando B
    input  wire       carry_in,   // Carry-in
    input  wire [2:0] seletor,    // Seleção da operação
    output reg  [7:0] resultado,  // Resultado
    output reg        carry_out,  // Carry-out (válido na soma)
    output wire       P_msb,      // Propagate do bit 7
    output wire       G_msb       // Generate  do bit 7
);

    // -----------------------------------------------------------
    // Sinais de propagate e generate por bit (para a soma)
    // -----------------------------------------------------------
    wire [7:0] P = A ^ B;         // Propagate por bit
    wire [7:0] G = A & B;         // Generate  por bit
    assign P_msb = P[7];          // Exposição do P do MSB
    assign G_msb = G[7];          // Exposição do G do MSB

    // Carry look-ahead (comportamental calculando c[8])
    reg [8:0] c;                  // c[0]=carry_in, c[8]=carry_out da soma
    reg [7:0] soma;

    always @* begin
        // ---------------- Soma via CLA -------------------------
        c[0] = carry_in;                                      // carry inicial
        // Equações de look-ahead (expandidas)
        c[1] = G[0] | (P[0] & c[0]);
        c[2] = G[1] | (P[1] & G[0]) | (P[1] & P[0] & c[0]);
        c[3] = G[2] | (P[2] & G[1]) | (P[2] & P[1] & G[0]) | (P[2] & P[1] & P[0] & c[0]);
        c[4] = G[3] | (P[3] & G[2]) | (P[3] & P[2] & G[1]) | (P[3] & P[2] & P[1] & G[0]) | (P[3] & P[2] & P[1] & P[0] & c[0]);
        c[5] = G[4] | (P[4] & G[3]) | (P[4] & P[3] & G[2]) | (P[4] & P[3] & P[2] & G[1]) | (P[4] & P[3] & P[2] & P[1] & G[0]) | (P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);
        c[6] = G[5] | (P[5] & G[4]) | (P[5] & P[4] & G[3]) | (P[5] & P[4] & P[3] & G[2]) | (P[5] & P[4] & P[3] & P[2] & G[1]) | (P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);
        c[7] = G[6] | (P[6] & G[5]) | (P[6] & P[5] & G[4]) | (P[6] & P[5] & P[4] & G[3]) | (P[6] & P[5] & P[4] & P[3] & G[2]) | (P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);
        c[8] = G[7] | (P[7] & G[6]) | (P[7] & P[6] & G[5]) | (P[7] & P[6] & P[5] & G[4]) | (P[7] & P[6] & P[5] & P[4] & G[3]) | (P[7] & P[6] & P[5] & P[4] & P[3] & G[2]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & G[1]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & G[0]) | (P[7] & P[6] & P[5] & P[4] & P[3] & P[2] & P[1] & P[0] & c[0]);

        // Soma = P ^ c[7:0]
        soma[0] = P[0] ^ c[0];
        soma[1] = P[1] ^ c[1];
        soma[2] = P[2] ^ c[2];
        soma[3] = P[3] ^ c[3];
        soma[4] = P[4] ^ c[4];
        soma[5] = P[5] ^ c[5];
        soma[6] = P[6] ^ c[6];
        soma[7] = P[7] ^ c[7];

        // ---------------- Seletor de operações -----------------
        case (seletor)
            3'b000: begin
                resultado = soma;
                carry_out = c[8];
            end
            3'b001: begin
                {carry_out,resultado} = A + (~B) + 1'b1; // subtração A-B
            end
            3'b010: begin
                resultado = A & B;
                carry_out = 1'b0;
            end
            3'b011: begin
                resultado = A | B;
                carry_out = 1'b0;
            end
            3'b100: begin
                resultado = A ^ B;
                carry_out = 1'b0;
            end
            3'b101: begin
                resultado = ~A;
                carry_out = 1'b0;
            end
            3'b110: begin
                {carry_out,resultado} = A + 8'd1;        // incremento
            end
            default: begin
                resultado = B;                              // passagem
                carry_out = 1'b0;
            end
        endcase
    end
endmodule
