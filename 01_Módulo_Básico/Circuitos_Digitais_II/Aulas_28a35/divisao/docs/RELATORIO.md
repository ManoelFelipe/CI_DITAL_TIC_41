# RELATÓRIO — Comparação entre RDA e NRDA

Este relatório detalha os resultados obtidos na simulação comparativa entre os algoritmos de divisão RDA (*Restoring Division*) e NRDA (*Non-Restoring Division*).

## 1. Configuração de simulação

- **Largura dos operandos:** N = 8 bits
- **Clock:** 100 MHz (Período = 10 ns)
- **Ferramenta de simulação:** Icarus Verilog v12.0
- **Visualização de ondas:** GTKWave

## 2. Resultados obtidos

A tabela abaixo apresenta os dados coletados das simulações para quatro pares de valores de entrada.
Os tempos foram calculados considerando o período do clock de 10 ns (Tempo = Ciclos × 10 ns).

| Teste | Dividend (N) | Divisor (D) | Q obtido | R obtido | Ciclos RDA | Ciclos NRDA | Tempo RDA | Tempo NRDA |
|:-----:|:------------:|:-----------:|:--------:|:--------:|:----------:|:-----------:|:---------:|:----------:|
|   1   |      11      |      3      |     3    |     2    |     31     |      25     |   310 ns  |   250 ns   |
|   2   |      115     |      7      |    16    |     3    |     32     |      25     |   320 ns  |   250 ns   |
|   3   |      113     |      19     |     5    |    18    |     31     |      25     |   310 ns  |   250 ns   |
|   4   |      200     |      13     |    15    |     5    |     29     |      25     |   290 ns  |   250 ns   |

## 3. Análise Comparativa

### Correção dos Resultados
Observa-se que tanto o RDA quanto o NRDA produziram os resultados matematicamente corretos (Quociente e Resto) para todos os casos de teste, validando a lógica implementada em ambos.

### Desempenho (Ciclos)
*   **NRDA (Non-Restoring):** Apresentou um desempenho **constante** de **25 ciclos** para todas as operações. Isso ocorre porque o algoritmo tem um fluxo de execução mais previsível, realizando uma operação aritmética (soma ou subtração) e deslocamento em cada iteração, sem estados condicionais de "volta" (rollback).
*   **RDA (Restoring):** Apresentou um desempenho **variável** e **inferior**, variando entre 29 e 32 ciclos. O número maior de ciclos deve-se à necessidade de "restaurar" o valor do registrador de resto parcial (`A`) sempre que uma subtração resulta em um valor negativo. Essa etapa extra consome ciclos de clock adicionais dependendo dos valores dos dados de entrada.

### Conclusão Teórica
Os resultados práticos confirmam a teoria:
- O **RDA** é conceitualmente mais simples, mas paga um preço em performance devido às etapas de restauração condicional.
- O **NRDA** evita a restauração ao permitir que o resto parcial transite temporariamente por valores negativos e corrigindo isso nas iterações subsequentes. Isso resulta em uma execução mais rápida e determinística (número fixo de ciclos para um dado N).

## 4. Síntese (Estimativa)
Embora a síntese física não tenha sido realizada aqui, teoricamente espera-se que:
- O **NRDA** possa utilizar um pouco mais de área devido à lógica para controlar a operação de soma/subtração em cada ciclo (+/- M).
- O **RDA** utiliza apenas subtração na comparação, mas tem a lógica de desvio de estado para a restauração.
- Em FPGAs modernos, ambos ocupariam poucos recursos (poucas LUTs), mas o NRDA é preferível para aplicações que exigem latência fixa ou maior vazão.
