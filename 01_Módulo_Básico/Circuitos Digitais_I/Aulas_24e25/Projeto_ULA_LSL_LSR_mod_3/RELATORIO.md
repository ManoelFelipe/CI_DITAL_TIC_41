
# RELATÓRIO — Exercício 05  
## ULA_LSL_LSR_mod_3 — Inclusão das operações NOR e XOR  
**Autor:** Manoel Furtado  
**Data:** 15/11/2025  

---

## 1) Objetivo do Exercício  
O Exercício 05 teve como objetivo estender a ULA já construída no exercício anterior, adicionando duas novas operações lógicas:

- **NOR** (`op_sel = 1000`)
- **XOR** (`op_sel = 1001`)

Como consequência, a palavra de seleção precisou ser expandida de 3 para **4 bits**.  
Além disso, o testbench deveria ser atualizado para contemplar todas as combinações possíveis de entradas e validar as novas operações.

---

## 2) Compilação e Simulação  
A execução no **Questa Intel Starter FPGA Edition** demonstrou:

- Compilação limpa das três abordagens (*behavioral*, *dataflow* e *structural*)
- Compilação limpa do testbench
- **4096 vetores aplicados** (`16 opcodes × 16 valores de A × 16 valores de B`)
- **0 erros** reportados
- Flags e resultados idênticos entre DUT e modelo de referência

Trecho do log:

```
Testbench tb_ULA_LSL_LSR_mod_3 — RESUMO
Vetores aplicados : 4096
Erros encontrados : 0
STATUS: TODOS OS TESTES PASSARAM.
```

Ou seja, **todas as operações incluindo NOR e XOR funcionaram corretamente**, tanto no DUT como no modelo ouro.

---

## 3) Análise das Formas de Onda  
A simulação no GTKWave confirma visualmente:

- Alternância correta de `op_sel` entre 0000 e 1111
- Mudança ordenada dos operandos `a_in` e `b_in`
- Correspondência perfeita entre:
  - `resultado_out`  
  - `ref_resultado`
- Flags `C`, `V`, `Z`, `N` compatíveis com o modelo de referência

Observações relevantes:

- As operações **NOR** e **XOR** aparecem visualmente como padrões distintos e coerentes na forma de onda.
- Nas operações aritméticas, o cálculo de overflow (`flag_v`) responde exatamente como esperado para números em complemento de dois.
- A saturação de deslocamento (`shift_amt <= 4`) funciona corretamente, evitando comportamentos inesperados quando `b_in > 4`.

---

## 4) Conclusão  
✓ **Resultado esperado:** SIM  
✓ **Implementação correta:** Todas as abordagens sintetizaram e simularam corretamente.  
✓ **Testbench robusto:** Varredura exaustiva, comparação bit a bit e VCD completo.  
✓ **ULA ampliada:** NOR e XOR integradas sem quebrar compatibilidade com operações anteriores.  

O Exercício 05 está **totalmente validado**, tanto pela simulação exaustiva quanto pela inspeção de ondas.

---

## 5) Próximos Passos (Opcional)
- Adicionar operações como XNOR, rotação (ROL/ ROR) ou comparações (SLT, SLTU)
- Parametrizar a largura (`parameter N = 4`)
- Inserir registradores para transformar a ULA em um módulo pipeline

---

Fim do relatório.
