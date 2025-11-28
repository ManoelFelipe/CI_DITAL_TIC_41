// ============================================================================
// Arquivo  : reg_sipo_8_struct.v (implementação Structural)
// Autor    : Manoel Furtado
// Data     : 25/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Registrador SIPO de 8 bits estrutural.
//            Composto por 8 Flip-Flops D e Multiplexadores 2:1.
// Revisão   : v1.0 — criação inicial
// ============================================================================

module reg_sipo_8_struct (
    input  wire       clk,    // Clock do sistema
    input  wire       rst,    // Reset assíncrono (ativo alto)
    input  wire       din,    // Entrada serial de dados
    input  wire       dir,    // Direção: 0=Direita, 1=Esquerda
    output wire [7:0] q       // Saída paralela de 8 bits
);

    // Fios internos para interconexão dos estágios
    wire [7:0] d_in; // Entrada D de cada Flip-Flop

    // Instanciação dos 8 bits usando generate para clareza (opcional, mas bom para estrutural repetitivo)
    // Mas faremos manual para ser puramente estrutural clássico se preferir, 
    // ou generate que é suportado no 2001. Vou usar generate para ser conciso e elegante.
    
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_sipo
            // Lógica do Mux para cada bit:
            // Se dir=0 (Direita): bit i recebe do bit i+1 (ou din se i=7)
            // Se dir=1 (Esquerda): bit i recebe do bit i-1 (ou din se i=0)
            
            wire shift_right_in;
            wire shift_left_in;

            // Definindo a entrada de deslocamento à direita (vem da esquerda/MSB)
            if (i == 7) begin
                assign shift_right_in = din;
            end else begin
                assign shift_right_in = q[i+1];
            end

            // Definindo a entrada de deslocamento à esquerda (vem da direita/LSB)
            if (i == 0) begin
                assign shift_left_in = din;
            end else begin
                assign shift_left_in = q[i-1];
            end

            // Mux 2:1 para selecionar a entrada do FF baseada em 'dir'
            // dir=0 -> shift_right_in
            // dir=1 -> shift_left_in
            assign d_in[i] = (dir == 1'b0) ? shift_right_in : shift_left_in;

            // Instância do Flip-Flop D
            d_ff_struct ff_inst (
                .clk(clk),
                .rst(rst),
                .d(d_in[i]),
                .q(q[i])
            );
        end
    endgenerate

endmodule

// Submódulo Flip-Flop D auxiliar para a abordagem estrutural
module d_ff_struct (
    input  wire clk,
    input  wire rst,
    input  wire d,
    output reg  q
);
    always @(posedge clk or posedge rst) begin
        if (rst)
            q <= 1'b0;
        else
            q <= d;
    end
endmodule
