# Relatório de Simulação: FIFO 8x16 com Barrel Shift

**Autor:** Manoel Furtado  
**Data:** 12/12/2025  

## 1. Objetivos da Simulação

O objetivo desta etapa foi validar o funcionamento das três implementações da FIFO (Behavioral, Dataflow e Structural) utilizando a técnica de *barrel shift* (escrita na cauda, leitura na cabeça com deslocamento). A validação foi realizada através de um testbench determinístico (`tb_fifo_8x16_buffer_barrel_shift.v`) que compara automaticamente as saídas de todos os módulos entre si e contra um modelo de referência (buffer circular), garantindo integridade lógica e funcional.

## 2. Metodologia de Teste

O ambiente de simulação foi configurado no Questa/ModelSim. O testbench aplica vetores de teste cobrindo 100% dos estados críticos da FIFO:
- **Estados Vazios e Cheios:** Validação das flags `empty` e `full`.
- **Overflow/Underflow:** Tentativas de escrita quando cheia e leitura quando vazia.
- **Operação de Deslocamento:** Verificação visual e lógica do comportamento de *shift* dos dados na leitura.
- **Concorrência:** Operações simultâneas de escrita e leitura (`wr_en` e `rd_en` ativos) para confirmar a manutenção da ocupação.

Em todos os ciclos de clock, o testbench verifica se:
1. `dout`, `full`, `empty` e `wp_count` são idênticos nas três implementações (Behavioral, Dataflow, Structural).
2. O comportamento funcional (Behavioral) corresponde ao modelo de referência.

## 3. Análise dos Resultados

A simulação foi concluída com **SUCESSO**, totalizando 38 vetores de teste sem erros. Abaixo estão detalhadas as tabelas geradas pelo testbench, ilustrando o comportamento esperado do circuito.

### Tabela 1: Preenchimento e Condição de Full
Neste teste, escrevemos sequencialmente 8 valores (padrão `00A1` a `0B18`). Observa-se que o contador `wp_count` incrementa de 0 a 8. Ao atingir 8, a flag `full` vai para nível lógico alto. A tentativa subsequente de escrever `0xDEAD` é ignorada, mantendo o estado da memória inalterado (proteção contra overflow).

```text
--------------------------------------------------------------------------------------------
 tempo(ns) | wr rd | din(hex) | dout(hex) | wp_count | full empty | Observacao
--------------------------------------------------------------------------------------------
       46 |  1  0 | 0x00a1  | 0x00a1   |   1     |  0    0   | escrevendo...
       56 |  1  0 | 0x00b2  | 0x00a1   |   2     |  0    0   | escrevendo...
       66 |  1  0 | 0x00c3  | 0x00a1   |   3     |  0    0   | escrevendo...
       76 |  1  0 | 0x00d4  | 0x00a1   |   4     |  0    0   | escrevendo...
       86 |  1  0 | 0x00e5  | 0x00a1   |   5     |  0    0   | escrevendo...
       96 |  1  0 | 0x00f6  | 0x00a1   |   6     |  0    0   | escrevendo...
      106 |  1  0 | 0x0a07  | 0x00a1   |   7     |  0    0   | escrevendo...
      116 |  1  0 | 0x0b18  | 0x00a1   |   8     |  1    0   | apos escrita -> FULL=1
      126 |  1  0 | 0xdead  | 0x00a1   |   8     |  1    0   | escrita apos cheia -> ignorada
```

### Tabela 2: Leitura e Condição de Empty
Inicia-se a drenagem da FIFO. A cada leitura (`rd=1`), o dado na cabeça (`dout`) é validado e ocorre o *barrel shift* interno, trazendo o próximo dado para a posição 0. O contador `wp_count` decrementa. Note que `dout` sempre apresenta o próximo dado disponível (`FWFT - First Word Fall Through`). Ao final, `empty` vai para 1 e leituras adicionais são ignoradas.

```text
--------------------------------------------------------------------------------------------
 tempo(ns) | wr rd | din(hex) | dout(hex) | wp_count | full empty | Observacao
--------------------------------------------------------------------------------------------
      136 |  0  1 | 0x0000  | 0x00b2   |   7     |  0    0   | la leitura -> esperado 00A1
      146 |  0  1 | 0x0000  | 0x00c3   |   6     |  0    0   | lendo...
      156 |  0  1 | 0x0000  | 0x00d4   |   5     |  0    0   | lendo...
      166 |  0  1 | 0x0000  | 0x00e5   |   4     |  0    0   | lendo...
      176 |  0  1 | 0x0000  | 0x00f6   |   3     |  0    0   | lendo...
      186 |  0  1 | 0x0000  | 0x0a07   |   2     |  0    0   | lendo...
      196 |  0  1 | 0x0000  | 0x0b18   |   1     |  0    0   | lendo...
      206 |  0  1 | 0x0000  | 0x0000   |   0     |  0    1   | lendo...
      216 |  0  1 | 0x0000  | 0x0000   |   0     |  0    1   | leitura apos vazia -> ignorada
```

### Tabela 3: Validação do Barrel Shift (Deslocamento)
Este cenário demonstra claramente a inserção de zeros. Escrevemos `1111`, `2222`, `3333`. Ao ler, `1111` sai e `2222` assume a cabeça (posição 0). Na próxima leitura, `2222` sai e `3333` assume a cabeça. Quando a FIFO esvazia, o valor `0000` (inserido pelo deslocamento na cauda) chega à saída.

```text
--------------------------------------------------------------------------------------------
 tempo(ns) | wr rd | din(hex) | dout(hex) | wp_count | full empty | Observacao
--------------------------------------------------------------------------------------------
      226 |  1  0 | 0x1111  | 0x1111   |   1     |  0    0   | escreve 1111
      236 |  1  0 | 0x2222  | 0x1111   |   2     |  0    0   | escreve 2222
      246 |  1  0 | 0x3333  | 0x1111   |   3     |  0    0   | escreve 3333
      256 |  0  1 | 0x0000  | 0x2222   |   2     |  0    0   | le -> esperado 1111; cabeca vira 2222
      266 |  0  1 | 0x0000  | 0x3333   |   1     |  0    0   | le -> esperado 2222; cabeca vira 3333
      276 |  0  1 | 0x0000  | 0x0000   |   0     |  0    1   | le -> esperado 3333; FIFO esvazia
```

### Tabela 4: Tráfego Misto (Read + Write)
Testa a robustez do design ao realizar leitura e escrita no mesmo ciclo. O comportamento esperado é que a ocupação (`wp_count`) se mantenha constante, pois um dado sai e outro entra. O dado que entra é escrito na última posição válida (`wp_count-1`), garantindo que não haja "buracos" no buffer.

```text
--------------------------------------------------------------------------------------------
 tempo(ns) | wr rd | din(hex) | dout(hex) | wp_count | full empty | Observacao
--------------------------------------------------------------------------------------------
      286 |  1  0 | 0x4000  | 0x4000   |   1     |  0    0   | pre-carga
      296 |  1  0 | 0x4001  | 0x4000   |   2     |  0    0   | pre-carga
      306 |  1  0 | 0x4002  | 0x4000   |   3     |  0    0   | pre-carga
      316 |  1  0 | 0x4003  | 0x4000   |   4     |  0    0   | pre-carga
      326 |  1  1 | 0x5000  | 0x4001   |   4     |  0    0   | wr+rd (ocupacao deve manter)
      336 |  1  1 | 0x5001  | 0x4002   |   4     |  0    0   | wr+rd (ocupacao deve manter)
      346 |  1  1 | 0x5002  | 0x4003   |   4     |  0    0   | wr+rd (ocupacao deve manter)
      356 |  1  1 | 0x5003  | 0x5000   |   4     |  0    0   | wr+rd (ocupacao deve manter)
      366 |  1  1 | 0x5004  | 0x5001   |   4     |  0    0   | wr+rd (ocupacao deve manter)
      376 |  1  1 | 0x5005  | 0x5002   |   4     |  0    0   | wr+rd (ocupacao deve manter)
      386 |  0  1 | 0x0000  | 0x5003   |   3     |  0    0   | drenando
      396 |  0  1 | 0x0000  | 0x5004   |   2     |  0    0   | drenando
      406 |  0  1 | 0x0000  | 0x5005   |   1     |  0    0   | drenando
      416 |  0  1 | 0x0000  | 0x0000   |   0     |  0    1   | drenando
```

## 4. Conclusão

A mensagem final do testbench confirma a integridade do projeto:
> **SUCESSO: Todas as implementacoes estao consistentes em 38 testes.**

Isso demonstra que:
1. O mecanismo de **barrel shift** (deslocamento físico ou lógico) foi implementado corretamente nas três abordagens.
2. A política de **First-Word-Fall-Through** (dado disponível imediatamente na saída) foi respeitada.
3. Não há divergências entre os modelos comportamentais (Behavioral/Dataflow) e o modelo estrutural (registradores físicos), validando o design para síntese.
