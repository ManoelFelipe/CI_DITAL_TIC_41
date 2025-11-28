
# RELATORIO — Teste das 3 Implementações do Comparador de 2 Bits

## ✔️ 1. Resultado da Simulação

A simulação executou todas as **16 combinações possíveis** de entradas (00..11 × 00..11) e verificou:

- **Consistência funcional** de cada implementação (behavioral, dataflow e structural) em relação ao valor esperado.
- **Consistência entre as três implementações**.
- Impressão de logs detalhados `OK : ...` para cada combinação.
- Geração de forma de onda contendo todas as saídas simultâneas.

O console exibiu **0 erros**, e todas as linhas foram validadas corretamente.

**Conclusão:**  
👉 **As três abordagens são 100% equivalentes.**  
👉 **Não há divergência funcional ou estrutural.**  
👉 **O comportamento apresentado está exatamente de acordo com o esperado.**

---

## ✔️ 2. Validação na Forma de Onda

A waveform confirma:

- `out_bhv`, `out_df` e `out_st` possuem transições idênticas.
- `expected` coincide com todas as saídas.
- Não há glitch, hazard ou instabilidade.
- As mudanças ocorrem com 5ns de espaçamento, exatamente como definido no testbench.

---

## ✔️ 3. Conclusão Geral

O módulo `comp_2` está **corretamente implementado nas três abordagens**:

- **Behavioral:** Uso de comparação direta `==`.
- **Dataflow:** Comparações XNOR + AND.
- **Structural:** Instanciação explícita de portas lógicas.

E o testbench aprimorado cumpre tudo que foi solicitado:

- Testa as três versões simultaneamente.
- Verifica erros funcionais.
- Verifica inconsistências entre versões.
- Imprime logs iguais ao testbench clássico.
- Gera VCD completo.
- Finaliza automaticamente com sucesso.

---

## 🔚 4. Status Final

✔ **Sim, o resultado foi exatamente o esperado.**  
✔ **Sim, o projeto está totalmente validado.**

Fim do relatório.
