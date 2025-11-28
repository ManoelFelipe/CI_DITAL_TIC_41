
# Projeto: Multiplicador Qm.n (ponto_fixo_multi_8)

**Autor:** Manoel Furtado  
**Data:** 10/11/2025

## Objetivo
Implementar um multiplicador **parametrizável** de ponto fixo (formato Qm.n) em três abordagens de Verilog (**behavioral**, **dataflow** e **structural**) com **testbench** e **scripts** para o **Questa**. Por padrão, utiliza-se **N=8** e **NFRAC=3** (Q5.3).

## Arquitetura e Escalonamento
A multiplicação é realizada como produto inteiro (`a*b`). Em Qm.n, o produto tem **2n bits fracionários**. Para retornar ao mesmo formato dos operandos, aplica-se **arredondamento** (+2^(n-1)) seguido de **deslocamento à direita de n** posições. O resultado reduzido para N bits recebe **saturação opcional** (padrão: ligada).

- Entradas: `a[7:0]`, `b[7:0]` (**Q5.3**).
- Saídas: `p_raw[15:0]` (**Q10.6**) e `p_qm_n[7:0]` (Q5.3 reescalado).
- `overflow`: indica que houve saturação ao reduzir para `N` bits.

## Abordagens
- **Behavioral:** usa operadores aritméticos e lógica de reescala em `always @*`.
- **Dataflow:** usa `assign` contínuo para todo o caminho de dados.
- **Structural:** array multiplier (somas de parciais) + somadores ripple.

## Testbench
Arquivo `Questa/tb/tb_ponto_fixo_multi_8.v`.  
Cobre vetores **dirigidos** (7.5=00111_100, 7.125=00111_001, 2.25=00010_010) e **varredura** reduzida. Gera `wave.vcd`.

### Como rodar (Questa)
```tcl
cd Questa/scripts
vsim -do run_gui.do
# ou modo não interativo:
vsim -c -do run_cli.do
```

## Pergunta teórica
> O circuito é capaz de multiplicar números em formato **Q3.5**?

**Sim, desde que o parâmetro `NFRAC` seja ajustado para 5.**  
O hardware opera sobre inteiros; o que muda é a posição do ponto binário. Com `N=8` e `NFRAC=5`, o produto terá **Q6.10** (ainda 16 bits). A implementação fornecida já instancia um DUT extra com `NFRAC=5` no testbench para demonstrar isso. Se `NFRAC` permanecer 3, o produto ainda será matematicamente correto enquanto inteiro, mas **será interpretado** como Q5.3 e não como Q3.5 (ou seja, a escala estará errada).

## Aplicações
- DSP de baixa complexidade, controle digital, sistemas embarcados, filtros FIR/IIR com coeficientes em ponto fixo.
- Unidades aritméticas em microcontroladores softcore e aceleradores específicos.

## Estrutura
```
Projeto_ponto_fixo_multi_8/
 ├── README.md
 ├── Quartus/rtl/{behavioral,dataflow,structural}/ponto_fixo_multi_8.v
 └── Questa/
      ├── rtl/{behavioral,dataflow,structural}/ponto_fixo_multi_8.v
      ├── tb/tb_ponto_fixo_multi_8.v
      └── scripts/{clean.do,compile.do,run_cli.do,run_gui.do}
```
