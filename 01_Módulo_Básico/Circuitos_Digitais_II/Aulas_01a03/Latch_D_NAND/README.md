# Relatório de Projeto: Latch D com Portas NAND

## 1. Objetivo
O objetivo deste projeto é implementar e validar o comportamento de um **Latch D (Data Latch)** sensível ao nível alto do clock (High-Level Transparent), utilizando a linguagem de descrição de hardware Verilog. A validação é feita através de simulação, comparando a forma de onda gerada com um diagrama de referência ("enunciado").

## 2. Metodologia

### 2.1. Implementação (`latch_d_nand.v`)
O Latch D foi modelado de forma comportamental para garantir clareza e funcionalidade. O circuito opera em dois modos distintos, controlados pelo sinal de `CLK`:

*   **Modo Transparente (`CLK = 1`)**: A saída `Q` segue imediatamente o valor da entrada `D`.
*   **Modo Memória (`CLK = 0`)**: A saída `Q` mantém o último valor armazenado, ignorando variações em `D`.

A implementação reflete a lógica de um Latch D construído com portas NAND, onde o sinal de habilitação controla o acesso dos dados ao elemento de memória.

### 2.2. Testbench (`tb_latch_d_nand.v`)
O ambiente de teste foi projetado para replicar exatamente os cenários propostos no exercício. O clock foi regularizado com um período de 40ns (20ns High / 20ns Low) para facilitar a análise.

Os seguintes cenários foram simulados:
1.  **Transparência**: Verificação da propagação de `D` para `Q` durante o nível alto do clock.
2.  **Estabilidade**: Confirmação de que `Q` não muda se `D` for estável em 0.
3.  **Glitches**: Teste de resposta a múltiplas transições rápidas em `D` (ruído) durante o período transparente.
4.  **Latch em Nível Alto**: Verificação da capacidade de memorizar o valor '1' quando o clock desce.
5.  **Latch em Nível Baixo**: Verificação da capacidade de memorizar o valor '0' quando o clock desce.

## 3. Resultados da Simulação

A simulação produziu a seguinte tabela de eventos (resumo):

| Tempo (ns) | CLK | D | Q | Comentário |
|-----------:|:---:|:-:|:-:|:-----------|
| 0          | 0   | 0 | 0 | Estado Inicial |
| 20         | 1   | 0 | 0 | Início do Pulso 1 (Transparente) |
| 25         | 1   | 1 | 1 | Q segue D (Sobe) |
| 35         | 1   | 0 | 0 | Q segue D (Desce) |
| 40         | 0   | 0 | 0 | Fim do Pulso 1 |
| 60         | 1   | 0 | 0 | Início do Pulso 2 (D=0) |
| 80         | 0   | 0 | 0 | Fim do Pulso 2 |
| 100        | 1   | 0 | 0 | Início do Pulso 3 (Glitches) |
| 103        | 1   | 1 | 1 | Glitch 1 (Sobe) |
| 106        | 1   | 0 | 0 | Glitch 1 (Desce) |
| 109        | 1   | 1 | 1 | Glitch 2 (Sobe) |
| 112        | 1   | 0 | 0 | Glitch 2 (Desce) |
| 120        | 0   | 0 | 0 | Fim do Pulso 3 |
| 140        | 1   | 0 | 0 | Início do Pulso 4 (Latch High) |
| 145        | 1   | 1 | 1 | D sobe, Q sobe |
| 160        | 0   | 1 | 1 | **Clock desce, Q memoriza 1** |
| 170        | 0   | 0 | 1 | D muda, mas Q mantém 1 (Correto) |
| 180        | 1   | 0 | 0 | Início do Pulso 5 (Latch Low) |
| 185        | 1   | 1 | 1 | D sobe, Q sobe |
| 195        | 1   | 0 | 0 | D desce, Q desce |
| 200        | 0   | 0 | 0 | **Clock desce, Q memoriza 0** |

### Análise da Forma de Onda
A forma de onda obtida na simulação está **alinhada com o enunciado**, demonstrando:
- Pulsos de clock regulares.
- Comportamento transparente correto (Q = D quando CLK=1).
- Comportamento de memória correto (Q = Q_ant quando CLK=0).
- Imunidade a mudanças em D quando o clock está baixo.

## 4. Conclusão
O projeto foi concluído com sucesso. O código Verilog implementa corretamente a lógica do Latch D, e o testbench valida todos os casos de borda e cenários operacionais exigidos. A documentação e os comentários no código foram aprimorados para facilitar a manutenção e o entendimento futuro.
