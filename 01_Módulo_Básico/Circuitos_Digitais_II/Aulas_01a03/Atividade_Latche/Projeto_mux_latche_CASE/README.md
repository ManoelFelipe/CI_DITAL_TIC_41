# Relatório Técnico: Multiplexador com Latch via CASE (mux_latche_case)

## 5.1 Descrição do Projeto
**Autor:** Manoel Furtado  
**Data:** 15/11/2025  

Este projeto, denominado `mux_latche_case`, explora a implementação de um multiplexador de 4 entradas com funcionalidade de Latch (memória transparente) utilizando a diretiva `case` do Verilog como elemento central da abordagem comportamental. O objetivo é demonstrar como diferentes construções da linguagem HDL influenciam a inferência de hardware, especificamente na criação de elementos de memória em circuitos que, idealmente, seriam puramente combinacionais.

A arquitetura consiste em um módulo parametrizável (`WIDTH`) com um seletor de 2 bits (`sel`) e quatro entradas de dados (`in0`..`in3`). A lógica define que para `sel=00, 01, 10`, o circuito atua como um multiplexador padrão. No entanto, para a condição `sel=11`, o circuito deve reter o valor anterior da saída, ignorando as entradas. Este comportamento de "Hold" é a característica definidora de um Latch. O projeto foi desenvolvido seguindo rigorosos padrões de codificação (Verilog-2001), com estrutura de diretórios compatível com Quartus e Questa, e validado por um testbench unificado que verifica simultaneamente três implementações distintas: Behavioral (foco deste exercício), Dataflow e Structural.

---

## 5.2 Análise das Abordagens

### Implementação Behavioral (CASE)
A implementação Behavioral neste projeto difere do exercício anterior pelo uso da instrução `case` em vez de `if-else`. A estrutura `case (sel)` lista explicitamente as condições para `00`, `01` e `10`, atribuindo as respectivas entradas à saída. A inferência do Latch ocorre pela **omissão deliberada** da condição `11` e da cláusula `default`.

Em Verilog, um bloco `always @*` descreve lógica combinacional se, e somente se, a saída for atribuída em *todas* as ramificações possíveis. Ao omitir um caso, instruímos o sintetizador a "manter o valor anterior" quando essa condição ocorrer, o que fisicamente resulta na criação de um Latch Transparente. Esta abordagem é elegante e direta para máquinas de estados ou lógicas de controle simples, mas exige cautela. A omissão acidental de um `default` em designs complexos é uma causa frequente de Latches indesejados, que introduzem problemas de temporização e dificultam o fechamento de timing em FPGAs e ASICs. Neste exercício, porém, o Latch é o comportamento desejado e a diretiva `case` fornece uma maneira clara e estruturada de descrevê-lo.

### Implementação Dataflow
A abordagem Dataflow utiliza atribuição contínua com `assign` e operadores ternários aninhados. Diferente da abordagem Behavioral que descreve o comportamento proceduralmente, o Dataflow descreve o fluxo de dados. Para inferir o Latch, utilizamos a técnica de **realimentação explícita**: `(sel == 2'b11) ? out : ...`.

Isso significa que, na condição de Latch, a saída é conectada à sua própria entrada. Embora funcionalmente correto para simulação, isso cria um "loop combinacional" na análise estática. Ferramentas de síntese modernas são inteligentes o suficiente para reconhecer esse padrão como um Latch, mas ele pode gerar avisos (warnings) severos. A vantagem desta abordagem é a concisão; todo o mux pode ser descrito em uma única linha. A desvantagem é a legibilidade reduzida para lógicas complexas e a dependência da ferramenta de síntese para interpretar corretamente o loop como um elemento de memória estável e não como um oscilador ou caminho crítico inválido.

### Implementação Structural
A implementação Structural é a mais detalhada, construindo o circuito porta a porta. O desafio aqui é garantir a estabilidade do Latch sem usar células de biblioteca prontas. Utilizamos uma lógica de **Soma de Produtos (SOP) com Feedback**: `Out = (in0 & S00) | ... | (Out & S11)`.

A robustez desta implementação depende da análise de hazards. Uma implementação ingênua (como um loop simples de Mux) pode falhar devido a "race conditions" onde o sinal de habilitação desliga antes que o feedback ligue, causando glitches. A topologia SOP adotada mitiga isso aproveitando os atrasos naturais dos inversores nas linhas de seleção, garantindo uma transição "make-before-break" (conecta antes de desconectar) segura. Esta abordagem oferece controle total sobre o hardware, sendo ideal para otimização de nível físico, mas é verbosa, difícil de manter e parametrizar sem o uso extensivo de laços `generate`.

---

## 5.3 Descrição do Testbench

O testbench `tb_mux_latche_case` foi projetado para ser uma plataforma de verificação robusta e unificada. Ele instancia as três implementações (`dut_behav`, `dut_data`, `dut_struct`) simultaneamente, alimentando-as com os mesmos estímulos.

**Metodologia de Verificação:**
1.  **Estímulos Determinísticos:** O testbench percorre todas as combinações de seleção (`00` a `10`) e verifica se a saída corresponde à entrada correta.
2.  **Verificação de Latch (Hold):** Ao transitar para `11`, o testbench verifica se a saída mantém o valor do estado anterior (`in2`).
3.  **Teste de Estabilidade:** Um teste crucial onde as entradas de dados são alteradas enquanto o seletor está em `11`. Se a saída mudar, o Latch falhou (tornou-se transparente ou instável).
4.  **Self-Checking:** Utilizamos uma task `check_output` que compara as saídas dos três DUTs contra um modelo de referência esperado. Se qualquer um divergir, um erro é reportado.

**Interpretação dos Resultados:**
A simulação gera um arquivo VCD para análise visual. No visualizador de ondas, observamos as três saídas alinhadas. A ausência de glitches na saída estrutural e a manutenção do valor durante a variação das entradas no modo Hold confirmam o sucesso do design. O log "SIMULACAO CONCLUIDA COM SUCESSO" resume a aprovação em todos os cenários.

---

## 5.4 Aplicações Práticas

O conceito de inferência de Latch via `case` incompleto tem aplicações específicas e importantes no design digital, embora o uso de Flip-Flops (borda) seja predominante em designs síncronos modernos.

**Máquinas de Estados (FSMs):**
Em FSMs estilo Mealy ou Moore, é comum usar um bloco `case` para definir a lógica de próximo estado. Se o projetista esquecer de definir o próximo estado para uma condição de entrada, um Latch será inferido. Embora geralmente indesejado (causando comportamento imprevisível), em designs assíncronos ou "glitch-tolerant", pequenos Latches de controle podem ser usados para filtrar ruídos ou reter estados de erro até um reset global.

**Endereçamento de Memória e Decodificadores:**
Em decodificadores de endereço complexos, às vezes deseja-se que o sinal de "Chip Select" permaneça ativo até que um ciclo de handshake seja completado, mesmo que o endereço mude transitoriamente. Um Latch transparente inferido por um `case` pode implementar essa lógica de "sample and hold" de endereços em barramentos assíncronos antigos (como em alguns periféricos legados ou interfaces de microcontroladores simples).

**Otimização de Área em ASICs:**
Latches ocupam significativamente menos área de silício que Flip-Flops (geralmente metade do tamanho). Em designs de ultra-baixo custo ou alta densidade, onde o timing permite (ciclos de clock longos), substituem-se bancos de registradores por Latches controlados por fases de clock (Two-phase clocking). O `mux_latche` implementado aqui é a célula básica para construir esses bancos de armazenamento compactos.

**Controle de Power Gating:**
Sinais de controle para desligar ilhas de energia (Power Gating) precisam ser extremamente estáveis. Um Latch é frequentemente usado para "travar" o comando de desligamento, garantindo que flutuações na lógica de controle durante o processo de power-down não reativem o bloco acidentalmente. A robustez demonstrada na nossa implementação estrutural é vital para essa aplicação crítica de segurança.
