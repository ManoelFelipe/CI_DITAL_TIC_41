// ============================================================================
// Arquivo  : sistema_memoria  (implementação [STRUCTURAL])
// Autor    : Manoel Furtado
// Data     : 2025-12-15
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Implementação estrutural instanciando 8 módulos rom8x8 e 8 módulos sram8x8 em uma malha 4x4. A seleção usa decodificadores (row/col) e multiplexação para formar o barramento de dados. Escrita síncrona na SRAM (WE + CLK). DOUT registrado garante consistência entre DUTs. Riscos: número de instâncias aumenta área; muxes podem afetar timing; decoder deve ser completo para não gerar X/latches em simulação.
// Revisão   : v1.0 — criação inicial
// ============================================================================
`timescale 1ns/1ps

// ============================================================================
// Bloco ROM 8x8 (8 palavras de 8 bits)
// - Conteúdo fixo derivado de parâmetros ROW/COL e do endereço interno.
// - Leitura puramente combinacional.
// ============================================================================
module rom8x8 #(
    parameter [1:0] ROW = 2'd0,                  // linha física do bloco
    parameter [1:0] COL = 2'd0                   // coluna física do bloco
)(
    input  wire [2:0] addr,                      // endereço interno 0..7
    output wire [7:0] dout                       // dado lido
);
    // Conteúdo: {ROW, COL, addr, 1'b0}
    assign dout = {ROW, COL, addr, 1'b0};
endmodule

// ============================================================================
// Bloco SRAM 8x8 (8 palavras de 8 bits)
// - Escrita síncrona no posedge clk quando we=1
// - Leitura combinacional (dout reflete o conteúdo atual em addr)
// - Inicialização a zero apenas para simulação
// ============================================================================
module sram8x8 (
    input  wire        clk,                      // clock
    input  wire        we,                       // write enable
    input  wire [2:0]  addr,                     // endereço interno 0..7
    input  wire [7:0]  din,                      // dado de entrada
    output wire [7:0]  dout                      // dado lido (combinacional)
);
    reg [7:0] mem [0:7];                          // memória interna
    integer i;

    // Zera a SRAM na simulação
    initial begin
        for (i = 0; i < 8; i = i + 1) begin
            mem[i] = 8'h00;
        end
    end

    // Escrita síncrona
    always @(posedge clk) begin
        if (we == 1'b1) begin
            mem[addr] <= din;
        end
    end

    // Leitura combinacional
    assign dout = mem[addr];
endmodule

// ============================================================================
// Topo: sistema_memoria (Structural)
// - Instancia 8 ROMs 8x8 e 8 SRAMs 8x8 em uma malha 4x4
// - Seleção por decodificadores de linha/coluna e mux final
// - DOUT registrado para equivalência e previsibilidade
// ============================================================================
module sistema_memoria_structural (
    input  wire        clk,
    input  wire        we,
    input  wire [6:0]  a,
    input  wire [7:0]  din,
    output reg  [7:0]  dout
);

    // Campos do endereço
    wire [1:0] row_sel;
    wire [1:0] col_sel;
    wire [2:0] off_sel;

    assign row_sel = a[6:5];
    assign col_sel = a[4:3];
    assign off_sel = a[2:0];

    // Saídas combinacionais dos 16 blocos (somente 8 ROM + 8 SRAM usados)
    wire [7:0] b00, b01, b02, b03;               // row 0 (ROM)
    wire [7:0] b10, b11, b12, b13;               // row 1 (ROM)
    wire [7:0] b20, b21, b22, b23;               // row 2 (SRAM)
    wire [7:0] b30, b31, b32, b33;               // row 3 (SRAM)

    // Enables de escrita para cada SRAM
    wire we20, we21, we22, we23;
    wire we30, we31, we32, we33;

    assign we20 = (we == 1'b1) && (row_sel == 2'd2) && (col_sel == 2'd0);
    assign we21 = (we == 1'b1) && (row_sel == 2'd2) && (col_sel == 2'd1);
    assign we22 = (we == 1'b1) && (row_sel == 2'd2) && (col_sel == 2'd2);
    assign we23 = (we == 1'b1) && (row_sel == 2'd2) && (col_sel == 2'd3);

    assign we30 = (we == 1'b1) && (row_sel == 2'd3) && (col_sel == 2'd0);
    assign we31 = (we == 1'b1) && (row_sel == 2'd3) && (col_sel == 2'd1);
    assign we32 = (we == 1'b1) && (row_sel == 2'd3) && (col_sel == 2'd2);
    assign we33 = (we == 1'b1) && (row_sel == 2'd3) && (col_sel == 2'd3);

    // ----------------------------
    // Instâncias ROM (linhas 0 e 1)
    // ----------------------------
    rom8x8 #(.ROW(2'd0), .COL(2'd0)) u_rom_00 (.addr(off_sel), .dout(b00));
    rom8x8 #(.ROW(2'd0), .COL(2'd1)) u_rom_01 (.addr(off_sel), .dout(b01));
    rom8x8 #(.ROW(2'd0), .COL(2'd2)) u_rom_02 (.addr(off_sel), .dout(b02));
    rom8x8 #(.ROW(2'd0), .COL(2'd3)) u_rom_03 (.addr(off_sel), .dout(b03));

    rom8x8 #(.ROW(2'd1), .COL(2'd0)) u_rom_10 (.addr(off_sel), .dout(b10));
    rom8x8 #(.ROW(2'd1), .COL(2'd1)) u_rom_11 (.addr(off_sel), .dout(b11));
    rom8x8 #(.ROW(2'd1), .COL(2'd2)) u_rom_12 (.addr(off_sel), .dout(b12));
    rom8x8 #(.ROW(2'd1), .COL(2'd3)) u_rom_13 (.addr(off_sel), .dout(b13));

    // ----------------------------
    // Instâncias SRAM (linhas 2 e 3)
    // ----------------------------
    sram8x8 u_sram_20 (.clk(clk), .we(we20), .addr(off_sel), .din(din), .dout(b20));
    sram8x8 u_sram_21 (.clk(clk), .we(we21), .addr(off_sel), .din(din), .dout(b21));
    sram8x8 u_sram_22 (.clk(clk), .we(we22), .addr(off_sel), .din(din), .dout(b22));
    sram8x8 u_sram_23 (.clk(clk), .we(we23), .addr(off_sel), .din(din), .dout(b23));

    sram8x8 u_sram_30 (.clk(clk), .we(we30), .addr(off_sel), .din(din), .dout(b30));
    sram8x8 u_sram_31 (.clk(clk), .we(we31), .addr(off_sel), .din(din), .dout(b31));
    sram8x8 u_sram_32 (.clk(clk), .we(we32), .addr(off_sel), .din(din), .dout(b32));
    sram8x8 u_sram_33 (.clk(clk), .we(we33), .addr(off_sel), .din(din), .dout(b33));

    // ----------------------------
    // Mux combinacional do bloco selecionado
    // ----------------------------
    reg [7:0] read_data;

    always @(*) begin
        // default para evitar latch
        read_data = 8'h00;

        case ({row_sel, col_sel})
            4'b0000: read_data = b00;
            4'b0001: read_data = b01;
            4'b0010: read_data = b02;
            4'b0011: read_data = b03;

            4'b0100: read_data = b10;
            4'b0101: read_data = b11;
            4'b0110: read_data = b12;
            4'b0111: read_data = b13;

            4'b1000: read_data = b20;
            4'b1001: read_data = b21;
            4'b1010: read_data = b22;
            4'b1011: read_data = b23;

            4'b1100: read_data = b30;
            4'b1101: read_data = b31;
            4'b1110: read_data = b32;
            4'b1111: read_data = b33;

            default: read_data = 8'h00;
        endcase
    end

    // Saída registrada
    always @(posedge clk) begin
        dout <= read_data;
    end

endmodule
