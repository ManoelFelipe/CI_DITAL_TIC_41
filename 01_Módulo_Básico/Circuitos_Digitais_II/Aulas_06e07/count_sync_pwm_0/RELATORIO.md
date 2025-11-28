
# RELATORIO.md

## 1. O PWM obtido tem período correto?

Sim. A verificação do período foi feita tanto de forma analítica quanto por simulação. Analiticamente, o período do PWM é determinado pela relação entre a frequência do clock (`f_clk`) e a frequência desejada do PWM (`f_pwm`). No projeto, o clock é de 100 MHz e o PWM alvo é de 50 Hz, o que leva a:

`COUNTER_MAX = f_clk / f_pwm = 100_000_000 / 50 = 2_000_000` ciclos por período.

Na simulação, para não ter um tempo de execução excessivo, foi adotado um valor reduzido de contador apenas no testbench (`TB_COUNTER_MAX = 2000`), mas mantendo a mesma lógica. O testbench conta quantos ciclos são necessários até o contador reiniciar e observa as transições da saída. O log mostra que, após cada janela de `TB_COUNTER_MAX` ciclos, o comportamento da forma de onda se repete, caracterizando um período estável de PWM. Em hardware real, bastaria usar `COUNTER_MAX = 2_000_000` para obter exatamente 20 ms de período (50 Hz). Portanto, o PWM implementado apresenta período consistente com a especificação.

## 2. O duty cycle está proporcional à escolha da entrada?

Sim. A entrada `duty_sel` (2 bits) foi codificada para selecionar diretamente a fração do período em que a saída fica em nível alto. A codificação adotada foi:

- `duty_sel = 2'b00` → aproximadamente **30%** de duty;
- `duty_sel = 2'b01` → aproximadamente **60%** de duty;
- `duty_sel = 2'b10` → **100%** de duty (saída sempre em nível alto);
- `duty_sel = 2'b11` → **0%** de duty (saída sempre em nível baixo, modo reserva).

No testbench, para cada valor de `duty_sel` é executada uma tarefa que mede, ao longo de um período completo, quantos ciclos o sinal fica em nível alto. Os resultados obtidos foram:

- 30% → `high = 600` ciclos de 2000;
- 60% → `high = 1200` ciclos de 2000;
- 100% → `high = 2000` ciclos de 2000.

Esses valores correspondem exatamente a 30%, 60% e 100%. Além disso, as três implementações (behavioral, dataflow e structural) apresentaram o mesmo número de ciclos em nível alto, comprovando que a lógica de seleção de limiar está correta. Em resumo, ao mudar `duty_sel` na simulação, vê‑se claramente a variação proporcional da largura do pulso, o que confirma que o duty cycle é proporcional à escolha da entrada.

## 3. Como o projeto pode ser adaptado para controle de motores?

O mesmo gerador de PWM pode ser usado como bloco de controle de potência para motores DC ou, com pequenas alterações, para motores brushless. Para motores DC, o PWM controla a **tensão média** aplicada à armadura: quanto maior o duty cycle, maior a tensão média e, consequentemente, maior a velocidade de rotação. A adaptação prática consiste em substituir o LED teórico por um estágio de potência, normalmente uma ponte H com MOSFETs, dimensionados para a corrente do motor. O sinal PWM gerado pelo módulo Verilog passa a chavear esses transistores, enquanto a alimentação principal vem de uma fonte externa (bateria ou fonte DC).

Em aplicações um pouco mais avançadas, o projeto pode ser estendido para múltiplos canais de PWM, permitindo controlar vários motores de forma independente. Também é possível adicionar lógica de proteção, como desligar o PWM quando um sensor de corrente indicar sobrecarga, ou implementar rampas de aceleração e frenagem (soft‑start/soft‑stop), alterando o duty cycle de forma gradual. Para motores BLDC, o PWM costuma ser aplicado nos transistores de um inversor trifásico, em combinação com uma lógica de comutação que depende da posição do rotor. Em todos esses casos, o núcleo do projeto — contador + comparador + seleção de duty — continua o mesmo, apenas integrado a um driver de potência adequado.

## 4. Quais vantagens de implementar PWM via hardware?

Implementar PWM diretamente em hardware (FPGA, CPLD, ASIC ou periférico dedicado de microcontrolador) apresenta diversas vantagens em relação a gerar o sinal por software:

1. **Determinismo temporal**: a geração do PWM não depende da carga da CPU, interrupções ou latência de software. A precisão de período e duty é garantida pelo relógio de hardware, o que é essencial em sistemas de tempo real.

2. **Alta frequência e resolução**: é possível operar com frequências de dezenas ou centenas de kHz e com grande resolução de duty (muitos bits), algo difícil de obter com laços de software sem consumir a maior parte do tempo do processador.

3. **Paralelismo**: vários canais de PWM podem ser gerados em paralelo praticamente “de graça” em termos de tempo de execução, bastando replicar a lógica ou compartilhar o contador com comparadores diferentes.

4. **Confiabilidade e segurança**: em aplicações como drivers de motor, conversores de potência e iluminação industrial, falhas de temporização podem causar aquecimento excessivo, ruído ou até danos ao equipamento. Um bloco de PWM em hardware dedicado reduz esse risco e pode ser combinado com lógica de proteção (desligar o sinal em caso de erro).

5. **Liberação da CPU**: o processador principal fica livre para executar algoritmos de controle mais complexos, comunicação, interface com usuário etc., enquanto o hardware de PWM cuida da modulação em nível de ciclo de clock.

Por esses motivos, a abordagem em hardware utilizada neste projeto é a mais adequada para aplicações reais de controle e acionamento em sistemas embarcados.
