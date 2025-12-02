# Implementação de FSM em Verilog (Modelo Mealy)

Este projeto implementa uma **Máquina de Estados Finitos (FSM)** utilizando a linguagem de descrição de hardware **Verilog**. O design segue a arquitetura **Mealy**, onde as saídas dependem tanto do estado atual quanto das entradas atuais.

## 📋 Visão Geral do Projeto

O objetivo é criar um circuito sequencial que navega por estados predefinidos (A, B, C) com base em um sinal de controle. A principal característica desta implementação é a antecipação da saída, típica de máquinas de Mealy.

### Arquitetura Mealy vs. Moore
O projeto original baseava-se em uma máquina de Moore, onde a saída `bo` era ativada apenas *dentro* do estado B.
Nesta adaptação para **Mealy**:
*   A saída `bo` é ativada **durante a transição** de A para B.
*   Isso permite que o sistema responda um ciclo de clock mais cedo do que na versão Moore equivalente.

## 📊 Diagrama de Estados

Abaixo está o diagrama de estados que ilustra o comportamento da máquina. Note que as saídas são indicadas nas setas de transição (`bi / bo`).

![Diagrama de Estados Mealy](./fsm_mealy_diagram.png)

*O diagrama também está disponível em formato Mermaid no arquivo [fsm_diagram.md](./fsm_diagram.md).*

### Detalhamento das Transições
1.  **Estado Inicial (A - Reset):**
    *   Se `bi=0`: Permanece em A, Saída `bo=0`.
    *   Se `bi=1`: Transita para B, **Saída `bo=1`** (Pulso de detecção).
2.  **Estado Intermediário (B):**
    *   Se `bi=0`: Retorna para A, Saída `bo=0`.
    *   Se `bi=1`: Avança para C, Saída `bo=0`.
3.  **Estado Final (C):**
    *   Se `bi=0`: Retorna para A, Saída `bo=0`.
    *   Se `bi=1`: Permanece em C, Saída `bo=0`.

## ⚙️ Especificações Técnicas

*   **Entradas:**
    *   `clk`: Clock do sistema (sincronização).
    *   `reset`: Sinal de reinicialização (ativo alto), força o estado para A.
    *   `bi`: Bit de entrada de controle que dita as transições.
*   **Saídas:**
    *   `bo`: Bit de saída (Flag de status).

### Tabela de Estados e Saídas

| Estado Atual | Entrada (bi) | Próximo Estado | Saída (bo) | Comentário |
| :---: | :---: | :---: | :---: | :--- |
| **A (00)** | 0 | A (00) | 0 | Aguardando ativação |
| **A (00)** | 1 | B (01) | **1** | **Detecção de início (Mealy)** |
| **B (01)** | 0 | A (00) | 0 | Reset da sequência |
| **B (01)** | 1 | C (10) | 0 | Sequência em progresso |
| **C (10)** | 0 | A (00) | 0 | Reset da sequência |
| **C (10)** | 1 | C (10) | 0 | Fim de curso (Trava) |

## 📂 Estrutura de Arquivos

*   `fsm_mealy.v`: Código fonte Verilog do módulo da FSM.
*   `tb_fsm_mealy.v`: Testbench para simulação e validação.
*   `fsm_diagram.md`: Código fonte do diagrama Mermaid.
*   `README.md`: Documentação do projeto.

## 🚀 Como Simular

Este código é compatível com qualquer simulador Verilog padrão (ModelSim, Vivado, Quartus, Icarus Verilog).

**Exemplo usando Icarus Verilog:**

1. Compile os arquivos:
   ```bash
   iverilog -o fsm_sim fsm_mealy.v tb_fsm_mealy.v
   ```

2. Execute a simulação:
   ```bash
   vvp fsm_sim
   ```

3. Visualize as formas de onda (se tiver GTKWave):
   ```bash
   gtkwave fsm_mealy.vcd
   ```