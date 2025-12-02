# Especificação de Hardware: Controlador de Laser Temporizado

## 1. Objetivo do Projeto
Desenvolver um circuito digital sequencial (controlador) para um sistema de cirurgia a laser.

**Comportamento:**
- O sistema monitora um botão de entrada (`b`).
- Ao detectar o acionamento (`b = 1`), o laser é ativado.
- O laser deve permanecer ligado por exatamente **três ciclos de clock**.
- Após os três ciclos, o laser desliga automaticamente, independentemente do estado do botão.

---

## 2. Interface do Módulo
Definição das portas para a entidade/módulo em Verilog.

| Porta | Tipo | Direção | Descrição |
| :--- | :---: | :---: | :--- |
| `clk` | `std_logic` | Input | Sinal de clock (sincronismo). |
| `rst` | `std_logic` | Input | Reset (recomendado para estado inicial). |
| `b` | `std_logic` | Input | Botão de ativação (1 = Pressionado). |
| `x` | `std_logic` | Output | Saída do Laser (1 = Ligado, 0 = Desligado). |

---

## 3. Máquina de Estados Finitos (FSM)
O sistema utiliza uma **Máquina de Moore** (a saída depende apenas do estado atual).

### Estados e Codificação
Codificação binária sequencial ($s_1 s_0$):

1.  **Des (00):** Estado de espera. Laser desligado ($x=0$). Aguarda $b=1$.
2.  **Lig1 (01):** Primeiro ciclo ativo. Laser ligado ($x=1$).
3.  **Lig2 (10):** Segundo ciclo ativo. Laser ligado ($x=1$).
4.  **Lig3 (11):** Terceiro ciclo ativo. Laser ligado ($x=1$).

---

## 4. Lógica de Transição
Comportamento de transição de estados baseado na entrada $b$.

| Estado Atual ($s_1 s_0$) | Nome | Entrada ($b$) | Próximo Estado ($n_1 n_0$) | Saída ($x$) |
| :---: | :--- | :---: | :---: | :---: |
| **00** | `Des` | 0 | **00** | 0 |
| **00** | `Des` | 1 | **01** | 0 |
| **01** | `Lig1` | X | **10** | 1 |
| **10** | `Lig2` | X | **11** | 1 |
| **11** | `Lig3` | X | **00** | 1 |

*Nota: "X" indica "don't care" (o valor de `b` não importa).*

---

## 5. Equações Booleanas (Para Síntese Estrutural)
Caso opte por implementação via fluxo de dados (dataflow) em vez de comportamental.

**Próximo Estado ($n_1$):**
$$n_1 = (s_1' \cdot s_0) + (s_1 \cdot s_0')$$
*(Equivalente a uma porta XOR: $s_1 \oplus s_0$)*

**Próximo Estado ($n_0$):**
$$n_0 = (s_1' \cdot s_0' \cdot b) + (s_1 \cdot s_0')$$

**Saída ($x$):**
$$x = s_1 + s_0$$
*(Laser ligado se o estado for diferente de 00)*

---

## 6. Considerações de Temporização
- **Período do Clock:** Exemplo de 10 ns.
- **Duração do Pulso:** O laser ficará ativo por $3 \times 10\text{ns} = 30\text{ns}$.
- **Risco de Glitch:** Como é uma máquina de Moore, a saída é sincronizada com a mudança de estado (borda do clock), garantindo um pulso limpo sem glitches combinacionais diretos da entrada.