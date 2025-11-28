// ============================================================================
// Arquivo  : tb_ula.v  (testbench para ULA Behavioral/Dataflow/Structural)
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Comatível com Quartus e Questa (Verilog 2001)
// Descricao: Testbench auto-verificador para tres implementacoes da mesma ULA.
//            Gera estimulos cobrindo todo o espaco de entrada (a, b, seletor),
//            calcula o resultado esperado em um modelo de referencia e verifica
//            se todas as abordagens produzem resultados identicos ao modelo.
//            Exporta um arquivo VCD para inspecao de formas de onda.
// Revisao  : v1.0 — criacao inicial
// ============================================================================

`timescale 1ns/1ps

module tb_ula;
    // ---------------------------------------------------------------------
    // Declaracao de sinais de estimulo (entradas comuns aos DUTs)
    // ---------------------------------------------------------------------
    reg  [3:0] op_a;         // Operando A (4 bits)
    reg  [3:0] op_b;         // Operando B (4 bits)
    reg  [2:0] seletor;      // Codigo da operacao (3 bits)

    // Sinais de saida de cada implementacao (8 bits)
    wire [7:0] resultado_behavioral; // Saida da ULA behavioral
    wire [7:0] resultado_dataflow;   // Saida da ULA dataflow
    wire [7:0] resultado_structural; // Saida da ULA structural

    // Sinal de referencia para comparacao
    reg  [7:0] resultado_esperado;   // Resultado calculado no modelo de referencia

    // Contador de erros para diagnostico
    integer erro_count;              // Numero de divergencias encontradas

    // ---------------------------------------------------------------------
    // Instancias das tres abordagens da ULA
    // ---------------------------------------------------------------------
    ula_behavioral u_ula_behavioral (
        .op_a     (op_a),               // Conecta operando A
        .op_b     (op_b),               // Conecta operando B
        .seletor  (seletor),            // Conecta seletor
        .resultado(resultado_behavioral)// Saida behavioral
    );

    ula_dataflow u_ula_dataflow (
        .op_a     (op_a),               // Conecta operando A
        .op_b     (op_b),               // Conecta operando B
        .seletor  (seletor),            // Conecta seletor
        .resultado(resultado_dataflow)  // Saida dataflow
    );

    ula_structural u_ula_structural (
        .op_a     (op_a),               // Conecta operando A
        .op_b     (op_b),               // Conecta operando B
        .seletor  (seletor),            // Conecta seletor
        .resultado(resultado_structural)// Saida structural
    );

    // ---------------------------------------------------------------------
    // Geracao de arquivo de onda VCD para inspecao visual
    // ---------------------------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");  // Nome do arquivo VCD gerado
        $dumpvars(0, tb_ula);   // Registra todos os sinais do testbench
    end

    // ---------------------------------------------------------------------
    // Bloco de estimulo: varre todo o espaco de entrada e verifica resultados
    // ---------------------------------------------------------------------
    integer i; // indice para op_a
    integer j; // indice para op_b
    integer k; // indice para seletor

    initial begin
        // Inicializa contador de erros
        erro_count = 0;

        // Loop triplo: op_a, op_b e seletor
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                for (k = 0; k < 8; k = k + 1) begin
                    // Aplica valores atuais aos registradores de entrada
                    op_a    = i[3:0];      // Atribui os 4 LSB de i
                    op_b    = j[3:0];      // Atribui os 4 LSB de j
                    seletor = k[2:0];      // Atribui os 3 LSB de k

                    // Espera pequena defasagem para propagacao combinacional
                    #1;

                    // Calcula o resultado esperado com base na mesma convencao
                    case (seletor)
                        3'b000: begin
                            // AND bit a bit, estendido para 8 bits
                            resultado_esperado = {4'b0000, (op_a & op_b)};
                        end
                        3'b001: begin
                            // OR bit a bit, estendido para 8 bits
                            resultado_esperado = {4'b0000, (op_a | op_b)};
                        end
                        3'b010: begin
                            // NOT de op_a, estendido para 8 bits
                            resultado_esperado = {4'b0000, (~op_a)};
                        end
                        3'b011: begin
                            // NAND de op_a e op_b, estendido para 8 bits
                            resultado_esperado = {4'b0000, ~(op_a & op_b)};
                        end
                        3'b100: begin
                            // Soma op_a + op_b, truncada a 4 bits e estendida
                            resultado_esperado = {4'b0000, (op_a + op_b)};
                        end
                        3'b101: begin
                            // Subtracao op_a - op_b, truncada e estendida
                            resultado_esperado = {4'b0000, (op_a - op_b)};
                        end
                        3'b110: begin
                            // Multiplicacao 4x4 sem truncamento
                            resultado_esperado = op_a * op_b;
                        end
                        3'b111: begin
                            // Divisao inteira com tratamento de divisor zero
                            if (op_b == 4'b0000) begin
                                // Convencao: quociente = 0 e resto = op_a
                                resultado_esperado[3:0] = 4'b0000; // quociente
                                resultado_esperado[7:4] = op_a;    // resto
                            end else begin
                                // Divisao normal
                                resultado_esperado[3:0] = op_a / op_b; // quociente
                                resultado_esperado[7:4] = op_a % op_b; // resto
                            end
                        end
                        default: begin
                            // Default defensivo
                            resultado_esperado = 8'b0000_0000;
                        end
                    endcase

                    // Compara as tres implementacoes com o modelo de referencia
                    if ((resultado_behavioral !== resultado_esperado) ||
                        (resultado_dataflow   !== resultado_esperado) ||
                        (resultado_structural !== resultado_esperado)) begin
                        // Incrementa contador de erros e exibe mensagem detalhada
                        erro_count = erro_count + 1;
                        $display("ERRO: a=%0d b=%0d sel=%0d | esp=%b beh=%b data=%b str=%b",
                                 op_a, op_b, seletor,
                                 resultado_esperado,
                                 resultado_behavioral,
                                 resultado_dataflow,
                                 resultado_structural);
                    end
                end
            end
        end

        // Ao final dos loops, verifica se houve ou nao erro
        if (erro_count == 0) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes para todas as combinacoes.");
        end else begin
            $display("FIM COM ERROS: Foram encontrados %0d casos com divergencias.", erro_count);
        end

        // Mensagem final de encerramento da simulacao
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
