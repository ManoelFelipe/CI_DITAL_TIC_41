# Relatório de Validação: Flip-Flop JK

**Autor:** Manoel Furtado  
**Data:** 24/11/2025  
**Status:** ✅ Aprovado

---


## 1. Introdução
Este relatório documenta os resultados da simulação funcional do projeto **Flip-Flop JK**, desenvolvido em Verilog. O objetivo foi validar o comportamento do componente sob diferentes condições de estímulo (Set, Reset, Toggle e Hold), garantindo conformidade com o diagrama de tempos especificado e a lógica teórica esperada.

### 1.1 Tabela Verdade Teórica
Para referência, a tabela abaixo descreve o comportamento esperado do Flip-Flop JK na borda de subida do clock (`↑`):

| Clock | J | K | Q(t+1) | Estado | Descrição |
| :---: | :-: | :-: | :---: | :---: | :--- |
| ↑ | 0 | 0 | Q(t) | **Hold** | Mantém o estado anterior |
| ↑ | 0 | 1 | 0 | **Reset** | Força a saída para 0 |
| ↑ | 1 | 0 | 1 | **Set** | Força a saída para 1 |
| ↑ | 1 | 1 | ~Q(t) | **Toggle** | Inverte o estado atual |

## 2. Resultados da Simulação

### 2.1 Análise do Transcript (Log de Execução)
A simulação foi executada utilizando o simulador Questa/ModelSim. O *testbench* `tb_ff_jk` realizou uma série de verificações automáticas em pontos estratégicos do tempo, logo após as bordas de subida do clock.

Conforme evidenciado pelos logs de saída:
- **t=31ns:** O comando **Set** (J=1, K=0) foi executado com sucesso, levando Q para nível alto.
- **t=51ns:** O comando **Reset** (J=0, K=1) forçou a saída Q para nível baixo, como esperado.
- **t=71ns:** O comando **Toggle** (J=1, K=1) inverteu o estado anterior (0 → 1).
- **t=91ns:** A condição de **Set/Hold** (J=1, K=0) manteve a saída em nível alto.
- **t=111ns:** Novo **Reset** confirmado.
- **t=131ns e t=151ns:** Testes consecutivos de **Toggle** demonstraram a capacidade do circuito de alternar estados corretamente a cada ciclo de clock.

**Resultado:** 0 Erros, 0 Avisos críticos. Todas as asserções de teste retornaram "OK".

### 2.2 Análise das Formas de Onda (Waveform)
A inspeção visual das ondas geradas (`wave.vcd`) corrobora os dados do transcript:
- O sinal **clk** apresenta o período correto de 20ns.
- As saídas **q** e **q_bar** são complementares em todo o tempo de simulação.
- As transições de saída ocorrem estritamente sincronizadas com a **borda de subida** do clock.
- Não foram observados *glitches* ou estados indeterminados (X) após a inicialização.

## 3. Conclusão
O projeto do Flip-Flop JK foi implementado e verificado com êxito. A simulação comprova que a lógica descrita (seja na abordagem Behavioral, Dataflow ou Structural) atende integralmente aos requisitos funcionais. O comportamento observado é fiel ao diagrama de tempos de referência, validando o componente para uso em sistemas digitais sequenciais mais complexos.
