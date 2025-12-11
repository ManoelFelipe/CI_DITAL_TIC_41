# Projeto RAM 16x8 Sync - Relatório Técnico

## 5.1 Descrição do Projeto
**Autor**: Manoel Furtado
**Data**: 10/12/2025
**Objetivo**:
O objetivo deste projeto é o desenvolvimento e validação de uma memória RAM síncrona com capacidade de armazenamento de 16 palavras de 8 bits (16x8). A memória deve suportar operações de escrita e leitura síncronas, gerenciadas por um sinal de clock global e um sinal de habilitação de escrita (`we`). O projeto explora três abordagens distintas de modelagem em HDL (Hardware Description Language) utilizando Verilog-2001: **Behavioral** (Comportamental), **Dataflow** (Fluxo de Dados) e **Structural** (Estrutural).

A arquitetura implementada é fundamental para sistemas digitais que requerem armazenamento temporário de dados com acesso rápido e determinístico. A operação síncrona garante que todas as transições de estado e transferências de dados ocorram em sincronia com a borda de subida do clock, eliminando problemas comuns em circuitos assíncronos, como glitches e metaestabilidade nas saídas durante as transições de endereço. A especificação exige uma latência de leitura de um ciclo de clock, o que significa que o dado endereçado estará disponível na porta de saída na borda de subida seguinte à apresentação do endereço, comportando-se como uma Block RAM típica de FPGAs modernos.

Este relatório detalha as escolhas de design, as diferenças semânticas e de síntese entre as três abordagens, e a metodologia rigorosa de verificação adotada para garantir que todas as implementações sejam funcionalmente equivalentes e corretas.

---

## 5.2 Análise das Abordagens

### Implementação Behavioral (Comportamental)
A implementação Behavioral é a mais abstrata e próxima de linguagens de programação de alto nível como C. Nela, descrevemos o *que* o circuito faz, sem necessariamente detalhar *como* ele é construído em termos de portas lógicas.
Neste projeto, utilizamos um vetor de registradores `reg [7:0] mem_array [0:15]` para inferir a memória. O bloco `always @(posedge clk)` encapsula toda a lógica sequencial. A escrita é descrita de forma direta: `if (we) mem_array[address] <= data_in;`. A leitura é igualmente simples e síncrona: `data_out <= mem_array[address];`.
**Vantagens**: Esta abordagem é extremamente legível e fácil de manter. É a forma recomendada para inferência de memórias em FPGAs (como Block RAMs ou Distributed RAMs), pois as ferramentas de síntese (como Quartus e Vivado) reconhecem esse padrão e mapeiam automaticamente para recursos dedicados de silício, otimizando área e performance.
**Riscos**: Se não houver clareza na descrição (ex: misturar lógica combinacional complexa dentro do bloco de clock de memória), a ferramenta pode não inferir uma RAM dedicada e sim utilizar milhares de Flip-Flops individuais, explodindo o uso de área lógica.

### Implementação Dataflow (Fluxo de Dados)
A modelagem Dataflow foca no fluxo de dados através do sistema, utilizando atribuições contínuas (`assign`) e construções de controle de fluxo explícitas. Embora funcionalmente idêntica à Behavioral neste contexto simples, a Dataflow oferece uma visão mais "RTL" (Register Transfer Level).
No nosso código, a leitura é implementada através de um `case` statement dentro do bloco síncrono, que age como um multiplexador gigante selecionando qual registrador conectar à saída.
**Comparação**: Diferente da Behavioral, que abstrai o acesso ao array, a Dataflow aqui explicita a decodificação do endereço na leitura.
**Riscos de Síntese**: O uso de um `case` grande para leitura pode, em ferramentas mais antigas ou sem otimização específica, ser sintetizado como um enorme multiplexador combinacional na saída dos registradores, o que é menos eficiente que uma memória dedicada. No entanto, para 16 posições, isso ainda é viável. A clareza do código é alta, mas a verbosidade é maior que na behavioral.

### Implementação Structural (Estrutural)
A abordagem Structural é a de mais baixo nível, onde descrevemos o circuito instanciando e conectando módulos básicos, como se estivéssemos desenhando um esquemático.
Neste projeto, a RAM foi construída conectando três tipos de componentes:
1.  **Decoder 4x16**: Recebe o endereço e o sinal `we`, gerando 16 sinais de enable individuais (um para cada palavra).
2.  **Registradores (16 instâncias)**: Cada um armazena 8 bits. Instanciamos 16 módulos `dff_8_en`, conectando o enable individual vindo do decoder a cada um.
3.  **Multiplexador 16x1**: Recebe as saídas dos 16 registradores e seleciona uma baseada no endereço de leitura.
4.  **Registrador de Saída**: Para garantir a característica síncrona exigida, a saída do Mux combinacional passa por um Flip-Flop final.
**Análise Crítica**: Esta abordagem é excelente para fins didáticos, pois mostra exatamente "o que tem dentro" do chip: decodificadores, elementos de memória e lógica de seleção. No entanto, é **péssima para produtividade e síntese** em projetos reais. Instanciar manualmente 16 registradores e um mux gigante impede a ferramenta de usar Block RAMs eficientes, forçando o uso de lógica distribuída (LUTs e FFs), o que consome muita área e roteamento. O erro original do projeto (falta de registrador na saída) foi corrigido adicionando o estágio final de registro para cumprir o requisito de latência de 1 ciclo.

---

## 5.3 Descrição do Testbench

A validação de circuitos de memória exige precisão temporal, especialmente para escritas síncronas. O Testbench desenvolvido (`tb_ram_16x8_sync.v`) foi projetado para:
1.  Verificar as três implementações simultaneamente (Golden Model Comparison).
2.  Garantir cobertura total de endereços (0 a 15).
3.  Evitar falsos positivos causados por instabilidade de sinais (race conditions).

### Metodologia de Estímulo (Negedge Driving)
Uma decisão crucial de design do Testbench foi a geração de estímulos na borda de **descida** (`negedge clk`).
Em circuitos síncronos, os Flip-Flops capturam dados na borda de **subida** (`posedge`). Se o Testbench alterar os dados de entrada (endereço, `we`, `data_in`) exatamente na borda de subida, cria-se uma condição de corrida: a RAM captura o dado antigo ou o novo? O simulador pode se comportar de forma imprevisível.
Ao alterar os estímulos no `negedge`, garantimos que, quando a borda de subida chegar, os sinais de entrada já estarão estáveis há meio ciclo (Setup Time garantido). Isso reflete o comportamento de um sistema digital real bem projetado.

### Monitoramento e Verificação
O Testbench executa duas fases:
1.  **Escrita**: Escreve um padrão conhecido (ex: `0xA0 + endereço`) em todas as 16 posições.
2.  **Leitura e Checagem**: Lê sequencialmente todos os endereços. Para cada leitura:
    *   Aguarda o ciclo de clock de leitura.
    *   Compara as saídas das 3 DUTs (`beh`, `df`, `str`) entre si e com o valor esperado (`golden_mem`).
    *   Imprime uma linha na tabela de log se houver sucesso (`OK`) ou falha (`ERRO`).

### Tabela Didática Unificada
Para evitar poluição visual, o log exibe uma tabela baseada apenas nos sinais da implementação Behavioral (assumida como referência), mas a flag de erro dispara se *qualquer* uma das outras divergir. Isso mantém o console limpo enquanto garante a integridade de todas as versões.
O formato escolhido (`tempo | addr | we | data_in || dout_beh | dout_exp || STATUS`) permite uma depuração rápida: se o status for `ERRO`, linhas adicionais detalham a discrepância específica entre as versões.

---

## 5.4 Aplicações Práticas

Memórias RAM síncronas de pequena capacidade, como a 16x8 desenvolvida aqui, são blocos fundamentais em quase todos os sistemas digitais complexos. Elas não servem apenas para "armazenar arquivos", mas desempenham papéis cruciais de controle e processamento.

### 1. Register Files (Bancos de Registradores) em Processadores
A aplicação mais direta desta arquitetura é o **Register File** de microprocessadores simples (como um processador RISK de 8 bits ou microcontroladores PIC básicos). O "R0 até R15" de um processador são, na verdade, uma pequena RAM multi-portas. Embora nossa implementação tenha apenas uma porta (leitura OU escrita), o princípio de decodificação e armazenamento é idêntico. Uma implementação Structural optimizada é frequentemente usada em custom ASICs para garantir timing preciso nesses caminhos críticos.

### 2. Buffers de Comunicação (FIFOs)
Em sistemas de comunicação (UART, SPI, I2C), é comum receber dados numa velocidade diferente da que se processa. Uma RAM pequena é usada como núcleo de **FIFOs (First-In, First-Out)**. Os ponteiros de escrita e leitura geram os endereços para a RAM. A sincronia com o clock é vital para evitar corrupção de dados quando os ponteiros cruzam domínios de clock (em FIFOs assíncronas) ou simplesmente para garantir throughput máximo em FIFOs síncronas.

### 3. Look-Up Tables (LUTs) Configuráveis
FPGAs utilizam pequenas memórias (Distributed RAMs) para implementar lógica. Mas em nível de sistema, podemos usar essa RAM 16x8 como uma tabela de conversão reprogramável. Por exemplo, em um sistema de controle de LED RGB, a RAM pode armazenar os valores de correção gama. O processador escreve a curva gama na RAM na inicialização (Fase 1), e o hardware de vídeo lê continuamente a tabela (Fase 2) para corrigir as cores em tempo real. A vantagem sobre uma ROM é que a curva pode ser ajustada sem regravar o chip.

### 4. Máquinas de Estados Programáveis
Para controladores complexos, em vez de uma FSM (Finite State Machine) "hard-coded" com `case`, pode-se usar uma RAM para armazenar a transição de estados e as saídas. O endereço é o "Estado Atual + Entradas", e o dado lido é o "Próximo Estado + Saídas". Isso permite alterar o comportamento da máquina de controle apenas reescrevendo o conteúdo da RAM, criando um micro-sequenciador flexível.

Em resumo, dominar a implementação e validação de RAMs síncronas é o primeiro passo para projetar desde caches de processadores de alto desempenho até buffers de interface simples em IoT.
