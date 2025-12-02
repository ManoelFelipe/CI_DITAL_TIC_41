/*
 * Módulo: moore_laser
 * Descrição: Implementação de uma Máquina de Estados Finitos (FSM) do tipo Moore para controle de um laser.
 *            A saída depende apenas do estado atual.
 * Entradas:
 *   - clk: Sinal de clock
 *   - rst: Sinal de reset (ativo alto)
 *   - b:   Sinal de entrada (botão)
 * Saídas:
 *   - x:   Sinal de saída (controle do laser)
 */
module moore_laser (
    input wire clk, // Entrada de clock
    input wire rst, // Entrada de reset
    input wire b,   // Entrada do botão
    output reg x    // Saída do laser
);

    // Codificação dos estados
    localparam DES  = 2'b00; // Estado Desligado
    localparam LIG1 = 2'b01; // Estado Ligado 1
    localparam LIG2 = 2'b10; // Estado Ligado 2
    localparam LIG3 = 2'b11; // Estado Ligado 3

    reg [1:0] current_state, next_state; // Registradores para estado atual e próximo estado

    // Registrador de estado (Lógica Sequencial)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= DES; // Se reset for alto, vai para o estado DES
        else
            current_state <= next_state; // Senão, atualiza para o próximo estado
    end

    // Lógica do próximo estado (Lógica Combinacional)
    always @(*) begin
        case (current_state)
            DES: begin
                if (b)
                    next_state = LIG1; // Se b for 1, vai para LIG1
                else
                    next_state = DES;  // Senão, permanece em DES
            end
            LIG1: begin
                next_state = LIG2; // Incondicionalmente vai para LIG2
            end
            LIG2: begin
                next_state = LIG3; // Incondicionalmente vai para LIG3
            end
            LIG3: begin
                next_state = DES;  // Incondicionalmente volta para DES
            end
            default: next_state = DES; // Estado padrão de segurança
        endcase
    end

    // Lógica de saída (Moore: depende apenas do estado)
    always @(*) begin
        case (current_state)
            DES:  x = 1'b0; // Em DES, saída é 0
            LIG1: x = 1'b1; // Em LIG1, saída é 1
            LIG2: x = 1'b1; // Em LIG2, saída é 1
            LIG3: x = 1'b1; // Em LIG3, saída é 1
            default: x = 1'b0; // Saída padrão
        endcase
    end

endmodule
