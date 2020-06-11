# Investimentos
Uma aplicação web para carregar o arquivo disponibilizado pela página de [séries históricas](http://www.b3.com.br/pt_br/market-data-e-indices/servicos-de-dados/market-data/historico/mercado-a-vista/series-historicas/) da Bovespa e criar visões que ajudem a encontrar oportunidades. 

**Funcionalidades:**

- Rankings configuráveis por variação de dia, semana, mês, últimos 30 dias e ano
- Segmentação do ranking por volume priorizando as mais líquidas
- Gestão de carteira
- Favoritos
- Mobile first
- Links para a ação na Tradingview e na ADVFN

# Como usar no celular

No android instale o **Termux** e instale o PHP, MariaDB e o Git:

`pkg update && pkg upgrade && pkg install php mariadb git`

Baixe o projeto:
`git clone https://github.com/viniciusosousa/investimentos.git`

Depois inicialize os servidores

`php -S localhost:8080 -t /sdcard/investimentos &`
`mysql_safe &`

Ai pode digitar no navegador:

`locahost:8080`

# Carga da base da bovespa

- Faça download e carregue no banco de dados com `localhost:8080/carga.php`
- Depois do upload clique no link **carga Bovespa**
- É possive carregar a carga de dia, mes ou ano.
- Após carregar os arquivos que precisar clique em **Atualiza Cortes de preços bovespa** para criar os cálculos das variações e rankings