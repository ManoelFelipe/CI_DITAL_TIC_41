// ============================================================================
// Arquivo  : fifo_16_buffer_circular (implementacao Dataflow)
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: FIFO parametrizavel com buffer circular separando a logica
//            combinacional (dataflow) de calculo das proximas variaveis
//            de estado da logica sequencial (registradores). Os sinais
//            de proximo estado (next_wr_ptr, next_rd_ptr, next_count e
//            next_data_out) sao obtidos por atribuicoes continuas e
//            condicionais, permitindo uma visualizacao mais clara do
//            fluxo de dados dentro da FIFO. Esta abordagem facilita
//            verificacao formal e analise de temporizacao, pois deixa
//            explicito o caminho combinacional entre entradas e registradores.
// Revisao  : v1.0 — criacao inicial
// ============================================================================

`timescale 1ns/1ps

module fifo_buffer_circular_dataflow
#(
    parameter DATA_WIDTH = 16,   // Largura da palavra
    parameter DEPTH      = 16,   // Numero de palavras
    parameter ADDR_WIDTH = 4     // Largura dos ponteiros (log2(DEPTH))
)
(
    input  wire                     clk,        // Clock principal
    input  wire                     rst,        // Reset assincrono ativo em alto
    input  wire                     wr_en,      // Habilita escrita
    input  wire                     rd_en,      // Habilita leitura
    input  wire [DATA_WIDTH-1:0]    data_in,    // Dado de entrada
    output reg  [DATA_WIDTH-1:0]    data_out,   // Dado de saida
    output wire                     full,       // FIFO cheia
    output wire                     empty       // FIFO vazia
);

    // --------------------------------------------------------------------
    // Memoria interna da FIFO
    // --------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // --------------------------------------------------------------------
    // Registradores de estado
    // --------------------------------------------------------------------
    reg [ADDR_WIDTH-1:0] wr_ptr;        // Ponteiro de escrita
    reg [ADDR_WIDTH-1:0] rd_ptr;        // Ponteiro de leitura
    reg [ADDR_WIDTH:0]   fifo_count;    // Contador de ocupacao

    // --------------------------------------------------------------------
    // Sinais combinacionais de proximo estado
    // --------------------------------------------------------------------
    wire                  write_ok;        // Escrita permitida
    wire                  read_ok;         // Leitura permitida
    wire [ADDR_WIDTH-1:0] next_wr_ptr;     // Proximo ponteiro de escrita
    wire [ADDR_WIDTH-1:0] next_rd_ptr;     // Proximo ponteiro de leitura
    wire [ADDR_WIDTH:0]   next_count;      // Proximo contador
    wire [DATA_WIDTH-1:0] next_data_out;   // Proxima saida

    // --------------------------------------------------------------------
    // Flags de estado
    // --------------------------------------------------------------------
    assign full  = (fifo_count == DEPTH); // Cheia quando contador == DEPTH
    assign empty = (fifo_count == 0);     // Vazia quando contador == 0

    // --------------------------------------------------------------------
    // Combinacional: libera escrita/leitura apenas quando possivel
    // --------------------------------------------------------------------
    assign write_ok = wr_en && !full;     // Escrita so se nao estiver cheia
    assign read_ok  = rd_en && !empty;    // Leitura so se nao estiver vazia

    // --------------------------------------------------------------------
    // Combinacional: calculo dos proximos ponteiros e contador
    // --------------------------------------------------------------------
    assign next_wr_ptr = write_ok ? ((wr_ptr == DEPTH - 1) ? {ADDR_WIDTH{1'b0}} : wr_ptr + 1'b1) : wr_ptr;
    assign next_rd_ptr = read_ok  ? ((rd_ptr == DEPTH - 1) ? {ADDR_WIDTH{1'b0}} : rd_ptr + 1'b1) : rd_ptr;

    assign next_count  = (write_ok && !read_ok) ? (fifo_count + 1'b1) :
                         (!write_ok && read_ok) ? (fifo_count - 1'b1) :
                                                   fifo_count;

    // --------------------------------------------------------------------
    // Combinacional: proxima saida
    // --------------------------------------------------------------------
    assign next_data_out = read_ok ? mem[rd_ptr] : data_out;

    // --------------------------------------------------------------------
    // Logica sequencial: atualiza registradores na borda de clock
    // --------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_ptr     <= {ADDR_WIDTH{1'b0}};
            rd_ptr     <= {ADDR_WIDTH{1'b0}};
            fifo_count <= {(ADDR_WIDTH+1){1'b0}};
            data_out   <= {DATA_WIDTH{1'b0}};
        end else begin
            // Escrita efetiva na memoria quando write_ok e verdadeiro
            if (write_ok) begin
                mem[wr_ptr] <= data_in;
            end

            // Atualizacao dos registradores a partir dos sinais combinacionais
            wr_ptr     <= next_wr_ptr;
            rd_ptr     <= next_rd_ptr;
            fifo_count <= next_count;
            data_out   <= next_data_out;
        end
    end

endmodule
