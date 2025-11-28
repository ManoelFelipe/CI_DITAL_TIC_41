# 🧮 Relatório Final — Carry Look-Ahead Adder (4 bits)

## 📘 1. Objetivo
Validar o funcionamento do **Carry Look-Ahead Adder (CLA) de 4 bits** em três abordagens distintas — *Behavioral*, *Dataflow* e *Structural* — verificando consistência lógica e equivalência funcional entre as implementações.

---

## ⚙️ 2. Configuração de Simulação
- **Ferramenta:** ModelSim / QuestaSim (Verilog 2001)
- **Arquivos Testados:**
  - `behave_4bit_carry_lookahead_adder.v`
  - `struct_4bit_carry_look_ahead_adder.v`
  - `carry_look_ahead_adder_4b.v`
  - `tb_carry_look_ahead_adder_4b.v`
- **Tempo de Simulação:** 5120 ns
- **Total de Combinações Testadas:** 512 (todas as combinações de `A[3:0]`, `B[3:0]` e `Cin`)

---

## 🧩 3. Estrutura do Testbench
O *testbench* realiza a comparação entre as três implementações (BEH, STR e DF) e uma referência aritmética (`REF = A + B + Cin`).  
Cada módulo recebe as mesmas entradas e possui suas próprias saídas isoladas:

```verilog
wire [3:0] sum_beh, sum_str, sum_df;
wire       c_out_beh, c_out_str, c_out_df;
```

O laço de simulação percorre todas as 512 combinações, comparando os resultados:
```verilog
if ((sum_beh !== sum_str) || (sum_beh !== sum_df) || (sum_beh !== ref[3:0])) errors++;
```

---

## 📊 4. Resultados da Simulação

### ✅ Log da Simulação
```
SUCESSO: 512 combinações & BEH == STR == DF == REF.
Fim da simulação.
Errors: 0, Warnings: 0
```

### 🧠 Interpretação
- Todas as três arquiteturas produziram **saídas idênticas** para todas as combinações possíveis.
- Nenhum conflito de largura de barramento (`sum[3:0]`) ou múltiplos drivers.
- A sincronização entre as abordagens foi verificada bit a bit.

---

## 🔍 5. Análise das Formas de Onda
As formas de onda mostram claramente:
- `a` e `b` realizando contagem binária (0–15);
- `c_in` alternando entre 0 e 1;
- `sum_beh`, `sum_str`, `sum_df` perfeitamente sobrepostas;
- `c_out_beh`, `c_out_str`, `c_out_df` coincidindo com o *carry* de saída esperado.

### Principais sinais monitorados
| Sinal | Descrição |
|:------|:-----------|
| `a[3:0]` | Operando A |
| `b[3:0]` | Operando B |
| `c_in` | Carry de entrada |
| `sum_beh`, `sum_str`, `sum_df` | Soma calculada nas três arquiteturas |
| `c_out_beh`, `c_out_str`, `c_out_df` | Carry de saída nas três abordagens |
| `ref` | Resultado aritmético de referência |

---

## 🧱 6. Conclusão
O projeto **Carry Look-Ahead Adder de 4 bits** foi **validado com sucesso**.  
As implementações *Behavioral*, *Dataflow* e *Structural* apresentam **equivalência funcional total**.

**Status Final:** ✅ *Aprovado*

---

**Autor:** Yasmin Priscilla da Silva Martins  
**Data:** 12/11/2025  
**Ferramentas:** Quartus Prime / ModelSim  
**Verilog Standard:** IEEE 1364-2001
