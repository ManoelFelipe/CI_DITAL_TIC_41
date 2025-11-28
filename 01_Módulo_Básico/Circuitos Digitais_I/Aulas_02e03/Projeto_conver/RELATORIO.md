# RELATORIO — Conversor BCD 5311 → BCD 8421

## 1. Validação das Simulações

As formas de onda apresentadas e o log do ModelSim/Questa confirmam que **todas as três implementações** — *behavioral*, *dataflow* e *structural* — produziram saídas idênticas para todos os dez valores válidos do código BCD 5311.  
O testbench comparou automaticamente as saídas de cada implementação com os valores esperados da tabela BCD 8421, não encontrando divergências.

### Evidências observadas:
- O log mostra a execução dos testes de 0 a 9, com todas as comparações coincidentes.  
- A mensagem final confirma:
  **“SUCESSO: Todas as implementacoes estao consistentes com a tabela BCD 5311 → 8421.”**
- O arquivo wave.vcd demonstra coerência temporal, sem glitches e com perfeita correspondência entre as três abordagens.

Portanto, **o resultado foi 100% o esperado**.

---

## 2. Análise do Funcionamento

### Entradas e Saídas
- Entradas: `H, G, F, E` (código BCD 5311)  
- Saídas: `D, C, B, A` (código BCD 8421)

As entradas foram aplicadas sequencialmente no testbench:
```
0000 → 0000  
0001 → 0001  
0011 → 0010  
0100 → 0011  
0101 → 0100  
0111 → 0101  
1001 → 0110  
1011 → 0111  
1100 → 1000  
1101 → 1001
```

Cada implementação converteu corretamente cada código.

---

## 3. Conclusão

A simulação comprova que:
- Não há inconsistência lógica;
- Todas as abordagens funcionam de forma equivalente;
- O testbench cumpre corretamente seu papel de verificação automatizada.

O conversor está **totalmente validado**.

