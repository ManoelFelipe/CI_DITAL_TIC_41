# Projeto PWM 50 Hz com Seleção de Duty Cycle em HDL (Verilog)

## 5.1 Descrição do Projeto

Autor: **Manoel Furtado**  
Data: **27/11/2025**  

Este projeto implementa em Verilog um gerador de PWM (Pulse Width Modulation) com frequência de **50 Hz**, alimentado por um clock de **100 MHz**, com seleção de quatro níveis de duty cycle (25%, 50%, 75% e 100%) por meio de uma entrada de controle de 2 bits. A saída do PWM é pensada, do ponto de vista didático, como conectada a um LED, permitindo observar visualmente a variação do brilho em função do duty cycle. A arquitetura é parametrizável e foi estruturada de forma a atender às exigências de um projeto acadêmico típico: três abordagens de descrição em HDL (behavioral, dataflow e structural), um testbench unificado para validação, scripts de automação de simulação no Questa e um relatório técnico consolidado neste README.

O núcleo do projeto é um **contador síncrono** que percorre todos os ciclos de clock necessários para compor um período de 50 Hz. Como o clock de entrada é de 100 MHz, o número de ciclos por período é dado por `COUNTER_MAX = 100e6 / 50 = 2_000_000`. Em cada ciclo, o valor atual do contador é comparado com um limiar associado ao duty cycle desejado. Para 25%, o limiar é de 500_000 ciclos; para 50%, 1_000_000 ciclos; para 75%, 1_500_000 ciclos; e para 100% o sinal permanece sempre em nível alto.

A entrada de seleção de duty cycle (`duty_sel`) foi mapeada da seguinte forma: `00` para 25%, `01` para 50%, `10` para 75% e `11` para 100%. Essa codificação cobre quatro níveis de intensidade. Do ponto de vista pedagógico, o projeto ilustra claramente a relação entre frequência de clock, contagem de ciclos, período e duty cycle.

---

## 5.2 Análise das Abordagens (Behavioral, Dataflow e Structural)

### Implementação Behavioral

Na abordagem **behavioral**, o módulo `pwm_50hz_behav` concentra praticamente toda a lógica em um único bloco sequencial `always @(posedge clk or negedge reset_n)`. Dentro desse bloco, o contador é incrementado a cada borda de subida do clock e reiniciado ao atingir `COUNTER_MAX - 1`. Em seguida, a saída PWM é atualizada com base em um `case` sobre o sinal `duty_sel`. Para 25%, 50% e 75%, realiza-se uma comparação direta entre o valor atual do contador e os limiares `DUTY_25`, `DUTY_50` e `DUTY_75`. Para 100% (caso 11), a saída é forçada para nível alto. Essa abordagem é muito intuitiva: o projetista pensa em termos de comportamento temporal (“a cada ciclo faça isto”), deixando para o sintetizador a tarefa de inferir comparadores e muxes.

### Implementação Dataflow

Na implementação **dataflow**, o contador continua sequencial, mas toda a lógica de geração da forma de onda é expressa com atribuições contínuas (`assign`). Um `wire [20:0] threshold` recebe, por um operador condicional encadeado, o limiar correspondente ao valor de `duty_sel`. Em seguida, outro `assign` compara o contador a esse limiar, produzindo `below_threshold`, e um terceiro define a saída PWM com tratamento explícito do caso 100% (sempre alto). Esse estilo reforça a visão de “fluxo de dados”: não pensamos mais em etapas temporais, mas em expressões combinacionais que relacionam entradas, estado interno e saída.

### Implementação Structural

A abordagem **structural** decompõe o sistema em três blocos principais: `pwm_counter_struct`, `pwm_duty_selector_struct` e `pwm_comparator_struct`. O módulo top-level `pwm_50hz_struct` apenas instancia esses submódulos e faz a multiplexação final da saída para tratar o caso de 100%. Nessa visão, o projeto se aproxima do diagrama de blocos de hardware: um contador gera uma rampa temporal, um bloco de seleção fornece o limiar adequado e um comparador converte a relação entre contador e limiar em um pulso PWM.

---

## 5.3 Descrição do Testbench e Metodologia de Simulação

O testbench `tb_pwm_50hz` foi projetado para validar simultaneamente as três implementações (`pwm_50hz_behav`, `pwm_50hz_data` e `pwm_50hz_struct`) utilizando uma metodologia sistemática e determinística. Primeiramente, define-se um clock de **100 MHz** com período de 10 ns. **Nota:** Para viabilizar a simulação em tempo razoável, o parâmetro `TB_COUNTER_MAX` foi reduzido para **2000 ciclos** no testbench, em vez dos 2.000.000 necessários para 20ms reais. Isso não afeta a lógica de verificação, apenas a escala de tempo. Em seguida, é aplicado um reset assíncrono ativo em nível baixo durante alguns ciclos. Após a liberação do reset, o testbench chama uma tarefa `run_case` para cada valor de `duty_sel` de interesse: 25% (`2'b00`), 50% (`2'b01`), 75% (`2'b10`) e 100% (`2'b11`).

Dentro de `run_case`, o testbench aguarda inicialmente um período completo de PWM para permitir que o sistema se estabilize após a mudança do duty cycle. Depois disso, realiza uma janela de medição de **um período inteiro**, durante o qual observa as saídas das três implementações ciclo a ciclo. Em cada borda de subida do clock, contadores de ciclos em nível alto (`high_behav`, `high_data`, `high_struct`) são atualizados, e uma checagem automática verifica se `pwm_behav`, `pwm_data` e `pwm_struct` são idênticos. Se alguma divergência é detectada, uma mensagem de erro é exibida no console com o tempo de simulação e os valores das três saídas, além de um `error_flag` ser ativado para sinalizar falha no teste.

Ao final da janela de medição, o testbench calcula o duty cycle efetivo de cada implementação pela razão `high_count / total_cycles * 100`, arredondando para inteiros. Esses valores são impressos em um resumo que compara a porcentagem esperada (25, 50, 75 ou 100) com as porcentagens medidas para cada abordagem. Isso permite validar se pequenas diferenças de arredondamento estão dentro do aceitável e se o dimensionamento de `COUNTER_MAX` está coerente com a frequência alvo de 50 Hz. Além disso, uma tarefa `tabela_didatica` imprime uma tabela com 16 amostras sequenciais da saída behavioral logo após a mudança de `duty_sel`, facilitando a inspeção visual da forma de onda gerada.

Ao final da simulação, caso nenhuma divergência entre abordagens tenha sido detectada, o testbench exibe a mensagem obrigatória:  
`"SUCESSO: Todas as implementacoes estao consistentes em %0d testes."`, onde `%0d` é substituído pelo número total de ciclos avaliados. Por fim, a mensagem `"Fim da simulacao."` é impressa e o comando `$finish` encerra a execução. O testbench também gera um arquivo `wave.vcd` com todas as formas de onda relevantes, permitindo a análise gráfica detalhada da largura do pulso, do período de 50 Hz e do comportamento do contador.

---

## 5.4 Aplicações Práticas e Extensões do Projeto

Geradores de PWM são blocos fundamentais em sistemas embarcados e aplicações de eletrônica de potência. O projeto apresentado, embora focado em um LED teórico, pode ser facilmente estendido para controlar **motores DC**, **drivers de LEDs de alta potência**, **fontes chaveadas** e até estágios de modulação em inversores trifásicos. Na prática, o PWM controla a **tensão média** aplicada à carga: quanto maior o duty cycle, maior a potência entregue. Em um motor de corrente contínua, por exemplo, o aumento de duty cycle se traduz em maior velocidade média, desde que a frequência de chaveamento seja alta o suficiente para que a inércia mecânica suavize as variações instantâneas de torque.

No contexto de um LED, o duty cycle controla o brilho percebido: 25% gera um brilho baixo, 50% médio, 75% alto e 100% máximo. É importante notar que a frequência de 50 Hz é adequada apenas para fins didáticos e simulações onde se deseja relacionar com o período da rede elétrica. Em aplicações reais de iluminação, utiliza-se normalmente uma frequência de PWM muito maior (na ordem de alguns kHz) para evitar cintilação perceptível ao olho humano e melhorar a resposta de drivers comerciais. Para adaptar o projeto a essas frequências, basta ajustar os parâmetros `CLK_FREQ_HZ` e `PWM_FREQ_HZ`, desde que o contador tenha largura suficiente para representar `COUNTER_MAX` sem overflow.

Outra extensão natural é o uso de vários canais de PWM em paralelo, compartilhando o mesmo clock e, eventualmente, o mesmo contador, mas com limiares de comparação independentes. Essa técnica reduz o consumo de recursos em FPGAs e CPLDs, permitindo controlar múltiplos motores ou LEDs RGB a partir de um único bloco de contagem. Do ponto de vista de integração com microcontroladores ou processadores de aplicação, o sinal `duty_sel` poderia ser substituído por um registrador programável de N bits, permitindo ajustar o duty cycle com resolução muito maior do que os três níveis fixos atuais. A mesma arquitetura poderia ser encapsulada em um periférico mapeado em memória, com interface AXI ou Wishbone, e controlada por software. Finalmente, a descrição em três abordagens distintas demonstra como o mesmo comportamento de hardware pode ser capturado em estilos de HDL diferentes, oferecendo ao projetista liberdade para priorizar legibilidade, reuso ou compacidade de código.

---

## 5.5 Respostas Teóricas – Atividade 4.5

1. **O PWM obtido tem período correto?**  
Sim. O período do PWM é definido a partir da relação direta entre a frequência do clock e a frequência desejada do sinal PWM. Com um clock de 100 MHz (período de 10 ns) e frequência-alvo de 50 Hz, calculamos `COUNTER_MAX = 100_000_000 / 50 = 2_000_000` ciclos. Isso significa que o contador leva 2 milhões de ciclos de clock para completar um período, o que corresponde a `2_000_000 × 10 ns = 20 ms`, exatamente o período de um sinal de 50 Hz. O testbench mede o número de ciclos por período e confirma que o reinício do contador ocorre no tempo esperado, validando assim o período do PWM tanto analiticamente quanto por simulação.

2. **O duty cycle está proporcional à escolha da entrada?**  
Sim. A entrada `duty_sel` foi mapeada de forma que cada combinação seleciona um limiar de comparação proporcional à porcentagem desejada. Para `duty_sel = 2'b00`, o limiar é `DUTY_25 = COUNTER_MAX × 25 / 100`; para `2'b01`, `DUTY_50 = COUNTER_MAX × 50 / 100`; para `2'b10`, `DUTY_75 = COUNTER_MAX × 75 / 100`; e para `2'b11`, o sinal fica permanentemente em nível alto, representando 100% de duty cycle. Durante a simulação, o testbench conta quantos ciclos do período o sinal permanece em nível alto e calcula a porcentagem efetiva, que se aproxima de 25%, 50%, 75% e 100%, confirmando que o duty cycle está proporcional à escolha da entrada.

3. **Como o projeto pode ser adaptado para controle de motores?**  
Para controlar motores DC, a mesma estrutura de PWM pode ser utilizada como sinal de comando de um estágio de potência, geralmente composto por um MOSFET, transistor bipolo ou ponte H. O duty cycle passa a representar a tensão média aplicada ao motor, influenciando diretamente a velocidade e, indiretamente, o torque. Em aplicações reais, costuma-se elevar a frequência do PWM para alguns kHz, a fim de minimizar ruídos audíveis e suavizar o comportamento mecânico. Também é comum introduzir recursos adicionais, como rampas de aceleração e desaceleração (soft-start e soft-stop), proteção contra sobrecorrente e monitoramento de temperatura. O módulo PWM aqui apresentado pode servir como bloco básico, bastando ajustar parâmetros, encapsular a interface de controle em registradores programáveis e interligá-lo ao estágio de potência adequado.

4. **Quais vantagens de implementar PWM via hardware?**  
Implementar PWM diretamente em hardware (FPGA, ASIC ou periférico dedicado de microcontrolador) traz várias vantagens em relação a gerar o sinal por software. Primeiramente, o hardware garante **determinismo temporal**: o período e o duty cycle não sofrem interferência de interrupções, latência de software ou variações de carga de CPU. Isso é crítico em sistemas de tempo real, como controle de motores, alimentação de cargas sensíveis e comunicação por modulação. Em segundo lugar, o hardware permite operar em frequências muito mais altas com resolução fina de duty cycle, sem sobrecarregar o processador. Além disso, múltiplos canais de PWM podem ser gerados em paralelo praticamente sem custo adicional de tempo de execução, apenas com aumento moderado de área em lógica programável. Por fim, um bloco de PWM em hardware pode ser integrado com outros recursos de proteção (comparadores analógicos, sensores de corrente e tensão) para desligar o estágio de potência de forma imediata em caso de falhas, algo difícil de garantir quando o controle depende exclusivamente de software rodando em um núcleo de processamento geral.
