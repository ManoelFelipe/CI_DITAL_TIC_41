// ============================================================================
// Arquivo  : ram_16x8_sync  (implementação structural)
// Autor    : Manoel Furtado
// Data     : 10/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Módulo de memória RAM síncrona 16x8. Implementa 16 posições de
//            memória de 8 bits. Escrita síncrona com clock. Leitura síncrona
//            (1 ciclo de latência) feita através de registrador na saída.
//            Usa sub-módulos para decoder, mux e registradores.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Módulo de flip-flop D de 8 bits com enable de escrita
// --------------------------------------------------------------------------
module dff_8_en (
    input  wire        clk,
    input  wire        we,
    input  wire [7:0]  d,
    output reg  [7:0]  q
);
    always @(posedge clk) begin
        if (we)
            q <= d;
    end
endmodule

// --------------------------------------------------------------------------
// Decoder 4-para-16: gera enables de escrita individuais
// --------------------------------------------------------------------------
module decoder_4x16 (
    input  wire [3:0] addr,
    input  wire       we,
    output wire [15:0] we_word
);
    assign we_word = we ? (16'b1 << addr) : 16'b0;
endmodule

// --------------------------------------------------------------------------
// Mux 16-para-1 de 8 bits: seleciona palavra para leitura
// --------------------------------------------------------------------------
module mux_16x1_8 (
    input  wire [3:0]  sel,
    input  wire [7:0]  d0, d1, d2, d3,
    input  wire [7:0]  d4, d5, d6, d7,
    input  wire [7:0]  d8, d9, d10, d11,
    input  wire [7:0]  d12, d13, d14, d15,
    output reg  [7:0]  y
);
    always @(*) begin
        case (sel)
            4'd0  : y = d0;
            4'd1  : y = d1;
            4'd2  : y = d2;
            4'd3  : y = d3;
            4'd4  : y = d4;
            4'd5  : y = d5;
            4'd6  : y = d6;
            4'd7  : y = d7;
            4'd8  : y = d8;
            4'd9  : y = d9;
            4'd10 : y = d10;
            4'd11 : y = d11;
            4'd12 : y = d12;
            4'd13 : y = d13;
            4'd14 : y = d14;
            4'd15 : y = d15;
            default: y = 8'h00;
        endcase
    end
endmodule

// --------------------------------------------------------------------------
// RAM estrutural 16x8
// --------------------------------------------------------------------------
module ram_16x8_sync_structural (
    input  wire        clk,
    input  wire        we,
    input  wire [3:0]  address,
    input  wire [7:0]  data_in,
    output wire [7:0]  data_out
);
    wire [15:0] we_word;
    wire [7:0] q0, q1, q2, q3, q4, q5, q6, q7;
    wire [7:0] q8, q9, q10, q11, q12, q13, q14, q15;
    wire [7:0] mux_out; // Saída do combinacional do Mux

    // Decoder
    decoder_4x16 u_decoder (
        .addr(address),
        .we(we),
        .we_word(we_word)
    );

    // Banco de Registradores (Memória)
    dff_8_en u_reg0  (clk, we_word[0],  data_in, q0);
    dff_8_en u_reg1  (clk, we_word[1],  data_in, q1);
    dff_8_en u_reg2  (clk, we_word[2],  data_in, q2);
    dff_8_en u_reg3  (clk, we_word[3],  data_in, q3);
    dff_8_en u_reg4  (clk, we_word[4],  data_in, q4);
    dff_8_en u_reg5  (clk, we_word[5],  data_in, q5);
    dff_8_en u_reg6  (clk, we_word[6],  data_in, q6);
    dff_8_en u_reg7  (clk, we_word[7],  data_in, q7);
    dff_8_en u_reg8  (clk, we_word[8],  data_in, q8);
    dff_8_en u_reg9  (clk, we_word[9],  data_in, q9);
    dff_8_en u_reg10 (clk, we_word[10], data_in, q10);
    dff_8_en u_reg11 (clk, we_word[11], data_in, q11);
    dff_8_en u_reg12 (clk, we_word[12], data_in, q12);
    dff_8_en u_reg13 (clk, we_word[13], data_in, q13);
    dff_8_en u_reg14 (clk, we_word[14], data_in, q14);
    dff_8_en u_reg15 (clk, we_word[15], data_in, q15);

    // Mux combinacional (lê valor atual dos registradores)
    mux_16x1_8 u_mux (
        .sel(address),
        .d0(q0), .d1(q1), .d2(q2), .d3(q3),
        .d4(q4), .d5(q5), .d6(q6), .d7(q7),
        .d8(q8), .d9(q9), .d10(q10), .d11(q11),
        .d12(q12), .d13(q13), .d14(q14), .d15(q15),
        .y(mux_out)
    );

    // Registrador de saída (torna a leitura SÍNCRONA)
    // Habilitado sempre (1'b1), atualiza a cada clock
    dff_8_en u_out_reg (
        .clk(clk),
        .we(1'b1),
        .d(mux_out),
        .q(data_out)
    );

endmodule
