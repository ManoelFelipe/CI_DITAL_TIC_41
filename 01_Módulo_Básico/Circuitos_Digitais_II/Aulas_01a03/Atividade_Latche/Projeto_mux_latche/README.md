# Relatório Técnico: Multiplexador com Latch (mux_latche)

## 5.1 Descrição do Projeto
**Autor:** Manoel Furtado  
**Data:** 15/11/2025  

Este projeto consiste na implementação e verificação de um módulo digital denominado `mux_latche`, que combina a funcionalidade de um multiplexador de 4 entradas com um elemento de memória do tipo Latch. O objetivo principal é demonstrar diferentes paradigmas de descrição de hardware em Verilog (Behavioral, Dataflow e Structural) para inferir intencionalmente um comportamento de memória em um circuito combinacional quando uma condição de seleção não é plenamente coberta.

A arquitetura do sistema baseia-se em um seletor de 2 bits (`sel`) e quatro entradas de dados (`in0` a `in3`) de largura parametrizável (`WIDTH`). A lógica opera de forma que, para as combinações de seleção `00`, `01` e `10`, o circuito se comporta como um multiplexador transparente, roteando a entrada correspondente para a saída. No entanto, para a combinação `11`, o circuito deve manter o estado anterior da saída, ignorando as entradas de dados. Este comportamento é característico de um Latch transparente habilitado por uma função lógica das linhas de seleção. O projeto é estruturado para ser compatível com ferramentas de síntese e simulação padrão da indústria, como Intel Quartus Prime e Siemens Questa (ModelSim), seguindo rigorosas práticas de codificação e organização de diretórios.

---

## 5.2 Análise das Abordagens

### Implementação Behavioral
A abordagem comportamental (Behavioral) é a mais abstrata e próxima da descrição algorítmica. Neste projeto, utilizamos um bloco `always @*` (combinacional) com uma estrutura de decisão `if-else if`. A inferência do Latch ocorre devido à incompletude proposital da estrutura de decisão: cobrimos explicitamente os casos `sel = 00`, `01` e `10`, mas omitimos o caso `sel = 11` e não fornecemos um valor padrão (`default`) para a saída `out`.

Em Verilog, quando uma variável atribuída dentro de um bloco combinacional não recebe um valor em todos os caminhos de execução possíveis, a ferramenta de síntese assume que o valor deve ser preservado, inferindo assim um elemento de memória (Latch). Esta abordagem é extremamente legível e fácil de manter, pois descreve "o que" o circuito faz, deixando os detalhes de implementação para o sintetizador. No entanto, o risco de síntese aqui é a criação acidental de Latches em projetos complexos onde o projetista esquece um `else`, o que pode causar problemas graves de temporização (timing analysis) e loops combinacionais indesejados. Neste exercício, o Latch é desejado, tornando esta abordagem a mais direta para atingir o objetivo.

### Implementação Dataflow
A implementação em fluxo de dados (Dataflow) utiliza atribuições contínuas (`assign`) com operadores condicionais ternários (`? :`). Esta técnica modela o fluxo de sinais através de expressões lógicas. Para implementar a funcionalidade de multiplexação, aninhamos operadores ternários: `(sel == 00) ? in0 : (sel == 01) ? in1 ...`.

O desafio e a distinção desta abordagem para inferir um Latch residem na condição final. Ao invés de atribuir um valor fixo ou `in3` para a condição `sel = 11`, atribuímos o próprio sinal de saída `out` a ele mesmo (`... : out`). Isso cria um loop de realimentação explícito na descrição. Em termos de hardware, isso é traduzido como um fio que conecta a saída de volta à entrada de um mux, mantendo o estado estável quando a condição de habilitação de escrita não é satisfeita. Embora funcionalmente correto para simulação e síntese de Latches, ferramentas de análise estática podem sinalizar isso como um "combinational loop" (loop combinacional), o que geralmente é um erro de design em lógica síncrona pura, mas é a essência de um elemento de memória assíncrono como o Latch descrito em dataflow.

### Implementação Structural
A abordagem estrutural (Structural) é a mais baixo nível, descrevendo o circuito como uma interconexão de primitivas lógicas. Nesta implementação, o desafio foi criar um Latch estável sem usar primitivas de alto nível.

Inicialmente, tentou-se uma abordagem simples de loop de realimentação (Mux Loop), mas isso causou **glitches** (race conditions) na simulação durante a transição para o estado de retenção (`11`), pois o sinal de habilitação desligava antes que o caminho de feedback se estabelecesse.

A solução definitiva adotada foi a lógica de **Soma de Produtos (SOP) com Feedback**:
`Out = (in0 & S00) | (in1 & S01) | (in2 & S10) | (Out & S11)`

Nesta topologia, o termo que mantém o valor (`Out & S11`) é ativado por sinais diretos, enquanto o termo que desliga a entrada anterior depende de inversores. O atraso natural dos inversores garante uma sobreposição segura ("make-before-break"), onde o feedback é ativado ligeiramente antes da entrada ser desconectada, prevenindo que a saída flutue ou caia para zero. Isso demonstra a importância da análise de temporização em nível de porta.

---

## 5.3 Descrição do Testbench

O testbench `tb_mux_latche` foi desenvolvido para validar exaustivamente o comportamento do módulo. Diferente de abordagens simples, este testbench instancia **as três implementações (Behavioral, Dataflow e Structural) simultaneamente**.

**Metodologia de Verificação Unificada:**
O testbench aplica os mesmos estímulos a todas as instâncias e compara suas saídas contra um valor esperado comum. Isso garante que todas as abordagens não apenas funcionem isoladamente, mas sejam perfeitamente equivalentes em comportamento lógico e temporização.

**Etapas de Estímulo e Monitoramento:**
1.  **Inicialização:** Definimos valores conhecidos e distintos para todas as entradas (`in0=AA`, `in1=BB`, `in2=CC`, `in3=DD`) e iniciamos o seletor em 0.
2.  **Varredura de Seleção (Mux):** O testbench itera sequencialmente pelos valores de `sel` `00`, `01` e `10`. A cada passo, aguarda-se um tempo de estabilização (`#10`) e compara-se a saída `out` com a entrada esperada correspondente.
3.  **Teste de Latch (Hold):** O passo crítico é a transição para `sel = 11`. O testbench verifica se a saída mantém o valor do estado anterior (`in2` = `CC`) e não assume o valor de `in3` ou zero.
4.  **Teste de Robustez:** Para garantir que o dispositivo está realmente memorizando, alteramos as entradas `in2` e `in3` enquanto o seletor permanece em `11`. O testbench monitora se a saída permanece inalterada (`CC`).
5.  **Recuperação:** Finalmente, retornamos o seletor para `00` para garantir que o Latch abre e volta a operar como multiplexador.

**Interpretação dos Resultados:**
O log do console informa "SIMULACAO CONCLUIDA COM SUCESSO" apenas se todas as três implementações passarem em todos os testes sem erros. O arquivo VCD gerado permite confirmar visualmente que não há glitches na saída estrutural durante as transições de latch.

---

## 5.4 Aplicações Práticas

O circuito `mux_latche` implementado, embora simples, ilustra conceitos fundamentais utilizados em sistemas digitais complexos. A função primária de um Latch transparente é a retenção de dados controlada por nível, diferentemente dos Flip-Flops que operam por borda.

**Aplicações em Pipelines e Retiming:**
Em processadores de alto desempenho, Latches são frequentemente utilizados em estágios de pipeline para "time borrowing" (empréstimo de tempo). Se um estágio lógico termina mais cedo, o Latch permite que o dado flua para o próximo estágio antes da borda do clock, ou se atrasa, permite que o estágio seguinte "espere" um pouco, absorvendo a latência. O `mux_latche` pode atuar como um estágio de seleção de operandos que mantém o valor estável para a ALU enquanto a instrução de controle muda.

**Controle de Barramentos e I/O:**
Em interfaces de comunicação, é comum multiplexar dados de várias fontes para um único pino de saída. O estado de "Latch" é útil para manter o último dado válido na linha durante períodos de transição ou "dead cycles" onde nenhuma fonte está ativa, evitando que o barramento flutue (o que consumiria energia excessiva em CMOS) ou assuma valores espúrios.

**Low Power Design (Clock Gating):**
A estrutura interna do Latch baseada em "Enable" é a base para células de "Clock Gating" integradas (ICG). Um ICG usa um Latch sensível ao nível baixo do clock para garantir que o sinal de enable do clock não mude durante a borda de subida, evitando glitches. Embora nosso `mux_latche` seja de dados, o princípio de usar um sinal de controle para congelar o estado é idêntico ao usado para desligar árvores de clock inteiras em chips modernos para economizar bateria.

**Exemplo Prático Adicional: Display Multiplexado:**
Considere um sistema que exibe dados de 3 sensores diferentes em um display de 7 segmentos. Um `mux_latche` poderia ciclar entre os sensores. Se o microcontrolador precisar realizar uma calibração e parar de enviar sinais de seleção válidos (entrando em um estado de "manutenção" `11`), o Latch garantiria que o último valor lido do sensor 3 permanecesse congelado no display, ao invés de apagar ou mostrar lixo, proporcionando uma melhor experiência de usuário.
