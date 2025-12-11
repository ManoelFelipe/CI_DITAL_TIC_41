import os
import shutil
from pathlib import Path


def limpar_diretorio():
    # === 1) Localizar raiz do projeto ===
    script_dir = Path(__file__).resolve().parent
    caminho_base = script_dir.parent

    print(f"🧹 Varredura iniciada no projeto: {caminho_base}\n")

    # === 2) EXTENSÕES E PASTAS A APAGAR ===
    extensoes_para_apagar = (
        # ModelSim / Questa
        '.ini', '.wlf', '.vcd', '.qdb', '.qdf', '.qpg',
        '.qtl', '.mpf', '.mti', '.cr.mti', '.ucdb', '.vstf',

        # Quartus
        '.rpt', '.summary', '.smsg', '.pin', '.done',
        '.jam', '.jbc', '.ekp', '.jic', '.rbf', '.sopcinfo',
        '.pof', '.sof', '.html',

        # Python / geral
        '.bak', '.pyc', '.pyo'
    )

    # Arquivos que NUNCA devem ser apagados
    extensoes_protegidas = ('.qpf', '.qsf')

    # pastas inteiras que devem ser apagadas
    pastas_para_apagar = [
        'db', 'incremental_db', 'output_files', 'simulation',
        'greybox_tmp', 'hc_output', 'work', 'cov',
    ]

    itens_para_remover = []

    # === 3) VARREDURA ===
    for raiz, diretorios, arquivos in os.walk(caminho_base, topdown=True):

        # nunca mexer na pasta .git
        if '.git' in diretorios:
            diretorios.remove('.git')

        # apagar pastas proibidas
        for pasta in diretorios[:]:
            if pasta.lower() in [p.lower() for p in pastas_para_apagar]:
                caminho_completo = os.path.join(raiz, pasta)
                itens_para_remover.append(('pasta', caminho_completo))
                diretorios.remove(pasta)

        # apagar arquivos por extensão
        for arquivo in arquivos:
            arq_lower = arquivo.lower()

            # proteger .qpf e .qsf
            if arq_lower.endswith(extensoes_protegidas):
                continue

            # apagar extensões listadas
            if arq_lower.endswith(extensoes_para_apagar):
                caminho_completo = os.path.join(raiz, arquivo)
                itens_para_remover.append(('arquivo', caminho_completo))

    # === 4) Confirmar ===
    if not itens_para_remover:
        print("Nenhum arquivo ou pasta para limpar ✨")
        return

    print("--- ITENS A REMOVER ---")
    for tipo, item in itens_para_remover:
        print(f"[{tipo.upper()}] {item}")
    print(f"Total: {len(itens_para_remover)}")
    print("-----------------------")

    confirm = input("\nDeseja apagar todos os itens? (s/n): ")
    if confirm.lower() != 's':
        print("Operação cancelada.")
        return

    # === 5) Remover ===
    print("\n🗑 Removendo arquivos...")
    count = 0
    for tipo, item in itens_para_remover:
        try:
            if tipo == 'arquivo':
                os.remove(item)
            else:
                shutil.rmtree(item)
            print(f"✔ Apagado: {item}")
            count += 1
        except Exception as e:
            print(f"ERRO removendo {item}: {e}")

    print(f"\n✨ Limpeza concluída: {count} itens removidos.")


if __name__ == "__main__":
    limpar_diretorio()
    input("\nPressione Enter para sair...")
