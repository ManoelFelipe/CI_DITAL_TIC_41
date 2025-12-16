# Projeto_regfile8x16c — Banco de Registradores 8×16 (1W / 2R)

**Autor:** Manoel Furtado  
**Data:** 2025-12-15  
**Compatibilidade:** Quartus e Questa/ModelSim (Verilog‑2001)

Este repositório implementa um banco de registradores 8×16 bits com 1 porta de escrita e
2 portas de leitura. A entrega inclui três implementações (Behavioral, Dataflow e Structural),
um testbench único que testa as três simultaneamente, e scripts `.do` para o Questa.

---

## 5.1 Descrição do Projeto

A interface do módulo possui `clk` e `reset` (reset síncrono), `write`, `wr_addr[2:0]` e
`wr_data[15:0]`. Existem duas portas de leitura independentes:
`rd_addr_a[2:0] → rd_data_a[15:0]` e `rd_addr_b[2:0] → rd_data_b[15:0]`.

Regras funcionais:

- Na borda de subida do clock, se `reset=1`, todos os 8 registradores são zerados.
- Na borda de subida do clock, se `reset=0` e `write=1`, o registrador selecionado por
  `wr_addr` recebe `wr_data`.
- As leituras são assíncronas (combinacionais): qualquer alteração em `rd_addr_a` ou
  `rd_addr_b` altera imediatamente as saídas, sem necessidade de clock.

Em hardware, o bloco equivale a 8 registradores de 16 bits (flip‑flops) e dois muxes 8→1
(um por porta de leitura). A escrita pode ser modelada como um barramento `wr_data` comum
a todos os registradores, habilitado por um sinal one‑hot gerado por um decodificador 3→8.
Para 8×16, a implementação em LUTs + FFs em FPGA é natural e de baixo custo.

---

## 5.2 Análise das Abordagens

### Implementação Behavioral

A implementação Behavioral descreve o banco como um array `reg [15:0] regfile [0:7]`,
com escrita síncrona e leituras por indexação do array. O código fica curto e direto:
o endereço de leitura seleciona a palavra, e o endereço de escrita seleciona a posição a ser
atualizada na borda de clock.

Vantagens:
- Alta legibilidade e baixo número de linhas.
- Ótima para prototipação e para exercícios, pois reduz boilerplate.
- Em síntese, normalmente gera a mesma estrutura de FFs + mux que as outras abordagens
  para bancos pequenos.

Riscos/atenções:
- Leituras assíncronas podem apresentar glitches quando o endereço muda, pois a rede de
  mux pode ter atrasos diferentes por caminho. Em geral, isso é resolvido registrando as
  saídas ou garantindo que o consumidor só amostre na borda de clock.
- Em designs grandes, alguns estilos com arrays podem levar a inferência de memória
  distribuída, o que pode ser desejado ou não dependendo do objetivo de área/timing.

### Implementação Dataflow

A implementação Dataflow explicita a rede: um decodificador one‑hot gera `we_dec[7:0]`
a partir de `wr_addr` quando `write=1`. Cada registrador `r0..r7` é escrito apenas se seu
enable estiver ativo. Para leitura, usam-se multiplexadores combinacionais descritos com
`case` (um para A e um para B).

Vantagens:
- Ajuda a enxergar claramente “decodificador + registradores + muxes”.
- Depuração por waveform fica mais fácil, porque o enable one‑hot mostra exatamente
  qual registrador deveria escrever em cada ciclo.
- Blocos combinacionais completos com `case/default` evitam latches e melhoram a robustez
  contra X em simulação.

Limitações:
- Código mais verboso; para bancos maiores, a manutenção manual cresce bastante.
- O caminho combinacional do mux ainda existe; se a saída alimentar muita lógica no mesmo
  ciclo, pode virar caminho crítico. Estratégias típicas: registrar saídas, reduzir fan‑out,
  ou adotar leitura síncrona quando permitido.

### Implementação Structural

A implementação Structural monta o banco a partir de submódulos:
- `reg16_en`: registrador de 16 bits com reset síncrono e enable.
- `dec3to8`: decodificador 3→8 que gera os enables one‑hot.
- `mux8_16`: mux 8→1 de 16 bits.

Vantagens:
- Modularidade e reuso: os submódulos podem ser reaproveitados em outros projetos.
- Facilita evolução: é simples inserir proteção de escrita, máscara de bits, paridade,
  ou trocar o mux por outra estrutura.
- O código se aproxima de um diagrama de blocos, fortalecendo o entendimento do hardware.

Atenções:
- Mais arquivos e hierarquia; exige disciplina de nomenclatura.
- Módulos combinacionais precisam ser completos (com `default`) para evitar latches.
- A síntese em FPGA geralmente otimiza/achata hierarquia, então a diferença de área para
  este exercício tende a ser pequena.

---

## 5.3 Descrição do Testbench

O testbench (`Questa/tb/tb_regfile8x16c`) é determinístico e instância as três DUTs ao
mesmo tempo. Para isso, no diretório `Questa/rtl` cada implementação foi salva com um nome
de módulo diferente (`regfile8x16c_beh`, `regfile8x16c_dat`, `regfile8x16c_str`), mantendo
a mesma interface. Assim, o TB aplica os mesmos sinais a todas e compara resultados.

Metodologia:

1) Geração de clock com período de 10 ns (`forever #5 clk = ~clk;`).

2) Reset síncrono alinhado ao clock. Após o reset, o TB valida que leituras em A e B
retornam zero (scoreboard inicializado com zero).

3) Escrita em todos os registradores (um por ciclo). O padrão de dados é determinístico:
`wr_data = (addr * 16'h1111) ^ 16'h00F0`. O TB atualiza o scoreboard exatamente no `posedge`.

4) Leitura em direções opostas (pedido do exercício): A lê 0→7 e B lê 7→0. A cada passo,
o TB imprime uma tabela baseada na saída Behavioral (para visualização) e executa checagens.

5) Cobertura extra: 16 sobrescritas determinísticas em endereços `(i*3) mod 8`, seguidas
de leituras cruzadas, aumentando a chance de detectar erros de enable, mux e reset.

Checagem automática:
- Em cada teste, o TB verifica se as saídas das três implementações são idênticas.
- Em seguida, compara contra o valor esperado do scoreboard.
- Ao final, imprime a mensagem exigida:
  `"SUCESSO: Todas as implementacoes estao consistentes em %0d testes."`

O TB também gera `wave.vcd` com `$dumpfile/$dumpvars` e encerra com `$finish`.

---

## 5.4 Aplicações Práticas

Um register file 2R1W é um bloco central em processadores e datapaths: duas leituras
permitem obter dois operandos no mesmo ciclo e a escrita registra o resultado em um ciclo
posterior. Mesmo sendo 8×16, a estrutura é a mesma usada em bancos 32×32 ou 64×64; o que
muda é a escala e, em projetos maiores, a forma de implementação (replicação, RAM interna,
ou multiport dedicado, quando disponível).

Também é comum usar pequenos bancos como “arquivo de configuração” em periféricos:
timers, UARTs, controladores SPI e ADCs expõem registradores de controle/status. Internamente,
um regfile simplifica o roteamento de sinais e o endereçamento. Exemplo: um timer pode manter
`PRESC=10` e `COMPARE=1000` em registradores, e a lógica interna usa esses valores para
gerar eventos periódicos, enquanto o firmware atualiza parâmetros pela porta de escrita.

Em sistemas de controle/DSP, um banco pequeno pode guardar coeficientes e offsets
(calibração). Um bloco pode ler `gain` e `offset` simultaneamente e aplicar
`y = x*gain + offset`, enquanto o firmware atualiza coeficientes em tempo de execução.
Como as leituras são combinacionais, é boa prática registrar a leitura antes de operações
sensíveis ou garantir estabilidade do endereço durante a janela de cálculo.

Por fim, a comparação das três abordagens tem valor prático. Behavioral favorece rapidez e
simplicidade. Dataflow favorece transparência da rede e depuração. Structural favorece reuso,
organização e evolução modular. O testbench único comparativo é uma técnica sólida para
garantir equivalência funcional durante refatorações e para aumentar confiança no resultado.
