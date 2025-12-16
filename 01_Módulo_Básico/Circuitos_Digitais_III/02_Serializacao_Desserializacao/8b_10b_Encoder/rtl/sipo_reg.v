module sipo_reg (
    input wire clk,
    input wire reset,
    input wire serial_in,
    output reg [9:0] parallel_out
);

    // O SIPO deve capturar os bits serialmente.
    // Como saber quando a palavra de 10 bits está pronta? 
    // O módulo de RX (Top Level) vai controlar quando ler a saída.
    // Este módulo apenas shifta continuamente.

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parallel_out <= 10'b0;
        end else begin
            // Deslocamento para direita para casar com o PISO LSB First:
            // O bit que entra (serial_in) deve entrar na posição mais significativa (MSB)
            // para que após 10 clocks, o primeiro bit (LSB) esteja na posição 0.
            // Ex: Clock 1: entra B0 -> reg[9] = B0
            // ...
            // Clock 10: entra B9 -> reg[9]=B9, ..., reg[0]=B0.
            parallel_out <= {serial_in, parallel_out[9:1]};
        end
    end

endmodule
