// ============================================================================
// Arquivo  : regfile8x16c.v (implementação Dataflow)
// Autor    : Manoel Furtado
// Data     : 2025-12-16
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Banco de 8 registradores de 16 bits com 1 porta de escrita síncrona
//            e 2 portas de leitura assíncronas (combinacionais). Reset síncrono.
//            Esta modelagem usa "Dataflow", explicitando o fluxo de dados através
//            de decodificação manual e registradores individuais.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Definição do módulo com as portas de entrada e saída
module regfile8x16c_dat (
    input         clk,       // Sinal de clock (sincronismo)
    input         reset,     // Sinal de reset (síncrono, ativo alto)
    input         write,     // Sinal de habilitação de escrita (Write Enable)
    input  [2:0]  wr_addr,   // Endereço de escrita (seleciona qual registrador escrever)
    input  [15:0] wr_data,   // Dado de entrada para escrita
    input  [2:0]  rd_addr_a, // Endereço de leitura A
    output [15:0] rd_data_a, // Saída de dados A
    input  [2:0]  rd_addr_b, // Endereço de leitura B
    output [15:0] rd_data_b  // Saída de dados B
);

    // Declaração do sinal de decodificação de escrita (8 bits, "one-hot")
    wire [7:0] we_dec;

    // Lógica de decodificação:
    // Se 'write' for 1, desloca o bit 1 para a posição indicada por 'wr_addr'.
    // Se 'write' for 0, o decodificador gera tudo zero (nenhuma escrita).
    assign we_dec = write ? (8'b00000001 << wr_addr) : 8'b00000000;

    // Declaração explícita dos 8 registradores de 16 bits
    reg [15:0] r0, r1, r2, r3, r4, r5, r6, r7;

    // Bloco sequencial para os registradores
    always @(posedge clk) begin
        // Reset síncrono: se reset ativo, zera todos os registradores
        if (reset) begin
            r0 <= 16'h0000; r1 <= 16'h0000; r2 <= 16'h0000; r3 <= 16'h0000;
            r4 <= 16'h0000; r5 <= 16'h0000; r6 <= 16'h0000; r7 <= 16'h0000;
        end else begin
            // Escrita condicional baseada no bit correspondente do decodificador
            // Apenas o registrador cujo bit em 'we_dec' é 1 será atualizado
            if (we_dec[0]) r0 <= wr_data;
            if (we_dec[1]) r1 <= wr_data;
            if (we_dec[2]) r2 <= wr_data;
            if (we_dec[3]) r3 <= wr_data;
            if (we_dec[4]) r4 <= wr_data;
            if (we_dec[5]) r5 <= wr_data;
            if (we_dec[6]) r6 <= wr_data;
            if (we_dec[7]) r7 <= wr_data;
        end
    end

    // Declaração de registradores (variáveis temporárias) para a lógica combinacional de saída
    reg [15:0] rd_a, rd_b;

    // Atribui os resultados da lógica combinacional às saídas do módulo
    assign rd_data_a = rd_a;
    assign rd_data_b = rd_b;

    // Multiplexador para a porta de leitura A
    // Seleciona o registrador correspondente ao endereço 'rd_addr_a'
    always @(*) begin
        case (rd_addr_a)
            3'd0: rd_a = r0;
            3'd1: rd_a = r1;
            3'd2: rd_a = r2;
            3'd3: rd_a = r3;
            3'd4: rd_a = r4;
            3'd5: rd_a = r5;
            3'd6: rd_a = r6;
            3'd7: rd_a = r7;
            default: rd_a = 16'h0000; // Valor padrão de segurança
        endcase
    end

    // Multiplexador para a porta de leitura B
    // Seleciona o registrador correspondente ao endereço 'rd_addr_b'
    always @(*) begin
        case (rd_addr_b)
            3'd0: rd_b = r0;
            3'd1: rd_b = r1;
            3'd2: rd_b = r2;
            3'd3: rd_b = r3;
            3'd4: rd_b = r4;
            3'd5: rd_b = r5;
            3'd6: rd_b = r6;
            3'd7: rd_b = r7;
            default: rd_b = 16'h0000; // Valor padrão de segurança
        endcase
    end

endmodule
