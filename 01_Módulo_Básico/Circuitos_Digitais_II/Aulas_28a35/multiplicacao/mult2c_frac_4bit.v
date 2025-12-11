// -------------------------------------------------------------
// Multiplicador fracionário em Complemento de 2 (4 bits)
// Arquivo: mult2c_frac_4bit.v
//
// Descrição:
// Este módulo implementa um multiplicador sequencial para números
// fracionários com sinal (Q1.3), onde:
//  - 1 bit de sinal
//  - 3 bits de fração
//
// O algoritmo baseia-se na tradução comportamental do VHDL de Roth
// (entity mult2C), utilizando uma Máquina de Estados Finita (FSM).
// -------------------------------------------------------------

module mult2c_frac_4bit (
    input  wire       clk,       // Sinal de clock do sistema
    input  wire       st,        // Sinal de Start: inicia a multiplicação (pulso de 1 ciclo)
    input  wire [3:0] mplier,    // Entrada: Multiplicador (Multiplier) de 4 bits
    input  wire [3:0] mcand,     // Entrada: Multiplicando (Multiplicand) de 4 bits
    output wire [6:0] product,   // Saída: Produto final de 7 bits (resultado com sinal)
    output reg        done       // Saída: Sinaliza que o cálculo terminou (nível alto)
);

    // ---------------------------------------------------------
    // Definição dos Estados da FSM (Codificação One-Hot ou Binária)
    // ---------------------------------------------------------
    // S0: Estado de espera (Idle) - Aguarda sinal de start
    localparam S0_IDLE   = 3'd0;
    // S1, S2, S3: Estados de processamento dos 3 bits menos significativos (magnitude)
    localparam S1_BIT0   = 3'd1; // Processa bit 0
    localparam S2_BIT1   = 3'd2; // Processa bit 1
    localparam S3_BIT2   = 3'd3; // Processa bit 2
    // S4: Estado especial para tratar o bit de sinal (bit mais significativo)
    localparam S4_SIGN   = 3'd4;
    // S5: Estado final que sinaliza a conclusão
    localparam S5_CLEAR  = 3'd5;

    // Registrador de estado atual
    reg [2:0] state;

    // ---------------------------------------------------------
    // Datapath (Caminho de Dados)
    // ---------------------------------------------------------
    // Registradores internos A (Acumulador) e B (Multiplicador/Shift)
    reg [3:0] A; // Parte mais significativa do resultado parcial
    reg [3:0] B; // Parte menos significativa (inicialmente contém o multiplicador)

    // Variável, não registrador, para saída do somador combinacional
    // 5 bits para comportar o resultado da soma de 4 bits + carry/excesso
    reg [4:0] addout;

    // M é um alias para o bit menos significativo (LSB) do registrador B.
    // Ele determina se faremos uma soma ou apenas deslocamento.
    wire M = B[0];

    // O Produto é formado pela concatenação dos 3 bits LSB de A com todo o B.
    // Isso resulta em 7 bits (A[2:0] & B[3:0]). O bit A[3] é descartado/usado apenas internamente.
    // No VHDL original: Product <= A(2 downto 0) & B;
    assign product = { A[2:0], B };

    // ---------------------------------------------------------
    // Lógica Sequencial da FSM
    // ---------------------------------------------------------
    always @(posedge clk) begin
        case (state)
            // -------------------------------------------------
            // Estado S0: IDLE
            // -------------------------------------------------
            S0_IDLE: begin
                done <= 1'b0;        // Mantém sinal done baixo enquanto espera
                
                // Se receber o pulso de start (st=1):
                if (st) begin
                    A     <= 4'b0000;   // Zera o acumulador A
                    B     <= mplier;    // Carrega o multiplicador no registrador B
                    state <= S1_BIT0;   // Avança para o primeiro bit (estado S1)
                end
            end

            // -------------------------------------------------
            // Estados S1, S2, S3: Loop principal (Bits de Dados)
            // -------------------------------------------------
            // Nestes estados, processamos os 3 bits de fração positiva.
            // A lógica é comum para S1, S2 e S3.
            S1_BIT0,
            S2_BIT1,
            S3_BIT2: begin
                // Se o bit atual do multiplicador (M = B[0]) for 1:
                if (M) begin
                    // Realiza SOMA: Acumulador A + Multiplicando
                    // Concatenamos 0 à esquerda para tratar como unsigned/magnitude neste passo
                    addout = {1'b0, A} + {1'b0, mcand}; 

                    // Atualiza A e B com DESLOCAMENTO À DIREITA (Arithmetic Shift)
                    // O bit mais significativo de A recebe o bit de sinal do multiplicando original
                    // Os outros bits de A vêm do resultado da soma (addout)
                    A <= { mcand[3], addout[3:1] };
                    
                    // O registrador B recebe o bit 0 da soma (LSB de addout) entrando no seu MSB
                    // e desloca seus bits para a direita.
                    B <= { addout[0], B[3:1] };
                end
                // Se o bit atual do multiplicador (M) for 0:
                else begin
                    // Apenas DESLOCAMENTO À DIREITA (Shift) sem soma
                    // Preserva o bit de sinal de A (Shift Aritmético)
                    A <= { A[3], A[3:1] };
                    
                    // O bit 0 de A entra no topo de B
                    B <= { A[0], B[3:1] };
                end

                // Avança para o próximo estado (S1->S2, S2->S3, S3->S4)
                state <= state + 3'd1;
                
                // Garante que done permanece 0
                done  <= 1'b0;
            end

            // -------------------------------------------------
            // Estado S4: Tratamento do Sinal
            // -------------------------------------------------
            // Este é o estado crucial para Complemento de 2.
            // Se o bit de sinal do multiplicador for 1, devemos SUBTRAIR o multiplicando.
            S4_SIGN: begin
                if (M) begin
                    // Subtração em Complemento de 2 é equivalente a: Somar (~B + 1)
                    // Aqui somamos (A + ~mcand + 1)
                    addout = {1'b0, A} + {1'b0, ~mcand} + 5'b00001;

                    // Atualiza A com o resultado da subtração (Not Mcand(3) é o ajuste de sinal)
                    A <= { ~mcand[3], addout[3:1] };
                    
                    // Atualiza B deslocando o LSB da soma para dentro
                    B <= { addout[0], B[3:1] };
                end
                else begin
                    // Se o bit de sinal for 0, apenas faz shift aritmético normal final
                    A <= { A[3], A[3:1] };
                    B <= { A[0], B[3:1] };
                end

                // Próximo estado: Limpeza
                state <= S5_CLEAR;
                
                // Ativa o sinal DONE, indicando que o 'product' na saída é válido agora
                done  <= 1'b1;
            end

            // -------------------------------------------------
            // Estado S5: Finalização
            // -------------------------------------------------
            S5_CLEAR: begin
                done  <= 1'b0;    // Baixa o sinal de done (pulso durou 1 ciclo)
                state <= S0_IDLE; // Retorna ao estado de espera para nova operação
            end

            // -------------------------------------------------
            // Estado Default (Segurança)
            // -------------------------------------------------
            default: begin
                state <= S0_IDLE; // Se algo der errado, volta pro início
                done  <= 1'b0;
                A     <= 4'b0000;
                B     <= 4'b0000;
            end
        endcase
    end

    // ---------------------------------------------------------
    // Bloco Initial (Apenas para simulação)
    // ---------------------------------------------------------
    // Garante valores conhecidos no tempo t=0 da simulação
    initial begin
        state  = S0_IDLE;
        done   = 1'b0;
        A      = 4'b0000;
        B      = 4'b0000;
        addout = 5'b00000;
    end

endmodule
