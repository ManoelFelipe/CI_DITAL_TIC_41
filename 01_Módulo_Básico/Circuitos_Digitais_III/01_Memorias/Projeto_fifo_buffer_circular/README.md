
# Projeto FIFO 8x8 usando Buffer Circular

Autor: Manoel Furtado  
Data: 11/12/2025  

Este projeto implementa uma FIFO de 8 palavras por 8 bits utilizando a técnica
de **buffer circular**. A arquitetura é apresentada em três estilos de descrição
em Verilog‑2001 — *behavioral*, *dataflow* e *structural* — permitindo comparar
não apenas o resultado funcional, mas também o impacto de cada abordagem na
leitura do código, na debugabilidade e nas decisões de síntese. Toda a estrutura
foi organizada em diretórios separados para uso com Quartus (foco em síntese para
FPGA) e Questa/ModelSim (foco em simulação), mantendo o mesmo conjunto de fontes
em ambas as ferramentas.

A FIFO possui duas operações básicas: **escrita** (`wr`) e **leitura** (`rd`).
Os dados são armazenados em um vetor de registros e o avanço dos ponteiros
é feito em aritmética modular. Como o número de palavras é potência de dois
(N = 8), o *wrap-around* ocorre naturalmente pela largura dos ponteiros
(3 bits), dispensando lógica adicional para retorno ao endereço zero. As
condições de `full` e `empty` são determinadas pela relação entre os ponteiros
de escrita e leitura, combinada com a informação da última operação. O projeto
aqui proposto assume o caso clássico em que `wp == rp` indica FIFO vazia logo
após o reset, e a transição para FIFO cheia ocorre quando um avanço de escrita
leva o ponteiro de escrita a coincidir com o ponteiro de leitura.

Além dos módulos RTL, o repositório inclui um **testbench unificado** capaz de
instanciar as três versões da FIFO simultaneamente e compará‑las ciclo a ciclo.
O testbench gera um conjunto de estímulos que exercitam as situações mais
críticas do ponto de vista de projeto: preenchimento completo até `full=1`,
tentativas de escrita com FIFO cheia, esvaziamento completo até `empty=1`,
tentativas de leitura com FIFO vazia e uma sequência mista de escritas e
leituras alternadas. Ao final, o testbench informa se todas as implementações
se comportaram de forma idêntica em todos os testes, emitindo a mensagem de
sucesso exigida.

---

## 5.2 Análise das Abordagens

### Implementação Behavioral

Na implementação **behavioral**, a FIFO é descrita de forma bastante próxima à
intuição algorítmica do problema. Há um único bloco `always @(posedge clk)`
responsável por aplicar o reset, atualizar ponteiros, gravar na memória e
controlar as flags `full` e `empty`. Dentro desse bloco, os casos de operação
são organizados explicitamente: leitura sem escrita, escrita sem leitura,
operações simultâneas ou inatividade. Essa abordagem facilita muito o processo
de ensino, pois o estudante consegue ler o código quase como um pseudocódigo:
“se tiver reset, zere tudo; senão, se houver leitura, faça tal coisa; se houver
escrita, faça tal outra” etc.

Do ponto de vista de síntese, porém, a abordagem behavioral exige disciplina.
Como o mesmo bloco controla múltiplas saídas, é fácil introduzir erros de
modelagem que resultem em *latches* indesejados ou em lógica combinacional
demasiadamente extensa entre registradores. No projeto atual, esse risco foi
mitigado ao inicializar explicitamente todos os sinais dentro do bloco de reset
e ao garantir que, em cada ramo de decisão, as variáveis relevantes recebem
atribuições. Outro ponto de atenção é o uso de `if/else if/else` aninhados:
dependendo do estilo, o sintetizador pode gerar lógica mais profunda do que a
obtida em uma descrição mais factorizada. Apesar disso, para uma FIFO simples
de 8 posições, a implementação behavioral é mais do que suficiente em termos
de desempenho e área, e tem a vantagem de ser facilmente expandida com novas
funcionalidades, como contadores de ocupação, sinais de *almost full* ou
*almost empty*.

### Implementação Dataflow

A implementação **dataflow** procura explicitar o fluxo de dados separando a
lógica combinacional de próxima‑estado dos registradores que guardam esse
estado. Em vez de atualizar ponteiros e flags diretamente dentro de um único
bloco síncrono, o código define `w_ptr_next`, `r_ptr_next`, `full_next` e
`empty_next` em um bloco `always @(*)` puramente combinacional. Em seguida,
um segundo bloco `always @(posedge clk or posedge reset)` trata apenas dos
registradores, copiando os valores “next” para os registros “reg”. Dessa forma,
a fronteira entre lógica combinacional e lógica sequencial fica visível, o que
ajuda tanto na análise de temporização quanto na etapa de debug.

Do ponto de vista de síntese, o estilo dataflow tende a gerar resultados muito
próximos ao behavioral quando ambos são cuidadosamente escritos. Entretanto, o
dataflow oferece vantagens na hora de isolar caminhos críticos: como a lógica
de próxima‑estado é explicitada, o projetista pode inserir comentários e
*constraints* pontuais, refatorar expressões ou mesmo duplicar trechos de
lógica para reduzir fan‑out. Um exemplo clássico é o tratamento das condições
de `full` e `empty`. No código atual, essas flags são atualizadas com base em
comparações simples (`w_ptr_succ == r_ptr_reg` e `r_ptr_succ == w_ptr_reg`),
mas nada impede que, em versões futuras, sejam introduzidos contadores de
ocupação com largura ajustável. Nessa situação, a divisão clara entre
combinacional e sequencial ajuda a manter o código sob controle.

### Implementação Structural

Já a implementação **structural** aproxima o código da organização física do
hardware. A FIFO é decomposta em dois blocos principais: um módulo de memória
(`fifo_mem_8x8`) e um módulo de controle (`fifo_ctrl_8x8`). O módulo de
memória encapsula o array de registros de 8×8, com sinais de endereço,
escrita e leitura bem definidos. O módulo de controle, por sua vez, implementa
os ponteiros, as flags e o sinal de `write enable` que alimenta a memória.
Essa divisão permite, por exemplo, reutilizar a mesma memória em outros
controladores ou substituir a memória por uma RAM de bloco específica da FPGA,
mantendo a lógica de controle intacta.

Em termos de síntese, a abordagem structural é especialmente interessante em
projetos maiores, onde cada submódulo pode ser mapeado para recursos físicos
específicos (como BRAMs, DSPs e PLLs). Além disso, a decomposição em blocos
facilita a verificação formal e a simulação modular: é possível testar o
controlador isoladamente com uma memória simples ou, ao contrário, testar uma
memória mais sofisticada com um controlador de referência. No contexto da FIFO
8x8 deste projeto, a implementação structural serve como exercício de boas
práticas de modularização. O custo de área tende a ser equivalente ao das
demais técnicas, mas a legibilidade melhora quando se deseja enxergar a FIFO
como parte de um sistema maior composto por diversos blocos de comunicação.

---

## 5.3 Descrição do Testbench

O testbench `tb_fifo_8x8_buffer_circular` foi projetado para atender a dois
objetivos principais: verificar exaustivamente a consistência entre as três
implementações e produzir uma visão didática do comportamento da FIFO ao longo
do tempo. Para isso, ele instancia simultaneamente as versões behavioral,
dataflow e structural, ligando todas ao mesmo conjunto de sinais de estímulo:
clock, reset, `wr`, `rd` e `w_data`. Cada instância gera suas próprias saídas
(`r_data`, `full` e `empty`), que são monitoradas por um conjunto de tarefas
de verificação.

A geração de estímulos é organizada em três fases. Na primeira fase, a FIFO é
preenchida completamente: em cada ciclo de clock, o testbench ativa `wr=1`,
mantém `rd=0` e incrementa o valor de `w_data`. Ao fim de oito ciclos, espera‑se
que `full` esteja ativo e que novas tentativas de escrita sejam ignoradas. A
segunda fase esvazia a FIFO: o testbench desativa `wr`, ativa `rd` e realiza
oito ciclos de leitura, verificando que os dados saem na mesma ordem em que
entraram. Novamente, tentativas adicionais de leitura devem ser inócuas e
mantê‑la vazia. Na terceira fase, são gerados padrões alternados de escrita e
leitura, simulando um cenário real de fila em equilíbrio, onde a taxa de entrada
se aproxima da taxa de saída.

A cada ciclo de interesse, o testbench chama a tarefa `check_consistency`, que
incrementa um contador de testes e compara as saídas das três abordagens. Se
qualquer divergência for detectada, um contador de erros é incrementado e uma
mensagem detalhada é exibida no console, contendo o tempo de simulação e os
valores de cada implementação. Paralelamente, a tarefa `print_line` imprime uma
linha da tabela didática baseada na implementação behavioral, mostrando tempo,
sinais de controle e valores dos dados. Isso permite acompanhar visualmente o
fluxo de dados sem depender exclusivamente das formas de onda. Ao final da
simulação, o testbench imprime um resumo com o número total de testes e erros.
Se não houver erros, a mensagem padrão de sucesso — `"SUCESSO: Todas as "
"implementacoes estao consistentes em %0d testes."` — é exibida, cumprindo o
requisito do enunciado. Por fim, o testbench gera o arquivo `wave.vcd` com
`$dumpfile` e `$dumpvars`, permitindo análise gráfica em qualquer visualizador
compatível com VCD.

---

## 5.4 Aplicações Práticas

Filas FIFO de pequena largura e profundidade, como a FIFO 8x8 implementada
neste projeto, aparecem em praticamente todas as arquiteturas digitais modernas.
Em sistemas embarcados baseados em FPGA, é comum utilizá‑las para desacoplar
domínios de clock, amortecer picos de tráfego ou sincronizar periféricos que
operam a taxas diferentes. Um exemplo típico é a interface entre um conversor
ADC que amostra dados a uma frequência fixa e um bloco de processamento digital
que trabalha de forma intermitente. A FIFO atua como um “pulmão”, armazenando
amostras enquanto o processador está ocupado e liberando‑as assim que houver
janela de processamento disponível.

Outra aplicação frequente é em protocolos de comunicação seriais, como UART,
SPI ou I²C. Nesses casos, a FIFO pode ser utilizada tanto no lado de transmissão
quanto no de recepção, permitindo que o software grave ou leia blocos maiores
de dados de uma só vez, reduzindo a necessidade de interrupções constantes. Em
projetos mais complexos, FIFOs também são peças‑chave para implementar buffers
de vídeo, filas de pacotes em roteadores ou pipelines de processamento de sinais
em alta taxa. Mesmo quando a FIFO final precisa ter profundidade maior do que
8 palavras, o estudo de uma FIFO 8x8 serve como base conceitual: a lógica de
ponteiros, flags e controle de leitura/escrita é essencialmente a mesma, apenas
ampliada para larguras de endereço diferentes.

Do ponto de vista de boas práticas de projeto, a coexistência das três
abordagens (behavioral, dataflow e structural) dentro de um mesmo repositório
é particularmente valiosa. Em contextos industriais, é comum que equipes
diferentes prefiram estilos distintos; alguns designers optam por descrições
mais algorítmicas, enquanto outros buscam códigos mais próximos da topologia
física. Ter um exemplo completo onde todas as abordagens são mantidas em
sincronia, validadas pelo mesmo testbench e acompanhadas por scripts
automatizados de simulação permite que o engenheiro escolha o estilo que melhor
se adapta às suas necessidades sem abrir mão da confiabilidade. Além disso, o
projeto atual pode ser facilmente estendido para FIFOs com sinais de quase
cheio/quase vazio, suporte a múltiplos produtores e consumidores, ou mesmo
para arquiteturas com domínios de clock independentes, bastando evoluir os
blocos de controle e ajustar o testbench para cobrir os novos cenários.
