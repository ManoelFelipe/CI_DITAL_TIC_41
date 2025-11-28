# Relatório Técnico: Registrador PISO de N Bits

## 5.1 Descrição do Projeto
**Autor:** Manoel Furtado  
**Data:** 15/11/2025  

Este projeto consiste na implementação de um Registrador de Deslocamento com Entrada Paralela e Saída Serial (PISO - Parallel-In Serial-Out) parametrizável de N bits. O objetivo principal é desenvolver um módulo flexível capaz de realizar deslocamentos tanto para a direita quanto para a esquerda, controlado por um parâmetro de design. A arquitetura foi desenvolvida utilizando a linguagem de descrição de hardware Verilog (padrão 2001), garantindo compatibilidade com as ferramentas Intel Quartus Prime (para síntese) e Siemens Questa/ModelSim (para simulação).

O sistema opera de forma síncrona à borda de subida do clock e possui reset assíncrono ativo em nível baixo. A funcionalidade central inclui dois modos de operação: carga paralela (Load), onde um dado externo é escrito no registrador, e deslocamento (Shift), onde os bits são movidos serially para a saída. A implementação foi realizada seguindo três abordagens de abstração distintas — Comportamental (Behavioral), Fluxo de Dados (Dataflow) e Estrutural (Structural) — permitindo uma análise comparativa de estilos de codificação e inferência de hardware.

## 5.2 Análise das Abordagens

### Implementação Behavioral
A abordagem comportamental descreve o circuito em termos de sua funcionalidade algorítmica, utilizando construções de alto nível como blocos `always` e estruturas de controle `if-else`. Neste projeto, a lógica é centrada na prioridade das operações: o reset tem precedência sobre a carga, que por sua vez tem precedência sobre o deslocamento. O uso de operadores de concatenação `{}` simplifica a descrição do deslocamento (ex: `{1'b0, reg[N-1:1]}` para shift right). Esta abordagem é geralmente a mais legível e fácil de manter, deixando para a ferramenta de síntese a tarefa de otimizar a lógica de portas e flip-flops.

### Implementação Dataflow
A implementação em fluxo de dados foca no caminho que os dados percorrem através do sistema, utilizando atribuições contínuas (`assign`) e expressões lógicas. Aqui, a lógica do "próximo estado" do registrador é separada da lógica sequencial de atualização. Utilizou-se o operador ternário `? :` para inferir multiplexadores que selecionam entre o dado de carga e o dado deslocado. Embora funcionalmente idêntica à comportamental, esta abordagem oferece uma visão mais clara da lógica combinacional que antecede os elementos de memória, sendo útil para entender o *timing* e o caminho crítico do sinal antes da síntese.

### Implementação Structural
A abordagem estrutural modela o circuito como uma interconexão de componentes básicos, descendo ao nível de portas lógicas e flip-flops. Neste projeto, foram instanciados explicitamente módulos de Multiplexadores 2:1 e Flip-Flops D. Utilizou-se a instrução `generate` para criar iterativamente os N estágios do registrador. Cada estágio consiste em um MUX (que escolhe entre o bit de carga ou o bit do estágio vizinho) alimentando um Flip-Flop. Esta descrição é a mais próxima do hardware físico gerado (netlist) e oferece controle total sobre a arquitetura, porém é mais verbosa e trabalhosa para alterar, especialmente em designs complexos.

## 5.3 Descrição do Testbench
O testbench `tb_reg_piso_n` foi projetado para validar robustamente as três implementações. A metodologia de verificação baseia-se na auto-checagem (self-checking), onde o próprio testbench compara as saídas do dispositivo sob teste (DUT) com valores esperados calculados internamente.

O ambiente de simulação instancia dois módulos PISO simultaneamente: um configurado para deslocamento à direita (`DIR=0`) e outro para a esquerda (`DIR=1`). O procedimento de teste inclui:
1.  **Inicialização e Reset:** Garante que o circuito parta de um estado conhecido.
2.  **Teste de Carga e Shift (Padrão 0xA5):** Carrega o valor `10100101` e verifica bit a bit a saída serial por N ciclos de clock. O testbench calcula o valor esperado realizando operações de shift (`>>` e `<<`) em variáveis inteiras a cada ciclo.
3.  **Teste de Carga e Shift (Padrão 0xF0):** Repete o processo com um padrão diferente para garantir a cobertura de transições de 0s e 1s.
4.  **Monitoramento:** Erros são reportados no console com o tempo e valores discrepantes. Ao final, uma mensagem de "SUCESSO" ou "FALHA" resume o resultado. Formas de onda são gravadas em `wave.vcd` para depuração visual.

## 5.4 Aplicações Práticas
Registradores PISO são componentes fundamentais em sistemas digitais, servindo como a principal interface entre domínios de dados paralelos e seriais.

**Comunicação Serial (UART/SPI/I2C):** Em microcontroladores e FPGAs, dados processados internamente em paralelo (bytes ou palavras) precisam ser transmitidos por um único fio para reduzir a contagem de pinos e o custo de cabeamento. O PISO realiza essa conversão na etapa de transmissão (TX).

**Conversão de Dados em Sensores:** Muitos sensores digitais (ex: temperatura, acelerômetros) acumulam leituras em registradores internos e as enviam serialmente para o processador mestre para economizar pinos no encapsulamento.

**Criptografia e CRC:** Algoritmos de verificação de integridade (como CRC) e cifras de fluxo (stream ciphers) frequentemente utilizam Linear Feedback Shift Registers (LFSRs), que são variações de registradores de deslocamento, para processar fluxos de bits e gerar sequências pseudo-aleatórias.

**Teste de Chips (JTAG/Scan Chains):** Na indústria de semicondutores, cadeias de registradores de deslocamento (Scan Chains) são inseridas dentro dos chips para permitir que dados de teste sejam inseridos e resultados sejam lidos serialmente, permitindo a verificação de falhas de fabricação em milhões de transistores usando poucos pinos de acesso.
