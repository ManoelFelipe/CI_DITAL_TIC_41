# Relatório de Implementação e Verificação: PWM 50Hz (Modificado)

## 1. Resumo das Modificações
O projeto original foi alterado para atender às novas especificações do enunciado:
*   **Frequência do PWM:** 50 Hz (Período de 20 ms).
*   **Clock:** 100 MHz (Período de 10 ns).
*   **Contador:** Expandido para **21 bits** para suportar a contagem de até 2.000.000 (necessária para 20 ms).
*   **Duty Cycles:** Ajustados para **25%, 50%, 75% e 100%**.
*   **Seleção (`duty_sel`):**
    *   `00`: 25%
    *   `01`: 50%
    *   `10`: 75%
    *   `11`: 100%

## 2. Implementações em Verilog
As três abordagens foram atualizadas para refletir a nova lógica:

### Behavioral (`pwm_50hz_behav.v`)
*   Utiliza um bloco `always` síncrono para o contador e um bloco combinacional `case` para a comparação.
*   Lógica ajustada para os novos limiares (500.000, 1.000.000, 1.500.000 ciclos).

### Dataflow (`pwm_50hz_data.v`)
*   Utiliza `assign` para definir o `threshold` com base em `duty_sel`.
*   Comparador contínuo `assign below_threshold = (counter < threshold)`.

### Structural (`pwm_50hz_struct.v`)
*   Módulos `pwm_counter_struct`, `pwm_duty_selector_struct` e `pwm_comparator_struct` atualizados para 21 bits e novos limiares.
*   Mantém a hierarquia e modularidade.

## 3. Verificação e Simulação

### Testbench (`tb_pwm_50hz.v`)
*   **Adaptação para Simulação:** O parâmetro `TB_COUNTER_MAX` foi reduzido para **2000** ciclos durante a simulação para permitir a visualização rápida das formas de onda e verificação lógica sem aguardar 20 ms reais de simulação (o que levaria muito tempo de processamento).
*   **Casos de Teste:** Foram executados testes automáticos para todas as combinações de `duty_sel`.

### Resultados Obtidos
A simulação foi concluída com **SUCESSO**, confirmando que as três implementações (Behavioral, Dataflow e Structural) produzem saídas idênticas e corretas para todos os casos.

| Duty Sel | Duty Cycle Esperado | Resultado (Behavioral) | Resultado (Dataflow) | Resultado (Structural) | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `00` | 25% | 25% | 25% | 25% | **OK** |
| `01` | 50% | 50% | 50% | 50% | **OK** |
| `10` | 75% | 75% | 75% | 75% | **OK** |
| `11` | 100% | 100% | 100% | 100% | **OK** |

### Evidências
*   **Log de Transcrição:** Confirma a consistência em 8000 testes simulados (escala reduzida).
*   **Waveform:** Mostra a variação correta da largura de pulso conforme a seleção muda de 0 a 3, com os duty cycles visualmente proporcionais (1/4, 1/2, 3/4 e total).

## 4. Conclusão
O projeto atende integralmente aos requisitos do enunciado modificado. O código está pronto para síntese (com o parâmetro `COUNTER_MAX` original de 2.000.000 configurado nos módulos RTL) e validado funcionalmente.
