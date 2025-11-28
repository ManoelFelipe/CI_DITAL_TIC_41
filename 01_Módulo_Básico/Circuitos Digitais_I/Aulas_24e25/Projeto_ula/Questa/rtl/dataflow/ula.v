// ============================================================================
// Arquivo  : ula.v  (implementacao Dataflow)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Comatível com Quartus e Questa (Verilog 2001)
// Descricao: ULA de 4 bits com 8 operacoes combinacionais, descrita em estilo
//            majoritariamente dataflow via atribuicoes continuas. As operacoes
//            logicas e aritmeticas simples sao pre-calculadas em wires internos
//            e depois multiplexadas em um barramento de 8 bits. A divisao inteira
//            possui tratamento explicito de divisor zero em um bloco always @*,
//            evitando warnings de simulacao e preservando a mesma convencao de
//            quociente/resto utilizada nas demais abordagens.
// Revisao  : v1.1 — divisao protegida sem warnings de simulacao
// ============================================================================

// Modulo: ula_dataflow
// Estrategia: rede combinacional explicita com wires para cada operacao.
//             A divisao inteira e encapsulada em um pequeno bloco combinacional
//             (always @*), utilizado apenas para montar {resto,quociente} de
//             forma segura, sem divisao por zero em tempo de simulacao.
module ula_dataflow (
    input  [3:0] op_a,      // Operando A (4 bits)
    input  [3:0] op_b,      // Operando B (4 bits)
    input  [2:0] seletor,   // Codigo da operacao (3 bits)
    output [7:0] resultado  // Barramento de saida (8 bits)
);
    // ------------------------------------------------------------------------
    // Bloco de operacoes basicas em dataflow (nivel de wires internos)
    // ------------------------------------------------------------------------

    // Operacoes logicas de 4 bits
    wire [3:0] and_4  = op_a & op_b;      // AND bit a bit
    wire [3:0] or_4   = op_a | op_b;      // OR bit a bit
    wire [3:0] not_4  = ~op_a;            // NOT apenas de op_a
    wire [3:0] nand_4 = ~(op_a & op_b);   // NAND bit a bit

    // Operacoes aritmeticas de 4 bits (soma e subtracao)
    wire [3:0] add_4 = op_a + op_b;       // Soma com truncamento natural a 4 bits
    wire [3:0] sub_4 = op_a - op_b;       // Subtracao com truncamento a 4 bits

    // Multiplicacao 4x4 = 8 bits sem truncamento
    wire [7:0] mul_8 = op_a * op_b;       // Produto completo em 8 bits

    // ------------------------------------------------------------------------
    // Divisao com protecao contra divisor zero (comportamento idêntico
    // ao das demais abordagens, porem sem warnings de simulacao).
    // resultado_div[3:0] = quociente
    // resultado_div[7:4] = resto
    // Convencao: se op_b == 0 => quociente = 0, resto = op_a.
    // ------------------------------------------------------------------------
    reg  [7:0] resultado_div;             // Registrador combinacional interno

    always @* begin
        // Verifica explicitamente o divisor
        if (op_b == 4'b0000) begin
            // Caso especial: divisao por zero
            // quociente = 0, resto = op_a
            resultado_div[3:0] = 4'b0000; // quociente
            resultado_div[7:4] = op_a;    // resto
        end else begin
            // Divisao inteira normal
            resultado_div[3:0] = op_a / op_b; // quociente
            resultado_div[7:4] = op_a % op_b; // resto
        end
    end

    wire [7:0] res_div = resultado_div;   // Wire para integrar com o restante

    // ------------------------------------------------------------------------
    // Adequacao das larguras: zero-extend das operacoes de 4 bits para 8 bits
    // ------------------------------------------------------------------------
    wire [7:0] res_and  = {4'b0000, and_4};   // AND estendido para 8 bits
    wire [7:0] res_or   = {4'b0000, or_4};    // OR estendido
    wire [7:0] res_not  = {4'b0000, not_4};   // NOT de op_a estendido
    wire [7:0] res_nand = {4'b0000, nand_4};  // NAND estendido
    wire [7:0] res_add  = {4'b0000, add_4};   // Soma estendida
    wire [7:0] res_sub  = {4'b0000, sub_4};   // Subtracao estendida
    wire [7:0] res_mul  = mul_8;              // Multiplicacao ja em 8 bits

    // ------------------------------------------------------------------------
    // Multiplexacao dataflow em um unico barramento de saida
    // ------------------------------------------------------------------------
    assign resultado =
           (seletor == 3'b000) ? res_and  : // AND
           (seletor == 3'b001) ? res_or   : // OR
           (seletor == 3'b010) ? res_not  : // NOT (op_a)
           (seletor == 3'b011) ? res_nand : // NAND
           (seletor == 3'b100) ? res_add  : // Soma
           (seletor == 3'b101) ? res_sub  : // Subtracao
           (seletor == 3'b110) ? res_mul  : // Multiplicacao
                                  res_div;   // Divisao (111)
endmodule
