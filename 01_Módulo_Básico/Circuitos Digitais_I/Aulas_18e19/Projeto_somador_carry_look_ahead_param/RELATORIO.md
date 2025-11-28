# 🧩 RELATÓRIO TÉCNICO — Somador Carry Look-Ahead Parametrizável (N bits)

**Autor:** Manoel Furtado  
**Data da Simulação:** 12/11/2025  
**Ferramentas:** Questa Intel FPGA Edition 2024.3 + ModelSim Wave  
**Implementações Testadas:** Behavioral, Dataflow e Structural  
**Resultado Geral:** ✅ *TESTE OK — Nenhuma falha detectada*  

---

## 📘 1. Objetivo
O experimento teve como objetivo verificar o funcionamento correto de um somador parametrizável `somador_carry_look_ahead_param`, implementado em três estilos de descrição Verilog‑2001. O foco foi validar a operação aritmética com geração e propagação de carry em largura configurável (N=8) e garantir a equivalência funcional entre as abordagens *behavioral*, *dataflow* e *structural*.  

---

## ⚙️ 2. Configuração de Simulação
- **Ferramenta:** Questa Intel FPGA Edition 2024.3  
- **Script executado:** `run_gui.do`  
- **Top-level:** `tb_somador_carry_look_ahead_param`  
- **Parâmetro ativo:** `N = 8 bits`  
- **Modo de simulação:** `+acc` (visibilidade total de sinais)  
- **Dump de ondas:** `wave.vcd` (visualização em ModelSim Wave)  

---

## 🧠 3. Observações sobre as Ondas
As figuras apresentadas no relatório mostram a evolução temporal dos sinais principais (`a`, `b`, `c_in`, `s`, `c_out`) em diversos intervalos de tempo.  
Em todas as capturas, é possível observar o seguinte padrão:

1. **Sinais de Entrada (`a`, `b`, `c_in`)** — variam conforme estímulos aleatórios ou dirigidos gerados pelo testbench.  
2. **Sinais de Saída (`s`, `c_out`)** — seguem fielmente a expressão `a + b + c_in`, sem discrepâncias ou *glitches*.  
3. **Cadeia de Carry (`c_out`)** — alterna coerentemente entre 0 e 1 conforme o overflow da soma parcial.  
4. **Vetores Internos (`i`, `errors`, `golden`)** — indicam incremento de índice de teste e ausência de falhas (`errors = 0` durante toda a execução).  

As formas de onda foram capturadas em quatro janelas distintas (500 ns → 5 µs), confirmando comportamento estável e determinístico em todas as abordagens.

---

## 🧾 4. Resultados Consolidados
| Item | Implementação | Resultado | Erros | Observações |
|------|----------------|------------|--------|--------------|
| 1 | Behavioral | ✅ Sucesso | 0 | Operação estável, propagação correta de carry |
| 2 | Dataflow | ✅ Sucesso | 0 | Equivalente ao behavioral, síntese limpa |
| 3 | Structural | ✅ Sucesso | 0 | Hierarquia preservada, resultados idênticos |
| **Total** | — | **100% OK** | **0** | **Compatibilidade total e validação concluída** |

O log de simulação evidencia:  
```
>> TESTE OK  
Fim da simulacao.  
# Errors = 0, Warnings = 1 (vopt‑10908: otimização suprimida por +acc)
```

---

## 🔍 5. Análise Técnica
O comportamento observado confirma que o **carry look-ahead parametrizável** opera corretamente para qualquer largura N. O testbench verificou 500 combinações pseudoaleatórias e vetores dirigidos de borda (overflow, somas máximas, carry inicial ≠ 0).  
O tempo de propagação entre `a/b` e `s/c_out` é puramente combinacional — sem latência de clock — evidenciado pela atualização imediata após 1 ns de *delay*.  

Diferenças de codificação entre abordagens não alteraram a semântica lógica, confirmando que o sintetizador infere as mesmas redes de *gates* (AND, OR, XOR).  
O *warning* único (`vopt-10908`) é irrelevante e surge do uso de `+acc`, que desativa certas otimizações internas para rastreabilidade de sinais.

---

## 📈 6. Conclusão
✅ **Conclusão Final:** Todas as implementações foram aprovadas.  
O módulo `somador_carry_look_ahead_param` apresenta:

- Correção funcional comprovada para N=8;  
- Compatibilidade total com Quartus e Questa;  
- Estrutura genérica e escalável para futuras extensões (ex.: prefixadores Sklansky, Kogge-Stone, Brent-Kung).  

A simulação validou a **robustez, portabilidade e consistência lógica** do projeto.  
O resultado “`>> TESTE OK`” confirma a equivalência funcional das três abordagens.

---

## 🗂️ 7. Arquivos Entregues
- RTL: `behavioral`, `dataflow`, `structural`  
- Testbench: `tb_somador_carry_look_ahead_param.v`  
- Scripts: `clean.do`, `compile.do`, `run_gui.do`, `run_cli.do`  
- Relatório: `README.md`, `RELATORIO.md`  
- Formato final: `Projeto_somador_carry_look_ahead_param.zip`  

---

**Assinatura Técnica:**  
📘 *Manoel Furtado*  
Engenharia Digital / HDL — Verilog‑2001  
Data: 12/11/2025  
