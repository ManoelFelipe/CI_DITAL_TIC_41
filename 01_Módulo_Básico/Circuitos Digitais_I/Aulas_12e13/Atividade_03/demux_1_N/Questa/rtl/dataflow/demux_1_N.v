// -----------------------------------------------------------------------------
//  Projeto: Demultiplexador 1xN Parametrizável (Verilog 2001)
//  Módulo : demux_1_N
//  Autor  : Manoel Furtado
//  Data   : 31/10/2025
//  Ferram.: Compatível com Quartus e Questa (ModelSim)
//  Notas  : Comentado linha a linha em Português.
// -----------------------------------------------------------------------------
    `timescale 1ns/1ps                     // Define a unidade/precisão de tempo

    // ----------------------------
    // Módulo principal (Dataflow)
    // ----------------------------
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

        // Mascara de N bits com 1's (ex.: N=8 => 8'hFF)
        wire [N-1:0] mask = {N{1'b1}}; // Cria uma máscara com N bits '1'

        // Desloca '1' para a posição 'sel' e faz AND com a máscara para limitar a N bits;
        // Se din=0, força todas as saídas para '0'.
        assign y = din ? (({(N){1'b0}} | ({(N){1'b0}} + 1'b1)) << sel) & mask : {N{1'b0}};
        // Observação: A expressão (0 + 1) gera o valor '1' com largura expandida para N bits.

    endmodule                               // Fim do módulo dataflow
