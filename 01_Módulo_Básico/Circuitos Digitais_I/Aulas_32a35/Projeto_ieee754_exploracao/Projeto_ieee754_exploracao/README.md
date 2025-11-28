# Projeto IEEE 754 — Exploração (Adder/Subtractor/Multiplier/Divider)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

Este projeto agrega operações básicas de ponto flutuante (precisão simples, 32 bits) em três estilos de descrição HDL — *Behavioral*, *Dataflow* e *Structural* — visando estudo comparativo entre legibilidade, controle de síntese e modularidade. O mesmo conjunto de testes é aplicado no *testbench* para todas as implementações.

---

## 4.2 Análise das Abordagens

### 4.2.1 Behavioral
A versão *Behavioral* implementa as quatro operações dentro de um único `always @(*)` usando um multiplexador de operações (`op_sel`). Os campos IEEE 754 são decompostos (sinal, expoente, mantissa com bit implícito) e a operação é descrita em termos de deslocamentos e aritmética inteira.  
**Soma/Subtração:** as mantissas são alinhadas pelo maior expoente; depois somamos/subtraímos e normalizamos (se `carry`, desloca à direita e incrementa o expoente; se *leading zeros*, desloca à esquerda e decrementa).  
**Multiplicação:** multiplicamos `24×24` (com o 1 implícito), somamos expoentes retirando o *bias* (127) e normalizamos com base em `p[47]`.  
**Divisão:** executamos `(mant_a << 23)/mant_b` para manter precisão, recompondo o expoente por `exp_a − exp_b + 127` e normalizando.  
**Vantagens:** rapidez de escrita, facilidade de prototipagem e de instrumentação com `if/while`. **Limitações:** maior risco de inferência de *latches* se faltarem atribuições, e menor previsibilidade de área/tempo — o sintetizador pode alocar *shifters* largos e *dividers* custosos. **Boas práticas:** garantir atribuições totais dentro de cada caso, isolar normalização em funções/tarefas, e limitar *loops* a contagens pequenas (aqui, 24–48 iterações máximas), aceitas por ferramentas modernas.  
**Exemplo numérico:** 4,75 (0 10000001 0011…) + 2,125 (0 10000000 0001…) → alinhamento de `2,125` em 1 bit, soma de mantissas = `1.0011 + 0.10001 = 1.10111₂`, `carry`=0; expoente final = 129; mantissa 23 bits = `101110000…`.

### 4.2.2 Dataflow
A variante *Dataflow* compõe o resultado por expressões e instâncias diretas de submódulos (`ieee754_adder`, `ieee754_subtractor`, `ieee754_multiplier`, `ieee754_divider`), todos descritos de forma compacta e combinacional. O arquivo permanece **auto‑contido** pois os submódulos estão incluídos no próprio `ieee754_exploracao.v`.  
**Vantagens:** alta clareza do caminho de dados; fácil troca de implementações (por exemplo, substituir o *divider* por um Newton‑Raphson *pipelined*). **Limitações:** o controle de latência é reduzido — como os blocos são combinacionais, uma única etapa pode ficar crítica (particularmente o divisor). **Boas práticas:** evoluir para versões *pipelined* quando a frequência alvo exigir; congelar interfaces (record types) para favorecer reuso.  
**Comparação com Behavioral:** *Dataflow* separa o que é *o que* (blocos) do *como* (seu conteúdo). Em síntese, ambos geram lógica semelhante para este nível, mas o *Dataflow* incentiva modularidade e verificação por bloco.

### 4.2.3 Structural
A abordagem *Structural* é próxima do *Dataflow*, porém enfatiza a conexão explícita e a hierarquia do sistema (instâncias nomeadas, fios internos dedicados). É a base natural para **pipelining** e **reuso IP**. **Vantagens:** previsibilidade e reconfiguração arquitetural — por exemplo, trocar apenas `divider_inst` por uma versão iterativa; fácil integração a barramentos e controle externo. **Limitações:** verbosidade inicial e necessidade de disciplina de nomes/sinais. **Riscos de síntese:** fan‑out elevado em sinais de controle e caminhos combinacionais longos se encadearmos operações; mitigue com *register balancing* e cortes de pipeline.  
**Resumo comparativo:** *Behavioral* = velocidade de escrita; *Dataflow* = clareza de dados; *Structural* = escalabilidade/hierarquia. Em projetos maiores, usa‑se *Structural* com submódulos *Dataflow* e miolo *Behavioral* por operação.

---

## 4.3 Descrição do Testbench

O `tb_ieee754_exploracao` aplica vetores clássicos do material didático — {{4,75; 2,125}} e {{9,5; 3,75}} — em **todas** as operações. A temporização é puramente combinacional, logo utilizamos atrasos `#10` para observar a estabilização.  
**Metodologia:**  
1. **Inicialização/VCD.** O bloco `initial` gera `wave.vcd` com `$dumpfile/$dumpvars` no escopo do TB, habilitando análise em GTKWave/Questa.  
2. **Estímulos e varredura.** Mantemos `a`/`b` fixos e alternamos `op_sel` em sequência (00, 01, 10, 11) para comparar, no mesmo *setup*, os resultados de soma, subtração, multiplicação e divisão. Em seguida mudamos o par de entradas e repetimos o ciclo; isso facilita checagem cruzada visual das ondas.  
3. **Observáveis.** O *task* `show()` imprime `S/E/M` (sinal, expoente, mantissa). A comparação com expectativas numéricas pode ser feita lendo as ondas e aplicando um conversor IEEE754→float no pós‑processamento, ou adicionando um *golden model* em SystemVerilog DPI/PLI (fora do escopo aqui).  
**Boas práticas de verificação:** adotar *self‑checking* — por exemplo, comparar `result` contra literais IEEE754 calculados off‑line e sinalizar `$error` quando divergirem; incluir vetores de borda (zero, denormal, overflow, underflow, NaN, ±Inf).  
**Riscos e mitigação:** diferenças de normalização entre operadores (principalmente divisão) podem introduzir *off‑by‑one* no expoente; monitore `result[30:23]` e *leading bits* do produto/quociente. A ausência de sinais de exceção na interface é deliberada (modelo didático); em projetos reais, adicione *flags* (NV, DZ, OF, UF, NX).

---

## 4.4 Aplicações Práticas

**Processadores e ALUs de ponto flutuante.** A estrutura aqui mostrada corresponde ao núcleo funcional de uma FPU escalar. Em aplicações embarcadas com requisitos moderados de *throughput*, a versão combinacional atende; para DSP/ML em FPGA/ASIC, é comum introduzir *pipelining* (por exemplo, 3 estágios no multiplicador: *align*, *mul*, *normalize*).  
**Exemplo numérico:** multiplicação `9,5 × 3,75` → expoentes 130 e 129; soma sem *bias* = 132; produto das mantissas (1,0011₂ × 1,1110₂) ≈ 11,1100011₂; normalização desloca uma casa, exponte final 133 (ou 132+carry), mantissa truncada a 23 bits.  
**Sinalização de exceções.** Em sistemas financeiros e científicos, *flags* determinam o tratamento de `NaN` e saturação em ±∞. O design modular permite anexar um *pre‑post processor* que detecta padrões especiais (exp=255, mant≠0 ⇒ NaN; exp=0 e mant=0 ⇒ zero; exp=255 e mant=0 ⇒ infinito).  
**Integração em pipelines.** No estilo *Structural*, cada operador vira um estágio; controladores upstream emitem `op_sel` e *valids*. A divisão pode ser substituída por algoritmo iterativo (restoring/non‑restoring, Goldschmidt, Newton‑Raphson) para reduzir área, mantendo a mesma interface.  
**Boas práticas de síntese:** registrar fronteiras entre operadores, inserir *clock enables* e permitir *retiming*. Parametrizar a largura (ex.: extender para *double*) é direto ao replicar campos e ajustar o *bias*.  
**Limitações do protótipo:** não tratamos denormais/rounding modes/flags e assumimos operandos positivos na parte aritmética simplificada; a precisão é suficiente para ensino, mas não conformante integralmente ao IEEE 754. Para uso real, acrescente arredondamento (*Round to Nearest Even*), empacotamento/ desempacotamento completo e tratamento de *sticky bits*.

---

## Como simular (Questa)
1. Entre em `Questa/scripts` e ajuste `compile.do` se quiser trocar a implementação: `set IMPLEMENTATION behavioral|dataflow|structural`.
2. Rode `do run_gui.do` (GUI) ou `do run_cli.do` (modo console).
3. Abra `wave.vcd`/`vsim.wlf` para inspeção das formas de onda.

## Estrutura
```
Quartus/rtl/<implementation>/ieee754_exploracao.v
Questa/rtl/<implementation>/ieee754_exploracao.v
Questa/tb/tb_ieee754_exploracao.v
Questa/scripts/*.do
```
