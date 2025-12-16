// ============================================================================
// Arquivo  : fifo_8x8_buffer_circular (implementação dataflow)
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação dataflow da FIFO 8x8 usando buffer circular. Separa a lógica combinacional de próxima-estado em atribuições contínuas e bloco always para registradores, destacando o fluxo de dados. Facilita análise de dependências e otimizações de síntese sem alterar o comportamento da máquina de estados.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module fifo_8x8_buffer_circular_dataflow (
    input  wire       clk,          // clock do sistema
    input  wire       reset,        // reset síncrono ativo em nível alto
    input  wire       wr,           // comando de escrita
    input  wire       rd,           // comando de leitura
    input  wire [7:0] w_data,       // dado de entrada
    output wire [7:0] r_data,       // dado de saída
    output wire       full,         // flag FIFO cheia
    output wire       empty         // flag FIFO vazia
);
    // --------------------------------------------------------------------
    // Parâmetros fixos: 8 palavras e 3 bits de ponteiro.
    // --------------------------------------------------------------------
    localparam N = 8;
    localparam PTR_WIDTH = 3;

    // Memória interna.
    reg [7:0] mem [0:N-1];

    // Registradores de estado.
    reg [PTR_WIDTH-1:0] w_ptr_reg, r_ptr_reg;
    reg                  full_reg, empty_reg;

    // Próximos estados calculados em lógica combinacional.
    reg [PTR_WIDTH-1:0] w_ptr_next, r_ptr_next;
    reg                  full_next, empty_next;

    // Saídas amarradas aos registradores de estado.
    assign full  = full_reg;
    assign empty = empty_reg;

    // Leitura Combinacional (Dataflow):
    // A atribuição direta de 'mem[r_ptr_reg]' à saída 'r_data' cria um caminho
    // puramente combinacional da memória para saída, caracterizando FWFT.
    assign r_data = mem[r_ptr_reg];

    // Incremento circular.
    wire [PTR_WIDTH-1:0] w_ptr_succ = w_ptr_reg + 1'b1;
    wire [PTR_WIDTH-1:0] r_ptr_succ = r_ptr_reg + 1'b1;

    integer i;

    // --------------------------------------------------------------------
    // Escrita na memória (síncrona ao clock).
    // --------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < N; i = i + 1) begin
                mem[i] <= 8'd0;
            end
        end else if (wr && !full_reg) begin
            mem[w_ptr_reg] <= w_data;
        end
    end

    // --------------------------------------------------------------------
    // Lógica combinacional: calcula próximos ponteiros e flags.
    // --------------------------------------------------------------------
    always @(*) begin
        // Valores padrão: mantém estado.
        w_ptr_next = w_ptr_reg;
        r_ptr_next = r_ptr_reg;
        full_next  = full_reg;
        empty_next = empty_reg;

        // Vetor agrupando operações.
        case ({wr, rd})
            2'b00: begin
                // Nenhuma operação: nada muda.
            end

            2'b01: begin
                // Somente leitura.
                if (!empty_reg) begin
                    r_ptr_next = r_ptr_succ;
                    full_next  = 1'b0;
                    if (r_ptr_succ == w_ptr_reg)
                        empty_next = 1'b1;
                end
            end

            2'b10: begin
                // Somente escrita.
                if (!full_reg) begin
                    w_ptr_next = w_ptr_succ;
                    empty_next = 1'b0;
                    if (w_ptr_succ == r_ptr_reg)
                        full_next = 1'b1;
                end
            end

            default: begin
                // Escrita e leitura simultâneas.
                if (!full_reg && !empty_reg) begin
                    w_ptr_next = w_ptr_succ;
                    r_ptr_next = r_ptr_succ;
                    // Flags geralmente se mantêm.
                end
            end
        endcase
    end

    // --------------------------------------------------------------------
    // Registradores de estado: atualizados no clock.
    // --------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            w_ptr_reg <= {PTR_WIDTH{1'b0}};
            r_ptr_reg <= {PTR_WIDTH{1'b0}};
            full_reg  <= 1'b0;
            empty_reg <= 1'b1;
        end else begin
            w_ptr_reg <= w_ptr_next;
            r_ptr_reg <= r_ptr_next;
            full_reg  <= full_next;
            empty_reg <= empty_next;
        end
    end

endmodule
