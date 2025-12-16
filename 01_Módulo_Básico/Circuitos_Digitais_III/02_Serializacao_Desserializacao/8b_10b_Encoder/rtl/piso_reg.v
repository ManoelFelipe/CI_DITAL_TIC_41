module piso_reg (
    input wire clk,
    input wire reset,
    input wire load,
    input wire [9:0] data_in,
    output wire serial_out
);

    // Registrador de deslocamento de 10 bits
    reg [9:0] shift_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 10'b0;
        end else if (load) begin
            // Carrega o dado paralelo
            shift_reg <= data_in;
        end else begin
            // Desloca para a direita (LSB first)
            // Preenche com 0 no MSB
            shift_reg <= {1'b0, shift_reg[9:1]};
        end
    end

    // O bit menos significativo é enviado serialmente
    // Assim, assim que o load acontece, o bit 0 já está disponível no fio
    // Se o load durar 1 ciclo, no proximo ciclo shift acontece e bit 1 vai pro fio.
    assign serial_out = shift_reg[0];

endmodule
