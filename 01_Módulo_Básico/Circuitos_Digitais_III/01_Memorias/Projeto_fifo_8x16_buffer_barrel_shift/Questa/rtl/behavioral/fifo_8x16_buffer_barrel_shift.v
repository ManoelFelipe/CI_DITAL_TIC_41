// ============================================================================
// Arquivo  : fifo_8x16_buffer_barrel_shift.v  (implementacao Behavioral)
// Autor    : Manoel Furtado
// Data     : 12/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: FIFO de 8 palavras x 16 bits pela tecnica de "barrel-shift".
//            Escrita na cauda (indice wp_count). Leitura sempre na cabeca
//            (indice 0). Ao ler, o buffer desloca 1 palavra em direcao a
//            cabeca e insere zeros na cauda. Flags full/empty derivadas do
//            contador de ocupacao (wp_count). DEPTH pequeno e didatico,
//            mas para DEPTH grande pode aumentar area e atraso critico.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module fifo_8x16_buffer_barrel_shift_behavioral
#(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)
(
    input  wire                  clk,
    input  wire                  rst,        // Reset assincrono ativo em alto
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out,
    output wire                  full,
    output wire                  empty,
    output reg  [ADDR_WIDTH:0]   wp_count    // 0..DEPTH (contador de ocupacao)
);

    // ------------------------------------------------------------------------
    // Memoria interna: DEPTH palavras
    // ------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // Flags
    assign full  = (wp_count == DEPTH);
    assign empty = (wp_count == 0);

    integer i;

    // Saida sempre aponta para a cabeca (endereco 0)
    always @(*) begin
        data_out = mem[0];
    end

    // Escrita na cauda e leitura com deslocamento por palavra
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wp_count <= 0;

            // Zera memoria para evitar X na simulacao
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            // ----------------------------------------------------------------
            // Caso 1: escrita apenas
            // ----------------------------------------------------------------
            if (wr_en && !rd_en) begin
                if (!full) begin
                    mem[wp_count] <= data_in;
                    wp_count      <= wp_count + 1'b1;
                end
                // else: FIFO cheia -> ignora escrita
            end
            // ----------------------------------------------------------------
            // Caso 2: leitura apenas
            // ----------------------------------------------------------------
            else if (!wr_en && rd_en) begin
                if (!empty) begin
                    // Desloca palavras em direcao a cabeca (indice 0)
                    for (i = 0; i < DEPTH-1; i = i + 1) begin
                        mem[i] <= mem[i+1];
                    end
                    mem[DEPTH-1] <= {DATA_WIDTH{1'b0}};
                    wp_count     <= wp_count - 1'b1;
                end
                // else: FIFO vazia -> ignora leitura
            end
            // ----------------------------------------------------------------
            // Caso 3: leitura e escrita simultaneas
            // Observacao: mantem ocupacao. Primeiro desloca, depois escreve.
            // ----------------------------------------------------------------
            else if (wr_en && rd_en) begin
                if (!empty && !full) begin
                    for (i = 0; i < DEPTH-1; i = i + 1) begin
                        mem[i] <= mem[i+1];
                    end
                    // apos deslocar, o ultimo indice valido vira (wp_count-1)
                    mem[wp_count-1] <= data_in;
                    wp_count        <= wp_count; // mantem
                end else if (empty && !full) begin
                    // Se esta vazia, leitura nao faz nada; vira apenas escrita
                    mem[0]    <= data_in;
                    wp_count  <= 1;
                end else if (!empty && full) begin
                    // Se esta cheia, escrita seria ignorada; vira apenas leitura
                    for (i = 0; i < DEPTH-1; i = i + 1) begin
                        mem[i] <= mem[i+1];
                    end
                    mem[DEPTH-1] <= {DATA_WIDTH{1'b0}};
                    wp_count     <= wp_count - 1'b1;
                end
                // else: empty && full nao ocorre
            end
            // ----------------------------------------------------------------
            // Caso 4: nenhuma operacao
            // ----------------------------------------------------------------
            else begin
                wp_count <= wp_count; // mantem
            end
        end
    end

endmodule
