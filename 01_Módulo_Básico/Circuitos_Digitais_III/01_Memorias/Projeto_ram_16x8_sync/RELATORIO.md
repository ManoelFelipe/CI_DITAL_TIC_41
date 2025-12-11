# Relatório de Simulação: RAM 16x8 Síncrona

**Autor**: Manoel Furtado
**Data**: 10/12/2025
**Projeto**: RAM 16x8 Sync (Behavioral, Dataflow, Structural)

---

## 1. Introdução
Este relatório documenta a validação funcional da memória RAM 16x8 síncrona. O objetivo foi verificar se as três implementações (Behavioral, Dataflow e Structural) comportam-se de maneiro idêntica e correta, respeitando os requisitos de escrita síncrona e latência de leitura de um ciclo de clock.

A validação foi realizada utilizando o simulador Questa (ModelSim) e um testbench automatizado que compara as saídas dos três módulos em tempo real.

---

## 2. Metodologia de Simulação

O arquivo de teste `tb_ram_16x8_sync.v` foi projetado para exercitar todos os endereços de memória (0 a 15) em duas fases distintas, garantindo cobertura total de funcionalidade.

### 2.1 Estratégia de Estímulos e Setup Time
Para garantir a estabilidade dos sinais e simular um ambiente digital realista, todos os estímulos de entrada (endereço, dado de entrada e habilitação de escrita `we`) foram aplicados na **borda de descida** (`negedge`) do clock.
Isso garante que, na borda de subida (`posedge`) — momento em que a memória efetivamente captura os dados ou atualiza a saída —, os sinais já estejam estáveis há meio ciclo de clock. Essa técnica elimina condições de corrida (race conditions) no simulador e verifica o cumprimento dos tempos de setup e hold.

### 2.2 Verificação Automática (Golden Model Check)
O testbench não apenas gera formas de onda, mas atua como um verificador inteligente:
1.  Calcula internamente o valor esperado (`golden_mem`) para cada endereço.
2.  Compara, ciclo a ciclo, as saídas dos modelos **Behavioral**, **Dataflow** e **Structural**.
3.  Verifica se todas as três saídas são iguais entre si **E** iguais ao valor esperado.
4.  Exibe o status `OK` ou `ERRO` no console para cada transição.

---

## 3. Análise dos Resultados

### 3.1 Análise do Console (Transcript)
A execução do script de simulação gerou o log apresentado nas evidências. A tabela formatada exibe as transações de leitura.

O log abaixo apresenta o resultado completo da fase de leitura, confirmando a consistência em todos os 16 endereços testados (0 a 15):

```text
tempo   | addr | we | data_in || dout_beh | dout_exp || STATUS
196000  | 00   | 0  | af      || a0       | a0       || OK
206000  | 01   | 0  | af      || a1       | a1       || OK
216000  | 02   | 0  | af      || a2       | a2       || OK
226000  | 03   | 0  | af      || a3       | a3       || OK
236000  | 04   | 0  | af      || a4       | a4       || OK
246000  | 05   | 0  | af      || a5       | a5       || OK
256000  | 06   | 0  | af      || a6       | a6       || OK
266000  | 07   | 0  | af      || a7       | a7       || OK
276000  | 08   | 0  | af      || a8       | a8       || OK
286000  | 09   | 0  | af      || a9       | a9       || OK
296000  | 0a   | 0  | af      || aa       | aa       || OK
306000  | 0b   | 0  | af      || ab       | ab       || OK
316000  | 0c   | 0  | af      || ac       | ac       || OK
326000  | 0d   | 0  | af      || ad       | ad       || OK
336000  | 0e   | 0  | af      || ae       | ae       || OK
346000  | 0f   | 0  | af      || af       | af       || OK
```

*Interpretação:*
*   **Colunas**: Tempo de simulação, Endereço lido, Sinal de escrita (0=Leitura), Dado na entrada (irrelevante na leitura).
*   **Verificação**: `dout_beh` (Saída do modelo Comportamental) comparada com `dout_exp` (Modelo Dourado).
*   **STATUS OK**: Indica que Behavioral, Dataflow e Structural convergiram para o mesmo valor esperado.

A mensagem final confirma a robustez do projeto:
> **"SUCESSO: Todas as implementacoes estao consistentes em 16 testes."**

Isso valida que a implementação Estrutural (composta por portas lógicas, Mux e Flip-Flops discretos) possui comportamento idêntico à abstração comportamental de alto nível.

### 3.2 Análise das Formas de Onda (Waveform)
A análise visual das ondas (VCD) confirma o comportamento síncrono.

#### Fase de Escrita (Write)
Observa-se o sinal `we` em nível alto. A cada borda de subida do clock, o dado presente em `data_in` é escrito no endereço `address`.
*   Não há alteração na saída `data_out` imediata, pois a operação é de escrita.

#### Fase de Leitura (Read)
Observa-se `we` em nível baixo.
1.  O endereço (`address`) altera-se na borda de descida.
2.  Na borda de subida subsequente, a memória interna é amostrada.
3.  A saída `data_out` atualiza-se para o novo valor com um atraso de clock (Clock-to-Q), confirmando a característica de **Synchronous Read**.
4.  Todas as três linhas de saída (`data_out_beh`, `data_out_df`, `data_out_str`) transicionam exatamente juntas, sem glitches observáveis nos pontos de amostragem.

---

## 4. Conclusão
A simulação demonstrou que o projeto da RAM 16x8 Síncrona atende a todas as especificações.
*   **Funcionalidade**: Escrita e leitura corretas em todos os 16 endereços.
*   **Timing**: Latência de leitura de 1 ciclo respeitada.
*   **Equivalência**: As três modelagens são funcionalmente indistinguíveis nas portas de I/O.

O código está validado e pronto para síntese ou integração em sistemas maiores.
