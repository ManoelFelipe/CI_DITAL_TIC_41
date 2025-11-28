
`timescale 1ns/1ps

// ============================================================================
// Módulo: debounce
// Descrição: Implementa um circuito de debounce para botões mecânicos.
//            O debounce remove oscilações indesejadas (bouncing) que ocorrem
//            quando um botão é pressionado ou solto, garantindo um sinal limpo.
// ============================================================================

module debounce #(
    // Frequência do clock do sistema em Hz (padrão 100 MHz)
    parameter CLK_FREQ = 100_000_000,
    // Tempo de debounce desejado em milissegundos (padrão 10 ms)
    parameter DEBOUNCE_MS = 10
) (
    input wire clk,        // Clock do sistema
    input wire reset_n,    // Reset assíncrono ativo em nível baixo (0 = reset)
    input wire button_in,  // Sinal bruto vindo do botão físico (sujeito a ruído)
    output reg button_out  // Sinal limpo e estável do botão
);

    // Calcula o número máximo de ciclos de clock para atingir o tempo de debounce.
    // Fórmula: (Frequência / 1000) * Tempo_em_ms
    localparam COUNTER_MAX = (CLK_FREQ / 1000) * DEBOUNCE_MS;

    // Contador para medir o tempo de estabilidade do sinal
    integer counter;

    // Registradores para sincronização do sinal de entrada com o clock do sistema
    // Isso evita metaestabilidade.
    reg button_sync_0; // Primeiro estágio de sincronização
    reg button_sync_1; // Segundo estágio de sincronização (sinal sincronizado)

    // Bloco sequencial sensível à borda de subida do clock ou borda de descida do reset
    always @(posedge clk or negedge reset_n) begin
        // Verifica se o reset está ativo (nível baixo)
        if (!reset_n) begin
            // Reseta todos os registradores e o contador
            counter <= 0;
            button_out <= 0;
            button_sync_0 <= 0;
            button_sync_1 <= 0;
        end else begin
            // --- Sincronização ---
            // Captura o sinal de entrada no primeiro flip-flop
            button_sync_0 <= button_in;
            // Passa para o segundo flip-flop para completar a sincronização
            button_sync_1 <= button_sync_0;

            // --- Lógica de Debounce ---
            // Verifica se o sinal sincronizado (button_sync_1) é diferente da saída atual.
            // Se for diferente, significa que houve uma mudança de estado no botão.
            if (button_sync_1 != button_out) begin
                // Se o contador ainda não atingiu o tempo máximo de debounce...
                if (counter < COUNTER_MAX) begin
                    // Incrementa o contador. Estamos esperando o sinal estabilizar.
                    counter <= counter + 1;
                end else begin
                    // Se o contador atingiu o máximo, significa que o sinal ficou estável
                    // pelo tempo determinado (DEBOUNCE_MS).
                    // Atualiza a saída com o novo valor do botão.
                    button_out <= button_sync_1;
                    // Reseta o contador para a próxima detecção.
                    counter <= 0;
                end
            end else begin
                // Se o sinal sincronizado for igual à saída atual (não houve mudança ou
                // a mudança foi ruído passageiro que não durou o tempo suficiente),
                // zera o contador.
                counter <= 0;
            end
        end
    end

endmodule
