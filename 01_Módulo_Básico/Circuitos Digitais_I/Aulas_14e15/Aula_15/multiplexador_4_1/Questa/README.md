# Multiplexador 4×1 — Behavioral | Dataflow | Structural

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Ferramentas:** Quartus / Questa (Verilog‑2001)  

## 1) Exercício 1 — MUX 4×1 com sinais escalares
Foi desenvolvido o módulo **`multiplexador_4_1`** em três abordagens. As seleções são escalares `s1` (MSB) e `s0` (LSB), e as entradas são `d0..d3`. O testbench gera formas de onda com padrões distintos para cada entrada e troca de seleções em 00 → 01 → 10 → 11, permitindo observar a comutação da saída conforme a figura do enunciado.

### a) Explicação — Behavioral
A versão comportamental usa um `case` sensível a `s1` e `s0` para **selecionar diretamente** qual entrada `d0..d3` é encaminhada à saída `y`. Essa abordagem é **clara e próxima da especificação de alto nível**, facilitando leitura e manutenção. O bloco é puramente combinacional (`always @*`), evitando inferência de latch.

### b) Explicação — Dataflow
Na abordagem de fluxo de dados, a saída é escrita como **soma de produtos canônicos**:  
`y = (~s1 & ~s0 & d0) | (~s1 & s0 & d1) | (s1 & ~s0 & d2) | (s1 & s0 & d3)`  
Essa forma é ideal para **síntese otimizada**, pois o elaborador reconhece os termos minimizados e mapeia para LUTs/portas de forma direta e eficiente.

### c) Explicação — Structural
A versão estrutural instancia **portas primitivas** (`not`, `and`, `or`) e fios internos para construir a mesma expressão do dataflow. É útil para fins didáticos, pois **explicita** a decomposição em componentes lógicos elementares.

## 2) Testbench único (três exercícios)
O arquivo `tb/tb_multiplexador_4_1.v` cobre:
- **Ex.1**: gera ondas para `d0..d3, s0, s1` com períodos diferentes, permitindo conferir a comutação da saída `y` conforme a seleção 00/01/10/11.
- **Ex.2**: implementa `f(A,B) = \overline{B}` usando o MUX com seleções `{A,B}` e **constantes** nas entradas: `D0=1, D1=0, D2=1, D3=0`. Assim, quando `B=0` a saída vale 1 e quando `B=1` vale 0, **independente de A**. O testbench varre a tabela verdade e imprime com `$display`.
- **Ex.3**: implementa `f(A,B,C) = A·\overline{B}·\overline{C} + \overline{A}·B·\overline{C} = \overline{C}·(A XOR B)` com o MUX usando seleções `{A,B}` e entradas `D0=0, D1=~C, D2=~C, D3=0`. A saída só é 1 quando `C=0` e `A` difere de `B`. A tabela‑verdade é impressa no terminal.

**Formas de onda e logs:** o testbench cria `wave.vcd` para inspeção, imprime linhas resumidas com `$display` e finaliza limpo com `$finish` após 200 ns.

## 3) Scripts (Questa)
- `clean.do`: apaga artefatos com segurança e recria a `work`.
- `compile.do`: define `IMPLEMENTATION` (padrão `behavioral`) e compila a RTL correspondente + testbench.
- `run_gui.do`: limpa, recompila, abre a simulação com `-voptargs=+acc`, adiciona todos os sinais e executa.
- `run_cli.do`: opção em modo console (não força saída do Questa).

Para alternar a implementação simulada, edite a variável `IMPLEMENTATION` dentro de `compile.do` para `dataflow` ou `structural`.

## 4) Aplicações práticas (exemplos)
- **Roteamento de dados** em barramentos SoC (selecionar entre periféricos).
- **Áudio/Vídeo**: escolher qual fonte (HDMI/DP/AV) segue para o pipeline.
- **Sensoriamento**: múltiplos sensores para um único conversor/atuador digital.
- **Comutação de debug**: selecionar entre sinais internos para observação em pinos/ILAs.
- **Controle**: escolha de estratégias (gains/lookup) conforme modo de operação.

## 5) Organização do projeto
```
Quartus/
  rtl/{behavioral,dataflow,structural}/multiplexador_4_1.v
Questa/
  rtl/{behavioral,dataflow,structural}/multiplexador_4_1.v
  tb/tb_multiplexador_4_1.v
  scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
```
> Dica: no Quartus, a versão **dataflow** costuma gerar implementações mais compactas; no Questa, use `run_gui.do` para depurar e visualizar todas as formas de onda.





















# Relatório – Multiplexador 4x1 e Implementações Lógicas

## 1. Exercício 1 – Multiplexador 4x1

### 1.1 Objetivo
Implementar um multiplexador com:
- 4 entradas de dados (`d0, d1, d2, d3`)
- 1 saída (`y`)
- 2 linhas de seleção (`s1, s0`)
- Nome do módulo: `multiplexador_4x1`
- Todo o código em Verilog com uso exclusivo de sinais escalares.

### 1.2 Relação de funcionamento
| s1 | s0 | Saída `y` |
|----|----|-----------|
|  0 |  0 | d0        |
|  0 |  1 | d1        |
|  1 |  0 | d2        |
|  1 |  1 | d3        |

A saída seleciona uma das entradas dependendo do valor binário das linhas de seleção.

### 1.3 Testbench
O testbench segue a forma de onda fornecida, variando `s1s0` de `00 → 01 → 10 → 11` enquanto as entradas mudam em tempos diferentes para validar todas as combinações.

### 1.4 Análise da Simulação
Na simulação (captura de tela enviada):

- As entradas `d0, d1, d2, d3` mudam conforme esperado.
- O sinal `y` segue corretamente a entrada correspondente ao valor da seleção.
- O comportamento está **idêntico ao diagrama do enunciado**.  
✅ **Resultado: Simulação validada com sucesso.**

---

## 2. Exercício 2 – Função Lógica com MUX 4x1

### 2.1 Função proposta
\[
f(A,B) = \overline{A} \cdot \overline{B} + A \cdot \overline{B}
\]

### 2.2 Tabela-Verdade
| A | B | f(A,B) |
|---|---|---------|
| 0 | 0 | 1 |
| 0 | 1 | 0 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

### 2.3 Implementação com MUX 4x1
Usando `B` como linha de seleção:

| Sel (B) | Entradas do MUX | Explicação |
|---------|-----------------|------------|
| 0       | f = 1 quando A=0 ou A=1 → **1** |
| 1       | f = 0 para todos os valores de A → **0** |

Logo:

| d0 | d1 | d2 | d3 |
|----|----|----|----|
| 1  | 0  | 1  | 0  |

✅ A implementação via MUX está correta.

---

## 3. Exercício 3 – Função Lógica com 3 Variáveis

### 3.1 Função proposta
\[
f(A,B,C) = A \cdot \overline{B} \cdot \overline{C} + \overline{A} \cdot B \cdot \overline{C}
\]

### 3.2 Tabela-Verdade
| A | B | C | f(A,B,C) |
|---|---|---|-----------|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 1 |
| 0 | 1 | 1 | 0 |
| 1 | 0 | 0 | 1 |
| 1 | 0 | 1 | 0 |
| 1 | 1 | 0 | 0 |
| 1 | 1 | 1 | 0 |

### 3.3 Uso do MUX 4x1
Escolhendo `A` e `B` como seleção (`s1=A, s0=B`):

| AB | f | Entrada do MUX |
|----|---|----------------|
| 00 | 0 | d0 = 0 |
| 01 | 1 | d1 = \(\overline{C}\) |
| 10 | 1 | d2 = \(\overline{C}\) |
| 11 | 0 | d3 = 0 |

✅ Válido: MUX utilizado com entradas dependentes de `C`.

---

## 4. Conclusão

| Item | Status |
|------|--------|
| Implementação do MUX 4x1 | ✅ Correta |
| Simulação do testbench | ✅ Resultado esperado |
| Exercício 2 (função de 2 variáveis) | ✅ Implementado corretamente via MUX |
| Exercício 3 (função de 3 variáveis) | ✅ MUX configurado corretamente |

✔ O comportamento do multiplexador está correto  
✔ As funções lógicas foram corretamente mapeadas nas entradas do MUX  
✔ As formas de onda confirmam a funcionalidade

---

### Possível extensão prática
✅ Multiplexadores são usados em:
- Seleção de barramentos em CPU
- Roteamento de sinais em FPGA
- Multiplexação de sensores
- Implementação de lógica combinacional sem portas lógicas tradicionais (usando MUX como LUT)


