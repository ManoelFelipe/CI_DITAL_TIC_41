// ============================================================================
// Arquivo  : fifo_8x16_buffer_barrel_shift.v  (implementacao Dataflow)
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

module fifo_8x16_buffer_barrel_shift_dataflow
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
    output wire [DATA_WIDTH-1:0] data_out,
    output wire                  full,
    output wire                  empty,
    output reg  [ADDR_WIDTH:0]   wp_count
);

    reg [DATA_WIDTH-1:0] mem     [0:DEPTH-1];
    reg [DATA_WIDTH-1:0] mem_nxt [0:DEPTH-1];

    assign data_out = mem[0];

    assign full  = (wp_count == DEPTH);
    assign empty = (wp_count == 0);

    integer i;

    // Proximo estado da memoria
    always @(*) begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            mem_nxt[i] = mem[i];
        end

        // Leitura apenas: desloca rumo a cabeca
        if (rd_en && !wr_en) begin
            if (!empty) begin
                for (i = 0; i < DEPTH-1; i = i + 1) begin
                    mem_nxt[i] = mem[i+1];
                end
                mem_nxt[DEPTH-1] = {DATA_WIDTH{1'b0}};
            end
        end

        // Escrita apenas: escreve na cauda
        if (wr_en && !rd_en) begin
            if (!full) begin
                mem_nxt[wp_count] = data_in;
            end
        end

        // Simultaneo: desloca e escreve no ultimo indice valido
        if (wr_en && rd_en) begin
            if (!empty && !full) begin
                for (i = 0; i < DEPTH-1; i = i + 1) begin
                    mem_nxt[i] = mem[i+1];
                end
                mem_nxt[wp_count-1] = data_in;
            end else if (empty && !full) begin
                mem_nxt[0] = data_in;
            end else if (!empty && full) begin
                for (i = 0; i < DEPTH-1; i = i + 1) begin
                    mem_nxt[i] = mem[i+1];
                end
                mem_nxt[DEPTH-1] = {DATA_WIDTH{1'b0}};
            end
        end
    end

    // Registradores
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wp_count <= 0;
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= mem_nxt[i];
            end

            // Atualiza contador de ocupacao
            if (wr_en && !rd_en) begin
                if (!full) wp_count <= wp_count + 1'b1;
            end else if (!wr_en && rd_en) begin
                if (!empty) wp_count <= wp_count - 1'b1;
            end else if (wr_en && rd_en) begin
                if (empty && !full) begin
                    wp_count <= 1;
                end else if (!empty && full) begin
                    wp_count <= wp_count - 1'b1;
                end else begin
                    wp_count <= wp_count;
                end
            end else begin
                wp_count <= wp_count;
            end
        end
    end

endmodule
