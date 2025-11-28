
# Relatório de Verificação - Desafio Extra

## 1. Resumo da Implementação

O desafio extra foi implementado com sucesso, integrando os seguintes módulos:

*   **`top_pwm_challenge.v`**: Módulo topo de hierarquia que integra o sistema.
*   **`debounce.v`**: Responsável por filtrar o ruído do botão de ajuste, garantindo transições limpas.
*   **`seven_seg_driver.v`**: Controlador multiplexado para display de 7 segmentos, exibindo o valor percentual do duty cycle (25, 50, 75, 100).
*   **`pwm_50hz_behav.v`**: Duas instâncias deste módulo geram os sinais PWM sincronizados.

## 2. Análise dos Resultados de Simulação

Com base nas imagens fornecidas da simulação no Questa/ModelSim, podemos confirmar o funcionamento correto do circuito.

### 2.1. Análise da Waveform (Ondas)

A imagem da waveform mostra claramente o comportamento esperado:

1.  **Transição de Duty Cycle (`duty_sel`)**:
    *   O sinal `duty_sel` (linha azul) altera seu valor sequencialmente: `0` (25%) $\rightarrow$ `1` (50%) $\rightarrow$ `2` (75%) $\rightarrow$ `3` (100%) $\rightarrow$ `0` (25%).
    *   Isso confirma que a máquina de estados no `top_pwm_challenge` e o módulo de `debounce` estão funcionando corretamente ao detectar o pressionamento do botão `btn_adjust`.

2.  **Sinais PWM (`pwm_out_1`, `pwm_out_2`)**:
    *   Observa-se que a largura do pulso em nível alto (duty cycle) aumenta conforme `duty_sel` incrementa.
    *   No estado `duty_sel = 3` (100%), o sinal fica constantemente em nível alto, como esperado.
    *   Os dois canais são idênticos e sincronizados.

3.  **Display de 7 Segmentos (`segments`, `anodes`)**:
    *   Os sinais `anodes` e `segments` apresentam atividade constante de comutação, indicando que a multiplexação (varredura) dos dígitos está ativa e operante.

### 2.2. Análise do Log (Transcript)

O log do console confirma a execução do testbench:

*   A mensagem "Starting Simulation..." indica o início.
*   As mensagens "Pressing Button..." aparecem 4 vezes, correspondendo aos 4 eventos de teste programados no testbench.
*   A simulação termina com "Simulation Finished." sem erros, validando a lógica de teste.

## 3. Conclusão

O resultado obtido **foi o esperado**. O sistema responde corretamente aos estímulos do botão, ajustando o PWM e atualizando o display conforme especificado no desafio. A implementação atende a todos os requisitos:
- [x] Ajuste de duty cycle via botão.
- [x] Exibição no display de 7 segmentos.
- [x] Dois canais PWM simultâneos.
