// ============================================================================
// Arquivo  : tb_full_adder_4bits.v
// Autor    : Manoel Furtado
// Data     : 11/11/2025
// Ferramentas: Compatível com Questa/ModelSim (Verilog 2001)
// Descrição: Testbench autochecado para o módulo full_adder_4bits. Varre
//            exaustivamente todos os pares A/B de 4 bits (0..15) e ambos os
//            valores de Cin, totalizando 512 vetores. Gera VCD, imprime erros
//            detalhados e encerra com flag de sucesso/fracasso.
// Revisão   : v1.0 — criação inicial
// ============================================================================

`timescale 1ns/1ps

module tb_full_adder_4bits;
    // Parâmetro local para permitir variação fácil de largura (ainda testando 4)
    localparam N = 4;

    // Estímulos
    reg  [N-1:0] a;
    reg  [N-1:0] b;
    reg          cin;

    // Saídas do DUT
    wire [N-1:0] s;
    wire         cout;

    // Controles de checagem
    integer ia, ib, icin;                 // Contadores de laço
    integer erros;                        // Contador de falhas
    reg [N:0] esperado;                   // Resultado esperado (N+1 bits)

    // --------------------------- Instância do DUT ----------------------------
    // OBS: O script compile.do seleciona qual implementação compilar (behavioral,
    // dataflow ou structural). Em todas elas o nome do módulo é o mesmo.
    full_adder_4bits #(.N(N)) dut (
        .a(a),
        .b(b),
        .cin(cin),
        .s(s),
        .cout(cout)
    );

    // ------------------------------ Geração VCD ------------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_full_adder_4bits);
    end

    // --------------------------- Geração de Estímulos ------------------------
    initial begin
        erros = 0;                        // Zera o acumulador de erros
        // Varredura exaustiva: todos A, B e Cin possíveis para N=4
        for (ia = 0; ia < (1<<N); ia = ia + 1) begin
            for (ib = 0; ib < (1<<N); ib = ib + 1) begin
                for (icin = 0; icin < 2; icin = icin + 1) begin
                    // Atribui vetores de teste
                    a   = ia[N-1:0];
                    b   = ib[N-1:0];
                    cin = icin[0];
                    // Aguarda propagação combinacional
                    #1;
                    // Calcula valor esperado usando aritmética inteira
                    esperado = ia + ib + icin;
                    // Checagem: compara {cout, s} com 'esperado'
                    if ({cout, s} !== esperado[N:0]) begin
                        $display("ERRO @t=%0t ns: A=%0d (0x%0h)  B=%0d (0x%0h)  Cin=%0d | got {C,S}=%0d (0x%0h)  exp=%0d (0x%0h)",
                                 $time, ia, ia, ib, ib, icin,
                                 {cout, s}, {cout, s},
                                 esperado, esperado);
                        erros = erros + 1;
                    end
                end
            end
        end

        // Relato final & encerramento
        if (erros == 0) begin
            $display("Teste CONCLUIDO: todos os %0d vetores passaram.", (1<<N)*(1<<N)*2);
        end else begin
            $display("Teste FALHOU: %0d erro(s) encontrado(s).", erros);
        end
        $display("Fim da simulacao.");
        $finish;
    end
endmodule
