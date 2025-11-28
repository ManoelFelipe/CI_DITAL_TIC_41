// ============================================================================
// Arquivo  : reg_piso_n.v  (implementação STRUCTURAL)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Registrador de deslocamento PISO de N bits.
//            Implementado instanciando MUXes e Flip-Flops explicitamente.
//            Utiliza generate loop para criar a cadeia de N estágios.
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

    wire [N-1:0] q;        // Saídas dos FFs
    wire [N-1:0] d;        // Entradas dos FFs
    wire [N-1:0] shift_in; // Sinal de entrada de deslocamento para cada bit

    genvar i;
    generate
        for (i = 0; i < N; i = i + 1) begin : gen_stages
            
            // Lógica de conexão do deslocamento baseada em DIR
            if (DIR == 0) begin // Shift Right (>>): bit i recebe de i+1
                if (i == N-1) assign shift_in[i] = 1'b0; // MSB recebe 0
                else          assign shift_in[i] = q[i+1];
            end else begin      // Shift Left (<<): bit i recebe de i-1
                if (i == 0)   assign shift_in[i] = 1'b0; // LSB recebe 0
                else          assign shift_in[i] = q[i-1];
            end

            // Multiplexador para selecionar entre Carga (din) ou Deslocamento (shift_in)
            // Se load=1 -> seleciona din[i]
            // Se load=0 -> seleciona shift_in[i]
            my_mux2 mux_inst (
                .sel(load),
                .a(shift_in[i]), // Entrada 0 (Shift)
                .b(din[i]),      // Entrada 1 (Load)
                .y(d[i])
            );

            // Flip-Flop D
            my_dff dff_inst (
                .clk(clk),
                .rst_n(rst_n),
                .d(d[i]),
                .q(q[i])
            );
        end
    endgenerate

    // Saída serial: LSB se DIR=0, MSB se DIR=1
    assign dout = (DIR == 0) ? q[0] : q[N-1];

endmodule

// ============================================================================
// Sub-módulos Auxiliares
// ============================================================================

// Multiplexador 2:1
module my_mux2 (
    input  wire sel,
    input  wire a, // sel=0
    input  wire b, // sel=1
    output wire y
);
    assign y = (sel) ? b : a;
endmodule

// Flip-Flop D com Reset Assíncrono
module my_dff (
    input  wire clk,
    input  wire rst_n,
    input  wire d,
    output reg  q
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) q <= 1'b0;
        else        q <= d;
    end
endmodule
