  # Prompt-Modelo Aprimorado — Projetos HDL (Verilog)

  ## Objetivo Geral
  Garantir que **toda geração de código** produza:
  - 3 implementações: *Behavioral*, *Dataflow*, *Structural*  
  - Testbench **único**, capaz de testar **simultaneamente** as três abordagens  
  - Tabela didática baseada em **uma única abordagem** (facilita visualização)  
  - Scripts `.do`, README técnico (≥250 palavras/ seção) e cabeçalho padronizado  
  - Compatível com **Quartus** e **Questa (Verilog‑2001)**  
  - Organização de diretórios rígida e padronizada

  ---

  ## 1) Regras para o Módulo Principal
  Sempre gerar **reg_piso_n** ou o módulo solicitado com:
  - 3 arquivos `.v`: behavioral, dataflow, structural  
  - Comentários linha a linha  
  - snake_case  
  - Compatível com Verilog‑2001  
  - Parametrizável (quando fizer sentido)  
  
  Estrutura:

  ```
  Projeto_sistema_memoria/
  ├── README.md
  ├── Quartus/
  │   └── rtl/
  │       ├── behavioral/sistema_memoria
  │       ├── dataflow/sistema_memoria
  │       └── structural/sistema_memoria
  └── Questa/
      ├── rtl/
      │   ├── behavioral/sistema_memoria
      │   ├── dataflow/sistema_memoria
      │   └── structural/sistema_memoria
      ├── tb/tb_sistema_memoria
      └── scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
  ```

  ---

  ## 2) Cabeçalho Obrigatório em TODOS os arquivos `.v`

  ```verilog
  // ============================================================================
  // Arquivo  : sistema_memoria  (implementação [ABORDAGEM])
  // Autor    : Manoel Furtado
  // Data     : [data atual]
  // Ferramentas: Compatível com Quartus e Questa (Verilog 2001)
  // Descrição: [3–20 linhas — largura, função, técnica usada, riscos de síntese]
  // Revisão   : v1.0 — criação inicial
  // ============================================================================
  ```

  ---

  ## 3) **Testbench — Requisito Obrigatório Atualizado**

  O Testbench gerado deve:
  1. **Instanciar as três DUTs ao mesmo tempo**:

  2. Comparar automaticamente as saídas:
    - Em cada ciclo → `if (a!=b || b!=c) -> erro`

  3. Exibir mensagem final obrigatória:
    - `"SUCESSO: Todas as implementacoes estao consistentes em %0d testes."`

  4. **Tabela didática baseada apenas EM UMA abordagem**  
    Exemplo:
    - Escolher a abord. **Behavioral**
    - Gerar tabela:
      ```
      tempo | a(dec) | a(bin) | b(dec) | b(bin) | sel(dec) | y(bin)
      ```
    - Usar 16 linhas (0–15) pelo menos.  
    - Nunca deixar looping infinito  

  5. Testbench precisa:

    - Não criar latches
    - Estímulos sequenciais claros
    - `timescale 1ns/1ps`
    - Sem `$stop` permanente; usar controle de tempo
  
  6. Seja criativo e mostre mais tabelas:

    - Tabelas que expresem o objetivo da questão a ser resolvida.
    - Se for necessáro.

  Inclua **obrigatoriamente**:
  - Geração de estímulos com `#delays` e *loops*;  
  - Checagem automática com `if (...) $display(...)` e **flag de sucesso**;  
  - **VCD** para ondas:
    ```verilog
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_sistema_memoria);
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
      vlog -work work ../rtl/behavioral/sistema_memoria
  } elseif {$IMPLEMENTATION eq "dataflow"} {
      vlog -work work ../rtl/dataflow/sistema_memoria
  } elseif {$IMPLEMENTATION eq "structural"} {
      vlog -work work ../rtl/structural/sistema_memoria
  } else {
      echo "IMPLEMENTATION invalido: $IMPLEMENTATION"
      return
  }

  vlog -work work ../tb/tb_sistema_memoria
  ```

  ### ▶️ run_gui.do
  ```tcl
  do clean.do
  do compile.do
  vsim -voptargs=+acc work.tb_sistema_memoria
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
    - Data: *[data atual]*  
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

  ## 6) Qualidade Exigida
  - Código identado  
  - Sem SystemVerilog  
  - Comentado linha a linha  
  - Snake_case  
  - Evitar latches e X/Z  
  - Sempre incluir default no case  
  - Testbench totalmente determinístico  

  ---

  ## 7) Entrega Final - Entregue tudo em um único arquivo .zip no final. 
  - Diretórios completos  
  - Três implementações  
  - Testbench com testes simultâneos  
  - Scripts `.do`  
  - README.md ≥ 1.000 palavras  
  - Tabela didática de 1 abordagem  
  - Projeto compactado em .zip 
