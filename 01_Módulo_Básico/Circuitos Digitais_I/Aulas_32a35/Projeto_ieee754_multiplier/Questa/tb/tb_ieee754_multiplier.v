
`timescale 1ns/1ps
// ============================================================================
// Testbench: tb_ieee754_multiplier
// Checagem automática com referência interna (algoritmo equivalente).
// Gera VCD, imprime campos e relata sucesso/falha.
// ============================================================================
module tb_ieee754_multiplier;

    // Entradas dirigidas como regs
    reg  [31:0] a;
    reg  [31:0] b;
    // Saída do DUT
    wire [31:0] result;

    // DUT — será mapeado por compile.do (behavioral|dataflow|structural)
    ieee754_multiplier dut (
        .a(a),
        .b(b),
        .result(result)
    );

    // Sinalizador de sucesso geral
    integer success;
    integer i;

    // Dump VCD para analisar ondas ------------------------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_ieee754_multiplier);
    end

    // ----------------------------------------------------------------------------
    // Função de referência bit-a-bit (mesmo algoritmo do behavioral)
    // Função de referência (Verilog-2001 puro)
    // Observação importante:
    //   Verilog-2001 NÃO permite slice direto sobre resultado de expressão.
    //   Portanto, usamos um registrador auxiliar 'prod_shift' antes do slice.
    // ----------------------------------------------------------------------------
    function [31:0] mul_ref;
        input [31:0] x;
        input [31:0] y;
        reg sign_x, sign_y, sign_r;
        reg [7:0] exp_x, exp_y, exp_r;
        reg [22:0] frac_x, frac_y, frac_r;
        reg [23:0] man_x, man_y;
        reg [47:0] prod;
        reg [47:0] prod_shift;   // <<< auxiliar para permitir slice em Verilog-2001
        reg [7:0] shift;
        integer k;
        begin
            // Extrai campos de x
            sign_x = x[31];
            exp_x  = x[30:23];
            frac_x = x[22:0];
            // Extrai campos de y
            sign_y = y[31];
            exp_y  = y[30:23];
            frac_y = y[22:0];

            // Sinal do resultado
            sign_r = sign_x ^ sign_y;

            // Zeros curtos
            if (((exp_x==0)&&(frac_x==0)) || ((exp_y==0)&&(frac_y==0))) begin
                mul_ref = 32'b0;
            end else begin
                // Reconstrói mantissas com bit oculto
                man_x = (exp_x==0) ? {1'b0, frac_x} : {1'b1, frac_x};
                man_y = (exp_y==0) ? {1'b0, frac_y} : {1'b1, frac_y};

                // Produto das mantissas
                prod = man_x * man_y;

                // Expoente parcial (sem normalização)
                exp_r = exp_x + exp_y - 8'd127;

                // Normalização
                if (prod[47]) begin
                    // Já está na forma 1.xxxxx * 2^n
                    frac_r = prod[46:24];
                    exp_r  = exp_r + 8'd1;
                end else begin
                    // Priority-encoder para achar o primeiro '1'
                    shift = 8'd0;
                    for (k = 46; (k >= 0) && (prod[k] == 1'b0); k = k - 1)
                        shift = shift + 1'b1;

                    // Verilog-2001: primeiro guardar em 'prod_shift' e só depois fazer o slice
                    prod_shift = prod << shift;
                    frac_r     = prod_shift[46:24];
                    exp_r      = exp_r - shift;
                end

                // Monta palavra IEEE754
                mul_ref = {sign_r, exp_r, frac_r};
            end
        end
    endfunction

    // Estímulos ------------------------------------------------------------------
    initial begin
        success = 1;

        // Vetores manuais (comentados com valores decimais)
        // 4.75 (0x40980000) * 2.125 (0x40080000) = 10.09375
        a = 32'h40980000;  // 4.75
        b = 32'h40080000;  // 2.125
        #10;
        if (result !== mul_ref(a,b)) begin
            $display("FALHA #1 A=%h B=%h -> DUT=%h REF=%h", a,b,result,mul_ref(a,b));
            success = 0;
        end

        // 9.5 * 3.75
        a = 32'h41180000;  // 9.5
        b = 32'h40700000;  // 3.75
        #10;
        if (result !== mul_ref(a,b)) begin
            $display("FALHA #2 A=%h B=%h -> DUT=%h REF=%h", a,b,result,mul_ref(a,b));
            success = 0;
        end

        // Casos com zero
        a = 32'h00000000;  // 0.0
        b = 32'h3F800000;  // 1.0
        #10;
        if (result !== mul_ref(a,b)) begin
            $display("FALHA #3 A=%h B=%h -> DUT=%h REF=%h", a,b,result,mul_ref(a,b));
            success = 0;
        end

        // Loop pseudoaleatório simples (variação paramétrica)
        for (i=0; i<20; i=i+1) begin
            a = 32'h3F000000 + (i<<16); // ~0.5.. (variação simples)
            b = 32'h40000000 + (i<<15); // ~2.0.. (variação simples)
            #10;
            if (result !== mul_ref(a,b)) begin
                $display("FALHA RAND i=%0d A=%h B=%h -> DUT=%h REF=%h", i,a,b,result,mul_ref(a,b));
                success = 0;
            end
        end

        // Relatório final
        if (success)
            $display("SUCESSO: todos os testes passaram.");
        else
            $display("ATENCAO: houve falhas. Verifique o log.");

        $display("Fim da simulacao.");
        $finish;
    end
endmodule
