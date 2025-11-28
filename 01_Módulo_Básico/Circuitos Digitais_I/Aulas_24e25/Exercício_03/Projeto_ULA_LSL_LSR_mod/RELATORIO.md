# RELATORIO – ULA_LSL_LSR_mod

## 1. Funcionamento Observado na Simulação

A simulação realizada no **QuestaSim** demonstrou que todas as combinações de entradas foram exercitadas de forma exaustiva, incluindo:

- Todos os valores possíveis de **A** (0–15);
- Todos os valores possíveis de **B** (0–15);
- Todos os valores possíveis de **op_sel**;
- Testes completos para:
  - LSL (deslocamento lógico à esquerda)
  - LSR (deslocamento lógico à direita)
  - Operações adicionais herdadas da ULA base, quando aplicável.

O resultado exibido no transcript confirma que:

```
tb_ULA_LSL_LSR_mod: TODOS OS TESTES PASSARAM
```

Isso indica que:
- A lógica de deslocamento baseada no operando **B** está correta.
- O limite de deslocamentos (máx. 4) está sendo respeitado.
- A função `calcula_esperado()` no TB está convertendo corretamente o comportamento de referência.
- Todas as abordagens sintetizadas (behavioral/dataflow/structural) convergem para o mesmo resultado funcional.

---

## 2. Evidências Visuais da Simulação

### Formas de onda (Wave)
As waveforms mostram:
- Transições coerentes entre entradas e saída.
- Deslocamentos sendo aplicados exatamente conforme o valor de **B**.
- Nenhum glitch ou comportamento desconhecido (X/Z).

### Transcript do Questa
Trechos importantes:

```
resultado=0000 esperado=0000
resultado=0100 esperado=0100
resultado=1110 esperado=1110
...
TODOS OS TESTES PASSARAM
```

Todos os vetores exibidos demonstram conformidade total entre a implementação e o modelo de referência.

---

## 3. Conclusão

✔ **O resultado foi o esperado.**  
✔ **A ULA modificada está funcional e consistente.**  
✔ **Todos os testes passaram sem warnings ou erros.**  

A simulação confirma que a implementação do deslocamento baseado em **B** está correta e totalmente estável.

---

## 4. Possíveis Aprimoramentos

- Adicionar checagem automática de *overflow* em deslocamentos (se aplicável ao curso).
- Parametrizar a largura de bits para facilitar expansão futura.
- Gerar automaticamente tabelas de comparação para documentação.
- Integrar o RTL com scripts de síntese para medir área/tempo real.

---

## 5. Finalização

Arquivo gerado automaticamente conforme solicitado.
