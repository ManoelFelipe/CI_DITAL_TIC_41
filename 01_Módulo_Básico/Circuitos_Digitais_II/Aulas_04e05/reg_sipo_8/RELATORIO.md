# Relatório de Verificação: Registrador SIPO 8 Bits

**Data:** 25/11/2025  
**Autor:** Manoel Furtado  
**Status:** ✅ Aprovado

## 1. Resumo da Simulação
A verificação funcional do Registrador SIPO de 8 bits foi realizada com sucesso. O testbench unificado comparou simultaneamente as três implementações (Behavioral, Dataflow e Structural) e não detectou nenhuma divergência durante os ciclos de teste.

**Resultado Final:**
> `SUCESSO: Todas as implementacoes estao consistentes em 7 testes.`

## 2. Tabela de Resultados (Log de Simulação)
Abaixo está a tabela gerada automaticamente pelo testbench durante a simulação, demonstrando o funcionamento correto dos modos de deslocamento e reset.

| Tempo (ps) | rst | dir | din | q_behav (bin) | q_behav (dec) | Observações |
|:---:|:---:|:---:|:---:|:---:|:---:|:---|
| 15000 | 0 | 0 | 0 | `00000000` | 0 | Reset liberado |
| 25000 | 0 | 0 | 1 | `10000000` | 128 | Shift Right: Entra 1 no MSB |
| 35000 | 0 | 0 | 0 | `01000000` | 64 | Shift Right: Entra 0 no MSB |
| 45000 | 0 | 0 | 1 | `10100000` | 160 | Shift Right: Entra 1 no MSB |
| 55000 | 0 | 1 | 1 | `01000001` | 65 | Shift Left: Entra 1 no LSB |
| 65000 | 0 | 1 | 1 | `10000011` | 131 | Shift Left: Entra 1 no LSB |
| 75000 | 1 | 1 | 1 | `00000000` | 0 | Reset ativado |

## 3. Análise das Formas de Onda
A análise visual do arquivo `wave.vcd` (conforme captura de tela) confirma:
1.  **Consistência:** Os sinais `q_behav`, `q_data` e `q_struct` são idênticos em todos os momentos.
2.  **Reset:** O sinal `rst` limpa o registrador imediatamente (assíncrono).
3.  **Shift Right (`dir=0`):** O bit de entrada `din` entra na posição `q[7]` e os dados se movem para `q[0]`.
4.  **Shift Left (`dir=1`):** O bit de entrada `din` entra na posição `q[0]` e os dados se movem para `q[7]`.

## 4. Conclusão
O projeto atende a todos os requisitos funcionais especificados. As três abordagens de modelagem são logicamente equivalentes e sintetizáveis. O sistema está validado para uso.
