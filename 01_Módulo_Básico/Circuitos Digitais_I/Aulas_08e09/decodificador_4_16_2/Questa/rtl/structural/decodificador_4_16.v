// =============================================================
// Projeto: Decodificador 4→16 (saídas ativas em nível BAIXO - one-cold)
// Autor: Manoel Furtado
// Data: 27/10/2025
// Compatibilidade: Verilog-2001 (Quartus / Questa)
// Descrição: Diferente do exemplo one-hot, aqui as saídas são
//            ativas em '0' (one-cold). Somente uma linha vai a '0'.
// =============================================================

// ------------------------------
/* Arquivo: decodificador_4_16.v
   Estilo: Estrutural (Structural) – exigência da Atividade 2

   Estratégia:
   - Usa DOIS blocos 3→8 (dec3to8) com ENABLE ativo-alto.
   - O bit mais significativo a[3] seleciona qual bloco é habilitado:
       en_lo = ~a[3] habilita os endereços 0..7
       en_hi =  a[3] habilita os endereços 8..15
   - As saídas internas dos 3→8 são one-hot ATIVAS-ALTAS.
   - Combina em um barramento de 16 bits e, por fim, INVERTE tudo
     para fornecer SAÍDAS ATIVAS-BAIXAS (one-cold).
*/
// ------------------------------
`timescale 1ns/1ps

// Bloco reutilizável 3→8 com enable, saídas ativas em ALTO
module dec3to8(
    input        en,      // habilita (ativo-alto)
    input  [2:0] a,       // entrada 0..7
    output [7:0] y        // saídas one-hot ativas em '1'
);
    // Se desabilitado, y=0; se habilitado, desloca '1' por a posições
    assign y = en ? (8'h01 << a) : 8'h00;
endmodule

// Topo 4→16 com SAÍDA ATIVA-BAIXA
module decodificador_4_16_structural(
    input  [3:0]  a,     // a[3] seleciona o banco alto/baixo
    output [15:0] y_n    // ativo-baixo: linha selecionada vai a '0'
);
    wire en_lo = ~a[3];  // habilita faixa 0..7 quando a[3]=0
    wire en_hi =  a[3];  // habilita faixa 8..15 quando a[3]=1

    wire [7:0] y_lo_hot; // saídas 0..7 ativas em ALTO (interno)
    wire [7:0] y_hi_hot; // saídas 8..15 ativas em ALTO (interno)

    // Instâncias dos decodificadores 3→8
    dec3to8 u_lo (.en(en_lo), .a(a[2:0]), .y(y_lo_hot));
    dec3to8 u_hi (.en(en_hi), .a(a[2:0]), .y(y_hi_hot));

    // Junta os dois vetores em um barramento 16 bits (dataflow simples)
    wire [15:0] y_hot = { y_hi_hot, y_lo_hot };

    // Converte para ativo-baixo (one-cold): somente a linha escolhida vai a '0'
    assign y_n = ~y_hot;
endmodule
