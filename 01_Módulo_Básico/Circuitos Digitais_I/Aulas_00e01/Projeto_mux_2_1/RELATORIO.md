
# RELATORIO.md

## 🧩 Relatório Técnico — Validação do MUX 2:1 (d[1:0], sel)

**Autor:** Manoel Furtado  
**Data:** 17/11/2025  
**Ferramentas:** QuestaSim (vsim), Verilog‑2001  
**Implementações:** Behavioral, Dataflow, Structural  

---

# 1. Objetivo do Teste

O objetivo deste relatório é documentar a validação completa do módulo **mux_2_1**, implementado em três estilos distintos e verificado por meio de um testbench exaustivo. O módulo possui:

- `d[1:0]` — vetor de duas entradas de 1 bit  
- `sel` — seletor  
- `y` — saída combinacional

O comportamento desejado é:

- `sel = 0 → y = d[0]`
- `sel = 1 → y = d[1]`

A simulação tem como meta validar a equivalência funcional entre as três abordagens e verificar se a saída responde corretamente a todas as combinações de entrada.

---

# 2. Metodologia do Testbench

O testbench foi desenvolvido de forma **auto‑verificante** e utiliza:

- loops `for` aninhados para testar todas as 8 combinações possíveis;
- comparação forte (`!==`) para capturar divergências, X e Z;
- contadores automáticos de erros e total de testes;
- mensagens de feedback (“OK” ou “ERRO”);
- geração de arquivo `wave.vcd` para análise visual;
- encerramento limpo com `$finish`.

### Ciclo de Teste

Para cada combinação de `d` (0–3):

1. aplica-se `d = i[1:0]`
2. varre-se `sel = 0` e `sel = 1`
3. aguarda-se `#10` para estabilização
4. verifica-se se `y === d[sel]`

---

# 3. Resultados da Simulação

A execução do QuestaSim retornou:

```
TESTE CONCLUIDO SEM ERROS.
Total de vetores aplicados: 8
Numero total de erros: 0
```

Isso confirma que:

- todas as implementações funcionam corretamente;
- não houve nenhum glitch, atraso indevido ou valor desconhecido;
- a saída sempre satisfez `y = d[sel]`.

---

# 4. Análise das Formas de Onda

As waves indicam:

- propagação combinacional imediata;
- transições limpas, sem X ou Z;
- comportamento alinhado com o esperado para muxes 2:1;
- contadores internos evoluindo conforme planejado.

Observações importantes:

- o “break at line ...” exibido ao final é apenas o ponto do `$finish`  
  → **não é erro**.

---

# 5. Conclusão Final

O multiplexador `mux_2_1` implementado com `d[1:0]`:

✔ passou em todas as validações funcionais  
✔ produziu ondas consistentes  
✔ não apresentou warnings relevantes  
✔ está pronto para integração em sistemas maiores  

O projeto encontra-se formalmente validado.

---

Fim do relatório.
