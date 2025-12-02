# Controlador de Laser Temporizado (Verilog)

Este repositório contém duas implementações de um controlador de laser que ativa uma saída por exatamente 3 ciclos de clock após o acionamento de um botão.

## Estrutura do Projeto

*   `moore_laser.v`: Implementação usando Máquina de Moore.
*   `mealy_laser.v`: Implementação usando Máquina de Mealy.
*   `tb_moore_laser.v`: Testbench para a versão Moore.
*   `tb_mealy_laser.v`: Testbench para a versão Mealy.

## Diferenças entre as Implementações

### 1. Máquina de Moore (`moore_laser.v`)
*   **Conceito**: A saída depende **apenas** do estado atual.
*   **Estados**: 4 estados (`Des`, `Lig1`, `Lig2`, `Lig3`).
*   **Comportamento**: A mudança na saída ocorre sincronizada com a borda do clock (quando o estado muda).
*   **Vantagem**: Saída mais estável (livre de glitches combinacionais da entrada), pois vem de registros de estado.
*   **Desvantagem**: Reage um ciclo de clock "atrasado" em relação à entrada se comparado ao Mealy (a menos que o design compense), e geralmente usa mais estados.

### 2. Máquina de Mealy (`mealy_laser.v`)
*   **Conceito**: A saída depende do estado atual **E** da entrada atual.
*   **Estados**: 3 estados (`Idle`, `S1`, `S2`).
*   **Comportamento**: A saída pode mudar imediatamente quando a entrada muda (assíncrono dentro do ciclo), antes mesmo da borda do clock.
*   **Vantagem**: Reação mais rápida (no mesmo ciclo) e geralmente usa menos estados.
*   **Desvantagem**: A saída pode ter "glitches" se a entrada tiver ruído, pois há um caminho combinacional direto da entrada para a saída.

## Como Simular

Se você tiver o `iverilog` (Icarus Verilog) instalado:

**Moore:**
```bash
iverilog -o moore_test tb_moore_laser.v moore_laser.v
vvp moore_test
gtkwave moore_wave.vcd
```

**Mealy:**
```bash
iverilog -o mealy_test tb_mealy_laser.v mealy_laser.v
vvp mealy_test
gtkwave mealy_wave.vcd

```

Para visualizar as ondas, abra os arquivos `.vcd` gerados (ex: `moore_wave.vcd`) no GTKWave.
