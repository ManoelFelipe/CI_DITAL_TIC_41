# Relatório Técnico: Projeto PWM 50Hz

## 1. Resumo da Verificação

A verificação funcional do projeto foi realizada utilizando o simulador **QuestaSim**, através de um testbench unificado (`tb_pwm_50hz.v`) projetado para validar e comparar simultaneamente as três arquiteturas desenvolvidas: **Behavioral**, **Dataflow** e **Structural**.

### Metodologia de Teste
-   **Ambiente de Simulação:** O testbench instanciou os três módulos lado a lado, alimentando-os com os mesmos sinais de entrada (`clk`, `reset_n`, `duty_sel`).
-   **Estímulos:** Foram aplicados vetores de teste cobrindo todas as condições de operação especificadas:
    -   Reset assíncrono.
    -   Transição dinâmica entre os duty cycles de **30%**, **60%** e **100%**.
-   **Verificação Automática:** O testbench implementou um monitoramento **ciclo a ciclo** (cycle-accurate). A cada borda de subida do clock de 100 MHz, as saídas das três implementações foram comparadas entre si. Qualquer divergência (ex: uma implementação em '0' e outra em '1') dispararia um erro imediato.

### Correção de Divergência de Fase
Inicialmente, foi identificada uma divergência de fase: a implementação *Behavioral* apresentava um atraso de 1 ciclo de clock em relação às demais.
-   **Causa:** A saída `pwm_out` estava sendo registrada (lógica sequencial) dentro do bloco `always @(posedge clk)`.
-   **Solução:** O código foi refatorado para separar a lógica de saída em um bloco combinacional (`always @*`), mantendo apenas o contador como sequencial. Isso alinhou perfeitamente a fase da implementação Behavioral com as implementações Dataflow e Structural (que já eram combinacionais na saída).

### Resultados Finais
Após a correção, a simulação foi executada por **6000 ciclos de teste** (cobrindo múltiplos períodos de PWM para cada duty cycle).
-   **Erros Detectados:** 0 (Zero).
-   **Conclusão:** As três implementações são funcionalmente equivalentes e atendem rigorosamente às especificações de frequência (50 Hz) e duty cycle (30/60/100%). As formas de onda obtidas confirmam a largura de pulso correta para cada seleção.

---

## 2. Respostas às Questões Teóricas (Atividade 4.5)

### 1. O PWM obtido tem período correto?
**Sim.**
O projeto utiliza um clock de entrada de **100 MHz** (período de 10 ns). Para obter uma frequência de **50 Hz** (período de 20 ms), o contador foi configurado para contar até 2.000.000 ciclos ($2.000.000 \times 10\text{ns} = 20\text{ms}$).
A simulação comprova que o contador reinicia corretamente ao atingir este valor, garantindo a frequência de 50 Hz exata.

### 2. O duty cycle está proporcional à escolha da entrada?
**Sim.**
Os limiares de comparação foram calculados proporcionalmente ao valor máximo do contador:
- **Entrada `00` (30%)**: Comparação com $0,3 \times 2.000.000 = 600.000$ ciclos.
- **Entrada `01` (60%)**: Comparação com $0,6 \times 2.000.000 = 1.200.000$ ciclos.
- **Entrada `10` (100%)**: Saída mantida em nível alto constantemente.
A simulação validou que a largura do pulso em nível alto corresponde exatamente a essas proporções.

### 3. Como o projeto pode ser adaptado para controle de motores?
Para controlar motores reais, duas adaptações principais são necessárias:
1.  **Interface de Potência:** A saída do FPGA (3.3V e baixa corrente) não consegue acionar um motor diretamente. É necessário conectar o pino de saída `pwm_out` a um **driver de potência** (como uma Ponte H ou um transistor MOSFET/IGBT) que suporte a tensão e corrente do motor.
2.  **Ajuste de Frequência:** 50 Hz é uma frequência típica para servomotores de modelismo. Para motores DC comuns ou brushless, pode ser necessário aumentar a frequência (para a faixa de kHz) para evitar ruído audível e garantir uma rotação mais suave. Isso seria feito alterando o parâmetro `COUNTER_MAX`.

### 4. Quais vantagens de implementar PWM via hardware?
As principais vantagens de usar um FPGA/Hardware dedicado em vez de software (microcontrolador) são:
- **Precisão e Determinismo:** O hardware garante tempos exatos de subida e descida, sem o "jitter" (variação) causado por interrupções ou escalonamento de tarefas em um processador.
- **Desempenho (Zero CPU Load):** A geração do sinal não consome ciclos de processamento. O processador (se houver) fica livre para tarefas de alto nível.
- **Paralelismo Real:** É possível instanciar dezenas ou centenas de blocos PWM idênticos para controlar múltiplos motores simultaneamente, sem nenhuma perda de desempenho ou precisão, algo impossível em um microcontrolador sequencial comum.
