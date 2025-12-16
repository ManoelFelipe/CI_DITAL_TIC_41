// ============================================================================
// Arquivo  : sistema_memoria  (implementação [DATAFLOW])
// Autor    : Manoel Furtado
// Data     : 2025-12-15
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Mesma arquitetura do exercício usando estilo dataflow: decodificadores e muxes descritos com assign/always combinacional, mantendo escrita síncrona. DOUT é registrado no clock. A ROM é modelada por função combinacional fixa; SRAM por bancos com enables derivados do endereço. Riscos: cuidado com defaults em case para evitar latches; escrita deve ser restrita às linhas SRAM.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps

// ============================================================================
// Módulo: sistema_memoria (Dataflow)
// - Decodificação de linha/coluna feita por fios (assign)
// - ROM por função combinacional fixa
// - SRAM implementada em 8 bancos (2 linhas SRAM x 4 colunas)
// - Escrita síncrona e leitura registrada
// ============================================================================
module sistema_memoria_dataflow (
    input  wire        clk,
    input  wire        we,
    input  wire [6:0]  a,
    input  wire [7:0]  din,
    output reg  [7:0]  dout
);

    // ----------------------------
    // Campos do endereço
    // ----------------------------
    wire [1:0] row_sel;                          // A6..A5
    wire [1:0] col_sel;                          // A4..A3
    wire [2:0] off_sel;                          // A2..A0

    assign row_sel = a[6:5];                     // extrai linha
    assign col_sel = a[4:3];                     // extrai coluna
    assign off_sel = a[2:0];                     // extrai offset interno

    // ----------------------------
    // Região ROM vs SRAM
    // ----------------------------
    wire is_rom;                                 // 1 = ROM; 0 = SRAM
    assign is_rom = (row_sel < 2'd2);            // linhas 0/1 são ROM

    // ----------------------------
    // ROM: conteúdo fixo por função
    // ----------------------------
    function [7:0] rom_byte;
        input [1:0] r;                           // linha
        input [1:0] c;                           // coluna
        input [2:0] o;                           // offset
        begin
            rom_byte = {r, c, o, 1'b0};           // padrão fixo
        end
    endfunction

    wire [7:0] rom_data;                         // dado ROM combinacional
    assign rom_data = rom_byte(row_sel, col_sel, off_sel);

    // ----------------------------
    // SRAM: 8 bancos 8x8
    // - bank_sel = {row_sel[0], col_sel}
    //   row_sel = 2 (10b) -> row_sel[0]=0 -> bancos 0..3
    //   row_sel = 3 (11b) -> row_sel[0]=1 -> bancos 4..7
    // ----------------------------
    wire [2:0] bank_sel;                         // 0..7
    assign bank_sel = {row_sel[0], col_sel};     // 3 bits

    // Memórias dos bancos (cada uma com 8 posições)
    reg [7:0] sram0 [0:7];
    reg [7:0] sram1 [0:7];
    reg [7:0] sram2 [0:7];
    reg [7:0] sram3 [0:7];
    reg [7:0] sram4 [0:7];
    reg [7:0] sram5 [0:7];
    reg [7:0] sram6 [0:7];
    reg [7:0] sram7 [0:7];

    integer i;

    // Inicialização apenas para simulação (SRAM zerada)
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            sram0[i] = 8'h00;
            sram1[i] = 8'h00;
            sram2[i] = 8'h00;
            sram3[i] = 8'h00;
            sram4[i] = 8'h00;
            sram5[i] = 8'h00;
            sram6[i] = 8'h00;
            sram7[i] = 8'h00;
        end
    end

    // ----------------------------
    // Leitura combinacional SRAM via mux (case)
    // ----------------------------
    reg [7:0] sram_data;                         // dado lido da SRAM

    always @(*) begin
        // default para evitar latch
        sram_data = 8'h00;

        case (bank_sel)
            3'd0: sram_data = sram0[off_sel];
            3'd1: sram_data = sram1[off_sel];
            3'd2: sram_data = sram2[off_sel];
            3'd3: sram_data = sram3[off_sel];
            3'd4: sram_data = sram4[off_sel];
            3'd5: sram_data = sram5[off_sel];
            3'd6: sram_data = sram6[off_sel];
            3'd7: sram_data = sram7[off_sel];
            default: sram_data = 8'h00;
        endcase
    end

    // ----------------------------
    // Mux final ROM/SRAM (combinacional)
    // ----------------------------
    wire [7:0] read_data;
    assign read_data = (is_rom == 1'b1) ? rom_data : sram_data;

    // ----------------------------
    // Escrita síncrona SRAM
    // - Só escreve se NÃO for ROM e we=1
    // ----------------------------
    always @(posedge clk) begin
        if ((is_rom == 1'b0) && (we == 1'b1)) begin
            case (bank_sel)
                3'd0: sram0[off_sel] <= din;
                3'd1: sram1[off_sel] <= din;
                3'd2: sram2[off_sel] <= din;
                3'd3: sram3[off_sel] <= din;
                3'd4: sram4[off_sel] <= din;
                3'd5: sram5[off_sel] <= din;
                3'd6: sram6[off_sel] <= din;
                3'd7: sram7[off_sel] <= din;
                default: ;                       // sem ação
            endcase
        end

        // saída registrada para equivalência entre implementações
        dout <= read_data;
    end

endmodule
