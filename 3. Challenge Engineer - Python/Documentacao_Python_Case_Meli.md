# Etapas Principais:
## 1.	Coleta de Dados:
-	Utilização das APIs do MercadoLivreAR para buscar itens com termos específicos.
-	Realização de `requests` para obter detalhes de cada item usando seus IDs.
## 2.	Processamento de Dados:
-	Normalização dos dados JSON recebidos das respostas da API.
-	Armazenamento dos dados relevantes em um arquivo CSV.
## 3.	Análise Exploratória:
-	Leitura do arquivo CSV em um DataFrame do pandas.
-	Análise descritiva e exploratória dos dados.
-	Remoção de outliers usando o método IQR.
-	Categorização e visualização de variáveis.
## 4.	Visualização e Relatórios:
-	Criação de gráficos, tabelas e visualizações para entender a distribuição dos dados.
# Componentes:
## 1.	API do MercadoLibre:
Endpoints utilizados:
-	https://api.mercadolibre.com/sites/MLA/search?q={termo}&limit=50
-	https://api.mercadolibre.com/items/{Item_Id}
## 2.	Python e Bibliotecas:
-	pandas para manipulação de dados.
-	matplotlib para visualizações gráficas.
-	requests para chamadas API.
## 3.	Arquivo CSV:
-	Armazenamento dos dados coletados de itens.
## 4.	Jupyter Notebook:
-	Ambiente para realização da análise exploratória e visualização de dados.
# Diagrama da Solução:
![Diagrama](https://github.com/BobMarques/case-meli/blob/main/3.%20Challenge%20Engineer%20-%20Python/DiagramaChallengePython.png)
