// ============================================================================
// Arquivo  : fifo_16_buffer_circular (implementacao Behavioral)
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: FIFO parametrizavel com buffer circular. Implementacao
//            puramente comportamental usando registradores internos
//            para ponteiros de leitura/escrita e contador de ocupacao.
//            A largura da palavra (DATA_WIDTH) e o numero de posicoes
//            (DEPTH) sao ajustaveis via parametro. O sinal full indica
//            que a FIFO esta cheia e empty indica vazia. A leitura e
//            escrita ocorrem na borda de subida do clock. Esta abordagem
//            e ideal para simulacao e prototipacao rapida, mas em
//            sintese deve-se atentar para o mapeamento em memoria
//            interna (block RAM) e para o tamanho de DEPTH a fim de
//            evitar uso excessivo de flip-flops discretos.
// Revisao  : v1.0 — criacao inicial
// ============================================================================

`timescale 1ns/1ps

module fifo_16_buffer_circular
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
    // Memoria interna da FIFO: DEPTH posicoes de DATA_WIDTH bits
    // --------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // --------------------------------------------------------------------
    // Ponteiros de leitura e escrita e contador de ocupacao
    // --------------------------------------------------------------------
    reg [ADDR_WIDTH-1:0] wr_ptr;   // Ponteiro de escrita
    reg [ADDR_WIDTH-1:0] rd_ptr;   // Ponteiro de leitura
    reg [ADDR_WIDTH:0]   fifo_count; // Contador de elementos armazenados

    // --------------------------------------------------------------------
    // Flags de status: cheias e vazias
    // --------------------------------------------------------------------
    assign full  = (fifo_count == DEPTH); // Cheia quando contador == DEPTH
    assign empty = (fifo_count == 0);     // Vazia quando contador == 0

    // --------------------------------------------------------------------
    // Logica sequencial principal da FIFO
    // --------------------------------------------------------------------
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset assincrono: zera ponteiros, contador e saida
            wr_ptr     <= {ADDR_WIDTH{1'b0}};
            rd_ptr     <= {ADDR_WIDTH{1'b0}};
            fifo_count <= {(ADDR_WIDTH+1){1'b0}};
            data_out   <= {DATA_WIDTH{1'b0}};
        end else begin
            // ----------------------------------------------------------------
            // Escrita independendte do contador
            // ----------------------------------------------------------------
            if (wr_en && !full) begin
                mem[wr_ptr] <= data_in;
                if (wr_ptr == DEPTH - 1)
                    wr_ptr <= {ADDR_WIDTH{1'b0}};
                else
                    wr_ptr <= wr_ptr + 1'b1;
            end

            // ----------------------------------------------------------------
            // Leitura independente do contador
            // ----------------------------------------------------------------
            if (rd_en && !empty) begin
                data_out <= mem[rd_ptr];
                if (rd_ptr == DEPTH - 1)
                    rd_ptr <= {ADDR_WIDTH{1'b0}};
                else
                    rd_ptr <= rd_ptr + 1'b1;
            end

            // ----------------------------------------------------------------
            // Atualizacao do contador (Considerando prioridades)
            // ----------------------------------------------------------------
            // Se escrita e leitura ocorrerem simultaneamente, contador mantem.
            // Se so escrita, incrementa.
            // Se so leitura, decrementa.
            if ((wr_en && !full) && !(rd_en && !empty)) begin
                fifo_count <= fifo_count + 1'b1;
            end else if (!(wr_en && !full) && (rd_en && !empty)) begin
                fifo_count <= fifo_count - 1'b1;
            end
            // Else: mantem valor (simultaneo ou nenhum)
        end
    end

endmodule
