import os
import shutil

def limpar_diretorio():
    # Define o diretório atual onde o script está rodando
    caminho_base = os.getcwd()
    
    # Definições do que apagar
    extensoes_para_apagar = ('.ini', '.wlf', '.vcd')
    pastas_para_apagar = ['work']

    itens_para_remover = []
    
    print(f"Varrendo diretório: {caminho_base}...\n")

    # 1. ETAPA DE VARREDURA (Scan)
    # topdown=True é importante para podermos modificar a lista de diretórios durante a iteração
    for raiz, diretorios, arquivos in os.walk(caminho_base, topdown=True):
        
        # Verificar arquivos
        for arquivo in arquivos:
            if arquivo.lower().endswith(extensoes_para_apagar):
                caminho_completo = os.path.join(raiz, arquivo)
                itens_para_remover.append(('arquivo', caminho_completo))

        # Verificar pastas (modificamos a lista 'diretorios' para não entrar na pasta que será apagada)
        # Iteramos sobre uma cópia da lista (diretorios[:]) para poder remover itens da original
        for pasta in diretorios[:]:
            if pasta.lower() in pastas_para_apagar:
                caminho_completo = os.path.join(raiz, pasta)
                itens_para_remover.append(('pasta', caminho_completo))
                
                # Removemos da lista de navegação para o os.walk não tentar entrar nela
                diretorios.remove(pasta)

    # 2. RELATÓRIO E CONFIRMAÇÃO
    if not itens_para_remover:
        print("Nenhum arquivo ou pasta correspondente encontrado.")
        return

    print("--- ITENS ENCONTRADOS PARA REMOÇÃO ---")
    for tipo, item in itens_para_remover:
        print(f"[{tipo.upper()}] {item}")
    print("--------------------------------------")
    print(f"Total de itens encontrados: {len(itens_para_remover)}")
    
    confirmacao = input("\nDeseja realmente APAGAR todos esses itens permanentemente? (s/n): ")

    if confirmacao.lower() != 's':
        print("Operação cancelada. Nada foi apagado.")
        return

    # 3. ETAPA DE REMOÇÃO (Delete)
    print("\nIniciando limpeza...")
    contagem = 0
    for tipo, item in itens_para_remover:
        try:
            if tipo == 'arquivo':
                os.remove(item)
            elif tipo == 'pasta':
                shutil.rmtree(item) # Apaga a pasta e tudo que tem dentro
            print(f"Removido: {item}")
            contagem += 1
        except Exception as e:
            print(f"ERRO ao remover {item}: {e}")

    print(f"\nLimpeza concluída. {contagem} itens removidos.")

if __name__ == "__main__":
    limpar_diretorio()
    input("\nPressione Enter para sair...")