// ============================================================
//  divNRDA_FSM.v
//  Divisor binário sem sinal - Algoritmo Não Restaurador (NRDA)
//  Implementação comportamental baseada no pseudocódigo do slide.
//
//  Interface:
//      clk, reset, start: Controle
//      dividend, divisor: Entradas de dados
//      quotient, remainder: Saídas de dados
//      ready: Sinal de conclusão
//
//  Algoritmo Implementado (Non-Restoring Division):
//     A := 0
//     M := divisor
//     Q := dividendo
//     para i = n-1 .. 0:
//        A0 := A(n) (Sinal de A)
//        AQ << 1
//        se A0 = 0 então A := A - M
//        senão          A := A + M
//        se A(n) = 1 então Q(0) = 0
//        senão              Q(0) = 1
//     fim
//     se A(n) = 1 então A := A + M   (correção final do resto se negativo)
// ============================================================
module divNRDA_FSM #(parameter N = 8)
(   
    input  wire         clk,        // Clock do sistema
    input  wire         reset,      // Reset assíncrono
    input  wire         start,      // Pulso de início
    input  wire [N-1:0] dividend,   // Dividendo
    input  wire [N-1:0] divisor,    // Divisor
    output wire [N-1:0] quotient,   // Quociente calculado
    output wire [N-1:0] remainder,  // Resto calculado
    output reg          ready       // Flag de pronto
);

    // Definição dos Estados da FSM via parâmetros locais
    localparam ESPERA   = 3'b000; // Aguardando comando start
    localparam INICIO   = 3'b001; // Carregamento inicial dos registradores
    localparam DESLOCA  = 3'b010; // Deslocamento à esquerda de {A, Q}
    localparam ADD_SUB  = 3'b011; // Soma ou Subtração dependendo do sinal anterior
    localparam SET_Q    = 3'b100; // Definição do bit do quociente
    localparam AJUSTA   = 3'b101; // Correção final do resto (se necessário)

    reg [2:0] estado_atual, prox_estado; // Vetores de estado

    // Registradores internos (A, Q, M, contador i)
    reg signed [N:0] regA; // Acumulador/Resto (N+1 bits para sinal)
    reg [N-1:0]      regQ; // Quociente (inicializado com Dividendo)
    reg [N-1:0]      regM; // Divisor
    reg              a0;   // Armazena o bit de sinal de A antes do deslocamento
    integer          i;    // Contador de iterações

    // Atribuição contínua das saídas
    assign quotient  = regQ;
    assign remainder = regA[N-1:0]; // Resto é a parte baixa de A

    // ----------------- FSM: Processo Sequencial de Estado -----------------
    always @(posedge clk or posedge reset) begin
        if (reset)
            estado_atual <= ESPERA;
        else
            estado_atual <= prox_estado;
    end

    // ----------------- FSM: Lógica Combinacional de Próximo Estado --------------
    always @(*) begin
        case (estado_atual)
            // Se start=1, vai para INICIO, senão fica em ESPERA
            ESPERA:  prox_estado = (start) ? INICIO : ESPERA;
            
            // Vai para DESLOCA incondicionalmente
            INICIO:  prox_estado = DESLOCA;
            
            // Vai para ADD_SUB para operar aritméticamente
            DESLOCA: prox_estado = ADD_SUB;
            
            // Vai para SET_Q para definir bit do quociente
            ADD_SUB: prox_estado = SET_Q;
            
            // Se terminou iterações (i==N), vai para ajuste final, senão volta a DESLOCA
            SET_Q:   prox_estado = (i == N) ? AJUSTA : DESLOCA;
            
            // Termina e volta para ESPERA
            AJUSTA:  prox_estado = ESPERA;
            
            default: prox_estado = ESPERA;
        endcase
    end

    // ----------------- Processo Sequencial: Datapath e Controle --------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset de todos os registradores
            regA  <= 0;
            regQ  <= 0;
            regM  <= 0;
            a0    <= 0;
            i     <= 0;
            ready <= 1'b0;
        end
        else begin
            case (estado_atual)
                ESPERA: begin
                    ready <= 1'b0; // Mantém ready baixo
                end
                INICIO: begin
                    // Inicialização
                    regA <= 0;          // A zerado
                    regQ <= dividend;   // Carrega dividendo
                    regM <= divisor;    // Carrega divisor
                    i    <= 0;          // Zera contador
                    a0   <= 0;          // Zera flag de sinal auxiliar
                end
                DESLOCA: begin
                    // Captura MSB de A antes de deslocar (usado na decisão de ADD/SUB)
                    a0   <= regA[N];
                    
                    // Deslocamento à esquerda concatenado {A, Q}
                    regA <= {regA[N-1:0], regQ[N-1]};
                    regQ <= {regQ[N-2:0], 1'b0};
                    
                    // Incrementa contador de iterações
                    i    <= i + 1;
                end
                ADD_SUB: begin
                    // Se o sinal de A era positivo (a0==0), Subtrai M
                    // Se o sinal de A era negativo (a0==1), Soma M
                    if (a0 == 1'b0)
                        regA <= regA - {1'b0, regM};
                    else
                        regA <= regA + {1'b0, regM};
                end
                SET_Q: begin
                    // Define o bit do quociente (LSB de Q) baseado no NOVO sinal de A
                    // Se A(n) == 1 (negativo) -> Q(0) = 0
                    // Se A(n) == 0 (positivo) -> Q(0) = 1
                    if (regA[N] == 1'b1)
                        regQ[0] <= 1'b0;
                    else
                        regQ[0] <= 1'b1;

                    // Se foi a última iteração, sinaliza ready na próxima (no estado AJUSTA/fim)?
                    // O código original sinalizava ready aqui se i==N.
                    if (i == N)
                        ready <= 1'b1;
                end
                AJUSTA: begin
                    // Correção final do resto: O Resto deve ser positivo.
                    // Se o MSB de A for 1 (negativo), somamos M para restaurar o valor correto.
                    if (regA[N] == 1'b1)
                        regA <= regA + {1'b0, regM};
                    
                    // Nota: ready já foi setado em SET_Q, mas continua alto aqui até mudar estado
                    // (estado muda para ESPERA no próximo ciclo, onde ready zera).
                end
            endcase
        end
    end

endmodule
