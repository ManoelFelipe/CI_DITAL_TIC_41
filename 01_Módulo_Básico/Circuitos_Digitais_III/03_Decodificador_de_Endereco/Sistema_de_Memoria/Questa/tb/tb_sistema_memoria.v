// ============================================================================
// Arquivo  : tb_sistema_memoria (Testbench Principal)
// Autor    : Manoel Furtado
// Data     : 2025-12-15
// Ferramenta: ModelSim / Questa / Quartus Prime
// Descrição:
//      Este testbench tem como objetivo validar o funcionamento do "Sistema
//      de Memória" de 128 bytes, dividido entre ROM (endereços 0-63) e 
//      SRAM (endereços 64-127).
//
//      Caraterísticas principais:
//      1. Validação Cruzada (Cross-Checking): Instancia três versões do 
//         mesmo circuito (Behavioral, Dataflow, Structural) e compara
//         suas saídas a cada ciclo de clock. Se houver divergência, aponta erro.
//      2. Modelo Dourado (Golden Model): Simula internamente o comportamento
//         esperado da memória (array para SRAM, função para ROM) para
//         garantir que não apenas as versões sejam iguais, mas que estejam CORRETAS.
//      3. Tabelas Didáticas: Gera logs formatados no console para facilitar
//         a visualização do mapa de memória e testes de fronteira.
//
//      O clock é de 100 MHz (10 ns de período), e as leituras/escritas
//      são síncronas.
// ============================================================================
`timescale 1ns/1ps

module tb_sistema_memoria;

    // ========================================================================
    // 1. Declaração de Sinais e Variáveis
    // ========================================================================
    
    // --- Sinais Globais de Estímulo (Entradas dos Módulos) ---
    reg         clk;       // Relógio do sistema (sincronismo)
    reg         we;        // Write Enable: 1=Escrever, 0=Ler
    reg [6:0]   a;         // Barramento de Endereço (0 a 127)
    reg [7:0]   din;       // Barramento de Dados de Entrada (para escrita)

    // --- Sinais de Monitoramento (Saídas dos Módulos) ---
    // Cada implementação tem sua própria saída para comparação
    wire [7:0]  dout_beh;  // Saída do modelo Comportamental (Behavioral)
    wire [7:0]  dout_df;   // Saída do modelo Fluxo de Dados (Dataflow)
    wire [7:0]  dout_st;   // Saída do modelo Estrutural (Structural)

    // --- Variáveis de Controle da Simulação ---
    integer test_count;    // Contador de testes realizados
    integer error_count;   // Contador de erros detectados
    reg     success_flag;  // Flag que indica se a simulação foi bem sucedida

    // --- Golden Model (Modelo de Referência) ---
    // Simulamos a SRAM (64 bytes superiores) com um array de regs.
    // A ROM não precisa de array pois é calculada matematicamente.
    reg [7:0] sram_golden [0:63];

    // Variável auxiliar para loops
    integer i;

    // ========================================================================
    // 2. Instanciação dos Dispositivos Sob Teste (DUTs)
    // ========================================================================

    // DUT 1: Modelo Comportamental (Behavioral)
    // Referência principal de lógica de alto nível.
    sistema_memoria_behavioral u_dut_beh (
        .clk(clk),
        .we(we),
        .a(a),
        .din(din),
        .dout(dout_beh)
    );

    // DUT 2: Modelo de Fluxo de Dados (Dataflow)
    // Baseado em atribuições contínuas (assigns) ou lógica RTL direta.
    sistema_memoria_dataflow u_dut_df (
        .clk(clk),
        .we(we),
        .a(a),
        .din(din),
        .dout(dout_df)
    );

    // DUT 3: Modelo Estrutural (Structural)
    // Feito de subcomponentes discretos (decodificadores, multiplexadores).
    sistema_memoria_structural u_dut_st (
        .clk(clk),
        .we(we),
        .a(a),
        .din(din),
        .dout(dout_st)
    );

    // ========================================================================
    // 3. Configuração do Ambiente de Simulação
    // ========================================================================

    // Geração de Arquivo de Ondas (VCD) para visualização gráfica
    initial begin
        $dumpfile("wave.vcd");           // Nome do arquivo de saída
        $dumpvars(0, tb_sistema_memoria);// Grava todos os sinais deste módulo
    end

    // Geração de Clock
    // Frequência: 100 MHz -> Período: 10 ns (5ns LOW, 5ns HIGH)
    initial begin
        clk = 1'b0;                      // Inicia em 0
        forever #5 clk = ~clk;           // Inverte a cada 5ns
    end

    // ========================================================================
    // 4. Funções Auxiliares (Golden Model da ROM)
    // ========================================================================

    // Função que define o conteúdo esperado da ROM.
    // Lógica: {addr[6:5], addr[4:3], addr[2:0], 0}
    // Isso garante que sabemos exatamente o que deve sair da ROM sem ler o arquivo Verilog.
    function [7:0] rom_byte;
        input [6:0] addr;
        begin
            rom_byte = {addr[6:5], addr[4:3], addr[2:0], 1'b0};
        end
    endfunction

    // ========================================================================
    // 5. Tasks (Procedimentos de Teste Automatizados)
    // ========================================================================

    // --- Task: Realizar Leitura (Read) ---
    // Configura endereço, aguarda clock e verifica consistência.
    task do_read;
        input [6:0] addr;
        begin
            // 1. Configurar os estímulos antes da borda do clock
            a  = addr;
            we = 1'b0;      // Desabilita escrita (modo Leitura)
            din = 8'h00;    // Dado de entrada irrelevante na leitura

            // 2. Aguardar a borda de subida do clock (momento da amostragem)
            @(posedge clk);

            // 3. Aguardar um pequeno delta (#1) após a borda para
            //    garantir que as saídas dos DUTs estabilizaram.
            #1;

            // 4. Incrementar contador de testes
            test_count = test_count + 1;

            // 5. Verificar consistência entre os três modelos
            //    Se beh != df ou df != st, então algo está errado.
            if ((dout_beh !== dout_df) || (dout_df !== dout_st)) begin
                error_count = error_count + 1;
                success_flag = 1'b0;
                $display("ERRO @%0t ns: addr=%0d (0b%07b) | beh=%02h df=%02h st=%02h",
                         $time, addr, addr, dout_beh, dout_df, dout_st);
            end
        end
    endtask

    // --- Task: Realizar Escrita (Write) ---
    // Configura endereço e dados, pulsa WE e verifica se houve erro imediato.
    task do_write;
        input [6:0] addr;
        input [7:0] data;
        integer idx;
        begin
            // 1. Configurar estímulos
            a   = addr;
            din = data;
            we  = 1'b1;     // Habilita escrita

            // 2. Aguardar o pulso de clock efetivo
            @(posedge clk);
            #1; // Delta para estabilização

            // 3. Atualizar nosso "Golden Model" local (apenas se for SRAM)
            //    A SRAM começa no endereço 64 (2'd2 nos bits mais altos: 10xxxx)
            if (addr[6:5] >= 2'd2) begin
                idx = addr - 7'd64;      // Calcula índice base 0 (0..63)
                sram_golden[idx] = data; // Salva o valor esperado
            end
            // Nota: Se tentar escrever na ROM (addr < 64), o golden model NÃO muda,
            // o que é correto, pois a ROM não deve aceitar escrita.

            // 4. Desativar WE para segurança (evitar escritas indesejadas depois)
            we  = 1'b0;
            din = 8'h00;

            test_count = test_count + 1;

            // 5. Verificar se as saídas continuam consistentes mesmo após escrita
            if ((dout_beh !== dout_df) || (dout_df !== dout_st)) begin
                error_count = error_count + 1;
                success_flag = 1'b0;
                $display("ERRO-WR @%0t ns: addr=%0d data=%02h | beh=%02h df=%02h st=%02h",
                         $time, addr, data, dout_beh, dout_df, dout_st);
            end
        end
    endtask

    // --- Task: Gerar Tabela Didática da ROM ---
    // Lê os primeiros 16 endereços e imprime formatado no console.
    task didactic_table_rom16;
        integer k;
        begin
            $display("");
            $display("TABELA DIDATICA (Behavioral) — 16 leituras na ROM (addr 0..15)");
            $display("tempo(ns) | a(dec) | a(bin)    | we | din  | dout_beh");
            $display("------------------------------------------------------");

            for (k = 0; k < 16; k = k + 1) begin
                a = k[6:0];
                we = 1'b0;
                din = 8'h00;

                @(posedge clk); // Sincroniza
                #1;             // Estabiliza

                $display("%8t | %6d | %07b |  %0d | %02h | %02h",
                         $time, a, a, we, din, dout_beh);
            end

            $display("------------------------------------------------------");
            $display("");
        end
    endtask

    // --- Task: Tabela de Amostras da SRAM ---
    // Realiza um par Escrita/Leitura em alguns endereços para mostrar funcionamento.
    task didactic_table_sram_samples;
        reg [6:0] addr;
        integer k;
        begin
            $display("TABELA EXTRA — Escrita e leitura na SRAM (amostras)");
            $display("tempo(ns) | op | a(dec) | a(bin)    | din  | dout_beh | golden");
            $display("----------------------------------------------------------------");

            // Testa 8 endereços sequenciais a partir de 64 (Início da SRAM)
            for (k = 0; k < 8; k = k + 1) begin
                addr = 7'd64 + k[6:0];

                // Passo A: Escrita
                do_write(addr, 8'hA0 + k[7:0]); // Escreve valores A0, A1, A2...
                $display("%8t | WR | %6d | %07b | %02h | %02h   | %02h",
                         $time, addr, addr, (8'hA0 + k[7:0]), dout_beh, sram_golden[k]);

                // Passo B: Leitura (Confirmação)
                do_read(addr);
                $display("%8t | RD | %6d | %07b | %02h | %02h   | %02h",
                         $time, addr, addr, 8'h00, dout_beh, sram_golden[k]);
            end

            $display("----------------------------------------------------------------");
            $display("");
        end
    endtask

    // --- Task: Verificação de Mapa de Memória (Boundary Check) ---
    // Teste crucial: Verifica os limites entre ROM e SRAM.
    // Prova que ROM ignora escrita e SRAM aceita.
    task didactic_table_map_check;
        reg [6:0] addr_probe;
        reg [7:0] write_val;
        reg [7:0] read_val_pre;
        reg [7:0] read_val_post;
        integer k;
        reg [3:0] region_id; // 0=ROM, 1=SRAM
        begin
            $display("TABELA DE VERIFICACAO DE MAPA DE MEMORIA");
            $display("Range Addr | Tipo Esp. | Endereco Testado | Escrita | Leitura Pre | Leitura Pos | Status");
            $display("------------------------------------------------------------------------------------------");

            // Loop testa 4 pontos críticos:
            // 0: Primeiro endereço da ROM
            // 1: Último endereço da ROM (63)
            // 2: Primeiro endereço da SRAM (64)
            // 3: Último endereço da SRAM (127)
            for (k = 0; k < 4; k = k + 1) begin
                case (k)
                    0: addr_probe = 7'd0;   // ROM Start
                    1: addr_probe = 7'd63;  // ROM End
                    2: addr_probe = 7'd64;  // SRAM Start
                    3: addr_probe = 7'd127; // SRAM End
                endcase

                // Define em qual região estamos
                if (addr_probe < 64) region_id = 0; else region_id = 1;

                // Etapa 1: Ler o valor que já está lá (Estado Inicial)
                do_read(addr_probe);
                read_val_pre = dout_beh;

                // Etapa 2: Tentar escrever um valor INVERSO (para garantir mudança visível)
                write_val = ~read_val_pre;
                do_write(addr_probe, write_val);

                // Etapa 3: Ler novamente para ver se mudou
                do_read(addr_probe);
                read_val_post = dout_beh;

                // Etapa 4: Análise Automática do Resultado
                if (region_id == 0) begin
                    // Região ROM: O valor NÃO DEVE mudar.
                    // Pré deve ser igual a Pós.
                    if (read_val_pre === read_val_post)
                        $display("  00..63   |    ROM    |   %3d (0x%2h)   |   0x%2h  |    0x%2h     |    0x%2h     | OK (Ignored)", 
                                 addr_probe, addr_probe, write_val, read_val_pre, read_val_post);
                    else
                        // Se mudou, falha grave: ROM foi sobreescrita!
                        $display("  00..63   |    ROM    |   %3d (0x%2h)   |   0x%2h  |    0x%2h     |    0x%2h     | ERRO (Modified)",
                                 addr_probe, addr_probe, write_val, read_val_pre, read_val_post);
                end else begin
                    // Região SRAM: O valor DEVE mudar para o que escrevemos.
                    if (read_val_post === write_val)
                        $display("  64..127  |    SRAM   |   %3d (0x%2h)   |   0x%2h  |    0x%2h     |    0x%2h     | OK (Written)",
                                 addr_probe, addr_probe, write_val, read_val_pre, read_val_post);
                    else
                        // Se não mudou, falha grave: SRAM não aceitou escrita!
                        $display("  64..127  |    SRAM   |   %3d (0x%2h)   |   0x%2h  |    0x%2h     |    0x%2h     | ERRO (Falha)",
                                 addr_probe, addr_probe, write_val, read_val_pre, read_val_post);
                end
            end
            $display("------------------------------------------------------------------------------------------");
            $display("");
        end
    endtask

    // ========================================================================
    // 6. Bloco Principal de Teste (Main)
    // ========================================================================
    initial begin
        // --- A. Setup Inicial ---
        we = 1'b0;      // Começa em leitura
        a  = 7'd0;      // Endereço 0
        din = 8'h00;

        test_count   = 0;
        error_count  = 0;
        success_flag = 1'b1; // Assume sucesso até prova em contrário

        // Zera o Golden Model da SRAM para termos um estado conhecido
        for (i = 0; i < 64; i = i + 1) begin
            sram_golden[i] = 8'h00;
        end

        // Aguarda 2 ciclos para o reset global do sistema (se houvesse) 
        // ou apenas estabilização inicial.
        repeat (2) @(posedge clk);

        // --- B. Execução das Tabelas Didáticas ---
        
        // 1) Mostra leitura padrão da ROM
        didactic_table_rom16();

        // --- C. Testes Exaustivos ---

        // 2) Varredura Completa da ROM (0 a 63)
        //    Lê cada byte e compara com a função matemática esperada.
        for (i = 0; i < 64; i = i + 1) begin
            do_read(i[6:0]);

            // Validação adicional: O DUT bate com a fórmula?
            if (dout_beh !== rom_byte(i[6:0])) begin
                error_count = error_count + 1;
                success_flag = 1'b0;
                $display("ERRO-ROM @%0t ns: addr=%0d esperado=%02h obtido=%02h",
                         $time, i, rom_byte(i[6:0]), dout_beh);
            end
        end

        // 3) Teste de Robustez da ROM (Tentativa de Escrita)
        //    Tenta escrever 0xFF nos primeiros 8 bytes.
        //    Depois lê de volta -> deve continuar com o valor original.
        for (i = 0; i < 8; i = i + 1) begin
            do_write(i[6:0], 8'hFF); // Escreve Lixo
            do_read(i[6:0]);         // Lê de volta

            if (dout_beh !== rom_byte(i[6:0])) begin
                error_count = error_count + 1;
                success_flag = 1'b0;
                $display("ERRO-ROM-WRITE @%0t ns: addr=%0d esperado=%02h obtido=%02h",
                         $time, i, rom_byte(i[6:0]), dout_beh);
            end
        end

        // 4) Teste de Carga da SRAM (Pseudo-Aleatório)
        //    Escreve dados "bagunçados" matematicamente para testar padrões de bits.
        for (i = 0; i < 32; i = i + 1) begin : loop_sram_test
            // Declaração de variáveis locais ao bloco (requer nome no bloco)
            integer idx;
            reg [6:0] addr;
            reg [7:0] data;

            // Gera padrão determinístico mas não trivial
            idx  = (i * 3) % 64;
            addr = 7'd64 + idx[6:0];          // Offset 64 para cair na SRAM
            data = (8'h11 ^ i[7:0]) + idx[7:0]; // Dado misturado

            do_write(addr, data);             // Escreve
            do_read(addr);                    // Lê imediatamente

            // Compara com o que acabamos de salvar no Golden Model
            if (dout_beh !== sram_golden[idx]) begin
                error_count = error_count + 1;
                success_flag = 1'b0;
                $display("ERRO-SRAM @%0t ns: addr=%0d idx=%0d esperado=%02h obtido=%02h",
                         $time, addr, idx, sram_golden[idx], dout_beh);
            end
        end

        // --- D. Tabelas Finais ---

        // 5) Mostra exemplos reais de escrita/leitura na SRAM
        didactic_table_sram_samples();

        // 6) Mostra a tabela de verificação de mapa (fronteiras)
        didactic_table_map_check();

        // --- E. Encerramento ---
        
        // Verifica se passamos limpo por tudo
        if ((success_flag == 1'b1) && (error_count == 0)) begin
            $display("SUCESSO: Todas as implementacoes estao consistentes em %0d testes.", test_count);
        end else begin
            $display("FALHA: Divergencias encontradas. testes=%0d erros=%0d", test_count, error_count);
        end

        $display("Fim da simulacao.");
        $finish; // Encerra o simulador
    end

endmodule
