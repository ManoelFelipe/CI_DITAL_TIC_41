# Multiplexador 4×1 Parametrizável (N bits) — Behavioral, Dataflow e Structural
**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Compatibilidade:** Verilog-2001 · Quartus · Questa (Intel/ModelSim)

---

## 🎯 Objetivo
Implementar um **mux 4×1** de **N bits** em **três estilos** (Comportamental, Dataflow e Estrutural), com **testbench auto-verificado**, geração de **VCD**, e **scripts** para simulação no Questa.

---

## 📁 Estrutura do Projeto

```
Quartus/
  rtl/
    behavioral/   multiplex_4_1_N.v
    dataflow/     multiplex_4_1_N.v
    structural/   multiplex_4_1_N.v

Questa/
  rtl/
    behavioral/   multiplex_4_1_N.v
    dataflow/     multiplex_4_1_N.v
    structural/   multiplex_4_1_N.v
  tb/
    tb_multiplex_4_1_N.v
  scripts/
    clean.do
    compile.do
    run_cli.do
    run_gui.do
```

> Observação: todos os estilos usam **o mesmo nome de módulo** (`multiplex_4_1_N`).  
> Para evitar colisão, o `compile.do` compila **apenas um estilo por vez** (variável `IMPLEMENTATION`).

---

## ▶️ Como Simular no Questa

No terminal do Questa, entre em `Questa/scripts`:

**GUI (recomendado):**
```tcl
do run_gui.do
```

**CLI (modo texto):**
```tcl
do clean.do
do compile.do
do run_cli.do
```

No `compile.do`, escolha o estilo:
```tcl
quietly set IMPLEMENTATION behavioral   ;# ou dataflow | structural
```

O `run_gui.do` já:
- limpa e compila (`do clean.do` + `do compile.do`);
- executa com visibilidade de sinais:  
  `vsim -voptargs=+acc work.tb_multiplex_4_1_N`
- adiciona tudo no Wave: `add wave -r /*`
- roda até o fim: `run -all`

---

## 🧠 Relatório Técnico e Descritivo

### 1) Descrição **Comportamental**
A versão comportamental utiliza um bloco **`always @(*)`** e um **`case(sel)`** para rotear uma das quatro entradas (`d0`, `d1`, `d2`, `d3`) até a saída `y`.  
A largura dos barramentos é definida pelo **parâmetro `N`**, permitindo reutilização do mesmo código para 1, 3, 8, 16, 32 bits etc.  
Vantagens: **legibilidade**, **portabilidade** e **rapidez na modelagem** do comportamento lógico desejado, sem se comprometer com a topologia física.

### 2) Descrição **Dataflow**
A abordagem *dataflow* usa um **`assign`** com o operador condicional **ternário `?:`** encadeado, expressando diretamente o **caminho de dados**: conforme `sel`, um dos vetores é direcionado à saída.  
O sintetizador infere automaticamente a rede de multiplexadores **N-bit** equivalente.  
Vantagens: **compacidade**, **clareza declarativa** e **síntese previsível** para circuitos combinacionais.

### 3) Descrição **Estrutural**
A versão estrutural explicita a hierarquia de hardware por meio de uma **árvore de muxes 2×1** parametrizados (`mux2_N`).  
- **Nível 1** (`sel[0]`): `d0×d1` e `d2×d3` → `y_lo`, `y_hi`  
- **Nível 2** (`sel[1]`): `y_lo×y_hi` → `y`  
Essa organização espelha uma implementação **física típica**, facilita **reuso** de blocos e é útil para estudar **profundidade lógica** e **temporização**.

---

## 🧪 Testbench, Saída e Formas de Onda
O `tb_multiplex_4_1_N.v` usa **`N=3`** (parametrizável) e executa duas varreduras completas de `sel` com diferentes padrões de (`d0..d3`).  
Há um modelo de **referência interna** `y_ref` (expressão combinacional) que compara a saída do DUT e imprime **`OK/ERRO`** formatado no console:

- **`$display`** com tempo, `sel`, entradas, `y` e `y_ref`
- **Geração de VCD**:
  ```verilog
  initial begin
      $dumpfile("wave.vcd");
      $dumpvars(0, tb_multiplex_4_1_N);
  end
  ```
- **Encerramento limpo**:
  ```verilog
  $display("Fim da simulacao.");
  $finish;
  ```

No **Questa GUI**, o `run_gui.do` já adiciona **todos** os sinais ao Wave (útil para prints de tela).  
**Resultado esperado:** 100% das linhas com **OK**, validando equivalência funcional entre o DUT e `y_ref`.

---

## 🧩 Aplicações Práticas (com exemplos a mais)
Muxes 4×1 de N bits são onipresentes em sistemas digitais. Exemplos típicos:
- **CPU/ALU**: seleção entre operandos (registrador A/B, imediato, *forwarding* de pipeline).  
- **Roteamento de barramento**: escolher uma entre quatro fontes (DMA, CPU, periférico, porta de debug) para um canal.  
- **Sistemas embarcados**: concentração de **4 sensores** (N bits) em um único caminho de leitura.  
- **FPGA datapaths**: seleção de sub-módulos (p.ex., deslocador, somador, comparador, LUT).  
- **Comunicações**: seleção de **4 canais** de dados paralelos (N) para transmissão/observabilidade.  
- **Controle de modo**: escolher entre **4 perfis**/tabelas de parâmetros (ganhos, *setpoints*).  
- **Teste/Debug**: comutar **4 sinais internos** para um pino de *probe* único.  
- **Composição hierárquica**: construir muxes **8×1 / 16×1** a partir de 4×1 (e 2×1), seguindo a mesma árvore estrutural.

---

## 🧱 Observações de Síntese/FPGA
- Todos os estilos são **combinacionais puros** (sem latches).  
- A parametrização `N` propaga para toda a lógica, mantendo **coerência de largura**.  
- Em FPGAs, o mapeamento normalmente usa LUTs; a versão **estrutural** deixa mais explícitos os níveis de multiplexação (pode ajudar ao analisar **timing**).

---

## ✅ Checklist de Entrega
- [x] RTL **Comportamental** (`always/case`)  
- [x] RTL **Dataflow** (`assign ?:`)  
- [x] RTL **Estrutural** (árvore de `mux2_N`)  
- [x] **Testbench** com `N=3`, `timescale`, delays, `$display`, **VCD**, **finish**  
- [x] **Scripts** (`clean.do`, `compile.do`, `run_cli.do`, `run_gui.do`)  
- [x] Compatível com **Quartus** e **Questa**

---

## 🔧 Dicas Rápidas
- Se quiser trocar `N`, basta alterar no TB: `localparam N = <novo_valor>;`  
- Para comparar **estilos diferentes** em uma mesma simulação, renomeie os módulos (ex.: `multiplex_4_1_N_beh`, `..._df`, `..._str`) ou use libs/bibliotecas distintas.

---

**Comandos úteis (GUI):**
```tcl
do run_gui.do
# Internamente:
# vsim -voptargs=+acc work.tb_multiplex_4_1_N
# add wave -r /*
# run -all
```

**Logs esperados (exemplo):**
```
 tempo   sel   d0 d1 d2 d3  |  y  y_ref  OK
   5    00    001 010 101 111 | 001  001   OK
  10    01    001 010 101 111 | 010  010   OK
  ...
Fim da simulacao.
```
