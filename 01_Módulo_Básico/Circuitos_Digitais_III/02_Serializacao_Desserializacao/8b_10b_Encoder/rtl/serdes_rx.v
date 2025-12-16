module serdes_rx (
    input wire clk,
    input wire reset,
    input wire rx_in,
    input wire enable,
    output wire [8:0] data_out,
    output wire data_valid,
    output wire code_err,
    output wire disp_err
);

    wire [9:0] parallel_data;
    wire [8:0] decoded_data;
    wire dispout_dec;
    wire code_err_internal, disp_err_internal;
    
    // Registrador SIPO
    sipo_reg sipo_inst (
        .clk(clk),
        .reset(reset),
        .serial_in(rx_in),
        .parallel_out(parallel_data)
    );

    // Precisamos de um contador para saber quando temos 10 bits válidos.
    // E precisamos de um ALINHADOR (Clock Recovery/Word Alignment).
    
    reg [3:0] bit_counter;
    reg [8:0] data_out_reg;
    reg valid_reg;
    reg disp_current_rx; // Disparidade corrente do receptor
    reg aligned;
    
    // Registradores de erro para garantir estabilidade (sincronizados com data_valid)
    reg code_err_reg;
    reg disp_err_reg;

    // Detecção de Comma (K28.5)
    // K28.5 = 0011111010 ou 1100000101
    // Ajustado para parallel_data (variável corrigida)
    wire is_comma_neg = (parallel_data == 10'b1010111100);
    wire is_comma_pos = (parallel_data == 10'b0101000011);
    wire is_comma = is_comma_neg | is_comma_pos;

    // Instancia Decoder
    decode dec_inst (
        .datain(parallel_data),
        .dispin(disp_current_rx),
        .dataout(decoded_data),
        .dispout(dispout_dec),
        .code_err(code_err_internal),
        .disp_err(disp_err_internal)
    );
    
    // As saídas de erro agora vêm dos registradores, não direto da lógica combinacional
    assign code_err = code_err_reg;
    assign disp_err = disp_err_reg;
    assign data_out = data_out_reg;
    assign data_valid = valid_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bit_counter <= 4'd0;
            aligned <= 1'b0;
            data_out_reg <= 9'b0;
            valid_reg <= 1'b0;
            disp_current_rx <= 1'b0; // Inicialmente assumimos disp negativa
            code_err_reg <= 1'b0;
            disp_err_reg <= 1'b0;
        end else if (enable) begin
            if (is_comma) begin
                // ALINHAMENTO DETECTADO
                bit_counter <= 4'd0;
                aligned <= 1'b1;
                
                // Processa o K28.5 imediatamente
                data_out_reg <= decoded_data;
                valid_reg <= 1'b1;
                disp_current_rx <= dispout_dec;
                
                // Atualiza status de erro
                code_err_reg <= code_err_internal;
                disp_err_reg <= disp_err_internal;
            end else begin
                if (aligned) begin
                    if (bit_counter == 4'd9) begin
                        bit_counter <= 4'd0;
                        // Frame completo
                        data_out_reg <= decoded_data;
                        valid_reg <= 1'b1;
                        disp_current_rx <= dispout_dec;
                        
                        // Atualiza status de erro
                        code_err_reg <= code_err_internal;
                        disp_err_reg <= disp_err_internal;
                    end else begin
                        bit_counter <= bit_counter + 1'b1;
                        valid_reg <= 1'b0;
                        // Mantém erro anterior ou limpa? Geralmente valid indica se a saida (e status) são novos.
                        // Vamos manter o valor registrado até o próximo válido.
                    end
                end else begin
                    // Ainda procurando alinhamento...
                    valid_reg <= 1'b0;
                end
            end
        end
    end

endmodule
