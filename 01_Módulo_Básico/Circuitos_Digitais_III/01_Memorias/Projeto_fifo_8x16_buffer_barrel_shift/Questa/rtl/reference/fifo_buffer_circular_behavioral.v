`timescale 1ns/1ps
// ============================================================================
// Arquivo  : fifo_buffer_circular_behavioral.v  (referencia)
// Autor    : Manoel Furtado
// Data     : 12/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: FIFO de referencia com buffer circular (modelo comportamental)
//            usada para comparar com a FIFO barrel-shift. Mantem ponteiros
//            rp/wp e contador de ocupacao.
// Revisão   : v1.0 — criação inicial (referencia)
// ============================================================================

module fifo_buffer_circular_behavioral
#(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 8,
    parameter ADDR_WIDTH = 3
)
(
    input  wire                  clk,
    input  wire                  rst,
    input  wire                  wr_en,
    input  wire                  rd_en,
    input  wire [DATA_WIDTH-1:0] data_in,
    output wire [DATA_WIDTH-1:0] data_out,
    output wire                  full,
    output wire                  empty
);

    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    reg [ADDR_WIDTH-1:0] rp;
    reg [ADDR_WIDTH-1:0] wp;
    reg [ADDR_WIDTH:0]   count;

    assign full  = (count == DEPTH);
    assign empty = (count == 0);
    
    // FWFT: Saida sempre apresenta o dado apontado por rp (cabeca da fila)
    // Se vazia, força 0 para igualar o comportamento de "insercao de zeros" do barrel shift
    assign data_out = (empty) ? {DATA_WIDTH{1'b0}} : mem[rp];

    integer i;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rp       <= 0;
            wp       <= 0;
            count    <= 0;
            // data_out removed from reset because it is now wire
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            // escrita
            if (wr_en && !full) begin
                mem[wp] <= data_in;
                wp <= wp + 1'b1;
            end

            // leitura
            if (rd_en && !empty) begin
                // data_out <= mem[rp]; // REMOVED: FWFT output is combinatorial
                rp <= rp + 1'b1;
            end

            // contador
            if (wr_en && !rd_en) begin
                if (!full) count <= count + 1'b1;
            end else if (!wr_en && rd_en) begin
                if (!empty) count <= count - 1'b1;
            end else if (wr_en && rd_en) begin
                if (empty && !full) begin
                    count <= 1;
                end else begin
                    count <= count;
                end
            end else begin
                count <= count;
            end
        end
    end

endmodule
