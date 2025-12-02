`timescale 1ns / 1ps

module fsm_mealy (
    input wire clk,
    input wire reset,
    input wire bi,     // Entrada de controle
    output reg bo      // Saída de status (Flag)
);

    // Codificação dos Estados (A=00, B=01, C=10)
    // Utilizando localparam pois são constantes internas do módulo
    localparam S_A = 2'b00;
    localparam S_B = 2'b01;
    localparam S_C = 2'b10;

    reg [1:0] state_reg, next_state;

    // 1. Lógica Sequencial (Registrador de Estado)
    always @(posedge clk or posedge reset) begin
        if (reset)
            state_reg <= S_A;
        else
            state_reg <= next_state;
    end

    // 2. Lógica do Próximo Estado (Next State Logic)
    always @(*) begin
        case (state_reg)
            S_A: begin
                if (bi) next_state = S_B;
                else    next_state = S_A;
            end
            S_B: begin
                if (bi) next_state = S_C;
                else    next_state = S_A;
            end
            S_C: begin
                if (bi) next_state = S_C;
                else    next_state = S_A;
            end
            default: next_state = S_A; // Recuperação segura de estados inválidos
        endcase
    end

    // 3. Lógica de Saída (Output Logic) - Arquitetura Mealy
    // Na máquina Mealy, a saída depende do estado atual E da entrada.
    always @(*) begin
        bo = 1'b0; // Valor padrão para evitar latches inferidos
        
        case (state_reg)
            S_A: begin
                // Se estamos em A e a entrada é 1 (transição para B), ativamos a saída.
                if (bi) bo = 1'b1; 
            end
            
            // Nos outros estados, a saída permanece 0
            S_B: bo = 1'b0;
            S_C: bo = 1'b0;
            
            default: bo = 1'b0;
        endcase
    end

endmodule