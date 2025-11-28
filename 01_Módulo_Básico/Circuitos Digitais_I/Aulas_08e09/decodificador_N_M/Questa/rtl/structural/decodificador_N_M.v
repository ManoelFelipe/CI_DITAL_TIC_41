// =============================================================
// Projeto: Decodificador Parametrizável N→M (M = 2^N) - Atividade 3
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Notas:
//  - Três abordagens: Behavioral, Dataflow e Structural.
//  - Parâmetros: N (bits de entrada), M (=1<<N) derivado via localparam.
//  - Saídas ativas em ALTO (one-hot). Parâmetro opcional ACTIVE_LOW.
// =============================================================

// ------------------------------
// Estilo: Estrutural (Structural) com hierarquia paramétrica
// ------------------------------
`timescale 1ns/1ps

module dec1to2_struct(input a, output [1:0] y);
    assign y[0] = ~a;
    assign y[1] =  a;
endmodule

module decodificador_N_M_structural
#(
    parameter integer N = 4,
    parameter integer ACTIVE_LOW = 0
)
(
    input  [N-1:0] a,
    output [(1<<N)-1:0] y
);
    localparam integer M = (1<<N);

    generate
        if (N == 1) begin : base
            wire [1:0] y1;
            dec1to2_struct u_base (.a(a[0]), .y(y1));
            assign y = ACTIVE_LOW ? ~y1 : y1;
        end else begin : rec
            wire [(1<<(N-1))-1:0] y_lo;
            decodificador_N_M_structural #(.N(N-1), .ACTIVE_LOW(0)) u_sub (.a(a[N-2:0]), .y(y_lo));

            wire msb = a[N-1];
            wire [(1<<(N-1))-1:0] lower_half = (~msb) ? y_lo : {((1<<(N-1))){1'b0}};
            wire [(1<<(N-1))-1:0] upper_half = ( msb) ? y_lo : {((1<<(N-1))){1'b0}};
            wire [M-1:0] y_hot = {upper_half, lower_half};
            assign y = ACTIVE_LOW ? ~y_hot : y_hot;
        end
    endgenerate
endmodule
