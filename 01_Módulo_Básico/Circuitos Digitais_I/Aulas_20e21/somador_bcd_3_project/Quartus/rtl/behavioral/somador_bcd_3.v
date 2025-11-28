// ============================================================================
// Projeto: Somador BCD de 3 Dígitos (000–999)             
// Arquivo: somador_bcd_3.v
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Versão : Verilog 2001 – Compatível com Quartus e Questa
// Descrição: Implementação Comportamental (behavioral) do somador BCD de 3 dígitos com carry-in e
//            carry-out. Cada dígito BCD (centenas/dezenas/unidades) é somado
//            com propagação de carry.
// Observações:
//  - Números de entrada A e B estão no formato BCD em 12 bits: [11:8]=centenas,
//    [7:4]=dezenas, [3:0]=unidades.
//  - A saída SUM segue o mesmo formato e COUT indica milhar.
//  - Comentários linha a linha para fins didáticos.
// ============================================================================
`timescale 1ns/1ps

// -------------------- Módulo de 1 dígito (Behavioral) --------------------
module bcd_digit_adder_behavioral (
    input  wire [3:0] a,      // Dígito BCD A (0..9)
    input  wire [3:0] b,      // Dígito BCD B (0..9)
    input  wire       cin,    // Carry de entrada do dígito menos significativo
    output reg  [3:0] s,      // Soma corrigida em BCD do dígito
    output reg        cout    // Carry de saída para o próximo dígito
);
    // Bloco combinacional descrevendo a soma com correção decimal
    always @* begin
        // Soma binária de 4 bits + carry in (resultado cabe em 5 bits)
        // soma_bin representa a soma sem correção decimal
        integer soma_int;
        soma_int = a + b + cin;        // Ex.: 9 + 8 + 1 = 18

        // Se a soma for 10..19, precisa corrigir para BCD (somar 6) e gerar carry
        if (soma_int >= 10) begin
            s    = soma_int - 10;      // Corrige o resto decimal (ex.: 18 -> 8)
            cout = 1'b1;               // Indica carry para o próximo dígito
        end else begin
            s    = soma_int[3:0];      // Nenhuma correção necessária (0..9)
            cout = 1'b0;               // Sem carry
        end
    end
endmodule

// -------------------- Topo 3 dígitos (Behavioral) --------------------
module somador_bcd_3_behavioral (
    input  wire [11:0] a,   // Entradas BCD A (centenas,dezenas,unidades)
    input  wire [11:0] b,   // Entradas BCD B (centenas,dezenas,unidades)
    input  wire        cin, // Carry de entrada global (opcional)
    output wire [11:0] sum, // Saída BCD somada (C,H,D,U)
    output wire        cout // Carry de milhar
);
    // Wires de carry entre os estágios (U->D, D->C, C->milhar)
    wire c1; // carry das unidades para dezenas
    wire c2; // carry das dezenas para centenas

    // Unidades (bits [3:0])
    bcd_digit_adder_behavioral U0 (
        .a   (a[3:0]),
        .b   (b[3:0]),
        .cin (cin),
        .s   (sum[3:0]),
        .cout(c1)
    );

    // Dezenas (bits [7:4])
    bcd_digit_adder_behavioral U1 (
        .a   (a[7:4]),
        .b   (b[7:4]),
        .cin (c1),
        .s   (sum[7:4]),
        .cout(c2)
    );

    // Centenas (bits [11:8])
    bcd_digit_adder_behavioral U2 (
        .a   (a[11:8]),
        .b   (b[11:8]),
        .cin (c2),
        .s   (sum[11:8]),
        .cout(cout)
    );
endmodule
