# 🧮 Relatório Técnico — Carry Look-Ahead Adder 4 Bits

## 📘 1. Introdução

Este relatório descreve o desenvolvimento, simulação e análise do somador de 4 bits do tipo *Carry Look-Ahead Adder (CLA)*, implementado em três abordagens: **Behavioral**, **Dataflow** e **Structural**. O objetivo é avaliar o desempenho funcional e validar o comportamento esperado nas simulações realizadas no **Questa Intel FPGA Edition 2024.3**.  
O CLA é uma arquitetura otimizada para reduzir a latência de propagação de carry, sendo fundamental em projetos de **unidades aritméticas e lógicas (ALUs)**.

---

## ⚙️ 2. Resultados de Simulação

### ✅ Execução e Compilação

- As três versões foram compiladas com sucesso no ambiente Questa, conforme os logs mostrados.
- A simulação foi executada automaticamente via `run_gui.do`, sem erros ou *warnings* críticos.
- O relatório do console indica:

```
SUCESSO: 512 casos validados sem erros.
Fim da simulação.
```

### 📊 Forma de Onda

A forma de onda obtida mostra claramente a correta propagação dos sinais de **A**, **B**, **C_in**, **S**, e **C_out**.  
Durante cada ciclo, os valores de soma e carry correspondem ao esperado para um CLA funcional.  
As transições observadas demonstram que o circuito responde instantaneamente aos estímulos, comprovando o correto cálculo paralelo dos *carries intermediários*.  

O comportamento é consistente entre as implementações **estrutural** e **comportamental**, reforçando a equivalência lógica entre elas.

---

## 🧩 3. Análise das Abordagens

### **a) Behavioral**
A versão comportamental utiliza um bloco `always @(*)`, o que permite descrever a lógica aritmética em alto nível. É ideal para simulações rápidas e para verificar a corretude funcional sem se preocupar com os detalhes da síntese. O cálculo do *carry look-ahead* foi descrito por expressões booleanas diretas, reduzindo atrasos lógicos e mantendo clareza no código.  
**Vantagens:** legibilidade e portabilidade.  
**Desvantagens:** controle limitado sobre otimização estrutural.

### **b) Dataflow**
A versão de *dataflow* explora operadores contínuos (`assign`), tornando explícitas as dependências entre sinais. Essa abordagem representa um meio-termo entre abstração e controle, permitindo compreender o caminho dos sinais com maior precisão.  
**Vantagens:** menor latência e clareza das dependências.  
**Desvantagens:** manutenção mais trabalhosa e maior sensibilidade a erros de largura de barramento.

### **c) Structural**
A implementação estrutural faz uso de portas lógicas elementares (`and`, `or`, `xor`), refletindo fielmente a topologia do hardware físico. É a versão mais próxima de uma síntese real em FPGA ou ASIC, permitindo estimar consumo de área e temporização.  
**Vantagens:** fidelidade à arquitetura física.  
**Desvantagens:** código extenso e de leitura menos intuitiva.

---

## 🧪 4. Testbench — `tb_carry_look_ahead_adder_4b.v`

O *testbench* foi projetado para aplicar vetores de teste automáticos com geração sequencial de valores de **A**, **B** e **C_in**, cobrindo 512 combinações distintas.  
Cada operação foi validada em tempo real via `$monitor` e armazenada em arquivo VCD (`wave.vcd`) para análise visual.  
A checagem automática usa comparações lógicas entre a saída do DUT e a referência (`ref`), acumulando erros em um contador. O resultado final confirmou **0 erros**, garantindo plena conformidade funcional.

---

## 🚀 5. Conclusão

O resultado da simulação foi **exatamente o esperado**.  
O módulo **carry_look_ahead_adder_4b** apresentou comportamento consistente entre as versões **estrutural** e **comportamental**, com **propagação paralela de carry** corretamente implementada.  
A execução no Questa foi bem-sucedida e sem falhas, confirmando a correta integração dos scripts `.do` e a validade dos vetores de teste.  

O projeto está **apto para síntese FPGA**, podendo ser expandido para 8, 16 ou 32 bits com uso de CLA hierárquico ou *group carry look-ahead*.  
Esse resultado demonstra domínio dos conceitos de **soma paralela**, **otimização temporal** e **verificação HDL**.

---

**Autor:** Manoel Furtado  
**Data:** 12/11/2025  
**Ferramentas:** Questa Intel FPGA 2024.3, Verilog‑2001  
**Status:** ✅ Simulação validada com sucesso.
