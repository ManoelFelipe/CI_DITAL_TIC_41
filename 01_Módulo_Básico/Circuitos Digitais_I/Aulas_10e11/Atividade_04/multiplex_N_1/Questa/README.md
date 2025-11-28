# Multiplexador N×1 (Verilog‑2001) — Behavioral / Dataflow / Structural

**Autor:** Manoel Furtado  
**Data:** 31/10/2025

## Objetivo
Implementar um multiplexador parametrizável Nx1 (entradas de 1 bit e 1 saída) nas três abordagens, **sem SystemVerilog**.

## Como rodar no Questa
Na pasta `Questa/scripts`:
```
do run_gui.do
```
Isso limpa, compila e abre a GUI com:
```
vsim -voptargs=+acc work.tb_multiplex_N_1
add wave -r /tb_multiplex_N_1/*
```

## Explicações


### 🔹 Código Comportamental  
No modelo comportamental, o multiplexador é descrito usando um bloco `always` sensível a todas as entradas, onde a lógica é escrita de forma descritiva, normalmente com estruturas condicionais como `case` ou `if/else`. Nesse formato, o código expressa **o que o hardware deve fazer**, e não como ele é fisicamente construído. O seletor (`sel`) define qual linha de entrada será encaminhada à saída (`dout`), e cada valor possível de `sel` corresponde a um caso dentro do `case`. Essa abordagem facilita a leitura e a modificação do código, sendo ideal para prototipagem e entendimento lógico do multiplexador N:1.

---

### 🔹 Código Dataflow  
Na abordagem dataflow, o foco é representar o comportamento do circuito através de **atribuições contínuas (`assign`)**, expressando a lógica com operadores combinacionais. Geralmente, a saída é definida diretamente como `assign dout = din[sel];`, onde `din` é tratado como um vetor indexado, permitindo que o valor da posição `sel` seja automaticamente roteado para a saída. Isso torna o código curto, elegante e fiel ao conceito funcional de fluxo de dados. Essa forma se aproxima da descrição matemática/equacional do mux, e é sintetizada de maneira eficiente pelas ferramentas de FPGA/ASIC.

---

### 🔹 Código Estrutural  
Na versão estrutural, o multiplexador é construído **instanciando módulos menores**, como multiplexadores 2:1, conectados em forma de árvore até restar apenas uma saída. Cada nível da hierarquia é controlado por um bit do seletor, permitindo escalabilidade modular do circuito. Essa abordagem representa explicitamente a arquitetura física do hardware, sendo útil quando se deseja controlar profundidade lógica, latência, consumo e organização real dos blocos. É o método mais fiel ao hardware real e o mais didático quando o objetivo é aprender como um mux é construído internamente.

---

### 🔹 Testbench e Formas de Onda  
O testbench foi projetado para simular o comportamento do multiplexador aplicando diferentes valores no vetor de entradas e variando o seletor `sel` automaticamente. A simulação usa `#delay` para escalonar os estímulos, `$display` para imprimir resultados e `$dumpfile/$dumpvars` para gerar o arquivo `.vcd`, possibilitando análise visual das formas de onda. Nas ondas, o esperado é que sempre que `sel` muda, `dout` passe a reproduzir exatamente a entrada correspondente (`din[sel]`) sem glitches após o tempo de propagação. Se `din[x]` muda, `dout` só acompanha quando `sel == x`, confirmando que o roteamento está correto.

---

### 🔹 Aplicações Práticas do Dia a Dia  
O multiplexador N:1 está presente em inúmeras aplicações reais onde é necessário selecionar um único sinal entre várias fontes. Exemplos: (1) escolha de sensores diferentes para um único conversor ADC; (2) seleção de câmera ou microfone em sistemas multimídia; (3) roteamento de dados em barramentos de CPU ou FPGA (ALU, registradores, periféricos); (4) chaveamento entre canais de comunicação (debug vs. produção); (5) painéis com múltiplas entradas HDMI/USB onde apenas uma é exibida; (6) roteamento interno em sistemas de automação industrial; (7) escolha de perfis de PWM ou lookup table em motores ou LEDs; (8) rádios SDR que escolhem qual frequência/demodulador processar. Em resumo: toda vez que existe **múltiplos sinais concorrendo por uma única saída**, existe um multiplexador.

## Aplicações
Seleção de fontes em barramentos, roteamento de sensores, DSP (bancos de coeficientes), embarcados (GPIO compartilhado) etc.
