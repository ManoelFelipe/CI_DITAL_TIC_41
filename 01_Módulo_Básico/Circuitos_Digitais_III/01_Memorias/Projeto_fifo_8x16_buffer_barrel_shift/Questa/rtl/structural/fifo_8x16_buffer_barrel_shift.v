// ============================================================================
// Arquivo  : fifo_8x16_buffer_barrel_shift.v  (implementacao Structural)
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

module fifo_8x16_buffer_barrel_shift_structural
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

    reg [DATA_WIDTH-1:0] r0;
    reg [DATA_WIDTH-1:0] r1;
    reg [DATA_WIDTH-1:0] r2;
    reg [DATA_WIDTH-1:0] r3;
    reg [DATA_WIDTH-1:0] r4;
    reg [DATA_WIDTH-1:0] r5;
    reg [DATA_WIDTH-1:0] r6;
    reg [DATA_WIDTH-1:0] r7;

    assign data_out = r0;

    assign full  = (wp_count == DEPTH);
    assign empty = (wp_count == 0);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wp_count <= 0;

            r0 <= {DATA_WIDTH{1'b0}};
            r1 <= {DATA_WIDTH{1'b0}};
            r2 <= {DATA_WIDTH{1'b0}};
            r3 <= {DATA_WIDTH{1'b0}};
            r4 <= {DATA_WIDTH{1'b0}};
            r5 <= {DATA_WIDTH{1'b0}};
            r6 <= {DATA_WIDTH{1'b0}};
            r7 <= {DATA_WIDTH{1'b0}};
        end else begin
            // Leitura apenas
            if (rd_en && !wr_en) begin
                if (!empty) begin
                    r0 <= r1;
                    r1 <= r2;
                    r2 <= r3;
                    r3 <= r4;
                    r4 <= r5;
                    r5 <= r6;
                    r6 <= r7;
                    r7 <= {DATA_WIDTH{1'b0}};
                    wp_count <= wp_count - 1'b1;
                end
            end

            // Escrita apenas
            if (wr_en && !rd_en) begin
                if (!full) begin
                    case (wp_count)
                        0: r0 <= data_in;
                        1: r1 <= data_in;
                        2: r2 <= data_in;
                        3: r3 <= data_in;
                        4: r4 <= data_in;
                        5: r5 <= data_in;
                        6: r6 <= data_in;
                        7: r7 <= data_in;
                        default: r7 <= r7;
                    endcase
                    wp_count <= wp_count + 1'b1;
                end
            end

            // Simultaneo
            if (wr_en && rd_en) begin
                if (!empty && !full) begin
                    // shift
                    r0 <= r1;
                    r1 <= r2;
                    r2 <= r3;
                    r3 <= r4;
                    r4 <= r5;
                    r5 <= r6;
                    r6 <= r7;
                    r7 <= {DATA_WIDTH{1'b0}};

                    // escreve no ultimo indice valido
                    case (wp_count - 1'b1)
                        0: r0 <= data_in;
                        1: r1 <= data_in;
                        2: r2 <= data_in;
                        3: r3 <= data_in;
                        4: r4 <= data_in;
                        5: r5 <= data_in;
                        6: r6 <= data_in;
                        7: r7 <= data_in;
                        default: r7 <= r7;
                    endcase

                    wp_count <= wp_count; // mantem
                end else if (empty && !full) begin
                    r0 <= data_in;
                    wp_count <= 1;
                end else if (!empty && full) begin
                    // vira apenas leitura
                    r0 <= r1;
                    r1 <= r2;
                    r2 <= r3;
                    r3 <= r4;
                    r4 <= r5;
                    r5 <= r6;
                    r6 <= r7;
                    r7 <= {DATA_WIDTH{1'b0}};
                    wp_count <= wp_count - 1'b1;
                end
            end
        end
    end

endmodule
