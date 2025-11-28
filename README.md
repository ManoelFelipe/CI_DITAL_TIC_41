# Programa CI Digital – Residência em TIC 41

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)


# 👩‍💻 Manoel Furtado · CI Digital – Residência em Sistemas Digitais (UEMA)

> Repositório oficial dos estudos, simulações, relatórios e projetos desenvolvidos durante o **Programa de Desenvolvimento de Competências em Sistemas Digitais – Residência em TIC 41**, vinculado à **Universidade Estadual do Maranhão (UEMA)** e ao programa nacional **CI Digital / Softex + MCTI**.

> Aluno: Manoel Felipe Costa Furtado. \
> Matricula: 20252009299

---

### 🚧 Status do Repositório  
> **Em construção** – este espaço será atualizado continuamente ao longo da pós-graduação para registrar a evolução técnica, os experimentos e o desenvolvimento de projetos.

---

## 🎓 Sobre o Programa CI Digital – Residência em TIC 41

O **Programa de Desenvolvimento de Competências em Sistemas Digitais** (Edital Nº 177/2025-PPG/CPG/UEMA) tem como objetivo **formar especialistas em microeletrônica e circuitos integrados digitais**, com foco na indústria nacional de semicondutores, utilizando uma abordagem **fortemente prática e orientada a projetos**.

📍 **Instituição executora:** UEMA – Universidade Estadual do Maranhão  
🧠 **Modalidade:** Pós-graduação lato sensu – 18 meses – Noturno/Presencial   
⚙️ **Foco técnico:** Microeletrônica, Verilog, Síntese Lógica, RISC-V, Arquiteturas Digitais e Verificação  
📡 **Fases:**  
- **Módulo Básico** – Fundamentos e Verilog (SD100 → SD142 → SD192)  
- **Módulo Avançado** – Design e Verificação de CIs (SD202 → SD292)  
- **Residência ou IP Final** (SD302 ou SD392)

---

## 📊 Progresso da Jornada

| Etapa | Período Oficial | Status |
|------|------------------|:------:|
| **Módulo Básico (SD100 → SD192)** | 22/09/2025 → 01/03/2026 | ⬜ Em Andamento |
| **Módulo Avançado (SD202 → SD292)** | 02/03/2026 → 02/09/2026 | ⬜ Aguardando início |
| **Residência / Trabalho Final (SD302 / SD392)** | 03/09/2026 → 03/03/2027 | ⬜ Aguardando início |



---

## 🗂️ Roadmap das Disciplinas

### 🔹 **Módulo Básico**
| Código | Disciplina | Status |
|-------|-----------------------------|:------:|
| SD100 | Introdução à Microeletrônica | ✅|
| SD112 | Introdução ao Verilog | ✅ |
| SD122 | Circuitos Digitais I (Combinacionais) | ✅ |
| SD132 | Circuitos Digitais II (Sequenciais) | ⬜ |
| SD142 | Circuitos Digitais III (Interfaces e Periféricos) | ⬜ |
| SD192 | Trabalho Orientado I | ⬜ |

### 🔹 **Módulo Avançado**
| Código | Disciplina | Status |
|-------|-----------------------------|:------:|
| SD202 | Circuitos Digitais IV – Arquiteturas IA/ML | ⬜ |
| SD212 | Arquitetura de Sistemas Digitais – RISC-V | ⬜ |
| SD221 | Síntese Lógica | ⬜ |
| SD232 | Análise Estática de Timing | ⬜ |
| SD242 | Verificação de Sistemas Digitais | ⬜ |
| SD292 | Trabalho Orientado II | ⬜ |

### 🔹 **Módulo de Conclusão**
| Código | Caminho | Status |
|-------|-----------------------------|:------:|
| SD302 | Residência na Indústria | ⬜ |
| SD392 | Desenvolvimento de IP Final | ⬜ |

---

## 🚀 Habilidades que serão desenvolvidas

✔️ Verilog HDL para synth e simulação  
✔️ Projetos digitais com abordagem RTL  
✔️ Instrumentação com FPGA e ferramentas EDA  
✔️ Análise de temporização e otimização de hardware  
✔️ Montagem de testbenches e verificação funcional  
✔️ Pipeline de design → simulação → síntese  
✔️ Introdução à arquitetura RISC-V e SoCs  
✔️ Documentação técnica de nível industrial

---

## 📁 Estrutura do Repositório

```bash
.
├── 01_Módulo_Básico/       # Fundamentos e Verilog (SD100 -> SD192)
├── 02_Módulo_Avançado/     # Design e Verificação de CIs (SD202 -> SD292)
├── 03_Módulo_de_Conclusão/ # Residência ou IP Final (SD302, SD392)
├── scripts/                # Scripts utilitários (Python, automação)
├── .gitattributes          # Configurações de atributos do Git
├── .gitignore              # Arquivos ignorados (Quartus, ModelSim, etc.)
├── LICENSE                 # Licença MIT
└── README.md               # Documentação principal
```

---

## 🛠️ Ferramentas Utilizadas

*   **FPGA Design:** Intel Quartus Prime (Lite/Standard)
*   **Simulação:** ModelSim / QuestaSim
*   **Editor de Código:** VS Code (com extensões para Verilog/SystemVerilog)
*   **Linguagens:** Verilog HDL, Python (scripts auxiliares)
*   **Controle de Versão:** Git & GitHub

---

## ⚙️ Como Utilizar

### Scripts Utilitários

Este repositório contém scripts em Python para auxiliar na manutenção do projeto.

#### Limpeza de Arquivos Temporários (`clean.py`)
Para remover arquivos temporários gerados pelas ferramentas de EDA (como pastas `work`, arquivos `.vcd`, `.wlf`, etc.), execute o seguinte comando na raiz do projeto:

```bash
python scripts/clean.py
```
> **Nota:** O script solicitará confirmação antes de apagar qualquer arquivo.

---

## 📜 Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo [LICENSE](LICENSE) para mais detalhes.


