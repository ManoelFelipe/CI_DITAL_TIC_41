//=================================================================
// tb_rom_16x8_async.v
// Testbench para ROM 16 x 8 assíncrona
//=================================================================
`timescale 1ns/1ps

module tb_rom_16x8_async;

    reg  [3:0] address;
    wire [7:0] data_out;

    // Instancia o DUT (Device Under Test)
    rom_16x8_async dut (
        .data_out(data_out),
        .address(address)
    );

    // Memória de referência para checagem
    reg [7:0] expected [0:15];

    integer i;
    integer errors;

    initial begin
        // Inicializa tabela esperada
        expected[ 0] = 8'h00;
        expected[ 1] = 8'h11;
        expected[ 2] = 8'h22;
        expected[ 3] = 8'h33;
        expected[ 4] = 8'h44;
        expected[ 5] = 8'h55;
        expected[ 6] = 8'h66;
        expected[ 7] = 8'h77;
        expected[ 8] = 8'h88;
        expected[ 9] = 8'h99;
        expected[10] = 8'hAA;
        expected[11] = 8'hBB;
        expected[12] = 8'hCC;
        expected[13] = 8'hDD;
        expected[14] = 8'hEE;
        expected[15] = 8'hFF;

        errors  = 0;
        address = 0;

        $display("=== Iniciando teste da rom_16x8_async ===");

        // Varre todos os endereços
        for (i = 0; i < 16; i = i + 1) begin
            address = i[3:0];
            #5;  // tempo para propagação assíncrona

            if (data_out !== expected[i]) begin
                errors = errors + 1;
                $display("ERRO  addr=%0d  esperado=%h  obtido=%h  t=%0t",
                         i, expected[i], data_out, $time);
            end else begin
                $display("OK    addr=%0d  dado=%h  t=%0t",
                         i, data_out, $time);
            end
        end

        // Resumo
        if (errors == 0)
            $display("=== TESTE CONCLUÍDO: PASSOU sem erros ===");
        else
            $display("=== TESTE CONCLUÍDO: %0d erro(s) encontrado(s) ===", errors);

        $finish;
    end

endmodule
