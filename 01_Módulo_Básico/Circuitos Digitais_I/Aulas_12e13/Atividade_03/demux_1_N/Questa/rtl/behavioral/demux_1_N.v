// -----------------------------------------------------------------------------
//  Projeto: Demultiplexador 1xN Parametrizável (Verilog 2001)
//  Módulo : demux_1_N
//  Autor  : Manoel Furtado
//  Data   : 31/10/2025
//  Ferram.: Compatível com Quartus e Questa (ModelSim)
//  Notas  : Comentado linha a linha em Português.
// -----------------------------------------------------------------------------
    `timescale 1ns/1ps                     // Define a unidade/precisão de tempo

    // ------------------------------
    // Módulo principal (Behavioral)
    // ------------------------------
    module demux_1_N
    #(parameter integer N = 8)             // Parâmetro: número de saídas (default 8)
    (
        input  wire                 din,   // Entrada única de dados
        input  wire [clog2(N)-1:0] sel,   // Seleção com largura mínima para endereçar N
        output reg  [N-1:0]        y      // Vetor de saídas do demux
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

        always @* begin                    // Bloco combinacional sensível a qualquer mudança
            y = {N{1'b0}};             // Inicializa todas as saídas em '0'
            if (din)                       // Se a entrada estiver em '1'
                y[sel] = 1'b1;             // Ativa somente a posição apontada por sel
        end                                 // Fim do bloco combinacional

    endmodule                               // Fim do módulo behavioral
