// demux_1_8.v — Implementação ESTRUTURAL (Structural)
// Autor: Manoel Furtado
// Data: 31/10/2025
// Compatível com Quartus e Questa (Verilog 2001)

`timescale 1ns/1ps
`default_nettype none

// Neste estilo, instanciamos blocos mais simples para compor o demux.
// A estrutura é: DECODIFICADOR 3→8 para gerar 'one-hot' + 8 portas AND
// para "mascarar" a entrada 'din' para cada saída.

// ------------------------
// Decodificador 3→8 simples
// ------------------------
module decoder3to8 (
    input  wire [2:0] a,   // Entradas de seleção
    output wire [7:0] y    // Saídas one-hot
);
    // Cada saída é uma combinação booleana de a[2:0]
    assign y[0] = (~a[2]) & (~a[1]) & (~a[0]); // 000
    assign y[1] = (~a[2]) & (~a[1]) & ( a[0]); // 001
    assign y[2] = (~a[2]) & ( a[1]) & (~a[0]); // 010
    assign y[3] = (~a[2]) & ( a[1]) & ( a[0]); // 011
    assign y[4] = ( a[2]) & (~a[1]) & (~a[0]); // 100
    assign y[5] = ( a[2]) & (~a[1]) & ( a[0]); // 101
    assign y[6] = ( a[2]) & ( a[1]) & (~a[0]); // 110
    assign y[7] = ( a[2]) & ( a[1]) & ( a[0]); // 111
endmodule

// ------------------------
// Módulo principal demux 1→8
// ------------------------
module demux_1_8 (
    input  wire       din,      // Entrada de dados (1 bit)
    input  wire [2:0] sel,      // Seleção (3 bits)
    output wire [7:0] dout      // Saídas (8 bits)
);
    // Fio interno para receber o padrão one-hot do decodificador
    wire [7:0] one_hot;         // Um único '1' de acordo com 'sel'
    
    // Instancia o decodificador 3→8
    decoder3to8 U_DEC (
        .a (sel),               // Conecta 'sel' nas entradas do decodificador
        .y (one_hot)            // Recebe padrão one-hot nas saídas
    );
    
    // Oito portas AND "bit a bit" – encaminham 'din' somente quando o bit
    // correspondente de 'one_hot' for 1.
    assign dout[0] = din & one_hot[0]; // Saída 0 ativa quando sel=000 e din=1
    assign dout[1] = din & one_hot[1]; // Saída 1 ativa quando sel=001 e din=1
    assign dout[2] = din & one_hot[2]; // Saída 2 ativa quando sel=010 e din=1
    assign dout[3] = din & one_hot[3]; // Saída 3 ativa quando sel=011 e din=1
    assign dout[4] = din & one_hot[4]; // Saída 4 ativa quando sel=100 e din=1
    assign dout[5] = din & one_hot[5]; // Saída 5 ativa quando sel=101 e din=1
    assign dout[6] = din & one_hot[6]; // Saída 6 ativa quando sel=110 e din=1
    assign dout[7] = din & one_hot[7]; // Saída 7 ativa quando sel=111 e din=1
endmodule

`default_nettype wire
