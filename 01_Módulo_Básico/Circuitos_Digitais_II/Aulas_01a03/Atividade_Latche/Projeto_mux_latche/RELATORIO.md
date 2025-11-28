# Relatório Final: Multiplexador com Latch (Mux-Latch)

**Autor:** Manoel Furtado  
**Data:** 20/11/2025  
**Status:** ✅ Concluído com Sucesso

---

## 1. Objetivo
O objetivo deste projeto foi implementar um **Multiplexador de 4 entradas** que atua como um **Latch (Memória)** quando a seleção é `11`. O desafio principal foi garantir que esse comportamento fosse replicado consistentemente em três níveis de abstração diferentes em Verilog: **Behavioral**, **Dataflow** e **Structural**, e validado por um testbench unificado.

---

## 2. Abordagens de Implementação

### 2.1 Behavioral (Comportamental)
*   **Estratégia:** Utilização de bloco `always @*` com estrutura `if-else-if`.
*   **Inferencia de Latch:** O Latch foi inferido omitindo-se propositalmente a cláusula final `else` (ou a condição `sel == 11`).
*   **Resultado:** O sintetizador entende que, para a condição não coberta, o valor de saída deve ser preservado.

### 2.2 Dataflow (Fluxo de Dados)
*   **Estratégia:** Utilização de atribuição contínua `assign` com operadores ternários aninhados.
*   **Inferencia de Latch:** O feedback foi explícito.
    ```verilog
    assign out = (sel == 00) ? in0 :
                 ...
                 out; // Feedback: saída ligada à entrada
    ```
*   **Resultado:** Cria um loop combinacional que mantém o estado.

### 2.3 Structural (Estrutural) - O Desafio Técnico
Esta foi a etapa mais crítica do projeto. A implementação estrutural exige a construção do circuito usando portas lógicas básicas.

*   **Tentativa Inicial (Mux Loop):** Construiu-se um loop onde a saída voltava para a entrada.
    *   *Problema:* **Race Condition (Corrida de Sinais)**. Na simulação, ao trocar de `sel=10` para `sel=11`, o sinal de habilitação desligava a entrada `in2` nanosegundos antes do caminho de feedback se estabelecer.
    *   *Sintoma:* A saída caía para `0` (glitch) momentaneamente, perdendo o dado armazenado.

*   **Solução Final (SOP com Feedback):**
    Implementou-se a lógica de **Soma de Produtos (Sum of Products)**:
    `Out = (in0 & S00) | (in1 & S01) | (in2 & S10) | (Out & S11)`

    *   *Por que funcionou?* O segredo está no atraso natural das portas. O termo que "desliga" a entrada anterior depende de um inversor (`NOT sel`). O termo que "liga" o feedback (`Out & sel[1] & sel[0]`) depende dos sinais diretos. Essa diferença sutil de tempo garante uma sobreposição segura (make-before-break), impedindo que a saída flutue ou zere durante a transição.

---

## 3. Validação (Testbench)

O testbench `tb_mux_latche.v` foi configurado para instanciar **as três versões simultaneamente**.

### Cenários de Teste:
1.  **Multiplexação (sel 00, 01, 10):** Verificou-se se a saída seguia as entradas `in0`, `in1`, `in2`.
2.  **Latch Hold (sel 11):** Verificou-se se a saída mantinha o valor anterior (`CC`).
3.  **Estabilidade:** Alteraram-se as entradas `in2` e `in3` enquanto em modo Latch. A saída permaneceu estável, provando que o circuito não estava mais "ouvindo" as entradas.

### Resultado Final
Conforme evidenciado pelos logs de simulação e formas de onda:
> **SIMULACAO CONCLUIDA COM SUCESSO! Todas as 3 abordagens passaram.**

As formas de onda mostram claramente o sinal `out_struct` mantendo o nível lógico alto (`CC`) perfeitamente alinhado com as versões `behav` e `data`, sem os glitches observados anteriormente.

---

## 4. Conclusão
O projeto demonstrou com sucesso a criação de elementos de memória (Latches) através de diferentes paradigmas de codificação HDL. A dificuldade encontrada na versão estrutural serviu como uma lição valiosa sobre **hazards** e **corridas** em circuitos digitais assíncronos, e como a topologia do circuito (SOP vs Mux-Loop) influencia a robustez do sinal.

---

## 5. Análise Teórica Aprofundada

Esta seção consolida as respostas teóricas sobre o funcionamento e a inferência de latches observados durante o desenvolvimento dos exercícios.

### 5.1 A ferramenta inferiu Latches?
**Sim.** Isso ocorre porque o código behavioral (tanto no exercício de IF/ELSE quanto no de CASE):
- Usa estruturas condicionais incompletas.
- Não possui cláusula explícita para `sel = 11` nem `else/default`.

Quando um bloco `always @(*)` não atribui valor à saída para todas as combinações possíveis de entrada, a síntese deve manter o valor anterior para garantir a lógica correta, o que fisicamente resulta na criação de **latches transparentes**.

### 5.2 Quantos Latches foram inferidos?
Foram inferidos **WIDTH latches**, ou seja, um elemento de memória para cada bit da saída (ex: 8 latches para um barramento de 8 bits).

### 5.3 Por que Dataflow e Structural também geram memória?
Nas abordagens Dataflow e Structural, a memória não é inferida por "falta de atribuição", mas sim por **realimentação explícita**.
- **Dataflow:** `assign out = ... : out;`
- **Structural:** A saída de uma porta lógica é conectada de volta à entrada de outra porta que a alimenta.

> **Observação Importante:** Ferramentas de análise estática frequentemente reportam isso como **"Combinational Loop"** (Loop Combinacional). Embora funcionalmente atue como memória neste design específico, na prática industrial loops combinacionais são geralmente evitados (exceto em designs assíncronos controlados) devido à dificuldade de análise de tempo (timing analysis) e risco de oscilações.

### 5.4 O Testbench confirma o comportamento?
Sim. O testbench valida o comportamento de memória ao:
1.  Estabelecer um valor na saída.
2.  Mudar o seletor para o modo de retenção (`11`).
3.  Alterar as entradas de dados.
4.  Verificar que a saída **não muda**, confirmando que o valor antigo foi memorizado.
