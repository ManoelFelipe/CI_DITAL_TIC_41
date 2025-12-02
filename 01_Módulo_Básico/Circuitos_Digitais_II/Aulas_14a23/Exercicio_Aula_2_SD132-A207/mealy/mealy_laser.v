/*
 * Módulo: mealy_laser
 * Descrição: Implementação de uma Máquina de Estados Finitos (FSM) do tipo Mealy para controle de um laser.
 *            A saída depende do estado atual E da entrada.
 * Entradas:
 *   - clk: Sinal de clock
 *   - rst: Sinal de reset (ativo alto)
 *   - b:   Sinal de entrada (botão)
 * Saídas:
 *   - x:   Sinal de saída (controle do laser)
 */
module mealy_laser (
    input wire clk, // Entrada de clock
    input wire rst, // Entrada de reset
    input wire b,   // Entrada do botão
    output reg x    // Saída do laser
);

    // Codificação dos estados
    // Para Mealy, podemos usar menos estados ou lógica diferente.
    // Para manter exatamente 3 ciclos de saída:
    // Ciclo 1: Detectou b=1 em IDLE -> Saída 1 imediatamente (Mealy) -> Próximo Estado S1
    // Ciclo 2: Em S1 -> Saída 1 -> Próximo Estado S2
    // Ciclo 3: Em S2 -> Saída 1 -> Próximo Estado IDLE
    
    localparam IDLE = 2'b00; // Estado Inicial
    localparam S1   = 2'b01; // Estado 1
    localparam S2   = 2'b10; // Estado 2

    reg [1:0] current_state, next_state; // Registradores para estado atual e próximo

    // Registrador de estado (Lógica Sequencial)
    always @(posedge clk or posedge rst) begin
        if (rst)
            current_state <= IDLE; // Reset para estado IDLE
        else
            current_state <= next_state; // Atualiza para próximo estado
    end

    // Lógica de próximo estado e saída (Mealy: depende de estado E entrada)
    always @(*) begin
        // Valores padrão para evitar latches indesejados
        next_state = current_state;
        x = 1'b0;

        case (current_state)
            IDLE: begin
                if (b) begin
                    x = 1'b1;          // Saída vai para alto imediatamente com a entrada
                    next_state = S1;   // Vai para estado S1
                end else begin
                    x = 1'b0;          // Saída permanece baixa
                    next_state = IDLE; // Permanece em IDLE
                end
            end
            S1: begin
                x = 1'b1;              // Saída alta durante este estado
                next_state = S2;       // Vai para estado S2
            end
            S2: begin
                x = 1'b1;              // Saída alta durante este estado
                next_state = IDLE;     // Volta para IDLE
            end
            default: next_state = IDLE; // Estado padrão de segurança
        endcase
    end

endmodule
