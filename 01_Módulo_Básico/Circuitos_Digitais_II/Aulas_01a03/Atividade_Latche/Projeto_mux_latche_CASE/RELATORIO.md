# Relatório de Validação: Mux Latch CASE

**Projeto:** `Projeto_mux_latche_CASE`  
**Status:** ✅ Sucesso Total  
**Data:** 20/11/2025

---

## 1. Resumo do Exercício
O objetivo deste exercício foi implementar um Multiplexador com Latch utilizando a diretiva **CASE** na abordagem comportamental. Diferente do `if-else`, o `case` permite uma listagem mais limpa das condições. A inferência de memória (Latch) foi obtida omitindo-se propositalmente a condição `sel = 11` e a cláusula `default`.

## 2. Correções Realizadas
Durante o desenvolvimento da versão **Structural**, identificou-se um erro de "Copy-Paste" onde o termo `term11` estava sendo atribuído incorretamente na lógica do `sel=01`, gerando conflito de drivers (sinal 'X').
*   **Ação:** Remoção da linha duplicada/incorreta no arquivo `mux_latche_case.v` (Structural).
*   **Resultado:** O conflito foi resolvido e a saída estrutural estabilizou.

## 3. Análise dos Resultados (Simulação)
As capturas de tela fornecidas comprovam o funcionamento correto:

1.  **Log de Simulação:**
    > `SIMULACAO CONCLUIDA COM SUCESSO! Todas as 3 abordagens passaram.`
    Isso confirma que os módulos Behavioral, Dataflow e Structural produziram saídas idênticas ao modelo de referência em todos os ciclos.

2.  **Formas de Onda:**
    *   **Mux (00, 01, 10):** As saídas `out_behav`, `out_data`, `out_struct` seguem perfeitamente as entradas `in0` (aa), `in1` (bb) e `in2` (cc).
    *   **Latch (11):** Ao mudar para `sel=11`, a saída mantém `cc`.
    *   **Estabilidade:** Quando as entradas mudam durante o estado `11` (veja o cursor amarelo na imagem), a saída permanece travada em `cc`, confirmando a robustez do Latch.

## 4. Conclusão
A abordagem **CASE** mostrou-se eficaz e elegante para inferir Latches em Verilog. A implementação estrutural, após a correção do typo, validou a robustez da topologia SOP com Feedback. O projeto atende a todos os requisitos de funcionalidade e codificação.

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
