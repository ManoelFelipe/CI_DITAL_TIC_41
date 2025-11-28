
# README — Projeto ULA_FULL (Versão Completa)

## 1. Introdução

Este documento unifica e revisa integralmente dois relatórios anteriores, complementando o material com uma **Tabela Teórica das Operações da ULA**, explicações detalhadas e uma organização profissional adequada para repositórios GitHub e uso acadêmico.  
A ULA_FULL é uma Unidade Lógica e Aritmética parametrizável, implementada em três abordagens distintas — **Behavioral**, **Dataflow** e **Structural** — e validada por um testbench robusto que realiza verificação cruzada entre as três versões.

---

## 2. Descrição Geral do Projeto

A ULA_FULL opera sobre dois operandos (`op_a`, `op_b`) de largura parametrizável (`WIDTH`, padrão 8 bits), permitindo modos numéricos variados:

- **Inteiro sem sinal (unsigned)**
- **Inteiro com sinal (2’s complement)**
- **Ponto fixo Q** (com `FRAC` bits fracionários)
- **Mini‑float simplificado** (em futuras extensões)

Para cada operação selecionada via `op_sel[3:0]`, a ULA produz:

- `result`
- `flag_overflow`
- `flag_saturate`
- `flag_zero`
- `flag_negative`
- `flag_carry`

A estrutura do projeto contempla:

- Três implementações funcionais idênticas:
  - `ula_full_behavioral`
  - `ula_full_dataflow`
  - `ula_full_structural`
- Um **testbench unificado** (`tb_ula_full.v`) que testa simultaneamente todas as três versões.

A arquitetura focou mais em clareza pedagógica do que em otimização de síntese, especialmente para operações de divisão, que, embora combinacionais, são detalhadas e funcionais para fins acadêmicos.

---

## 3. Análise das Abordagens

### 3.1 Behavioral

- Implementação concentrada em um único bloco `always @*`.
- Estrutura hierárquica via `case` externo (modo numérico) e `case` interno (operação).
- Fácil leitura para estudantes; manutenção moderadamente trabalhosa.
- Lógica explícita, ideal para ensino.

### 3.2 Dataflow

- Núcleo implementado como **função combinacional pura**, retornando resultado + flags empacotados.
- Módulo principal apenas desempacota esse vetor.
- Mais modular e reutilizável.
- Corpo do módulo fica enxuto.

### 3.3 Structural

- Implementada via instância do módulo `ula_full_core`.
- Demostra hierarquia e separação de responsabilidades.
- Ótima para integrar em processadores didáticos e arquiteturas pipelined.

---

## 4. Testbench — Metodologia de Verificação

O `tb_ula_full` realiza **verificação cruzada automatizada** entre as três abordagens.

### Estímulos gerados:

- `num_mode`: {unsigned, signed, Q}
- `op_sel`: 0 a 15 (todas as operações)
- `A` e `B`: 0 a 7 (faixa suficiente para capturar casos essenciais)
- Tratamento especial:
  - Divisão por zero
  - Overflow
  - Saturação

### Critérios de correção:

- Resultados idênticos entre as três implementações.
- Flags idênticas entre as três implementações.
- Uso de `!==` para detectar valores `X` e `Z`.

### Saída do console:

```
SUCESSO: Todas as implementacoes estao consistentes para o conjunto de testes.
Fim da simulacao.
```

Nenhuma inconsistência foi detectada.

---

## 5. Operações da ULA — Tabela Teórica Completa

### 🧮 **Tabela Teórica — Comportamento das Operações**

| OP | CMD  | Operação | Fórmula / Ação | Observações |
|---:|------|----------|----------------|-------------|
| 0 | ADD  | Soma | A + B | Pode gerar overflow. |
| 1 | SUB  | Subtração | A - B | Em 2’s complement. |
| 2 | MUL  | Multiplicação | A × B (8 bits) | Truncada; overflow comum. |
| 3 | DIVU | Divisão Unsigned | A / B | Divisão por 0 → saturação. |
| 4 | DIVS | Divisão Signed | A / B (signed) | Usa complemento de 2. |
| 5 | DIVQ | Divisão Q | (A / B) em Q | FRAC bits fracionários. |
| 6 | AND  | E bit‑a‑bit | A & B | – |
| 7 | OR   | OU bit‑a‑bit | A \| B | – |
| 8 | XOR  | XOR bit‑a‑bit | A ^ B | Diferenças. |
| 9 | NAND | NAND | ~(A & B) | – |
| 10| NOR  | NOR | ~(A \| B) | – |
| 11| XNOR | Igualdade | ~(A ^ B) | – |
| 12| SHL  | Shift Lógico Esq. | A << (B[2:0]) | Multiplica por 2ⁿ. |
| 13| SHR  | Shift Lógico Dir. | A >> (B[2:0]) | Divide sem sinal. |
| 14| SAR  | Shift Aritmético | A >>> (B[2:0]) | Preserva sinal. |
| 15| CMP  | Comparação | A - B | Atualiza flags. |

---

## 6. Resultados Obtidos

### Principais observações:

- As três implementações permaneceram **100% consistentes**.
- A lógica de divisão (DIVU, DIVS, DIVQ) funcionou conforme projetado.
- Detecção correta de:
  - overflow
  - saturação
  - divisão por zero
  - zero flag
  - sinal
- A waveform confirma a equivalência funcional completa.

---

## 7. Aplicações e Extensões Possíveis

- Uso como ALU em processadores didáticos.
- Estudos de formato numérico (unsigned, signed, Q).
- Prototipagem de sistemas DSP simples.
- Extensões futuras:
  - Pipeline
  - Operações adicionais (MAC, ROTL, ROTR)
  - Mini‑float avançado

---

## 8. Conclusão

O projeto ULA_FULL está **totalmente funcional**, **didático**, **organizado** e **consistente** entre suas três abordagens.  
O testbench é robusto, confiável e adequado para uso acadêmico e profissional.

A versão final deste README consolida todos os relatórios, revisões e a nova Tabela Teórica em um único documento completo e pronto para uso.

---
