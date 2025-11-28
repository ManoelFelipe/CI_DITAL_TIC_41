// ============================================================================
// Arquivo  : reg_piso_n.v  (implementação DATAFLOW)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Registrador de deslocamento PISO de N bits.
//            Utiliza atribuição contínua (assign) para lógica de próximo estado.
//            Latência de 1 ciclo.
// Revisão  : v1.0 — criação inicial
// ============================================================================

module reg_piso_n #(
    parameter N = 8,
    parameter DIR = 0 // 0: Direita, 1: Esquerda
)(
    input  wire         clk,
    input  wire         rst_n,
    input  wire         load,
    input  wire [N-1:0] din,
    output wire         dout
);

    reg  [N-1:0] shift_reg;
    wire [N-1:0] next_shift_reg;

    // Lógica Combinacional (Dataflow): Determina o próximo valor do registrador
    // Se load=1, próximo é din.
    // Se load=0, desloca baseado em DIR.
    assign next_shift_reg = (load) ? din :
                            (DIR == 0) ? {1'b0, shift_reg[N-1:1]} : // Shift Right
                                         {shift_reg[N-2:0], 1'b0};  // Shift Left

    // Lógica Sequencial: Atualização do estado
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) shift_reg <= {N{1'b0}};
        else        shift_reg <= next_shift_reg;
    end

    // Saída serial
    assign dout = (DIR == 0) ? shift_reg[0] : shift_reg[N-1];

endmodule
