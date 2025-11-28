# 🧩 Prompt-Modelo Aprimorado — Projetos HDL (Verilog)

> **Objetivo:** garantir que **toda** resposta da IA produza código Verilog com **cabeçalho padronizado**, comentários linha a linha, organização de pastas, testbench completo e scripts de simulação, mantendo compatibilidade com **Quartus** e **Questa (Verilog‑2001)**.

---

## 1) Instruções de geração do **módulo principal**

Crie o módulo **`ff_t`** em **três abordagens** — *Behavioral*, *Dataflow* e *Structural* — seguindo **exatamente**:

- Comentários **linha a linha** e blocos explicativos antes de cada sempre/assign/instância;
- Ser compatível com **Quartus** e **Questa** (padrão *Verilog 2001*);
- Utilizar **nomes de sinais e variáveis em snake_case** (sem acentos ou espaços);
- Ser organizada conforme a seguinte estrutura de diretórios:
  
```
  Projeto_ff_t/
  ├── README.md
  ├── Quartus/
  │    └── rtl/
  │         ├── behavioral/
  │         │     └── ff_t
  │         ├── dataflow/
  │         │     └── ff_t
  │         └── structural/
  │               └── ff_t
  │
  └── Questa/
        ├── rtl/
        │    ├── behavioral/ff_t
        │    ├── dataflow/ff_t
        │    └── structural/ff_t
        ├── tb/
        │    └── tb_ff_t
        └── scripts/
            ├── clean.do
            ├── compile.do
            ├── run_cli.do
            └── run_gui.do
  ```

---

## 2) **Cabeçalho obrigatório** (em todos os arquivos `.v`)

> Insira **antes do código** o cabeçalho abaixo, preenchendo os campos:
```verilog
// ============================================================================
// Arquivo  : ff_t  (implementação [ABORDAGEM])
// Autor    : Manoel Furtado
// Data     : 15/11/2025
// Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
// Descrição: [resumo técnico de 3–5 linhas: largura, função do bloco, visão
//            da estratégia (ex.: prefix-sum, carry-lookahead, CSA, etc.),
//            e notas de síntese (latência, recursos esperados).]
// Revisão   : v1.0 — criação inicial
// ============================================================================
```
**Regras do cabeçalho**
- Use **frases técnicas**, sem generalidades (“faz a soma” → ❌; “somador prefixado de 4 bits com propagação paralela de carry” → ✅).
- Se o módulo for **parametrizável**, cite parâmetros (ex.: `parameter N=8`).  
- Se houver **latência** (registradores), declare-a.
- Para o tb_ff_t do Testbench também precisa ter cabeçalho.
- Faça de uma forma a testar as três abordagens no mesmo testbench ao mesmo tempo.
- todo arquivo.v precisa ter cabeçalho.


---

## 3) Testbench — `tb_ff_t`

Inclua **obrigatoriamente**:
```verilog
`timescale 1ns/1ps
```
- Geração de estímulos com `#delays` e *loops*;  
- Checagem automática com `if (...) $display(...)` e **flag de sucesso**;  
- **VCD** para ondas:
  ```verilog
  initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_ff_t);
  end
  ```
- Encerramento limpo:
  ```verilog
  $display("Fim da simulacao.");
  $finish;
  ```

---

## 4) Scripts Questa (em `Questa/scripts/`)

### 🧹 clean.do
```tcl
# Limpeza segura (Questa/ModelSim Intel)
# clean.do — robusto / idempotente
# Fecha qualquer simulação e libera o handle do vsim.wlf
catch {quit -sim}
catch {dataset close -all}
catch {wave clear}
catch {transcript off}
catch {transcript file ""}

# Remove/zera a lib work com tolerância a erro
if {[file exists work]} { catch {vdel -lib work -all} }
catch {vlib work}
catch {vmap work work}

# Função utilitária: tenta deletar e não aborta se falhar
proc safe_delete {path} {
    if {[file exists $path]} {
        if {[catch {file delete -force $path} err]} {
            puts "WARN: não foi possível deletar '$path' — $err (continuando)."
        }
    }
}

# Arquivos típicos gerados pelo Questa/ModelSim
foreach f {transcript vsim.wlf wave.vcd vsim.dbg wlft3.wlf vsim.dbg/mdb.log} {
    safe_delete $f
}
```

 ### ⚙️ compile.do
```tcl
# compile.do — behavioral | dataflow | structural
quietly set IMPLEMENTATION behavioral
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

if {$IMPLEMENTATION eq "behavioral"} {
    vlog -work work ../rtl/behavioral/ff_t
} elseif {$IMPLEMENTATION eq "dataflow"} {
    vlog -work work ../rtl/dataflow/ff_t
} elseif {$IMPLEMENTATION eq "structural"} {
    vlog -work work ../rtl/structural/ff_t
} else {
    echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
    return
}

vlog -work work ../tb/tb_ff_t
```

### ▶️ run_gui.do
```tcl
do clean.do
do compile.do
vsim -voptargs=+acc work.tb_ff_t
add wave -r /*
run -all
```
  💡 *Não force a saída do Questa. O script `run_gui.do` deve limpar e compilar automaticamente antes da execução.*
---

## 5) **README.md** (Relatório Técnico)

Inclua as seções: **Descrição do Projeto**, **Análise das Abordagens**, **Metodologia do Testbench**, **Aplicações Práticas**.  
Cada seção deve ter **≥ 250 palavras**, com comparações diretas, riscos de síntese (timing, área), exemplos numéricos e boas práticas.


  ### 5.1 Descrição do Projeto
  - Autor: *Manoel Furtado*  
  - Data: *15/11/2025*  
  - Objetivo do projeto e breve explicação da arquitetura implementada.

  ### 5.2 Análise das Abordagens
  Descreva em detalhes, em parágrafos separados:
  - A implementação **Behavioral**;  
  - A implementação **Dataflow**;  
  - A implementação **Structural**.

  ### 5.3 Descrição do Testbench
  Explique em detalhes a metodologia de simulação e análise das **formas de onda**, destacando:
  - Etapas de entrada de estímulos;
  - Monitoramento dos sinais;
  - Interpretação dos resultados.

  ### 5.4 Aplicações Práticas
  Excreva em detalhes, relacionando o projeto com **situações reais**  
  Inclua **exemplos adicionais de aplicação prática** além dos discutidos no exercício.

  Escreva as seções 5.2, 5.3 e 5.4 do README em prosa técnica extensa, mínimo 250–350 palavras por seção, com exemplos numéricos, vantagens/limitações, riscos de síntese, e boas práticas. Use subtítulos, evite frases genéricas, e inclua comparações diretas entre as abordagens. Não faça sumário; escreva o texto final.


---

## 6) Critérios de qualidade exigidos da IA

- Código **identado**, sem linhas corridas;  
- **Sem** SystemVerilog (use `reg`, `wire`, `always @*` etc.);  
- Comentários **linha a linha** e blocos-resumo por seção;  
- **Nomes coerentes** com o enunciado e com o diagrama (quando houver);  
- **Erros comuns a evitar**: larguras inconsistentes, `X/Z` em comparações, *latches* acidentais, esquecimento de `default` em *case*, sinais não inicializados no TB.

---

## 7) Entrega Final

  - Estrutura completa de diretórios (**Quartus** e **Questa**);  
  - Código-fonte das três abordagens;  
  - Testbench;  
  - Scripts `.do`;  
  - Relatório `README.md`.
  - Mais o que achar necessário

---