
# Desafio Extra - PWM Controlado

Este documento descreve a implementação do desafio extra para o projeto PWM.

## Funcionalidades Implementadas

1.  **Ajuste do Duty Cycle via Botão:**
    *   Um botão (`btn_adjust`) permite alternar ciclicamente entre os duty cycles: 25%, 50%, 75% e 100%.
    *   Foi implementado um módulo de `debounce` para garantir leitura estável do botão.

2.  **Exibição em Display de 7 Segmentos:**
    *   O valor do duty cycle atual é exibido no display de 7 segmentos.
    *   Mapeamento:
        *   25% -> Exibe "25"
        *   50% -> Exibe "50"
        *   75% -> Exibe "75"
        *   100% -> Exibe "100"
    *   O driver do display utiliza multiplexação para controlar os anodos e segmentos.

3.  **Dois Canais PWM Simultâneos:**
    *   O módulo gera duas saídas PWM (`pwm_out_1` e `pwm_out_2`) simultaneamente.
    *   Ambos os canais seguem o mesmo duty cycle selecionado pelo botão.

## Arquivos Criados

*   `Questa/rtl/behavioral/debounce.v`: Módulo de debounce.
*   `Questa/rtl/behavioral/seven_seg_driver.v`: Driver para display de 7 segmentos.
*   `Questa/rtl/behavioral/top_pwm_challenge.v`: Módulo topo de hierarquia que integra tudo.
*   `Questa/tb/tb_top_pwm_challenge.v`: Testbench para verificar o funcionamento.
*   `Questa/scripts/compile_challenge.do`: Script de compilação para Questa/ModelSim.
*   `Questa/scripts/run_challenge_gui.do`: Script de execução com interface gráfica.

## Como Simular (Questa/ModelSim)

1.  Abra o Questa/ModelSim.
2.  Navegue até a pasta `Questa/scripts`.
3.  Execute o comando:
    ```tcl
    do run_challenge_gui.do
    ```
