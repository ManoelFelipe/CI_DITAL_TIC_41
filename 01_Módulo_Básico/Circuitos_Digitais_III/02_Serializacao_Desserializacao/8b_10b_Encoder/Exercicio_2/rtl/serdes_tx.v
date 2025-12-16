module serdes_tx (
    input wire clk,
    input wire reset,
    input wire enable,
    input wire [8:0] data_in, // 8 bits dados + 1 K
    output wire tx_out
);

    wire [9:0] encoded_data;
    wire dispout; // não usado logicamente no loop, mas saída do encoder
    reg disp_current; // registrador para manter o estado da disparidade
    
    // Controle de carga do PISO
    // Precisamos carregar a cada 10 clocks.
    reg [3:0] bit_counter;
    reg load_piso;

    // Instancia o Encoder 8b/10b
    // A disparidade de entrada (dispin) vem do nosso registro acumulado
    encode enc_inst (
        .datain(data_in),
        .dispin(disp_current),
        .dataout(encoded_data),
        .dispout(dispout)
    );

    // Instancia o PISO de 10 bits
    piso_reg piso_inst (
        .clk(clk),
        .reset(reset),
        .load(load_piso),
        .data_in(encoded_data),
        .serial_out(tx_out)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 4'd0;
            load_piso <= 1'b0;
            disp_current <= 1'b0; // Começa com disparidade negativa (padrão)
        end else if (enable) begin
            // Contador de 0 a 9
            if (bit_counter == 4'd9) begin
                bit_counter <= 4'd0;
                load_piso <= 1'b1; // Pulso de load para carregar o PRÓXIMO dado
                
                // NOTA CRÍTICA DE TEMPORIZAÇÃO:
                // O encoder é combinacional. Se mudarmos data_in agora, encoded_data muda.
                // piso_reg carrega no clock se load=1.
                // Então, load=1 deve coincidir com o "início" do próximo frame de dados válidos.
                // Se a entrada data_in for constante durante a transmissão, ok.
                // Assumindo que data_in é estável.
                
                // Atualiza a disparidade acumulada para o PRÓXIMO byte
                disp_current <= dispout; 
            end else begin
                bit_counter <= bit_counter + 1'b1;
                load_piso <= 1'b0;
            end
        end
    end

endmodule
