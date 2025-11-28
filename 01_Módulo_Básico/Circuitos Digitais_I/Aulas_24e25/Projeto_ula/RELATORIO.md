# RELATÓRIO — Validação da ULA com 8 Operações

## 1. Resultado da Simulação

A simulação no **QuestaSim** confirmou que **todas as três abordagens** da ULA — *Behavioral*, *Dataflow* e *Structural* — produziram **resultados idênticos** para **todas as combinações possíveis** de:

- `op_a` de 0 a 15  
- `op_b` de 0 a 15  
- `seletor` de 0 a 7  

Ao final, o testbench exibiu:

```
SUCESSO: Todas as implementacoes estao consistentes para todas as combinacoes.
```

Não houve divergências entre:

- `resultado_behavioral`
- `resultado_dataflow`
- `resultado_structural`
- `resultado_esperado`

---

## 2. Warnings sobre Divisão

Durante a simulação, o ModelSim gerou múltiplos warnings:

```
# ** Warning: (vsim-8630) Infinity results from division operation.
```

Isso ocorre na abordagem *Dataflow* porque o simulador avalia ambos os lados das expressões da divisão **antes** da escolha pelo operador `?:`, detectando a divisão por zero.  
Não é erro funcional, não causa divergências, e não afeta síntese.

---

## 3. Formas de Onda

As ondas mostram:

- `op_a` e `op_b` percorrendo todo o espaço 0–15.
- `seletor` repetindo 0–7.
- As três implementações sempre idênticas.
- `erro_count = 0`.
- `resultado_esperado` alinhado com todos os DUTs.

As imagens confirmam graficamente a consistência da ULA.

---

## 4. Conclusão

✔ Todas as operações funcionaram corretamente  
✔ Multiplicação e divisão validadas  
✔ A largura de 8 bits foi suficiente para todas as operações  
✔ Testbench validou 100% do espaço de entradas  
✔ Projeto coerente e pronto para síntese  

---

## 5. Sugestão futura

Caso deseje eliminar os warnings da divisão no *Dataflow*, é possível converter o bloco de divisão para um `always @*` com `if (op_b==0)`, como no Behavioral.

---

**Fim do relatório.**
