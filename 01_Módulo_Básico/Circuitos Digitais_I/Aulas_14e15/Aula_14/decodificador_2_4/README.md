
# Decodificador 2×4 — `decodificador_2_4` (Behavioral, Dataflow, Structural)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Compatibilidade:** Quartus e Questa (Verilog‑2001) — **todas as portas são escalares**.
**Arquiteturas:** Behavioral | Dataflow | Structural + Testbench

## 1) O que o módulo faz
Implementa um **decodificador 2→4** com saídas one‑hot `Y0..Y3` e expõe duas funções
derivadas a partir das próprias linhas do decodificador (conceito de **mintermos**):

- **f2(A,B)** = `Y0 + Y2` = `~B` (Exercício 2)
- **f3(A,B,C)** = `~C * (Y1 + Y2)` = `~C * (A*~B + ~A*B)` (Exercício 3)

As três versões (Comportamental, Dataflow, Estrutural) são **funcionalmente idênticas**.

## 2) Como escolher cada estilo
- **Comportamental:** mais legível para quem pensa em “seleção de caso” (one‑hot).
- **Dataflow:** descreve diretamente as **equações canônicas** com `assign`.
- **Estrutural:** reflete a rede de **portas** (NOT/AND/OR), útil para estudo e comparação.

## 3) Dicas de simulação
- Use um testbench que varra `AB = 00,01,10,11` (com `C=0`) para validar o **Ex. 1**.
- Para o **Ex. 2**, mostre que `f2` vale 1 quando `B=0`, independentemente de `A`.
- Para o **Ex. 3**, mostre que quando `C=0` a saída realiza `A XOR B`, e com `C=1` ela zera.

## 4) Aplicações práticas
- **Endereçamento/seleção** de registradores e periféricos (chip‑enable).
- **Síntese de funções booleanas** via combinação de mintermos (`OR` das saídas).
- **Controle digital/FSM** com ativações mutuamente exclusivas (one‑hot).


---

## 🔎 Objetivo Geral

Desenvolver e validar um **decodificador 2→4** usando **apenas sinais escalares** e, a partir dele, implementar duas funções lógicas derivadas (`f2` e `f3`) que são montadas combinando as **linhas (mintermos)** do decodificador.  
As simulações foram feitas no **QuestaSim** com geração de `wave.vcd` e impressão de tabelas no console via `$display`.

---

## 🧩 Exercício 1 — Decodificador 2×4

### Especificação
- Entradas: `A` (MSB), `B` (LSB)
- Saídas (one-hot): `Y0..Y3`  
  `Y0`=1 quando `AB=00`, `Y1`=1 quando `AB=01`, `Y2`=1 quando `AB=10`, `Y3`=1 quando `AB=11`.

### Implementação (3 estilos)
- **Comportamental (Behavioral):** `always @*` + `case ({A,B})`, garantindo somente uma saída ativa a cada combinação (one-hot).
- **Fluxo de Dados (Dataflow):** equações canônicas:
- Y0 = ~A & ~B
- Y1 = ~A & B
- Y2 = A & ~B
- Y3 = A & B
- - **Estrutural (Structural):** interligação explícita de `not/and/or` para formar os mintermos e combinações.

### Resultado esperado (e obtido)
| AB | Y0 | Y1 | Y2 | Y3 |
|----|----|----|----|----|
| 00 | 1  | 0  | 0  | 0  |
| 01 | 0  | 1  | 0  | 0  |
| 10 | 0  | 0  | 1  | 0  |
| 11 | 0  | 0  | 0  | 1  |

As formas de onda simuladas seguem exatamente o diagrama do enunciado (um único 1 por vez).

---

## 🧮 Exercício 2 — Função `f2(A,B)`

### Função dada:
- f(A,B) = A'·B' + A·B' = ~B
  
### Relação com o decodificador
- `Y0 = ~A·~B` e `Y2 = A·~B`  
- **Logo:** `f2 = Y0 | Y2 = ~B` (independe de `A`).

### Verificação em simulação
- Para `B=0` → `f2=1` (para qualquer `A`).  
- Para `B=1` → `f2=0`.  
Tabelas impressas pelo testbench confirmam o comportamento.

---

## 🧠 Exercício 3 — Função `f3(A,B,C)`

### Definição
- f(A,B,C)=A·B'·C' + A'·B·C'
- f = C' · (A·B' + A'·B)
- f = C' · (A XOR B)


### Relação com o decodificador
- `Y2 = A·B'` e `Y1 = ~A·B`  
- **Logo:** `f3 = ~C · (Y1 | Y2)`.

### Verificação em simulação
- Com `C=0`: `f3 = A XOR B`.  
- Com `C=1`: `f3 = 0` (saída mascarada).  
Ondas e `$display` confirmam a tabela verdade completa.

---

## 🖥️ Testbench

- Arquivo: `tb_decodificador_2_4.v`
- Diretiva: `` `timescale 1ns/1ps ``
- **Fases de teste:**
  1. **Ex.1:** Varredura `AB=00,01,10,11` com `C=0`, observando `Y0..Y3`.
  2. **Ex.2:** Tabela verdade de `f2` (mostra que é `~B`).
  3. **Ex.3:** Tabela verdade de `f3` (XOR mascarado por `~C`).
- Gera `wave.vcd`:
  ```verilog
  initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_decodificador_2_4);
  end
- Impressões com $display e encerramento limpo ("Fim da simulacao." + $finish).

Scripts do Questa (resumo de uso)

clean.do: limpa work, mapeia biblioteca e remove arquivos de simulação.

compile.do: compila rtl + tb. Configure IMPLEMENTATION = behavioral | dataflow | structural.

- run_gui.do:
- do clean.do
- do compile.do
- vsim -voptargs=+acc work.tb_decodificador_2_4
- add wave -r /*
- run -all
- run_cli.do: simulação em modo console (sem forçar fechar o vsim).

```
Quartus/
 └─ rtl/
    ├─ behavioral/decodificador_2_4.v
    ├─ dataflow/decodificador_2_4.v
    └─ structural/decodificador_2_4.v

Questa/
 ├─ rtl/ (mesma estrutura do Quartus)
 ├─ tb/tb_decodificador_2_4.v
 ├─ scripts/
 │   ├─ clean.do
 │   ├─ compile.do
 │   ├─ run_cli.do
 │   └─ run_gui.do
 └─ README.md
 ```

🛠️ Aplicações Práticas

Decodificação/endereçamento de registradores, periféricos e bancos de memória (chip-enable).

Síntese de funções combinando mintermos (como f2=~B e f3=~C·(A⊕B)).

Controle digital/FSM com ativações one-hot (habilitação exclusiva).

Integração com multiplexadores, ALUs e lógica de seleção de barramento.

✅ Conclusão

O módulo decodificador_2_4 foi implementado em três descrições equivalentes, testado e validado.
As formas de onda e as tabelas verdade confirmam os resultados teóricos dos Exercícios 1, 2 e 3:

Ex.1: decodificação one-hot correta.

Ex.2: f2 = ~B via Y0 + Y2.

Ex.3: f3 = ~C · (Y1 + Y2) ≡ ~C · (A ⊕ B).

Projeto pronto para reuso didático e integração em sistemas digitais maiores.
---