// Definição do Módulo: Flip-Flop JK com Reset Assíncrono
module jk_ff (
    input  wire clk, // Sinal de Clock
    input  wire j,   // Entrada J
    input  wire k,   // Entrada K
    input  wire rst, // Sinal de Reset (Reinicialização)
    output reg  q    // Saída Q (tipo 'reg' pois recebe valor dentro de um 'always')
);

    // Bloco Always: Define o comportamento sequencial
    // A lista de sensibilidade inclui "posedge rst", tornando o reset ASSÍNCRONO.
    // O bloco é ativado na subida do clock OU na subida do reset.
    always @(posedge clk or posedge rst) begin
        
        // 1. Verificação do Reset (Prioridade Máxima)
        if (rst) begin
            // Se o reset for alto, a saída vai para 0 IMEDIATAMENTE,
            // sem esperar o clock e ignorando J e K.
            q <= 1'b0; 
        end
        
        // 2. Comportamento Síncrono (Funcionamento Normal)
        else begin
            // O comando 'case' analisa a concatenação das entradas J e K.
            // {j, k} cria um vetor de 2 bits. Ex: se j=1 e k=0, vira 2'b10.
            case ({j, k})
                
                // Caso J=0, K=0 -> Hold (Memória)
                2'b00: q <= q;    // Mantém o valor atual
                
                // Caso J=0, K=1 -> Reset
                2'b01: q <= 1'b0; // Força a saída para 0
                
                // Caso J=1, K=0 -> Set
                2'b10: q <= 1'b1; // Força a saída para 1
                
                // Caso J=1, K=1 -> Toggle (Comutação)
                2'b11: q <= ~q;   // Inverte o valor atual (0 vira 1, 1 vira 0)
                
            endcase
        end
    end

endmodule

