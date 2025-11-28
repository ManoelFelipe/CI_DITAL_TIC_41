// Módulo Latch SR Gated (Chaveado) usando portas NOR
module Latch_SR_NOR (
    input S,      // Entrada Set (definir)
    input R,      // Entrada Reset (redefinir)
    input clock,  // Sinal de Clock (habilitação)
    output Qa,    // Saída Q
    output Qb     // Saída Q barrado (complemento de Q)
);

    wire S_g, R_g; // Fios internos para os sinais "gated" (chaveados)

    // Lógica de Gating (Chaveamento)
    // O sinal S só passa se o clock estiver em nível alto (1)
    assign S_g = S & clock; 
    // O sinal R só passa se o clock estiver em nível alto (1)
    assign R_g = R & clock;

    // Latch SR construído com portas NOR
    // A saída Qa é o resultado da operação NOR entre R_g e Qb
    nor (Qa, R_g, Qb);
    // A saída Qb é o resultado da operação NOR entre S_g e Qa
    nor (Qb, S_g, Qa);

endmodule
