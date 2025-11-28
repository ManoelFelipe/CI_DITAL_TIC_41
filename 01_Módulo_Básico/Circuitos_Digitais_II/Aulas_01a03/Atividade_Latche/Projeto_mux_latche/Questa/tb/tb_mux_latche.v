// ============================================================================
// Arquivo  : tb_mux_latche.v
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench para verificar o funcionamento do mux_latche.
//            Instancia as TRÊS abordagens (Behavioral, Dataflow, Structural)
//            simultaneamente e verifica se TODAS produzem o comportamento
//            esperado (incluindo o Latch em sel=11).
// Revisão   : v1.1 — Teste simultâneo das 3 abordagens
// ============================================================================

`timescale 1ns/1ps

module tb_mux_latche;

    // ========================================================================
    // Parâmetros e Sinais
    // ========================================================================
    parameter WIDTH = 8;

    reg  [1:0]       sel;
    reg  [WIDTH-1:0] in0, in1, in2, in3;
    
    // Saídas das 3 implementações
    wire [WIDTH-1:0] out_behav;
    wire [WIDTH-1:0] out_data;
    wire [WIDTH-1:0] out_struct;

    // Variável para contagem de erros
    integer errors = 0;

    // ========================================================================
    // Instâncias dos DUTs (Device Under Test)
    // ========================================================================
    
    mux_latche_behavioral #(.WIDTH(WIDTH)) dut_behav (
        .sel(sel), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out_behav)
    );

    mux_latche_dataflow #(.WIDTH(WIDTH)) dut_data (
        .sel(sel), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out_data)
    );

    mux_latche_structural #(.WIDTH(WIDTH)) dut_struct (
        .sel(sel), .in0(in0), .in1(in1), .in2(in2), .in3(in3), .out(out_struct)
    );

    // ========================================================================
    // Geração de VCD e Monitoramento
    // ========================================================================
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_mux_latche);
    end

    // ========================================================================
    // Estímulos e Verificação
    // ========================================================================
    initial begin
        // Inicialização
        sel = 0;
        in0 = 8'hAA;
        in1 = 8'hBB;
        in2 = 8'hCC;
        in3 = 8'hDD; 
        
        $display("==================================================");
        $display("Iniciando Simulacao Simultanea (Behav, Data, Struct)");
        $display("==================================================");
        
        #10;

        // --------------------------------------------------------------------
        // Teste 1: Seleção 00 (in0)
        // --------------------------------------------------------------------
        sel = 2'b00;
        #10;
        check_output(in0, "sel=00");

        // --------------------------------------------------------------------
        // Teste 2: Seleção 01 (in1)
        // --------------------------------------------------------------------
        sel = 2'b01;
        #10;
        check_output(in1, "sel=01");

        // --------------------------------------------------------------------
        // Teste 3: Seleção 10 (in2)
        // --------------------------------------------------------------------
        sel = 2'b10;
        #10;
        check_output(in2, "sel=10");

        // --------------------------------------------------------------------
        // Teste 4: Seleção 11 (Latch - Hold)
        // --------------------------------------------------------------------
        // O valor anterior era in2 (CC). Deve manter CC.
        sel = 2'b11;
        #10;
        check_output(8'hCC, "sel=11 (Latch Hold)");

        // --------------------------------------------------------------------
        // Teste 5: Robustez do Latch
        // --------------------------------------------------------------------
        // Alterar as entradas in2 e in3 enquanto sel=11. A saída NÃO deve mudar.
        in2 = 8'hFF;
        in3 = 8'h00;
        #10;
        check_output(8'hCC, "sel=11 (Latch Stability)");

        // --------------------------------------------------------------------
        // Teste 6: Recuperação
        // --------------------------------------------------------------------
        sel = 2'b00;
        #10;
        check_output(in0, "sel=00 (Recovery)");

        $display("==================================================");
        if (errors == 0) begin
            $display("SIMULACAO CONCLUIDA COM SUCESSO! Todas as 3 abordagens passaram.");
        end else begin
            $display("SIMULACAO FALHOU COM %d ERROS.", errors);
        end
        $display("==================================================");
        
        $display("Fim da simulacao.");
        $finish;
    end

    // Task para verificar as 3 saídas contra o valor esperado
    task check_output;
        input [WIDTH-1:0] expected_val;
        input [127:0] test_name;
        begin
            if (out_behav !== expected_val) begin
                $display("[ERRO BEHAV] %s. Esperado: %h, Obtido: %h", test_name, expected_val, out_behav);
                errors = errors + 1;
            end
            if (out_data !== expected_val) begin
                $display("[ERRO DATA]  %s. Esperado: %h, Obtido: %h", test_name, expected_val, out_data);
                errors = errors + 1;
            end
            if (out_struct !== expected_val) begin
                $display("[ERRO STRUCT] %s. Esperado: %h, Obtido: %h", test_name, expected_val, out_struct);
                errors = errors + 1;
            end
            
            if (out_behav === expected_val && out_data === expected_val && out_struct === expected_val) begin
                $display("[OK] %s. Saida correta: %h", test_name, expected_val);
            end
        end
    endtask

endmodule
