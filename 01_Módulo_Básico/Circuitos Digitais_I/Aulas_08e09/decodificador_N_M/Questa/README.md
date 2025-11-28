
# Decodificador Parametrizável N→M (M = 2^N)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Linguagem:** Verilog-2001 | Compatível com Quartus e Questa

> Projeto genérico com três estilos (Behavioral, Dataflow, Structural).  
> Simulado com **N=4** (M=16). Há parâmetro `ACTIVE_LOW` para quem quiser estudar a variante ativo-baixo.

---

## Como rodar (Questa)

```
cd Questa/scripts
do clean.do
do run_cli.do     ;# console: vsim -voptargs=+acc work.tb_decodificador_N_M
# ou
do run_gui.do     ;# GUI: limpa, compila e roda, adiciona ondas
```

Um `wave.vcd` é gerado automaticamente.

---

## Relatório

### 1) Código comportamental
O módulo `decodificador_N_M_behavioral` recebe `N` e deriva `M=2^N`. Em `always @(*)`, zera-se o vetor de saída e seta-se apenas o bit indexado por `a` (`y[a]=1'b1`). Essa forma é direta, legível e escalável. O parâmetro `ACTIVE_LOW` permite inverter todas as linhas ao final para estudar convenções ativo-baixo.

### 1.1) Código estrutural
A versão **estrutural** é hierárquica e paramétrica. Para `N=1`, usa-se o bloco base `dec1to2_struct`. Para `N>1`, instancia-se recursivamente um decodificador de `N-1` bits para os bits menos significativos, gerando `M/2` linhas one-hot. O bit mais significativo seleciona em qual metade o vetor será ativado, formando o barramento de `M` linhas por concatenação. Isso espelha a construção de decodificadores reais a partir de blocos menores (1→2, 2→4, 3→8...).

### 2) Testbench e formas de onda
O `tb_decodificador_N_M` (arquivo `tb_decodificador_4_16.v`) fixa `N=4` e varre todas as entradas com `#5` ns. Imprime os três vetores (`behavioral`, `dataflow` e `structural`) e verifica equivalência. As ondas mostram um *one-hot* avançando da posição 0 à 15, confirmando o correto mapeamento. O `-voptargs=+acc` garante visibilidade dos sinais internos na GUI.

### 3) Aplicações práticas (e exemplos extras)
- Seleção de **bancos de memória**/registradores (chip-select).  
- **Demux** de pulsos de habilitação para múltiplos módulos.  
- **Decodificação de endereço** em GPIOs e periféricos mapeados.  
- **FSM one-hot**: ativa exatamente um bloco por estado.  
- **Controle de displays** (seleção de dígitos em multiplex).  
- **Roteamento de interrupções** com prioridade simples.  
- Versões com `ACTIVE_LOW` aplicam-se a sinais `/CS`, `/OE`, `/WE` muito comuns em hardware.

---
