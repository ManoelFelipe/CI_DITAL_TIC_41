// ============================================================================
// Arquivo  : fifo_16_buffer_circular (implementacao Structural)
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descricao: FIFO parametrizavel montada de forma estrutural a partir de
//            blocos menores: registradores de ponteiro, contador de
//            ocupacao, memoria e logica de controle. Cada bloco e
//            instanciado explicitamente, evidenciando a arquitetura
//            interna do circuito. Esta abordagem aproxima a descricao
//            do esquema em portas e registradores reais, facilitando o
//            estudo de microarquitetura e a reutilizacao de IPs em
//            projetos maiores. Em sintese, permite mapeamento direto
//            para recursos especificos do FPGA, mas exige maior cuidado
//            com o roteamento de sinais e complexidade do codigo.
// Revisao  : v1.0 — criacao inicial
// ============================================================================

`timescale 1ns/1ps

// ----------------------------------------------------------------------
// Bloco: registrador de ponteiro com incremento condicional
// ----------------------------------------------------------------------
module fifo_ptr_reg
#(
    parameter ADDR_WIDTH = 4,
    parameter DEPTH      = 16
)
(
    input  wire                   clk,
    input  wire                   rst,
    input  wire                   inc_en,
    output reg  [ADDR_WIDTH-1:0]  ptr
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ptr <= {ADDR_WIDTH{1'b0}};
        end else begin
            if (inc_en) begin
                if (ptr == DEPTH - 1)
                    ptr <= {ADDR_WIDTH{1'b0}};
                else
                    ptr <= ptr + 1'b1;
            end
        end
    end
endmodule

// ----------------------------------------------------------------------
// Bloco: contador de ocupacao da FIFO (inalterado, apenas logica de contagem)
// ----------------------------------------------------------------------
module fifo_count_reg
#(
    parameter COUNT_WIDTH = 5
)
(
    input  wire                    clk,
    input  wire                    rst,
    input  wire                    inc,
    input  wire                    dec,
    output reg  [COUNT_WIDTH-1:0]  count
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count <= {COUNT_WIDTH{1'b0}};
        end else begin
            if (inc && !dec) begin
                count <= count + 1'b1;
            end else if (!inc && dec) begin
                count <= count - 1'b1;
            end
        end
    end
endmodule

// ----------------------------------------------------------------------
// Bloco: memoria da FIFO (Com Reset na saida para evitar 'x' e Enable de Leitura)
// ----------------------------------------------------------------------
module fifo_mem_block
#(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     wr_en,
    input  wire                     rd_en,  // Added read enable
    input  wire [ADDR_WIDTH-1:0]    wr_addr,
    input  wire [ADDR_WIDTH-1:0]    rd_addr,
    input  wire [DATA_WIDTH-1:0]    data_in,
    output reg  [DATA_WIDTH-1:0]    data_out
);
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always @(posedge clk) begin
        if (wr_en) begin
            mem[wr_addr] <= data_in;
        end
    end
    
    // Separate process for output with reset and enable
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= {DATA_WIDTH{1'b0}};
        end else begin
            if (rd_en) begin
                data_out <= mem[rd_addr];
            end
        end
    end
endmodule

// ----------------------------------------------------------------------
// Top-level estrutural da FIFO
// ----------------------------------------------------------------------
module fifo_buffer_circular_structural
#(
    parameter DATA_WIDTH = 16,
    parameter DEPTH      = 16,
    parameter ADDR_WIDTH = 4
)
(
    input  wire                     clk,
    input  wire                     rst,
    input  wire                     wr_en,
    input  wire                     rd_en,
    input  wire [DATA_WIDTH-1:0]    data_in,
    output wire [DATA_WIDTH-1:0]    data_out,
    output wire                     full,
    output wire                     empty
);

    // ------------------------------------------------------------------
    // Sinais internos
    // ------------------------------------------------------------------
    wire [ADDR_WIDTH-1:0] wr_ptr_int; // Ponteiro interno de escrita
    wire [ADDR_WIDTH-1:0] rd_ptr_int; // Ponteiro interno de leitura
    wire [ADDR_WIDTH:0]   count_int;  // Contador interno
    wire                  write_ok;   // Escrita permitida
    wire                  read_ok;    // Leitura permitida

    // ------------------------------------------------------------------
    // Flags de status baseadas no contador
    // ------------------------------------------------------------------
    assign full  = (count_int == DEPTH); // Cheia
    assign empty = (count_int == 0);     // Vazia

    // ------------------------------------------------------------------
    // Controle de habilitacao de escrita/leitura
    // ------------------------------------------------------------------
    assign write_ok = wr_en && !full;    // Escreve apenas se nao cheia
    assign read_ok  = rd_en && !empty;   // Lê apenas se nao vazia

    // ------------------------------------------------------------------
    // Instancia dos blocos de ponteiro
    // ------------------------------------------------------------------
    fifo_ptr_reg
    #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH     (DEPTH)
    )
    u_wr_ptr_reg
    (
        .clk   (clk),
        .rst   (rst),
        .inc_en(write_ok),
        .ptr   (wr_ptr_int)
    );

    fifo_ptr_reg
    #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DEPTH     (DEPTH)
    )
    u_rd_ptr_reg
    (
        .clk   (clk),
        .rst   (rst),
        .inc_en(read_ok),
        .ptr   (rd_ptr_int)
    );

    // ------------------------------------------------------------------
    // Instancia do contador de ocupacao
    // ------------------------------------------------------------------
    fifo_count_reg
    #(
        .COUNT_WIDTH(ADDR_WIDTH+1)
    )
    u_count_reg
    (
        .clk  (clk),
        .rst  (rst),
        .inc  (write_ok),
        .dec  (read_ok),
        .count(count_int)
    );

    // ------------------------------------------------------------------
    // Instancia do bloco de memoria
    // ------------------------------------------------------------------
    fifo_mem_block
    #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH     (DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    )
    u_mem_block
    (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (write_ok),
        .rd_en   (read_ok),    // Connected read enable
        .wr_addr (wr_ptr_int),
        .rd_addr (rd_ptr_int),
        .data_in (data_in),
        .data_out(data_out)
    );

endmodule
