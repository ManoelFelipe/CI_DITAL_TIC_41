`timescale 1ns / 1ps // 1GHz = 1ns period

module tb_exercise2;

    reg clk;
    reg reset;
    reg enable; // Enable do TX
    reg rx_enable; // Enable do RX

    reg [8:0] tx_data_in;
    wire tx_wire;

    wire [8:0] rx_data_out;
    wire rx_valid;
    wire rx_code_err;
    wire rx_disp_err;

    // --- INSTÂNCIA DO TX (Transmitter) ---
    serdes_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .data_in(tx_data_in),
        .tx_out(tx_wire)
    );

    // --- INSTÂNCIA DO RX (Receiver) ---
    serdes_rx rx_inst (
        .clk(clk),
        .reset(reset),
        .rx_in(tx_wire),
        .enable(rx_enable),
        .data_out(rx_data_out),
        .data_valid(rx_valid),
        .code_err(rx_code_err),
        .disp_err(rx_disp_err)
    );

    // Clock de 1GHz -> Período 1ns -> Toggle a cada 0.5ns
    always #0.5 clk = ~clk;

    // Definições de Caracteres
    localparam K28_1 = 9'b1_0011_1100; // Start Frame
    localparam K28_5 = 9'b1_1011_1100; // End Frame
    // Payload Data (Qualquer coisa com K=0)
    localparam D_AA  = 9'b0_1010_1010; 
    localparam D_55  = 9'b0_0101_0101; 

    initial begin
        // Inicialização
        clk = 0;
        reset = 1;
        enable = 0;
        rx_enable = 0;
        tx_data_in = 0;
        
        $dumpfile("exercise2_wave.vcd");
        $dumpvars(0, tb_exercise2);

        #10;
        reset = 0;
        rx_enable = 1; // RX sempre habilitado para ouvir

        // --- EXERCÍCIO 2: SEQUÊNCIA ESPECÍFICA ---
        
        // 1. Start of frame: Data_in = 100111100 (K28.1)
        // "Dica: enable deve ser assertado um clock depois da entrada"
        
        $display("--- Step 1: Start Frame (K28.1) ---");
        @(posedge clk);
        tx_data_in = K28_1;
        
        @(posedge clk); // Delay de 1 clock
        enable = 1; // Habilita TX
        
        // Wait for PISO load (internal logic loads every 10 cycles, but first load happens when counter wraps? 
        // Need to check serdes_tx logic. It loads at bit_counter=9.
        // Initially 0. It counts 0..9.
        // We need to wait for it to actually accept the data.
        
        // Vamos manter o dado estável até o próximo "load slot".
        // O tb_serdes original esperava `wait(tx_inst.load_piso == 1)`.
        wait(tx_inst.load_piso == 1);
        $display("TX Loaded Start Frame: %h", tx_data_in);
        
        // 2. Payload Data
        // Envio de conjuntos de dados. Vamos enviar 2 dados exemplo.
        
        @(negedge tx_inst.load_piso); // Wait for load edge
        
        $display("--- Step 2: Payload Data 1 (0xAA) ---");
        // Prepara próximo dado
        tx_data_in = D_AA;
        
        // Wait for next load
        wait(tx_inst.load_piso == 1);
        $display("TX Loaded Payload 1: %h", tx_data_in);
        
        @(negedge tx_inst.load_piso);
        
        $display("--- Step 2: Payload Data 2 (0x55) ---");
        tx_data_in = D_55;
        
        wait(tx_inst.load_piso == 1);
        $display("TX Loaded Payload 2: %h", tx_data_in);
        
        @(negedge tx_inst.load_piso);

        // 3. End of frame: Data_in = 110111100 (K28.5)
        
        $display("--- Step 3: End Frame (K28.5) ---");
        tx_data_in = K28_5;
        
        wait(tx_inst.load_piso == 1);
        $display("TX Loaded End Frame: %h", tx_data_in);
        
        @(negedge tx_inst.load_piso);
        enable = 0; // Desabilita após mandar o último
        $display("--- Transmission Ended ---");

        #50; // Wait for RX to flush
        
        $display("=== Reviewing RX Log should happen above ===");
        $finish;
    end
    
    reg [7:0] type_char; // Variável auxiliar para monitoramento

    // Monitor
    always @(posedge clk) begin
        if (rx_valid) begin
           if (rx_data_out[8]) type_char = "K"; else type_char = "D";
           
           $display("[RX RECV] Time=%t | Data=%h (%s) | Error=%b", 
                    $time, rx_data_out, type_char, {rx_code_err, rx_disp_err});
                    
           if (rx_code_err | rx_disp_err) $display("ERROR DETECTED!");
        end
    end

    // Debug Monitor
    always @(posedge clk) begin
        // Display parallel_data every time it looks like a Comma, or just periodically
        if (rx_inst.is_comma) begin
            $display("[DEBUG] Comma Detected! Data=%b", rx_inst.parallel_data);
        end
        // Uncomment to see every stream word (spammy)
        // $display("[DEBUG STREAM] %b (Aligned=%b) (DataIn=%h)", rx_inst.parallel_data, rx_inst.aligned, tx_data_in);
    end

endmodule
