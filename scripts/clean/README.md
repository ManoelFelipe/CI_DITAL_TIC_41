# 🧹 Clean Script — Documentação Completa

Este projeto inclui um script avançado de limpeza para remover arquivos temporários gerados por:

- **Quartus Prime**
- **ModelSim / QuestaSim**
- **Python**
- Arquivos de cache e build

Ele mantém seu repositório limpo e alinhado ao `.gitignore`, garantindo que nenhuma sujeira acabe indo para o Git.

---

# 📌 Como usar o `clean.py`

O script pode ser executado diretamente com Python:

```bash
python scripts/clean/clean.py
```
|
Quando executado sem argumentos, ele:

- Varre automaticamente a **raiz do repositório**
- Detecta arquivos temporários
- Pergunta confirmação antes de apagar

---

# ⚙️ Argumentos disponíveis

## 🔍 1. **Modo de simulação (dry-run)**  
Mostra tudo o que *seria* apagado, mas **não apaga nada**:

```bash
python scripts/clean.py --dry-run
```

---

## ⚠️ 2. **Sem confirmação (perigoso, mas útil para automação)**

Apaga tudo sem perguntar:

```bash
python scripts/clean.py --no-confirm
```

---

## 📢 3. **Modo verboso**

Mostra cada arquivo apagado:

```bash
python scripts/clean.py --verbose
```

---

## 📁 4. **Definir manualmente a raiz do projeto**

```bash
python scripts/clean.py --root "D:/GitHub/Meu_Projeto"
```

---

# 🛠 Arquitetura do script

O `clean.py` funciona em 4 etapas:

1. Identifica a raiz do projeto  
2. Carrega configurações internas + opcionais via `clean_config.json`
3. Varre recursivamente TODAS as pastas
4. Remove arquivos temporários e pastas de build

---

# 🧩 `clean_config.json` — Configuração opcional

Você pode criar na pasta `scripts/` um arquivo:

```
scripts/
    ├──clean/
        ├── clean.py
        └── clean_config.json
```

### Exemplo pronto:

```json
{
    "extensions_to_delete": [
        ".tmp",
        ".log"
    ],
    "protected_extensions": [
        ".qpf",
        ".qsf"
    ],
    "folders_to_delete": [
        "work",
        "output_files",
        "__pycache__"
    ],
    "skip_dirs": [
        ".git",
        ".venv"
    ]
}
```

---

# 📘 O que cada campo significa?

### `extensions_to_delete`
Lista de extensões que serão removidas automaticamente.

### `protected_extensions`
Extensões que **nunca** devem ser apagadas  
(ex.: arquivos essenciais do Quartus).

### `folders_to_delete`
Pastas que podem ser excluídas por completo.

### `skip_dirs`
Pastas que não devem ser percorridas.

---

# 🎯 Benefícios

- Evita sujeira no Git  
- Mantém o projeto sempre limpo  
- Funciona em QUALQUER estrutura de pastas  
- Pode ser totalmente personalizado

---

# 💬 Dúvidas ou melhorias?

Posso ajudar a criar:
- Versão GUI (interface gráfica)
- Versão que integra direto ao VS Code
- Versão com logs automáticos

Só pedir! 😊
