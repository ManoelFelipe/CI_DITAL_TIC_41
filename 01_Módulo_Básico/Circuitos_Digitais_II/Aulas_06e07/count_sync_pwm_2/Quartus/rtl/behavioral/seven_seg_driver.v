
`timescale 1ns/1ps

// ============================================================================
// Módulo: seven_seg_driver
// Descrição: Controlador para display de 7 segmentos multiplexado.
//            Exibe o valor do duty cycle (25, 50, 75, 100) com base na seleção.
//            Controla os segmentos (a-g) e os anodos para varredura.
// ============================================================================

module seven_seg_driver #(
    // Frequência do clock do sistema em Hz (padrão 100 MHz)
    parameter CLK_FREQ = 100_000_000
) (
    input wire clk,            // Clock do sistema
    input wire reset_n,        // Reset assíncrono ativo em nível baixo
    input wire [1:0] duty_sel, // Seleção do duty cycle: 00=25%, 01=50%, 10=75%, 11=100%
    output reg [6:0] segments, // Saída para os segmentos (a,b,c,d,e,f,g) - Ativo em 0
    output reg [3:0] anodes    // Saída para os anodos (controle dos dígitos) - Ativo em 0
);

    // Registradores para armazenar o valor numérico de cada um dos 4 dígitos
    reg [3:0] digit0; // Dígito da direita (unidades)
    reg [3:0] digit1; // Dígito das dezenas
    reg [3:0] digit2; // Dígito das centenas
    reg [3:0] digit3; // Dígito da esquerda (milhares) - não usado aqui
    
    // --- Decodificação da Seleção de Duty Cycle ---
    // Define quais números devem aparecer nos dígitos com base em duty_sel.
    // Usamos o valor 15 (4'd15) para representar "apagado" (Blank).
    always @* begin
        case (duty_sel)
            2'b00: begin // Caso 25%
                digit3 = 4'd15; // Apagado
                digit2 = 4'd15; // Apagado
                digit1 = 4'd2;  // Exibe '2'
                digit0 = 4'd5;  // Exibe '5' -> Resultado "25"
            end
            2'b01: begin // Caso 50%
                digit3 = 4'd15; // Apagado
                digit2 = 4'd15; // Apagado
                digit1 = 4'd5;  // Exibe '5'
                digit0 = 4'd0;  // Exibe '0' -> Resultado "50"
            end
            2'b10: begin // Caso 75%
                digit3 = 4'd15; // Apagado
                digit2 = 4'd15; // Apagado
                digit1 = 4'd7;  // Exibe '7'
                digit0 = 4'd5;  // Exibe '5' -> Resultado "75"
            end
            2'b11: begin // Caso 100%
                digit3 = 4'd15; // Apagado
                digit2 = 4'd1;  // Exibe '1'
                digit1 = 4'd0;  // Exibe '0'
                digit0 = 4'd0;  // Exibe '0' -> Resultado "100"
            end
            default: begin // Caso padrão de segurança
                digit3 = 4'd15;
                digit2 = 4'd15;
                digit1 = 4'd0;
                digit0 = 4'd0;
            end
        endcase
    end

    // --- Lógica de Multiplexação (Varredura) ---
    // Para controlar 4 dígitos com apenas um conjunto de fios de segmentos,
    // ligamos um dígito de cada vez muito rapidamente.
    
    // Define a contagem para a taxa de atualização.
    // 400 Hz é uma taxa confortável para evitar cintilação (flicker).
    localparam REFRESH_COUNT = CLK_FREQ / 400; 
    
    integer refresh_counter; // Contador para dividir o clock
    reg [1:0] digit_sel;     // Seleciona qual dígito está ativo (0 a 3)

    // Bloco sequencial para o contador de varredura
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            refresh_counter <= 0;
            digit_sel <= 0;
        end else begin
            // Se atingiu a contagem para trocar de dígito...
            if (refresh_counter >= REFRESH_COUNT) begin
                refresh_counter <= 0;       // Reseta contador
                digit_sel <= digit_sel + 1; // Passa para o próximo dígito
            end else begin
                refresh_counter <= refresh_counter + 1; // Incrementa contador
            end
        end
    end

    // Registrador temporário para guardar o valor do dígito ativo no momento
    reg [3:0] current_digit_val;

    // --- Controle dos Anodos e Seleção do Valor ---
    // Ativa o anodo correspondente ao digit_sel e seleciona o valor a ser exibido.
    // Assumindo display Anodo Comum, onde 0 no anodo liga o dígito.
    always @* begin
        case (digit_sel)
            2'b00: begin
                anodes = 4'b1110;          // Liga o dígito 0 (direita)
                current_digit_val = digit0; // Seleciona valor do dígito 0
            end
            2'b01: begin
                anodes = 4'b1101;          // Liga o dígito 1
                current_digit_val = digit1; // Seleciona valor do dígito 1
            end
            2'b10: begin
                anodes = 4'b1011;          // Liga o dígito 2
                current_digit_val = digit2; // Seleciona valor do dígito 2
            end
            2'b11: begin
                anodes = 4'b0111;          // Liga o dígito 3 (esquerda)
                current_digit_val = digit3; // Seleciona valor do dígito 3
            end
        endcase
    end

    // --- Decodificador de 7 Segmentos ---
    // Converte o valor numérico (0-9) para os segmentos (a-g).
    // Padrão: Segmentos ativos em nível BAIXO (0 liga o LED).
    // Mapeamento: gfedcba
    always @* begin
        case (current_digit_val)
            4'd0: segments = 7'b1000000; // 0: acende a,b,c,d,e,f
            4'd1: segments = 7'b1111001; // 1: acende b,c
            4'd2: segments = 7'b0100100; // 2: acende a,b,d,e,g
            4'd3: segments = 7'b0110000; // 3: acende a,b,c,d,g
            4'd4: segments = 7'b0011001; // 4: acende b,c,f,g
            4'd5: segments = 7'b0010010; // 5: acende a,c,d,f,g
            4'd6: segments = 7'b0000010; // 6: acende a,c,d,e,f,g
            4'd7: segments = 7'b1111000; // 7: acende a,b,c
            4'd8: segments = 7'b0000000; // 8: acende todos
            4'd9: segments = 7'b0010000; // 9: acende a,b,c,d,f,g
            4'd15: segments = 7'b1111111; // Blank: apaga tudo (1111111)
            default: segments = 7'b1111111; // Padrão: apagado
        endcase
    end

endmodule
