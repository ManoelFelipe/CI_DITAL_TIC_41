// ============================================================================
// Arquivo  : regfile8x16c.v (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 2025-12-16
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Banco de 8 registradores de 16 bits com 1 porta de escrita síncrona
//            e 2 portas de leitura assíncronas (combinacionais). Reset síncrono.
//            Esta modelagem usa "Structural", interconectando submódulos básicos
//            (registrador enable, decodificador e multiplexador) para formar o sistema.
// Revisão   : v1.0 — criação inicial
// ============================================================================

// Definição do submódulo: Registrador de 16 bits com Enable (Habilitação)
module reg16_en (
    input         clk,       // Sinal de clock
    input         reset,     // Sinal de reset (síncrono)
    input         en,        // Sinal de enable (habilita a carga do valor 'd')
    input  [15:0] d,         // Entrada de dados
    output reg [15:0] q      // Saída registrada
);
    // Lógica sequencial básica de um registrador
    always @(posedge clk) begin
        // Reset tem prioridade: zera a saída
        if (reset) q <= 16'h0000;
        // Se enable estiver ativo, carrega o valor da entrada 'd'
        else if (en) q <= d;
    end
endmodule

// Definição do submódulo: Decodificador 3 para 8
module dec3to8(
    input       write,       // Habilitação da decodificação (Enable global)
    input [2:0] a,           // Endereço de entrada (3 bits)
    output [7:0] y           // Saída decodificada (one-hot)
);
    // Se 'write' estiver ativo, desloca o bit 1 para a posição 'a'
    // Caso contrário, retorna 0 em todas as linhas
    assign y = write ? (8'b00000001 << a) : 8'b00000000;
endmodule

// Definição do submódulo: Multiplexador 8 para 1 de 16 bits
module mux8_16(
    input [2:0] sel,         // Sinal de seleção da entrada
    input [15:0] d0,d1,d2,d3,d4,d5,d6,d7, // 8 Entradas de 16 bits
    output reg [15:0] y      // Saída selecionada
);
    // Lógica combinacional do multiplexador
    always @(*) begin
        case(sel)
            3'd0: y = d0; // Seleciona d0
            3'd1: y = d1; // Seleciona d1
            3'd2: y = d2; // Seleciona d2
            3'd3: y = d3; // Seleciona d3
            3'd4: y = d4; // Seleciona d4
            3'd5: y = d5; // Seleciona d5
            3'd6: y = d6; // Seleciona d6
            3'd7: y = d7; // Seleciona d7
            default: y = 16'h0000; // Padrão de segurança
        endcase
    end
endmodule

// Módulo principal que conecta os componentes estruturais
module regfile8x16c_str (
    input         clk,       // Clock do sistema
    input         reset,     // Reset geral
    input         write,     // Habilitação de escrita
    input  [2:0]  wr_addr,   // Endereço de escrita
    input  [15:0] wr_data,   // Dados de escrita
    input  [2:0]  rd_addr_a, // Endereço de leitura A
    output [15:0] rd_data_a, // Dados de leitura A (saída)
    input  [2:0]  rd_addr_b, // Endereço de leitura B
    output [15:0] rd_data_b  // Dados de leitura B (saída)
);
    // Fio interno para conectar a saída do decodificador aos enables dos registradores
    wire [7:0] we;
    
    // Instancia o decodificador para gerar os sinais de enable individuais
    dec3to8 u_dec(.write(write), .a(wr_addr), .y(we));

    // Fios internos para as saídas de cada um dos 8 registradores
    wire [15:0] q0,q1,q2,q3,q4,q5,q6,q7;

    // Instancia os 8 registradores, conectando clock, reset e enable (we[i])
    reg16_en u0(.clk(clk), .reset(reset), .en(we[0]), .d(wr_data), .q(q0));
    reg16_en u1(.clk(clk), .reset(reset), .en(we[1]), .d(wr_data), .q(q1));
    reg16_en u2(.clk(clk), .reset(reset), .en(we[2]), .d(wr_data), .q(q2));
    reg16_en u3(.clk(clk), .reset(reset), .en(we[3]), .d(wr_data), .q(q3));
    reg16_en u4(.clk(clk), .reset(reset), .en(we[4]), .d(wr_data), .q(q4));
    reg16_en u5(.clk(clk), .reset(reset), .en(we[5]), .d(wr_data), .q(q5));
    reg16_en u6(.clk(clk), .reset(reset), .en(we[6]), .d(wr_data), .q(q6));
    reg16_en u7(.clk(clk), .reset(reset), .en(we[7]), .d(wr_data), .q(q7));

    // Instancia o multiplexador da porta A para selecionar qual registrador será lido
    mux8_16 mux_a(.sel(rd_addr_a), .d0(q0),.d1(q1),.d2(q2),.d3(q3),.d4(q4),.d5(q5),.d6(q6),.d7(q7), .y(rd_data_a));
    
    // Instancia o multiplexador da porta B para selecionar qual registrador será lido
    mux8_16 mux_b(.sel(rd_addr_b), .d0(q0),.d1(q1),.d2(q2),.d3(q3),.d4(q4),.d5(q5),.d6(q6),.d7(q7), .y(rd_data_b));
endmodule
