// ============================================================================
// Arquivo  : ula.v  (implementacao Behavioral)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Comatível com Quartus e Questa (Verilog 2001)
// Descricao: ULA combinacional de 4 bits com 8 operacoes logicas e aritmeticas.
//            Entradas op_a e op_b de 4 bits, seletor de 3 bits e resultado de
//            8 bits, permitindo representar o produto completo da multiplicacao
//            4x4, bem como quociente e resto compactados na divisao inteira.
//            Bloco modelado de forma puramente comportamental com case
//            combinacional e atribuicoes blocantes, otimizavel em uma unica
//            etapa de logica combinacional na sintese.
// Revisao  : v1.0 — criacao inicial
// ============================================================================

// Modulo: ula_behavioral
// Estrategia: descreve a ULA em alto nivel usando um bloco always @* com case
//             sobre o seletor. Cada operacao e mapeada explicitamente a partir
//             dos operandos op_a e op_b, com sinal de saida de 8 bits.
module ula_behavioral (
    input  [3:0] op_a,      // Operando A (4 bits)
    input  [3:0] op_b,      // Operando B (4 bits)
    input  [2:0] seletor,   // Codigo da operacao (3 bits, 8 combinacoes)
    output reg [7:0] resultado // Resultado da operacao (8 bits)
);
    // Bloco always combinacional para descrever o comportamento da ULA
    always @* begin
        // Valor padrao para evitar inferencia de latch
        resultado = 8'b0000_0000; // Inicializa a saida com zero

        // Selecao de operacao com base no campo seletor
        case (seletor)
            3'b000: begin
                // Operacao 000: AND bit a bit entre op_a e op_b (4 bits)
                // Zero-extend para 8 bits posicionando o resultado nos bits menos significativos
                resultado = {4'b0000, (op_a & op_b)};
            end
            3'b001: begin
                // Operacao 001: OR bit a bit entre op_a e op_b (4 bits)
                // Zero-extend para 8 bits nos bits menos significativos
                resultado = {4'b0000, (op_a | op_b)};
            end
            3'b010: begin
                // Operacao 010: NOT bit a bit apenas sobre op_a (4 bits)
                // op_b e ignorado; resultado nos 4 LSB com extensao de zeros
                resultado = {4'b0000, (~op_a)};
            end
            3'b011: begin
                // Operacao 011: NAND bit a bit entre op_a e op_b (4 bits)
                // Primeiro AND, depois negacao bit a bit, truncado a 4 bits
                resultado = {4'b0000, ~(op_a & op_b)};
            end
            3'b100: begin
                // Operacao 100: soma inteira entre op_a e op_b (4 bits)
                // Resultado e truncado a 4 bits e depois estendido para 8 bits
                resultado = {4'b0000, (op_a + op_b)};
            end
            3'b101: begin
                // Operacao 101: subtracao inteira op_a - op_b (4 bits)
                // Resultado truncado a 4 bits e estendido para 8 bits
                resultado = {4'b0000, (op_a - op_b)};
            end
            3'b110: begin
                // Operacao 110: multiplicacao inteira op_a * op_b
                // Multiplicacao 4x4 produz ate 8 bits; nao ha truncamento.
                resultado = op_a * op_b;
            end
            3'b111: begin
                // Operacao 111: divisao inteira op_a / op_b com tratamento de divisor zero
                // Convencao: resultado[3:0]  = quociente
                //            resultado[7:4]  = resto
                if (op_b == 4'b0000) begin
                    // Caso especial: divisao por zero
                    // Quociente definido como 0 e resto igual ao dividendo
                    resultado[3:0] = 4'b0000; // quociente = 0
                    resultado[7:4] = op_a;    // resto = op_a
                end else begin
                    // Divisao inteira normal com quociente e resto modulo
                    resultado[3:0] = op_a / op_b; // quociente
                    resultado[7:4] = op_a % op_b; // resto
                end
            end
            default: begin
                // Caso default: reforca a saida como zero em situacao invalida
                resultado = 8'b0000_0000;
            end
        endcase
    end
endmodule
