// ============================================================================
// Arquivo  : fifo_8x8_buffer_circular (implementação structural)
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação structural da FIFO 8x8 usando buffer circular. Divide o projeto em dois blocos principais: memória e controle. A memória é um array registrador simples, enquanto o controle implementa a máquina de estados de ponteiros e flags. Essa abordagem aproxima o código da topologia física e facilita reuso de blocos em projetos maiores.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

// --------------------------------------------------------------------------
// Bloco de memória: armazena 8 palavras de 8 bits.
// --------------------------------------------------------------------------
module fifo_mem_8x8 (
    input  wire       clk,        // clock
    input  wire       reset,      // reset (necessário para inicialização simulada)
    input  wire       we,         // write enable
    input  wire [2:0] w_addr,     // endereço de escrita
    input  wire [2:0] r_addr,     // endereço de leitura
    input  wire [7:0] w_data,     // dado de entrada
    output wire [7:0] r_data      // dado de saída
);
    reg [7:0] mem [0:7];          // memória de 8 posições

    integer i;
    always @(posedge clk) begin
        // Reset síncrono para garantir estado inicial conhecido (evita 'X' na simulação)
        if (reset) begin
            for (i = 0; i < 8; i = i + 1) begin
                mem[i] <= 8'd0;
            end
        end else if (we) begin
            mem[w_addr] <= w_data; // escrita sincronizada
        end
    end

    // Leitura Combinacional:
    // O endereço r_addr seleciona imediatamente o dado de saída.
    assign r_data = mem[r_addr];

endmodule

// --------------------------------------------------------------------------
// Bloco de controle: gerencia ponteiros, flags e write enable.
// --------------------------------------------------------------------------
module fifo_ctrl_8x8 (
    input  wire       clk,        // clock
    input  wire       reset,      // reset
    input  wire       wr,         // comando de escrita
    input  wire       rd,         // comando de leitura
    output reg  [2:0] w_ptr,      // ponteiro de escrita
    output reg  [2:0] r_ptr,      // ponteiro de leitura
    output reg        full,       // flag cheia
    output reg        empty,      // flag vazia
    output wire       we          // write enable para memória
);
    wire [2:0] w_ptr_succ = w_ptr + 1'b1;
    wire [2:0] r_ptr_succ = r_ptr + 1'b1;

    assign we = wr && !full;      // somente escreve se não estiver cheia

    // Próximos estados.
    reg [2:0] w_ptr_next, r_ptr_next;
    reg       full_next, empty_next;

    // Lógica combinacional.
    always @(*) begin
        w_ptr_next = w_ptr;
        r_ptr_next = r_ptr;
        full_next  = full;
        empty_next = empty;

        case ({wr, rd})
            2'b00: begin
                // Nenhuma operação.
            end

            2'b01: begin
                // Somente leitura.
                if (!empty) begin
                    r_ptr_next = r_ptr_succ;
                    full_next  = 1'b0;
                    if (r_ptr_succ == w_ptr)
                        empty_next = 1'b1;
                end
            end

            2'b10: begin
                // Somente escrita.
                if (!full) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr)
                        full_next = 1'b1;
                end
            end

            default: begin
                // Leitura e escrita simultâneas.
                if (!full && !empty) begin
                    w_ptr_next = w_ptr_succ;
                    r_ptr_next = r_ptr_succ;
                end
            end
        endcase
    end

    // Registradores.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_ptr <= 3'd0;
            r_ptr <= 3'd0;
            full  <= 1'b0;
            empty <= 1'b1;
        end else begin
            w_ptr <= w_ptr_next;
            r_ptr <= r_ptr_next;
            full  <= full_next;
            empty <= empty_next;
        end
    end

endmodule

// --------------------------------------------------------------------------
// Topo structural da FIFO 8x8 com buffer circular.
// --------------------------------------------------------------------------
module fifo_8x8_buffer_circular_structural (
    input  wire       clk,       // clock
    input  wire       reset,     // reset
    input  wire       wr,        // comando de escrita
    input  wire       rd,        // comando de leitura
    input  wire [7:0] w_data,    // dado de entrada
    output wire [7:0] r_data,    // dado de saída
    output wire       full,      // flag cheia
    output wire       empty      // flag vazia
);
    wire [2:0] w_ptr_sig;
    wire [2:0] r_ptr_sig;
    wire       full_sig;
    wire       empty_sig;
    wire       we_sig;

    fifo_ctrl_8x8 ctrl_u (
        .clk   (clk),
        .reset (reset),
        .wr    (wr),
        .rd    (rd),
        .w_ptr (w_ptr_sig),
        .r_ptr (r_ptr_sig),
        .full  (full_sig),
        .empty (empty_sig),
        .we    (we_sig)
    );

    fifo_mem_8x8 mem_u (
        .clk   (clk),
        .reset (reset),
        .we    (we_sig),
        .w_addr(w_ptr_sig),
        .r_addr(r_ptr_sig),
        .w_data(w_data),
        .r_data(r_data)
    );

    assign full  = full_sig;
    assign empty = empty_sig;

endmodule
