// ============================================================
//  divRDA_FSM.v
//  Divisor binário sem sinal - Algoritmo Restaurador (RDA)
//  Implementação comportamental baseada no pseudocódigo do slide.
//
//  Interface compatível com a versão NRDA para permitir comparação.
//
//  Algoritmo Implementado:
//  A := 0
//  M := divisor
//  Q := dividendo
//  para i = n-1 .. 0:
//      AQ << 1
//      A := A - M
//      se A(n) == 0 então q(i) := 1
//      senão q(i) := 0;  A := A + M  (restauração)
//  fim
// ============================================================
module divRDA_FSM #(parameter N = 8)
(
    input  wire         clk,        // Clock do sistema
    input  wire         reset,      // Reset assíncrono (ativo alto)
    input  wire         start,      // Sinal de inicio da operação
    input  wire [N-1:0] dividend,   // Operando Dividendo (Numerador)
    input  wire [N-1:0] divisor,    // Operando Divisor (Denominador)
    output wire [N-1:0] quotient,   // Resultado Quociente
    output wire [N-1:0] remainder,  // Resultado Resto
    output reg          ready       // Sinaliza fim da operação
);

    // --------- Estados da Máquina de Estados Finita (FSM) -------------------
    localparam ESPERA   = 3'b000; // Estado ocioso, aguardando 'start'
    localparam INICIO   = 3'b001; // Estado de inicialização dos registros
    localparam DESLOCA  = 3'b010; // Estado de deslocamento à esquerda (Shift)
    localparam SUBTRAI  = 3'b011; // Estado de subtração (A = A - M)
    localparam COMPARA  = 3'b100; // Estado de comparação e decisão do bit do quociente
    localparam RESTAURA = 3'b101; // Estado de restauração do resto (se subtração negativa)

    reg [2:0] estado_atual, prox_estado; // Registradores de estado

    // --------- Registradores internos do Algoritmo -------
    reg signed [N:0] regA; // Registrador A (Acumulador/Resto parcial), N+1 bits para sinal
    reg [N-1:0]      regQ; // Registrador Q (Quociente/Dividendo inicial)
    reg [N-1:0]      regM; // Registrador M (Divisor)
    integer          i;    // Contador de iterações do laço

    // Saídas mapeadas diretamente para os registradores internos
    assign quotient  = regQ;
    assign remainder = regA[N-1:0]; // O resto são os N bits menos significativos de A

    // --------------------------------------------------------------
    // Processo sequencial para armazenar o estado atual da FSM
    // --------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            estado_atual <= ESPERA; // Vai para o estado inicial no reset
        else
            estado_atual <= prox_estado; // Atualiza para o próximo estado na borda do clock
    end

    // --------------------------------------------------------------
    // FSM — Lógica combinacional para Transição de Estados
    // Define qual será o próximo estado baseado no estado atual e entradas
    // --------------------------------------------------------------
    always @(*) begin
        case (estado_atual)
            // Se 'start' for acionado, inicia a divisão. Caso contrário, aguarda.
            ESPERA:   prox_estado = (start) ? INICIO : ESPERA;
            
            // Vai incondicionalmente para o deslocamento após inicializar
            INICIO:   prox_estado = DESLOCA;
            
            // Após deslocar, realiza a subtração
            DESLOCA:  prox_estado = SUBTRAI;
            
            // Após subtrair, vai comparar o resultado (verificar sinal de A)
            SUBTRAI:  prox_estado = COMPARA;
            
            // Analisa o resultado da subtração
            COMPARA: begin
                // Se o bit de sinal de A (regA[N]) for 1, o resultado foi negativo.
                // Precisamos restaurar o valor de A (fazer A + M). isso tem prioridade.
                if (regA[N] == 1'b1)
                    prox_estado = RESTAURA;
                // Se não negativo e o contador chegou a N, terminamos o laço.
                else if (i == N)
                    prox_estado = ESPERA;
                // Caso contrário (não negativo e i < N), volta a deslocar para o próximo bit.
                else
                    prox_estado = DESLOCA;
            end
            
            // Se precisou restaurar, verifca se já acabou (i==N) para sair, senão volta a deslocar
            RESTAURA: prox_estado = (i == N) ? ESPERA : DESLOCA;
            
            // Estado padrão de segurança
            default:  prox_estado = ESPERA;
        endcase
    end

    // --------------------------------------------------------------
    // Processo sequencial para atualizar registradores (Datapath)
    // Executa as operações aritméticas e lógicas em cada estado
    // --------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reseta todos os registros
            regA  <= 0;
            regQ  <= 0;
            regM  <= 0;
            i     <= 0;
            ready <= 1'b0;
        end
        else begin
            case (estado_atual)
                ESPERA: begin
                    // Garante que ready fique baixo enquanto espera
                    ready <= 1'b0;
                end
                INICIO: begin
                    // Inicializa os registradores com as entradas
                    regA  <= 0;          // A começa zerado
                    regQ  <= dividend;   // Q recebe o Dividendo
                    regM  <= divisor;    // M recebe o Divisor
                    i     <= 0;          // Zera o contador de iterações
                end
                DESLOCA: begin
                    // Deslocamento à esquerda do par {A, Q} (Concatenação)
                    // O MSB de Q entra no LSB de A
                    regA <= {regA[N-1:0], regQ[N-1]};
                    regQ <= {regQ[N-2:0], 1'b0}; // Desloca Q preenchendo com 0
                    i    <= i + 1;               // Incrementa iteração
                end
                SUBTRAI: begin
                    // Subtrai o divisor de A: A := A - M
                    // Usa concatenação {1'b0, regM} para garantir operação sem sinal correto se N bit
                    regA <= regA - {1'b0, regM};
                end
                COMPARA: begin
                    // Verifica o bit de sinal de A (MSB, bit N)
                    // Se A >= 0 (bit N == 0), o bit correspondente do quociente é 1
                    if (regA[N] == 1'b0) begin
                        regQ[0] <= 1'b1; // Define LSB de Q como 1
                        
                        // Se não precisamos restaurar e é a última iteração, terminamos.
                        if (i == N)
                            ready <= 1'b1;
                    end
                    else begin
                        // Se A < 0 (bit N == 1), o bit do quociente é 0.
                        regQ[0] <= 1'b0; 
                        // O estado seguinte será RESTAURA para corrigir A
                    end
                end
                RESTAURA: begin
                    // Restaura o valor de A somando M: A := A + M
                    regA <= regA + {1'b0, regM};
                    
                    // Se esta foi a última iteração, sinaliza pronto após a restauração
                    if (i == N)
                        ready <= 1'b1;
                end
            endcase
        end
    end

endmodule
