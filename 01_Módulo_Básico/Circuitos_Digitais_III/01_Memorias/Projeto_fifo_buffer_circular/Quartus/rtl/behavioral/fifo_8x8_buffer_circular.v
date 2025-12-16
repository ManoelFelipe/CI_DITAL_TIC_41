// ============================================================================
// Arquivo  : fifo_8x8_buffer_circular (implementação behavioral)
// Autor    : Manoel Furtado
// Data     : 11/12/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação behavioral da FIFO 8x8 usando buffer circular. Controla ponteiros de escrita e leitura em blocos always sensíveis ao clock, atualizando flags de full/empty com base nas operações de escrita e leitura. Ideal para descrição de alto nível e fácil compreensão, porém sintetiza lógica equivalente às demais abordagens se os estilos forem bem controlados.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module fifo_8x8_buffer_circular_behavioral (
    input  wire       clk,          // clock do sistema
    input  wire       reset,        // reset síncrono ativo em nível alto
    input  wire       wr,           // comando de escrita
    input  wire       rd,           // comando de leitura
    input  wire [7:0] w_data,       // dado de entrada
    output reg  [7:0] r_data,       // dado de saída
    output reg        full,         // flag FIFO cheia
    output reg        empty         // flag FIFO vazia
);
    // --------------------------------------------------------------------
    // Parâmetros fixos: 8 palavras de 8 bits.
    // Ponteiros com 3 bits pois 2^3 = 8 (potência de dois).
    // --------------------------------------------------------------------
    localparam N = 8;
    localparam PTR_WIDTH = 3;

    // Memória interna para armazenar 8 palavras.
    reg [7:0] mem [0:N-1];

    // Ponteiros de escrita e leitura.
    reg [PTR_WIDTH-1:0] w_ptr;
    reg [PTR_WIDTH-1:0] r_ptr;

    // Próximos valores dos ponteiros calculados com incremento circular.
    wire [PTR_WIDTH-1:0] w_ptr_next = w_ptr + 1'b1;
    wire [PTR_WIDTH-1:0] r_ptr_next = r_ptr + 1'b1;

    integer i; // usado apenas para reset opcional da memória

    // --------------------------------------------------------------------
    // Processo síncrono: escrita na memória e atualização de ponteiros.
    // --------------------------------------------------------------------
    always @(posedge clk) begin
        if (reset) begin
            // Reset global: zera ponteiros, flags e memória.
            w_ptr <= {PTR_WIDTH{1'b0}};
            r_ptr <= {PTR_WIDTH{1'b0}};
            full  <= 1'b0;
            empty <= 1'b1;
            for (i = 0; i < N; i = i + 1) begin
                mem[i] <= 8'd0;
            end
        end else begin
            // Valores padrão: mantém estado.
            full  <= full;
            empty <= empty;
            w_ptr <= w_ptr;
            r_ptr <= r_ptr;

            // Caso 1: leitura sem escrita.
            if (rd && !wr) begin
                if (!empty) begin
                    r_ptr  <= r_ptr_next;   // avança ponteiro de leitura
                    full   <= 1'b0;         // após leitura a FIFO não está cheia
                    if (r_ptr_next == w_ptr)
                        empty <= 1'b1;      // se ponteiros coincidem → vazia
                end
            end

            // Caso 2: escrita sem leitura.
            else if (wr && !rd) begin
                if (!full) begin
                    mem[w_ptr] <= w_data;   // escreve dado na posição w_ptr
                    w_ptr      <= w_ptr_next; // avança ponteiro de escrita
                    empty      <= 1'b0;       // após escrita a FIFO não está vazia
                    if (w_ptr_next == r_ptr)
                        full <= 1'b1;         // se ponteiros coincidem → cheia
                end
            end

            // Caso 3: leitura e escrita simultâneas.
            else if (wr && rd) begin
                if (!full && !empty) begin
                    // Escreve novo dado.
                    mem[w_ptr] <= w_data;
                    w_ptr      <= w_ptr_next;

                    // Avança leitura.
                    r_ptr  <= r_ptr_next;

                    // Ocupação tende a se manter; flags não mudam
                    // a menos que se esteja próximo das bordas.
                    if (w_ptr_next == r_ptr_next) begin
                        // buffer completamente ocupado e consumido ao mesmo tempo
                        full  <= 1'b0;
                        empty <= 1'b0;
                    end
                end
            end
        end
    end

    // --------------------------------------------------------------------
    // Saída de dados: Leitura Combinacional (First-Word-Fall-Through - FWFT)
    // --------------------------------------------------------------------
    // Nesta topologia (Show-Ahead), o dado apontado pelo ponteiro de leitura (r_ptr)
    // fica disponível na saída 'r_data' imediatamente, sem necessidade de um pulso 
    // de clock adicional para registrá-lo.
    // Isso garante que assim que a FIFO deixar de ser vazia, o primeiro dado já 
    // estará na saída, pronto para ser consumido.
    // --------------------------------------------------------------------
    always @(*) begin
        r_data = mem[r_ptr];
    end

endmodule
