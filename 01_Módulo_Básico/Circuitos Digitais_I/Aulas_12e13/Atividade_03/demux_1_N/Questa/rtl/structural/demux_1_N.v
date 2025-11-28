// -----------------------------------------------------------------------------
//  Projeto: Demultiplexador 1xN Parametrizável (Verilog 2001)
//  Módulo : demux_1_N
//  Autor  : Manoel Furtado
//  Data   : 31/10/2025
//  Ferram.: Compatível com Quartus e Questa (ModelSim)
//  Notas  : Comentado linha a linha em Português.
// -----------------------------------------------------------------------------
    `timescale 1ns/1ps                     // Define a unidade/precisão de tempo

    // --------------------------------
    // Módulo auxiliar: comparador sel==K
    // --------------------------------
    module eq_const
    #(parameter integer W = 3,             // Largura do barramento 'sel'
      parameter integer K = 0)             // Constante a ser comparada
    (
        input  wire [W-1:0] sel,           // Entrada: valor de seleção
        output wire         match          // Saída: 1 quando sel == K
    );
        // Implementação por portas: XNOR bit a bit seguido de AND de redução
        wire [W-1:0] xnor_bits;            // Fios intermediários para XNOR por bit
        genvar b;                           // Gerador para instanciar por bit
        generate
            for (b = 0; b < W; b = b + 1) begin : GEN_XNOR
                assign xnor_bits[b] = ~(sel[b] ^ K[b]); // XNOR: 1 quando bits são iguais
            end
        endgenerate
        assign match = &xnor_bits;         // AND de redução: 1 somente se todos os bits igualam
    endmodule

    // ------------------------------
    // Porta AND de 2 entradas
    // ------------------------------
    module and2 (
        input  wire a,                      // Entrada A
        input  wire b,                      // Entrada B
        output wire y                       // Saída
    );
        assign y = a & b;                   // Implementação por atribuição contínua
    endmodule

    // ------------------------------
    // Módulo principal (Structural)
    // ------------------------------
    module demux_1_N
    #(parameter integer N = 8)             // Parâmetro: número de saídas (default 8)
    (
        input  wire                 din,   // Entrada única de dados
        input  wire [clog2(N)-1:0] sel,   // Barramento de seleção
        output wire [N-1:0]        y      // Vetor de saídas
    );
    // Função utilitária para calcular ceil(log2(value)) em Verilog 2001
function integer clog2;
    // value: número do qual se deseja o log2 arredondado para cima
    input integer value;           // valor de entrada
    integer i;                     // índice auxiliar
    begin
        value = value - 1;         // ajusta para arredondar para cima
        for (i = 0; value > 0; i = i + 1)
            value = value >> 1;    // desloca até zerar
        clog2 = i;                 // i é a largura necessária
    end
endfunction

        localparam integer W = clog2(N);   // Largura calculada para o comparador
        genvar i;                          // Índice para geração de hardware
        generate
            for (i = 0; i < N; i = i + 1) begin : GEN_DEMUX
                wire hit_i;                // Sinal fica '1' quando sel == i
                eq_const #(.W(W), .K(i)) u_eq (
                    .sel(sel),             // Conecta o barramento de seleção
                    .match(hit_i)          // Resultado da comparação com i
                );
                and2 u_and (
                    .a(din),               // Habilita com 'din'
                    .b(hit_i),             // Seleciona a linha i
                    .y(y[i])               // Saída i do demux
                );
            end
        endgenerate

    endmodule                               // Fim do módulo structural
