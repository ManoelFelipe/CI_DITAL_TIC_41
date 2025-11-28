
// -----------------------------------------------------------------------------
// ponto_fixo_multi_8.v (Behavioral)
// -----------------------------------------------------------------------------
// Módulo: multiplicador de números em ponto fixo Qm.n parametrizável.
// Entrada: a, b (N bits cada).
// Saída : p_raw (2N bits - produto bruto, com 2*n bits fracionários),
//         p_qm_n (N bits - produto reescalado de volta para o mesmo formato dos
//                   operandos, com arredondamento para mais próximo),
//         overflow (indicador de saturação após o reescale).
// Observação: implementação comportamental (Verilog 2001).
// -----------------------------------------------------------------------------

module ponto_fixo_multi_8
#(
    parameter integer N      = 8,   // largura dos operandos
    parameter integer NFRAC  = 3,   // bits fracionários dos operandos
    parameter         SATURATE = 1  // 1: satura p_qm_n quando estoura; 0: apenas trunca
)
(
    input  wire [N-1:0]        a,   // operando A em Qm.n (sem sinal, didático)
    input  wire [N-1:0]        b,   // operando B em Qm.n (sem sinal, didático)
    output wire [2*N-1:0]      p_raw,     // produto bruto sem reescala (Q(2m).(2n))
    output reg  [N-1:0]        p_qm_n,    // produto reescalado para Qm.n
    output reg                 overflow    // flag de estouro após reescala
);

    // -------------------------------------------------------------------------
    // Produto inteiro "bruto". Em ponto fixo, multiplicar é igual a multiplicar
    // inteiros e depois ajustar a posição do ponto binário.
    // p_raw possui (2*NFRAC) bits fracionários.
    // -------------------------------------------------------------------------
    wire [2*N-1:0] mult_full = a * b;
    assign p_raw = mult_full;

    // -------------------------------------------------------------------------
    // Reescala para o mesmo formato Qm.n dos operandos (NFRAC bits fracionários)
    // usando arredondamento "round to nearest": soma 2^(NFRAC-1) antes do shift.
    // -------------------------------------------------------------------------
    localparam integer ROUND_BIAS = (NFRAC==0) ? 0 : (1 << (NFRAC-1));

    // valor arredondado antes de reduzir a largura
    wire [2*N-1:0] rounded = mult_full + ROUND_BIAS;

    // desloca NFRAC posições (de 2*NFRAC -> NFRAC bits fracionários)
    wire [2*N-1:0] scaled = (NFRAC==0) ? rounded : (rounded >> NFRAC);

    // -------------------------------------------------------------------------
    // Detecção de overflow na redução de 2N bits (scaled) para N bits (p_qm_n).
    // Se qualquer bit acima de N-1 estiver em '1', houve estouro no valor
    // reescalado. Quando SATURATE=1, clampeia em 0xFF...; caso contrário, trunca.
    // -------------------------------------------------------------------------
    wire sat_needed = |scaled[2*N-1:N];
    always @* begin
        overflow = sat_needed;
        if (sat_needed && SATURATE) begin
            p_qm_n = {N{1'b1}}; // saturação máxima (sem sinal)
        end else begin
            p_qm_n = scaled[N-1:0]; // truncamento (ou valor correto se não estourou)
        end
    end

endmodule
