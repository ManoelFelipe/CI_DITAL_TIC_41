//==============================================================
// rom_16x8_async.v
// ROM 16 x 8 assíncrona (somente leitura)
// Estilo comportamental com array + bloco initial
//==============================================================
module rom_16x8_async (
    output reg [7:0] data_out,  // dado lido da ROM
    input  wire [3:0] address   // endereço (0 a 15)
);

    // Memória: 16 palavras de 8 bits
    reg [7:0] ROM [0:15];

    // Inicialização da tabela (conforme figura do livro)
    initial begin
        ROM[ 0] = 8'h00;
        ROM[ 1] = 8'h11;
        ROM[ 2] = 8'h22;
        ROM[ 3] = 8'h33;
        ROM[ 4] = 8'h44;
        ROM[ 5] = 8'h55;
        ROM[ 6] = 8'h66;
        ROM[ 7] = 8'h77;
        ROM[ 8] = 8'h88;
        ROM[ 9] = 8'h99;
        ROM[10] = 8'hAA;
        ROM[11] = 8'hBB;
        ROM[12] = 8'hCC;
        ROM[13] = 8'hDD;
        ROM[14] = 8'hEE;
        ROM[15] = 8'hFF;
    end

    // Leitura assíncrona: data_out muda sempre que o address mudar
    always @* begin
        data_out = ROM[address];
    end

endmodule
