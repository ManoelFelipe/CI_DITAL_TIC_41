
# Multiplexador 16×1 — Behavioral, Dataflow e Structural
Autor: **Manoel Furtado** · Data: **31/10/2025**  
Compatível com **Quartus** e **Questa** (Verilog‑2001).

## Estrutura do projeto
```
Quartus/
  rtl/
    behavioral/  -> multiplex_16_1.v
    dataflow/    -> multiplex_16_1.v
    structural/  -> multiplex_16_1.v

Questa/
  rtl/
    behavioral/  -> multiplex_16_1.v
    dataflow/    -> multiplex_16_1.v
    structural/  -> multiplex_16_1.v
  tb/
    tb_multiplex_16_1.v
  scripts/
    clean.do | compile.do | run_cli.do | run_gui.do
```
> Observação: Para evitar colisão de módulos com o mesmo nome, os *scripts* de simulação
> compilam **apenas um** estilo por vez (variável `IMPLEMENTATION` em `compile.do`).

## Como simular no Questa
Dentro de `Questa/scripts`:
```tcl
# GUI (limpa, compila e roda)
do run_gui.do

# Somente terminal
do clean.do
do compile.do
do run_cli.do
```
O `vsim -voptargs=+acc work.tb_multiplex_16_1` habilita visibilidade de sinais.

## Relatório
### (1) Explicação — Código **Comportamental**
O modelo comportamental usa um bloco `always @(*)` e a indexação variável `d[sel]` para
selecionar dinamicamente qual entrada vai para a saída `y`. Essa forma descreve o
comportamento do circuito de maneira direta (o *o que*), deixando ao sintetizador
a decisão do *como* realizar fisicamente o mux. A vantagem é a legibilidade e a
facilidade de manutenção, pois qualquer tamanho do vetor pode ser manipulado com
o mesmo padrão de código.

### (2) Explicação — Código **Dataflow**
O estilo *dataflow* usa um único `assign` com operador condicional em cascata (`?:`).
Cada condição `sel == N` direciona um dos bits `d[N]` para a saída. É uma forma
de descrever explicitamente o caminho de dados, mantendo a natureza combinacional.
Sinta-se à vontade para reorganizar ou gerar automaticamente os ramos para tamanhos
maiores; o sintetizador infere os multiplexadores necessários.

### (3) Explicação — Código **Estrutural**
Na descrição estrutural, o mux 16:1 é construído como uma **árvore de muxes 2:1**:
primeiro 16→8, depois 8→4, 4→2 e 2→1. O submódulo `mux2` implementa um 2:1 e é
instanciado várias vezes. Essa abordagem espelha a **topologia física**, útil para
estudos de temporização (atrasos por níveis) e para reutilização de blocos menores
em arquiteturas hierárquicas.

### (4) Testbench e resultados
O testbench `tb_multiplex_16_1.v` aplica três baterias de estímulos: (i) varre
`sel` com `d` fixo; (ii) repete a varredura com outro padrão de `d`; (iii) mantém
`sel` fixo e executa um *walking one* sobre `d`. A checagem é **auto‑verificada**,
comparando a saída do DUT com a referência `y_ref = d[sel]`. Durante a simulação,
o console exibe linhas formatadas com tempo, seleção, vetor de dados, saída do DUT
e da referência, marcando `OK/ERRO`. Um arquivo `wave.vcd` é gerado para inspeção
visual de formas de onda. Em testes típicos, todas as linhas retornam `OK`,
confirmando a correção funcional.

### (5) Aplicações práticas
Multiplexadores são onipresentes: seleção de **fontes de dados** em barramentos,
escolha de **entradas de ALU** em CPUs, encaminhamento de **amostras** em sistemas
de aquisição, seleção de **canais de comunicação** e comutação de **sinais de
controle** entre modos *manual/automático*. Outros exemplos: seleção entre 16
sensores digitais para uma única linha de telemetria; escolha de 1 entre 16 sinais
de teste para um pino de *debug*; e construção de **crossbars**/**switch fabrics**
maiores através de árvores de muxes.

---
> Dica: No Quartus, a mesma árvore `rtl/` pode ser adicionada ao projeto. No Questa,
> ajuste `compile.do` para o estilo desejado.
