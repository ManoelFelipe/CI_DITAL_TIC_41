# RELATÓRIO — Exercício 04  
## ULA_LSL_LSR_mod_2 — Verificação Completa

### 1. Resultado da Simulação  
A simulação realizada no **Questa/ModelSim** utilizando o testbench exaustivo confirmou:

- Total de vetores aplicados: **2048**
- Total de erros encontrados: **0**
- Status final: **TODOS OS TESTES PASSARAM**

Isso valida que:
- Todas as operações — **AND, OR, NOT, NAND, ADD, SUB, LSL, LSR** — funcionam corretamente.
- As flags **C (Carry/Borrow), V (Overflow), Z (Zero), N (Negativo)** estão corretas em todos os cenários.
- A saturação do deslocamento funciona conforme especificado (máx. 4 posições).
- Não há discrepâncias entre DUT e modelo de referência.

---

### 2. Análise das Formas de Onda  
As formas de onda observadas no ModelSim confirmam:

- Transições corretas de `resultado_out` conforme `op_sel` progride de 000 a 111.
- Flags mudando coerentemente com os resultados:
  - **C** ativo apenas em ADD sem overflow ou SUB sem borrow.
  - **V** ativo somente nas condições clássicas de overflow em complemento de dois.
  - **Z** ligado quando o resultado é 0000.
  - **N** refletindo o MSB do resultado.
- Todos os ciclos apresentam comportamento completamente combinacional, com propagação estável (`#1` de delay no TB).

---

### 3. Conclusões  
O projeto **ULA_LSL_LSR_mod_2** está:

- **Correto** e totalmente funcional.
- **Determinístico e estável** na simulação.
- **Consistente** com as especificações do Exercício 04.
- Com implementação de flags idêntica ao comportamento esperado em arquiteturas reais.

O testbench exaustivo garantiu validação absoluta (**2048 combinações testadas**), confirmando a robustez da implementação.

