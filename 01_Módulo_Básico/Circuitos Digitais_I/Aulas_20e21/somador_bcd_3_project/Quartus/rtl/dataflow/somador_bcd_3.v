// ============================================================================
// Projeto: Somador BCD de 3 Dígitos (000–999)             
// Arquivo: somador_bcd_3.v
// Autor  : Manoel Furtado
// Data   : 31/10/2025
// Versão : Verilog 2001 – Compatível com Quartus e Questa
// Descrição: Implementação Fluxo de Dados (dataflow) do somador BCD de 3 dígitos com carry-in e
//            carry-out. Cada dígito BCD (centenas/dezenas/unidades) é somado
//            com propagação de carry.
// Observações:
//  - Números de entrada A e B estão no formato BCD em 12 bits: [11:8]=centenas,
//    [7:4]=dezenas, [3:0]=unidades.
//  - A saída SUM segue o mesmo formato e COUT indica milhar.
//  - Comentários linha a linha para fins didáticos.
// ============================================================================
`timescale 1ns/1ps

// -------------------- Módulo de 1 dígito (Dataflow) --------------------
module bcd_digit_adder_dataflow (
    input  wire [3:0] a,      // Dígito A
    input  wire [3:0] b,      // Dígito B
    input  wire       cin,    // Carry de entrada
    output wire [3:0] s,      // Soma BCD corrigida
    output wire       cout    // Carry de saída
);
    // Soma binária de 4 bits + carry-in (resultado em 5 bits)
    wire [4:0] soma_bin = a + b + cin;          // 0..19

    // Detecta a necessidade de correção (>=10) usando comparação combinacional
    wire corrige = (soma_bin > 5'd9);           // 1 quando 10..19

    // Soma condicional de 6 (BCD fix-up) quando houver correção
    wire [4:0] soma_corrigida = soma_bin + (corrige ? 5'd6 : 5'd0);

    // A soma final (corrigida) tem o 5º bit como carry
    assign cout = soma_corrigida[4];            // Carry para o próximo dígito
    assign s    = soma_corrigida[3:0];          // Resultado BCD (0..9)
endmodule

// -------------------- Topo 3 dígitos (Dataflow) --------------------
module somador_bcd_3_dataflow (
    input  wire [11:0] a,   // Entradas BCD A
    input  wire [11:0] b,   // Entradas BCD B
    input  wire        cin, // Carry global de entrada
    output wire [11:0] sum, // Saída BCD
    output wire        cout // Carry de milhar
);
    // Interconexões de carry
    wire c1, c2;

    // Encadeia 3 somadores de 1 dígito em dataflow
    bcd_digit_adder_dataflow U0 (a[3:0],  b[3:0],  cin, sum[3:0],  c1);
    bcd_digit_adder_dataflow U1 (a[7:4],  b[7:4],  c1,  sum[7:4],  c2);
    bcd_digit_adder_dataflow U2 (a[11:8], b[11:8], c2,  sum[11:8], cout);
endmodule
