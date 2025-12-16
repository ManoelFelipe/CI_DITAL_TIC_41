`timescale 1ns / 1ps

module tb_serdes;

    // Sinais globais
    reg clk;
    reg reset;
    reg enable;

    // Sinais TX
    reg [8:0] tx_data_in;
    wire tx_wire; // O fio serial único conectando TX e RX

    // Sinais RX
    wire [8:0] rx_data_out;
    wire rx_valid;
    wire rx_code_err;
    wire rx_disp_err;

    // Instancia o Transmissor
    serdes_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .data_in(tx_data_in),
        .tx_out(tx_wire)
    );

    // Instancia o Receptor
    // Conectamos o tx_wire diretamente no rx_in (Loopback perfeito)
    // Em um teste "criativo", poderíamos adicionar delay ou ruído neste fio.
    serdes_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx_in(tx_wire),
        .enable(enable),
        .data_out(rx_data_out),
        .data_valid(rx_valid),
        .code_err(rx_code_err),
        .disp_err(rx_disp_err)
    );

    // Geração de Clock (50MHz = 20ns periodo)
    always #10 clk = ~clk;

    // Variáveis para teste
    integer i;

    // Definição de K28.5
    // K=1, HGFEDCBA = 101 11100 (0xBC)
    localparam K28_5 = 9'b1_1011_1100;
    localparam D_0_0 = 9'b0_0000_0000;
    localparam D_10_2 = 9'b0_0100_1010; // Exemplo qualquer

    initial begin
        // Inicialização
        clk = 0;
        reset = 1;
        enable = 0;
        tx_data_in = 0;

        $display("=== Inicio da Simulacao SERDES ===");
        $dumpfile("serdes_wave.vcd");
        $dumpvars(0, tb_serdes);

        #100;
        reset = 0;
        enable = 1;
        
        // --- Fase 1: Enviar Caracteres de Sincronização (K28.5) ---
        // O RX precisa ver K28.5 para alinhar. Vamos enviar vários.
        // O TX envia um novo dado a cada 10 clocks.
        
        $display("--- Enviando Sequencia de Alinhamento (K28.5) ---");
        tx_data_in = K28_5; // Envia K28.5
        
        // Espera tempo suficiente para alguns frames (10 bits * 20ns = 200ns por frame)
        // Vamos esperar 5 frames
        #1000; 
        
        // --- Fase 2: Enviar Dados Úteis (Payload) ---
        // Vamos enviar uma sequência conhecida e verificar no waveform/console
        // "Oi" -> 'O' (0x4F), 'i' (0x69)
        
        $display("--- Enviando Dados Reais ---");
        
        @(posedge clk);
        wait(tx_inst.load_piso == 1); // Espera o TX estar pronto para aceitar dado
        tx_data_in = {1'b0, 8'h4F}; // 'O'
        $display("TX enviou: 'O' (0x4F)");
        
        @(negedge tx_inst.load_piso); // Espera o load passar
        wait(tx_inst.load_piso == 1); // Espera o proximo slot
        tx_data_in = {1'b0, 8'h69}; // 'i'
        $display("TX enviou: 'i' (0x69)");

        @(negedge tx_inst.load_piso);
        wait(tx_inst.load_piso == 1);
        tx_data_in = {1'b0, 8'h21}; // '!'
        $display("TX enviou: '!' (0x21)");
        
        // Volta a enviar Idle/Sync para manter o link vivo
        @(negedge tx_inst.load_piso);
        wait(tx_inst.load_piso == 1);
        tx_data_in = K28_5;
        $display("TX voltando para Idle (K28.5)");

        #1000;
        
        // --- Fase 3: Monitoramento de Erros ---
        if (rx_code_err || rx_disp_err) begin
             $display("ERRO DETECTADO no RX! CodeErr=%b DispErr=%b", rx_code_err, rx_disp_err);
        end else begin
             $display("Nenhum erro de protocolo detectado ate agora.");
        end

        $display("=== Fim do Teste ===");
        $finish;
    end

    // Monitor do RX
    always @(posedge clk) begin
        if (rx_valid) begin
            if (rx_data_out[8]) // K character
                $display("RX Recebeu K: %h (Alinhado: %b)", rx_data_out[7:0], rx_inst.aligned);
            else // Data character
                $display("RX Recebeu D: %h '%c'", rx_data_out[7:0], rx_data_out[7:0]);
        end
    end

endmodule
