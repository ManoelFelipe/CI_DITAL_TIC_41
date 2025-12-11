# Relatório de Verificação: Multiplicador de Frações com Sinal (4-bits)

## 1. Introdução e Objetivo
Este relatório documenta a validação funcional do projeto `mult2c_frac_4bit`, um multiplicador sequencial para números binários com sinal em representação de **Complemento de 2**.

O objetivo foi garantir que o circuito realize corretamente operações aritméticas do tipo **Q1.3** (1 bit de sinal, 3 bits fracioários), seguindo a lógica "Otimizada" descrita na literatura (baseada na arquitetura de Roth).

---

## 2. Fundamentação Teórica e Implementação

### 2.1. O Algoritmo
O multiplicador utiliza uma abordagem sequencial (Shift-and-Add) adaptada para números com sinal. Diferente de multiplicadores para números inteiros positivos (unsigned), este circuito precisa lidar corretamente com o bit de sinal dos operandos:

1.  **Bits de Magnitude (0 a 2):** Processados normalmente. Se o bit do multiplicador for 1, o multiplicando é somado ao acumulador parcial. Em seguida, realiza-se um deslocamento aritmético à direita.
2.  **Bit de Sinal (3):** O bit mais significativo (MSB) tem peso negativo em complemento de 2 ($-2^0 = -1$).
    *   Se o bit de sinal do multiplicador for 1, **subtrai-se** o multiplicando do acumulador acumulado até então.
    *   No hardware, isso é feito somando o complemento de 2 do multiplicando: $A = A + (\sim M_{cand} + 1)$.

### 2.2. Máquina de Estados (FSM)
A implementação em Verilog segue fielmente o diagrama de estados validado:

*   **S0 (Idle):** Aguarda o sinal de início (`st`). Limpa os registradores.
*   **S1, S2, S3 (Bits 0-2):** Estados responsáveis pelos bits de fração positiva.
    *   Lógica: `Se M=1 então (Soma + Shift) senão (Apenas Shift)`.
*   **S4 (Bit de Sinal):** Estado crítico que define o sinal do resultado.
    *   Lógica: `Se M=1 então (Subtração + Shift) senão (Apenas Shift)`.
*   **S5 (Clear):** Estado final para limpar flags e preparar para novo ciclo.

---

## 3. Metodologia de Teste

Para garantir robustez, o *testbench* (`tb_mult2c_frac_4bit.v`) foi projetado com as seguintes características:

*   **Verificação Automática (Self-Checking):** O testbench calcula o resultado esperado usando operadores matemáticos de alto nível do Verilog (`*`) e compara com a saída do circuito bit-a-bit.
*   **Cobertura de Casos:** Foram testadas as 4 combinações possíveis de sinais:
    1.  **Positivo x Positivo**
    2.  **Negativo x Positivo**
    3.  **Positivo x Negativo**
    4.  **Negativo x Negativo**
*   **Correções no Ambiente:**
    *   Solucionada condição de corrida no sinal `start` que impedia o início correto da simulação em alguns visualizadores.
    *   Implementado tempo de guarda (reset) entre testes consecutivos para evitar estados instáveis da FSM.

---

## 4. Resultados Detalhados da Simulação

A simulação comprovou que o hardware opera exatamente conforme a teoria matemática. Abaixo detalhamos os casos executados:

### Tabela de Resultados

| Caso | Operação (Binário Q1.3) | Decimal Equivalente | Resultado Esperado | Saída do DUT | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **++** | `0.101` x `0.101` | $+0.625 \times +0.625$ | $+0.390625$ ($25 \times 2^{-6}$) | `0011001` | ✅ APROVADO |
| **-+** | `1.101` x `0.101` | $-0.375 \times +0.625$ | $-0.234375$ ($-15 \times 2^{-6}$) | `1110001` | ✅ APROVADO |
| **+-** | `0.101` x `1.101` | $+0.625 \times -0.375$ | $-0.234375$ ($-15 \times 2^{-6}$) | `1110001` | ✅ APROVADO |
| **--** | `1.101` x `1.101` | $-0.375 \times -0.375$ | $+0.140625$ ($9 \times 2^{-6}$) | `0001001` | ✅ APROVADO |

> **Nota sobre o Resultado:** O produto de dois números de 4 bits (Q1.3) resulta em um número Q2.6 (8 bits teóricos). O circuito fornece 7 bits (o bit mais significativo é duplicado/descartado internamente na lógica de saída, mas a representação de valor é mantida corretamente pelo bit de sinal restante). Na simulação, estendemos esse sinal para fazer a comparação correta.

---

## 5. Conclusão Final

O projeto **está aprovado**.

1.  **Conformidade:** O código Verilog traduz corretamente a lógica sequencial e aritmética proposta nas imagens de referência.
2.  **Robustez:** O testbench foi melhorado para evitar falsos negativos e falhas de sincronização.
3.  **Precisão:** Todos os erros de cálculo teóricos foram zerados na comparação automática.

O arquivo de ondas `wave.vcd` gerado pode ser utilizado no GTKWave para inspeção visual ciclo a ciclo, confirmando o comportamento dos estados `state` e sinal `done`.
