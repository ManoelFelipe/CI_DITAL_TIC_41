//------------------------------------------------------------------------------
// ieee754_adder.v (Behavioral) — Soma IEEE 754 precisão simples (positivos)
// Compatível com Verilog‑2001, Quartus e Questa
//------------------------------------------------------------------------------
// Regras/assumptions:
// - Considera apenas operandos não‑negativos (bit de sinal = 0).
// - Não trata NaN/Inf/Subnormais em profundidade (entrada 0 funciona).
// - Rounding: "round toward zero" (corte dos bits extras).
// - Propósito didático: legibilidade e comentários linha a linha.
//------------------------------------------------------------------------------
module ieee754_adder (
    input  [31:0] a,          // operando A (IEEE754 single)
    input  [31:0] b,          // operando B (IEEE754 single)
    output [31:0] result      // resultado (IEEE754 single)
);
    // Quebra dos campos
    // sinal[31], expoente[30:23], mantissa[22:0]
    reg  [7:0]  exp_a, exp_b;              // expoentes
    reg  [23:0] man_a, man_b;              // mantissas com bit implícito
    reg  [24:0] sum_man;                   // soma de mantissas (pode ter carry)
    reg  [7:0]  exp_big, exp_out;          // expoente escolhido e final
    reg  [4:0]  shift;                      // deslocamento usado na normalização
    reg  [31:0] result_r;                  // registrador de saída

    // Liga a porta de saída
    assign result = result_r;

    // Bloco combinacional comportamental
    always @* begin
        // Extrai expoentes
        exp_a = a[30:23];
        exp_b = b[30:23];

        // Extrai mantissas e insere o 1 implícito para números normais
        man_a = (exp_a == 8'd0) ? {1'b0, a[22:0]} : {1'b1, a[22:0]};
        man_b = (exp_b == 8'd0) ? {1'b0, b[22:0]} : {1'b1, b[22:0]};

        // Se algum operando for zero, o outro prevalece (atalho simples)
        if (a[30:0] == 31'd0) begin
            result_r = b;
        end
        else if (b[30:0] == 31'd0) begin
            result_r = a;
        end
        else begin
            // Alinhamento de expoentes: define o maior para base
            if (exp_a >= exp_b) begin
                exp_big = exp_a;
                // desloca mantissa do operando menor
                man_b   = man_b >> (exp_a - exp_b);
            end else begin
                exp_big = exp_b;
                man_a   = man_a >> (exp_b - exp_a);
            end

            // Soma das mantissas estendidas (24 bits -> 25 bits)
            sum_man = {1'b0, man_a} + {1'b0, man_b};

            // Normalização pós-soma
            if (sum_man[24]) begin
                // Houve carry adicional -> desloca para direita e incrementa expoente
                sum_man = sum_man >> 1;
                exp_out = exp_big + 8'd1;
            end else begin
                // Sem carry — garantir o MSB em 1 para número normal
                shift = 0;
                // Encontrar posição do primeiro '1' a partir do bit 23
                // (limite 23 para evitar laço infinito em zero)
                while (sum_man[23-shift] == 1'b0 && shift < 23) begin
                    shift = shift + 1;
                end
                // Desloca à esquerda e ajusta expoente ao final
                sum_man = sum_man << shift;
                exp_out = (exp_big > shift) ? (exp_big - shift) : 8'd0;
            end

            // Montagem do resultado (sinal sempre 0 neste exercício)
            result_r[31]   = 1'b0;
            result_r[30:23]= exp_out;
            result_r[22:0] = sum_man[22:0]; // sem arredondamento (trunc)
        end
    end
endmodule
