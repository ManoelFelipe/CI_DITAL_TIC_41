# RELATORIO — Conversor BCD 8421 → Excesso‑3

## 1. Resultados da Simulação

A simulação executada no **QuestaSim** demonstrou que as três abordagens implementadas — *Behavioral*, *Dataflow* e *Structural* — produziram exatamente os mesmos resultados para todas as entradas **BCD válidas (0–9)**, conforme previsto pela tabela oficial do código Excesso‑3.  
As mensagens impressas no transcript confirmam:

- Para todas as entradas de **0 a 9**, o testbench exibiu a linha:
  ```
  OK : BCD=X (...) -> Excesso-3=YYYY (todas as abordagens)
  ```
- Nenhum erro foi identificado pelo mecanismo auto-verificante:
  ```
  SUCESSO: Todas as implementacoes estao consistentes para BCD 0-9.
  ```

As entradas inválidas (10 a 15) foram tratadas corretamente, exibindo apenas mensagens informativas, já que essas combinações não correspondem a valores BCD legítimos.

---

## 2. Verificação em Forma de Onda (Waveform)

A análise do arquivo **wave.vcd** confirma graficamente:

- As três saídas (`excess_behavioral`, `excess_dataflow`, `excess_structural`) mudam **em sincronia**.
- A função `expected_excess_3` também acompanha corretamente todos os valores esperados de 0 a 9.
- Para entradas inválidas (A–F em hexadecimal), as abordagens retornam padrões definidos internamente.

A waveform mostra:

- Ramp-up claro de `bcd_in` de `0000` até `1111`.
- Saídas mudando exatamente conforme a lógica Excesso‑3.
- Nenhuma presença de glitches, X, Z ou hazards.
- Testbench finalizando corretamente com `$finish`.

---

## 3. Conclusão

✔️ **Sim, o resultado foi exatamente o esperado.**  
✔️ **As três abordagens são consistentes e corretas.**  
✔️ **O testbench confirmou automaticamente a integridade lógica.**

O projeto está totalmente validado tanto por simulação textual quanto por inspeção visual das ondas.

