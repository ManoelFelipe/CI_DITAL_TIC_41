# 🧩 Prompt_ULA_FULL_Divisao_v1 — Projetos HDL (Verilog)

> **Objetivo:** gerar uma ULA completa (**ULA_FULL**) com suporte a:
> - múltiplas **representações numéricas** (unsigned, 2’s complement, sinal/magnitude, ponto fixo Q, mini‑float simplificado);
> - operações aritméticas e lógicas clássicas;
> - **divisão inteira sem sinal**, **divisão inteira com sinal** e **divisão em ponto fixo**;
> - detecção de **overflow**, **saturação**, **zero**, **sinal** e **carry/borrow**;
> - três abordagens de implementação: *Behavioral*, *Dataflow* e *Structural*;
> - compatível com **Quartus** e **Questa (Verilog‑2001)**.

A IA deve SEMPRE seguir este prompt quando for pedida para gerar o projeto `ULA_FULL` com divisão.

---

## 1) Interface e Convenções da ULA_FULL

Crie o módulo principal **`ula_full`** com interface genérica, parametrizável:

```verilog
module ula_full_<approach>
#(
    parameter WIDTH = 8,   // Largura dos dados
    parameter FRAC  = 4    // Bits fracionários para modo Q (ponto fixo)
)(
    input      [WIDTH-1:0] op_a,      // Operando A
    input      [WIDTH-1:0] op_b,      // Operando B
    input      [3:0]       op_sel,    // Código da operação (4 bits)
    input      [2:0]       num_mode,  // Modo numérico
    output reg [WIDTH-1:0] result,    // Resultado
    output reg             flag_overflow,  // Overflow aritmético
    output reg             flag_saturate,  // Saturação aplicada
    output reg             flag_zero,      // Resultado zero
    output reg             flag_negative,  // Bit de sinal do resultado
    output reg             flag_carry      // Carry/borrow (quando aplicável)
);
```

> **Observação:**  
> Use o sufixo `<approach>` para diferenciar as três versões:
> - `ula_full_behavioral`
> - `ula_full_dataflow`
> - `ula_full_structural`

### 1.1 Modos Numéricos (`num_mode`)

O campo `num_mode` (3 bits) deve ser interpretado assim:

- `3'b000` → **inteiro sem sinal (unsigned)**
- `3'b001` → **inteiro com sinal em 2’s complement**
- `3'b010` → **sinal/magnitude**  
- `3'b011` → **ponto fixo Q**, representado em 2’s complement com `FRAC` bits fracionários
- `3'b100` → **mini‑float simplificado**  
  - 1 bit de sinal (`sign`), 3 bits de expoente, resto mantissa compactada.
- `3'b101`–`3'b111` → reservados (podem ser tratados como unsigned por padrão)

### 1.2 Operações (`op_sel`)

O campo `op_sel` passa a ter **4 bits**, permitindo **até 16 operações**. Use o seguinte mapeamento:

| `op_sel` | Operação                                     | Comentário                                                  |
|----------|----------------------------------------------|-------------------------------------------------------------|
| `4'b0000`| ADD – soma                                   | respeitando o modo numérico                                |
| `4'b0001`| SUB – subtração                              | `A - B`                                                     |
| `4'b0010`| MUL – multiplicação                          | inteiro, 2’s complement, sinal/mag, Q                      |
| `4'b0011`| DIVU – divisão inteira **sem sinal**         | apenas modos unsigned / sinal/mag                          |
| `4'b0100`| DIVS – divisão inteira **com sinal**         | 2’s complement; cuida de sinal e divisão por zero          |
| `4'b0101`| DIVQ – divisão em **ponto fixo Q**           | 2’s complement + escalonamento por `FRAC`                  |
| `4'b0110`| AND – operação bit a bit                     | independente do modo                                        |
| `4'b0111`| OR – operação bit a bit                      |                                                             |
| `4'b1000`| XOR – operação bit a bit                     |                                                             |
| `4'b1001`| NAND – operação bit a bit                    | `~(A & B)`                                                  |
| `4'b1010`| NOR – operação bit a bit                     | `~(A | B)`                                                  |
| `4'b1011`| XNOR – operação bit a bit                    | `~(A ^ B)`                                                  |
| `4'b1100`| SHL – shift à esquerda                       | lógico ou aritmético (depende do modo)                     |
| `4'b1101`| SHR – shift à direita lógico                 | preserva zeros na esquerda                                  |
| `4'b1110`| SAR – shift à direita aritmético             | preserva bit de sinal (2’s complement, Q)                   |
| `4'b1111`| CMP – comparação (ex.: `A ? B`)              | pode gerar flags, ex: `result = A - B` com focus em flags  |

- O campo de deslocamento (`shift_amt`) deve ser derivado de `op_b[2:0]` (por exemplo).
- Em modos com sinal (2’s complement, Q), o **SAR** (`>>>`) deve preservar o bit de sinal.
- Em modos unsigned, **SHR** deve ser lógico (`>>`).

---

## 2) Cabeçalho obrigatório em TODOS os `.v`

Antes de qualquer módulo, insira o cabeçalho padrão:

```verilog
// ============================================================================
// Arquivo  : ula_full  (implementação [ABORDAGEM])
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: [resumo técnico de 3–5 linhas: largura, função do bloco, visão
//            da estratégia (ex.: prefix-sum, divisão inteira, ponto fixo Q),
//            e notas de síntese (latência, recursos esperados).]
// Revisão   : v1.0 — criação inicial
// ============================================================================
```

**Regras do cabeçalho:**

- Usar **frases técnicas**, nada genérico.
- Se o módulo for **parametrizável**, citar parâmetros (`WIDTH`, `FRAC` etc.).
- Se houver **latência**, declarar explicitamente (número de ciclos).
- O **testbench** também deve ter cabeçalho.
- Todo arquivo `.v` do projeto deve ter esse cabeçalho.

---

## 3) Estratégia para as Divisões

A ULA_FULL deve ter divisão implementada de forma **combinacional simples** e didática, ciente de que:

- Em FPGA real, o uso de operadores `/` e `%` pode gerar lógicas grandes;
- O objetivo é **didático**, não necessariamente otimizado em área.

### 3.1 DIVU – divisão inteira sem sinal (`op_sel = 4'b0011`)

Para **modo unsigned** (`num_mode = 3'b000`):

- `result = (op_b != 0) ? (op_a / op_b) : {WIDTH{1'b0}};`
- Em caso de divisão por zero (`op_b == 0`):
  - `flag_overflow = 1'b1;`
  - Pode-se configurar `result` como zero ou valor máximo (`{WIDTH{1'b1}}`), desde que isso seja documentado em comentários.

Para **modo sinal/magnitude** (`3'b010`):

- Usar apenas as magnitudes (`|op_a[WIDTH-2:0]|`, `|op_b[WIDTH-2:0]|`) para a divisão;
- Determinar o sinal do resultado com XOR dos sinais de entrada;
- Ajustar saturação se necessário (por exemplo, se divisor for zero).

### 3.2 DIVS – divisão inteira com sinal (`op_sel = 4'b0100`)

Para **2’s complement** (`3'b001`):

1. Extrair sinal de `op_a` e `op_b`;
2. Trabalhar com magnitudes absolutas (`abs_a`, `abs_b`);
3. Aplicar divisão inteira: `mag_res = abs_a / abs_b;`
4. Determinar o sinal de saída com `sign_res = sign_a ^ sign_b`;
5. Se `op_b == 0`, levantar `flag_overflow` e saturar:
   - `result = {1'b0, {WIDTH-1{1'b1}}}` (máximo positivo) ou  
   - `result = {1'b1, {WIDTH-1{1'b0}}}` (mínimo negativo), conforme documentado.

> A IA deve comentar **linha a linha** o tratamento de sinais, zero e saturação.

### 3.3 DIVQ – divisão em ponto fixo (`op_sel = 4'b0101`)

Para **ponto fixo Q** (`num_mode = 3'b011`):

- Considerar entradas em 2’s complement com `FRAC` bits fracionários.
- Para representar `A / B` em Q:

  ```text
  // Representações:
  // A_Q = A / 2^FRAC
  // B_Q = B / 2^FRAC
  // Resultado desejado:
  // (A_Q / B_Q) = (A / 2^FRAC) / (B / 2^FRAC) = A / B
  //
  // Como queremos resultado também em Q, podemos:
  // 1) converter A para maior precisão, ou
  // 2) dividir diretamente A por B e tratar saturação.
  ```

- Para fins didáticos, adotar a abordagem:

  ```verilog
  // pseudo:
  // signed_div = $signed(op_a) / $signed(op_b);
  // result     = saturate_to_width(signed_div);
  ```

- Se `op_b == 0`, ativar `flag_overflow` e aplicar saturação.

---

## 4) Abordagens de Implementação

### 4.1 Behavioral (`ula_full_behavioral`)

- Usar **um único** `always @*`:
  - `case (num_mode)` por fora,
  - `case (op_sel)` por dentro.
- Comentários **linha a linha** e blocos explicativos por operação.
- Tratar todas as flags (`overflow`, `saturate`, `zero`, `negative`, `carry`) dentro desse bloco, com valores default bem definidos.
- Divisão pode ser feita com operadores `/` e `%`, mas **explicitamente comentada** como solução didática, com alerta sobre síntese.

### 4.2 Dataflow (`ula_full_dataflow`)

- Usar **funções combinacionais** e atribuições contínuas:
  - Uma função central `ula_core` que recebe `op_a`, `op_b`, `op_sel`, `num_mode`.
  - Retornar um vetor empacotado com `{result, flags}`.
- Desempacotar o vetor em wires externos.
- Manter comentários explicando:
  - Como cada caso de divisão é tratado;
  - Diferença entre DIVU, DIVS e DIVQ.

### 4.3 Structural (`ula_full_structural`)

- Separar em submódulos:
  - `ula_mode_pre` – adaptador de entrada por modo numérico (se precisar).
  - `ula_core_arith` – núcleo da ULA (pode instanciar behavioral, por exemplo).
  - `ula_mode_post` – pós-processamento do resultado (opcional).
- A versão estrutural pode reutilizar o core behavioral, mas deve ser **claramente modularizada**.

---

## 5) Estrutura de Diretórios do Projeto

Organizar exatamente assim:

```text
Projeto_ula_full_divisao/
├── README.md
├── Quartus/
│    └── rtl/
│         ├── behavioral/
│         │     └── ula_full.v
│         ├── dataflow/
│         │     └── ula_full.v
│         └── structural/
│               └── ula_full.v
│
└── Questa/
     ├── rtl/
     │    ├── behavioral/ula_full.v
     │    ├── dataflow/ula_full.v
     │    └── structural/ula_full.v
     ├── tb/
     │    └── tb_ula_full.v
     └── scripts/
          ├── clean.do
          ├── compile.do
          ├── run_cli.do
          └── run_gui.do
```

- Todos os caminhos de arquivos devem bater com os scripts do Questa.
- Arquivos em `Quartus/rtl` e `Questa/rtl` podem ser cópias dos mesmos `.v`, mas colocados em locais diferentes por organização.

---

## 6) Testbench — `tb_ula_full` (3 DUTs simultâneos)

O testbench deve:

- Conter cabeçalho padrão.
- Ter:

  ```verilog
  `timescale 1ns/1ps
  ```

- Instanciar as três versões:
  - `ula_full_behavioral`
  - `ula_full_dataflow`
  - `ula_full_structural`
- Alimentar todas com os mesmos sinais de estímulo `op_a`, `op_b`, `op_sel`, `num_mode`.
- Gerar estímulos com:
  - Laços `for` aninhados sobre:
    - `num_mode` (0 até pelo menos 4)
    - `op_sel` (0 a 15)
    - subconjuntos dos valores de `op_a` e `op_b` (por exemplo 0 a 15, ou outro range prático).
- Incluir **VCD**:

  ```verilog
  initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_ula_full);
  end
  ```

- Implementar checagem automática:

  ```verilog
  if ( (result_beh  !== result_df) ||
       (result_beh  !== result_st) ||
       (ov_beh      !== ov_df)     ||
       (ov_beh      !== ov_st)     ||
       (sat_beh     !== sat_df)    ||
       (sat_beh     !== sat_st)    || ... ) begin
      // contar erros e mostrar detalhes
  end
  ```

- Exibir mensagem final:

  ```verilog
  $display("Fim da simulacao.");
  $finish;
  ```

- Quando todas as implementações coincidirem:
  - Mostrar: `"SUCESSO: Todas as implementacoes da ULA FULL DIVISAO estao consistentes."`

---

## 7) Scripts Questa (em `Questa/scripts/`)

### 7.1 `clean.do`

- Fechar simulação, limpar `work`, apagar arquivos temporários e `wave.vcd`, conforme modelo robusto:

```tcl
# Limpeza segura (Questa/ModelSim Intel)
# clean.do — robusto / idempotente
catch {quit -sim}
catch {dataset close -all}
catch {wave clear}
catch {transcript off}
catch {transcript file ""}

if {[file exists work]} { catch {vdel -lib work -all} }
catch {vlib work}
catch {vmap work work}

proc safe_delete {path} {
    if {[file exists $path]} {
        if {[catch {file delete -force $path} err]} {
            puts "WARN: não foi possível deletar '$path' — $err (continuando)."
        }
    }
}

foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf vsim.dbg/mdb.log} {
    safe_delete $f
}
```

### 7.2 `compile.do`

- Deve permitir escolher abordagem por variável `IMPLEMENTATION` (behavioral, dataflow, structural).
- Sempre compilar:
  - o RTL correspondente
  - + o testbench.

### 7.3 `run_gui.do`

- Chamar `clean.do`, depois `compile.do`, depois rodar GUI:

```tcl
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ula_full
add wave -r /*
run -all
```

### 7.4 `run_cli.do`

- Versão em modo console:

```tcl
do clean.do
do compile.do
vsim -c -voptargs=+acc work.tb_ula_full -do "run -all; quit"
```

---

## 8) README.md — Relatório Técnico

O `README.md` deve conter, no mínimo, as seções:

1. **Descrição do Projeto**  
   - Autor, data, contexto da ULA_FULL com divisão e múltiplos modos numéricos.  
   - Explicar em prosa técnica a arquitetura geral.

2. **Análise das Abordagens**  
   - Comparar **Behavioral**, **Dataflow** e **Structural**:
     - estilo de código,
     - clareza,
     - impacto esperado em síntese (área/timing),
     - vantagens e limitações.

3. **Descrição do Testbench**  
   - Explicar a metodologia de testes, loops, checagem de flags, geração de VCD.

4. **Aplicações Práticas**  
   - Relacionar a ULA a:
     - processadores didáticos;
     - DSP com ponto fixo;
     - prototipagem de mini‑float;
     - uso em FPGAs (como Spartan‑7, Cyclone, etc.).

> Cada seção (2–4) deve ter **≥ 250–350 palavras**, em prosa técnica, com exemplos numéricos, riscos de síntese, boas práticas de uso e possíveis extensões.

---

## 9) Critérios de Qualidade

- **Código identado**, sem linhas corridas.
- **Sem SystemVerilog** (usar apenas Verilog‑2001: `reg`, `wire`, `always @*`, etc.).
- Comentários **linha a linha** em blocos críticos (divisão, saturação, modos numéricos).
- Nomes em **snake_case**, sem acentos e sem abreviações confusas.
- Evitar:
  - larguras inconsistentes,
  - uso de `X/Z` em comparações,
  - *latches* acidentais,
  - falta de `default` em `case`,
  - sinais não inicializados no testbench.

---

## 10) Entrega Final por parte da IA

Quando a IA for solicitada a gerar o projeto com base neste prompt, ela deve entregar, organizado em um `.zip`:

- Estrutura completa de diretórios (**Quartus** e **Questa**);
- Código fonte das três abordagens (`behavioral`, `dataflow`, `structural`);
- Testbench `tb_ula_full.v` com três DUTs simultâneos;
- Scripts `.do` (`clean.do`, `compile.do`, `run_cli.do`, `run_gui.do`);
- Relatório `README.md` com seções detalhadas;
- Quaisquer arquivos auxiliares julgados necessários (por exemplo, diagramas em texto, tabelas de mapeamento de modos e operações).

Este arquivo é o **Prompt_ULA_FULL_Divisao_v1** e serve como **especificação completa** para a IA gerar o projeto de ULA com divisão.
