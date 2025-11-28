// ============================================================================
// tb_csa_multiplier.v — Testbench completo para multiplicador com CSA
// Autor: Manoel Furtado
// Data: 10/11/2025
// Exercita todas as combinações 4x4 (0..15) e verifica produto esperado.
// Gera VCD e imprime mensagens formatadas.
// ============================================================================
`timescale 1ns/1ps

module tb_csa_multiplier;
    // DUT parametrizado
    localparam WIDTH = 4;

    reg  [WIDTH-1:0] multiplicand;
    reg  [WIDTH-1:0] multiplier;
    wire [2*WIDTH-1:0] product;

    // Instância (altere a pasta/IMPLEMENTATION via compile.do)
    csa_multiplier #(.WIDTH(WIDTH)) dut (
        .multiplicand(multiplicand),
        .multiplier(multiplier),
        .product(product)
    );

    integer i, j;
    integer errors;
    reg [2*WIDTH-1:0] expected;

    // Dump de ondas (VCD)
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_csa_multiplier);
    end

    // Estímulos
    initial begin
        errors = 0;
        // Varre todas as combinações
        for (i = 0; i < (1<<WIDTH); i = i + 1) begin
            for (j = 0; j < (1<<WIDTH); j = j + 1) begin
                multiplicand = i[WIDTH-1:0];
                multiplier   = j[WIDTH-1:0];
                expected     = i * j;
                #10;
                if (product !== expected) begin
                    $display("ERRO: A=%0d, B=%0d, DUT=%0d, ESPERADO=%0d", i, j, product, expected);
                    errors = errors + 1;
                end else begin
                    $display("OK:   A=%0d, B=%0d, PROD=%0d", i, j, product);
                end
            end
        end

        if (errors == 0) begin
            $display("Teste bem-sucedido. Nenhum erro encontrado.");
        end else begin
            $display("Teste falhou. Total de erros = %0d", errors);
        end

        $display("Fim da simcsa_multipliercao.");
        $finish;
    end
endmodule
