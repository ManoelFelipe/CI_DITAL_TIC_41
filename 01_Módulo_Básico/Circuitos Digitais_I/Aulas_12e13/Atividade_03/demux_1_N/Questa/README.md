# Demultiplexador 1×N Parametrizável (Verilog 2001)

**Autor:** Manoel Furtado  
**Data:** 31/10/2025  
**Ferramentas:** Quartus / Questa (ModelSim)

## Visão Geral
Este projeto implementa um *demultiplexador 1×N parametrizável* em três estilos de descrição: **Comportamental**, **Fluxo de Dados** e **Estrutural**, além de um *testbench* comum e *scripts* para simulação no Questa/ModelSim.

O parâmetro `N` define o número de saídas (padrão `N=8`). A largura do seletor é calculada por uma função `clog2` compatível com Verilog 2001.

## Estrutura de Pastas
```
Quartus/
  └─ rtl/
     ├─ behavioral/demux_1_N.v
     ├─ dataflow/demux_1_N.v
     └─ structural/demux_1_N.v

Questa/
  ├─ rtl/ (cópias dos três arquivos acima)
  ├─ tb/
  │  └─ tb_demux_1_N.v
  ├─ scripts/
  │  ├─ clean.do
  │  ├─ compile.do   (ajuste IMPLEMENTATION=behavioral|dataflow|structural)
  │  ├─ run_cli.do
  │  └─ run_gui.do
  └─ README.md (este arquivo)
```

## Como Rodar no Questa
1. Abra o **Questa/ModelSim** na pasta `Questa/scripts`.
2. **GUI:** `do run_gui.do` (limpa, compila e roda; não força sair).
3. **Console:** `do run_cli.do` (modo `-c`).  
4. O *waveform* é salvo em `wave.vcd` e o transcript mostra as checagens via `$display`.

> **Dica:** No `compile.do`, altere `IMPLEMENTATION` entre `behavioral`, `dataflow` e `structural` para escolher qual RTL será compilada.

## Explicações por Estilo
**Comportamental:** A lógica é descrita em um `always @*`. Todas as saídas são zeradas e, se `din=1`, apenas `y[sel]` recebe `1`. Este estilo evidencia a intenção do hardware e é adequado para leitura e verificação rápidas.

**Fluxo de Dados:** Usa atribuição contínua para construir a máscara `1 << sel` limitada a `N` bits; quando `din=0`, a saída é forçada a zero. É sucinto, diretivo e enfatiza a *função* do circuito como expressão booleana/aritmética sobre vetores.

**Estrutural:** Decompõe o circuito em blocos: um comparador `eq_const` (implementado por rede de XNOR + AND de redução) detecta `sel==i` para cada linha, e uma porta `and2` combina esse *hit* com `din`. Um `generate` instancia `N` ramos idênticos, aproximando-se do arranjo físico real.

## Testbench e Resultados
O *testbench* (`tb_demux_1_N.v`) instancia as três variantes com o mesmo `N` e aplica dois conjuntos de testes:
1. **`din=0`:** varre `sel` de `0..N-1` e verifica que **todas as saídas permanecem `0`**.
2. **`din=1`:** varre `sel` e valida que o padrão gerado é **uma hot-line** (apenas um bit em `1`), igual a `(1'b1 << sel)` em cada abordagem.

As mensagens `$display` mostram tempo, `sel`, `din` e as três saídas. O arquivo `wave.vcd` permite observar facilmente a comutação da *hot-line* no visualizador de formas de onda.

## Aplicações Práticas
Demultiplexadores 1×N são onipresentes em sistemas digitais. Exemplos:
- **Roteamento de dados** em barramentos (habilitar apenas um registrador/dispositivo por vez).
- **Endereçamento de memória/IO** (decodificar endereço para selecionar um *slave*).
- **Controle de LEDs/Displays** por *scanning* (ativando uma coluna/linha específica).
- **Sistemas de comunicação** para comutação de trilhas entre módulos produtores e consumidores.
- **Máquinas de estado** para ativar blocos distintos conforme o estado (seletor como estado).

A parametrização em `N` facilita o reuso do mesmo código em designs que exigem diferentes larguras sem modificar a arquitetura.

## Observações de Compatibilidade
- Todo o código segue **Verilog 2001**. A função `clog2` evita depender de `$clog2` (SystemVerilog).
- Testado em fluxo padrão do **Questa**; o **Quartus** aceita os mesmos arquivos de RTL.
- Use `N` como potência de 2 para seleção uniforme; valores não-potência de 2 são suportados, porém alguns códigos de `sel` se tornam inválidos e simplesmente **não** produzirão hot-line (padrão permanece 0).

---

**Licença & Autor**: Manoel Furtado, 31/10/2025. Uso acadêmico/didático.
