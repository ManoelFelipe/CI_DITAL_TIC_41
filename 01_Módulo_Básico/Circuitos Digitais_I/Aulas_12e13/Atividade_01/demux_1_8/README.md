# Demultiplexador 1×8 (Verilog) — Behavioral / Dataflow / Structural

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Compatibilidade:** Quartus (Intel) e Questa/ModelSim (Verilog‑2001)  

## Estrutura do Projeto

```
Quartus/
 └─ rtl/
    ├─ behavioral/demux_1_8.v
    ├─ dataflow/demux_1_8.v
    └─ structural/demux_1_8.v

Questa/
 ├─ rtl/
 │  ├─ behavioral/demux_1_8.v
 │  ├─ dataflow/demux_1_8.v
 │  └─ structural/demux_1_8.v
 ├─ tb/
 │  └─ tb_demux_1_8.v
 ├─ scripts/
 │  ├─ clean.do
 │  ├─ compile.do
 │  ├─ run_cli.do
 │  └─ run_gui.do
 └─ README.md (este arquivo)
```

## Como simular no Questa

**GUI**  
1. Abra o Questa na pasta `Questa/scripts`.  
2. Digite: `do run_gui.do` (limpa, compila e abre a simulação).  
3. Para trocar a implementação, na própria barra de comando:  
   - `quietly set IMPLEMENTATION dataflow; do run_gui.do`  
   - `quietly set IMPLEMENTATION structural; do run_gui.do`

**CLI (modo console)**  
- Behavioral:  
  `vsim -c -do "quietly set IMPLEMENTATION behavioral; do run_cli.do"`  
- Dataflow:  
  `vsim -c -do "quietly set IMPLEMENTATION dataflow; do run_cli.do"`  
- Structural:  
  `vsim -c -do "quietly set IMPLEMENTATION structural; do run_cli.do"`  

O testbench gera `wave.vcd` automaticamente (pode ser aberto em GTKWave).

---

## Explicação dos Códigos

### 1) Comportamental (Behavioral)
Nesta versão, o bloco `always @*` zera todas as saídas e, via `case(sel)`, ativa **somente** a saída indexada por `sel`, atribuindo‑lhe o valor de `din`. Este estilo espelha diretamente o **comportamento** desejado do demultiplexador, sendo muito legível e direto para sintetizadores.

### 2) Fluxo de Dados (Dataflow)
Criamos uma máscara **one‑hot** com `(8'b1 << sel)` e fazemos `dout = {8{din}} & one_hot`. Assim, quando `din=1`, apenas o bit selecionado por `sel` fica 1; com `din=0`, todas as saídas ficam 0. É uma descrição **declarativa** e concisa, ideal para entender o caminho dos dados.

### 3) Estrutural (Structural)
Combinamos um **decodificador 3→8** (gera `one_hot`) com **8 portas AND** ligando `din` a cada bit de `one_hot`. Esse estilo evidencia a **interconexão de blocos** básicos de hardware, sendo útil para ensino e para mapeamento explícito em células lógicas.

---

## Testbench e Resultados Esperados
O `tb_demux_1_8.v` varre `sel` de 0 a 7 em dois cenários: primeiro com `din=0` (todas saídas devem ser `00000000`) e depois com `din=1` (a cada valor de `sel`, apenas um bit de `dout` fica 1).  
No console, são impressas linhas como:

```
Tempo | din sel | dout
   5  |  0   0 | 00000000
  ...
  50  |  1   0 | 00000001
  55  |  1   1 | 00000010
  60  |  1   2 | 00000100
  ...
  85  |  1   7 | 10000000
Fim da simulacao.
```

O arquivo `wave.vcd` mostrará exatamente essa sequência de ativações one‑hot nas formas de onda.

---

## Aplicações Práticas
Demultiplexadores são usados para **rotear** um único sinal para múltiplos destinos, como:  
- Selecionar qual **registrador** receberá um dado em barramentos compartilhados;  
- Endereçar **linhas de LEDs/Displays** a partir de uma entrada única;  
- Direcionar pulsos de **controle** para diferentes blocos funcionais em FSMs;  
- Expansão de **linhas de controle** em interfaces simples.  

Exemplos adicionais:  
- Em um sistema de **interrupções**, um demux pode disparar exatamente um handler entre 8, conforme o vetor de seleção;  
- Em automação, pode acionar **válvulas/relés** distintos a partir de um único canal de comando usando `sel` como endereço;  
- Em **DACs** multiplexados no tempo, um demux pode entregar amostras a saídas físicas diferentes conforme o slot de tempo.

---

## Observações de Síntese
- Todos os estilos inferem o mesmo hardware básico (decodificador + gates).  
- Os arquivos foram escritos com **Verilog‑2001** e comentados linha a linha, visando **Quartus** e **Questa**.  
- Evitamos macros/guards para manter aderência às suas preferências de nome e organização.

Bom estudo e boas simulações!
