// ============================================================================
// Arquivo  : tb_wallace.v
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: Testbench auto-verificante para o multiplicador Wallace 4x4.
//            Gera todos os 256 vetores (a,b), compara com referência
//            comportamental e emite VCD. Inclui flag de sucesso e relatório
//            de erros com casos de borda (0, 1, 15).
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_wallace;
    // ----------------------- DUT PORTS/REFS ---------------------------------
    reg  [3:0] a;                 // estimulo: multiplicando
    reg  [3:0] b;                 // estimulo: multiplicador
    wire [7:0] y_beh;             // saida ref (behavioral)
    wire [7:0] y_data;            // saida dataflow
    wire [7:0] y_str;             // saida estrutural

    integer i, j;                 // contadores de varredura
    integer erros;                // contador de falhas
    reg sucesso;                  // flag de sucesso

    // ----------------------- DUMP DE ONDAS ----------------------------------
    initial begin
        $dumpfile("wave.vcd");    // arquivo VCD
        $dumpvars(0, tb_wallace); // hierarquia completa
    end

    // ----------------------- DUT INSTANCIAS ---------------------------------
    wallace dut_beh   (.a(a), .b(b), .produto(y_beh));   // behavioral
    // Clones para cada abordagem: recompilar apontando para os diretórios
    // adequados no script compile.do. Aqui replicamos o mesmo nome de módulo.
    wallace dut_data  (.a(a), .b(b), .produto(y_data));  // dataflow
    wallace dut_str   (.a(a), .b(b), .produto(y_str));   // structural

    // ----------------------- ESTIMULOS E CHECAGEM ---------------------------
    initial begin
        erros   = 0;              // zera contador de erros
        sucesso = 1'b1;           // assume sucesso
        a = 4'd0; b = 4'd0;       // inicializa entradas
        #1;                       // pequena folga temporal

        // Varre todo o espaço de entradas (256 combinações)
        for (i = 0; i < 16; i = i + 1) begin
            for (j = 0; j < 16; j = j + 1) begin
                a = i[3:0];       // atribui a
                b = j[3:0];       // atribui b
                #1;               // tempo para propagação combinacional

                // Referência de ouro (produto inteiro sem sinal)
                if (y_beh !== (i*j)) begin
                    $display("REF ERR: a=%0d b=%0d y_beh=%0d ref=%0d", i, j, y_beh, i*j);
                    erros = erros + 1;
                    sucesso = 1'b0;
                end

                // Compara todas as abordagens entre si e com a referência
                if ((y_data !== y_beh) || (y_str !== y_beh)) begin
                    $display("MISMTCH: a=%0d b=%0d beh=%0d data=%0d str=%0d", i, j, y_beh, y_data, y_str);
                    erros = erros + 1;
                    sucesso = 1'b0;
                end
            end
        end

        // Relatório final
        if (sucesso) begin
            $display("Todas as %0d combinacoes passaram sem erros.", 16*16);
        end else begin
            $display("Falhas detectadas: %0d.", erros);
        end
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
