#-------------------------------------------------------------------------------
#
# PROJETO: Revisão I
#
# AUTOR: JOAO MENINGUE
#
# DATA DE CRIAÇÃO: 11/01/2025
#-------------------------------------------------------------------------------
# Questão:

# Exercício da Semana 1
# Exploratory Data Analysis of Global Income Inequality
# Contexto
# 
# A desigualdade de renda é um dos principais indicadores socioeconômicos utilizados para avaliar o desenvolvimento econômico e o bem-estar social. Economistas frequentemente investigam como a desigualdade evolui ao longo do tempo e como ela se relaciona com o nível de renda dos países.
# 
# Utilizando dados públicos do World Bank, você deverá realizar uma análise exploratória da desigualdade de renda entre países.
# 
# Objetivo do exercício
# 
# Realizar uma análise exploratória de dados (EDA) para investigar a relação entre:
#   
#   nível de renda dos países
# 
# desigualdade de renda
# 
# evolução temporal da desigualdade
# 
# A análise deve ser realizada exclusivamente em R.
# 
# Base de dados
# 
# Utilize indicadores disponíveis no World Development Indicators.
# 
# Baixe dados para todos os países disponíveis entre 2000 e 2022.
# 
# Indicadores obrigatórios:
#   
#   Indicador	Descrição
# Gini Index	medida de desigualdade
# GDP per capita	renda média
# Population	população total
# 
# Você deverá baixar os dados manualmente ou via API.
# 
# Tarefas
# 1 — Estrutura do projeto
# 
# Crie um repositório no GitHub com a seguinte estrutura:
#   
#   income-inequality-analysis
# 
# data
# raw
# clean
# 
# scripts
# 
# figures
# 
# README.md
# 
# O código deve ser organizado em scripts separados.
# 
# 2 — Limpeza e organização dos dados
# 
# Construa um script responsável por:
#   
#   Importar os datasets.
# 
# Padronizar nomes de países.
# 
# Manter apenas observações entre 2000 e 2022.
# 
# Tratar valores faltantes.
# 
# Construir um dataset final contendo:
#   
#   country
# year
# gini
# gdp_per_capita
# population
# 
# Criar uma variável adicional:
#   
#   log_gdp_per_capita
# 
# O dataset final deve ser salvo na pasta data/clean.
# 
# 3 — Análise exploratória
# 
# Realize uma análise descritiva contendo:
#   
#   Estatísticas básicas
# 
# Calcule:
#   
#   média
# 
# mediana
# 
# desvio padrão
# 
# mínimo
# 
# máximo
# 
# para:
#   
#   Gini
# 
# GDP per capita
# 
# 4 — Visualização de dados
# 
# Utilizando ggplot2, produza no mínimo três gráficos.
# 
# Os gráficos devem responder às seguintes perguntas:
#   
#   Gráfico 1
# 
# Como a desigualdade evoluiu ao longo do tempo em alguns países selecionados?
#   
#   Escolha 3 a 5 países e mostre a evolução do índice de Gini.
# 
# Gráfico 2
# 
# Existe relação entre renda e desigualdade?
#   
#   Construa um scatter plot relacionando:
#   
#   GDP per capita
# Gini index
# 
# Inclua uma linha de tendência.
# 
# Gráfico 3
# 
# Qual é o nível de desigualdade global recente?
#   
#   Construa um mapa mundial mostrando o índice de Gini em um ano recente.
# 
# Para isso utilize objetos espaciais com sf.
# 
# 5 — Regressão simples
# 
# Utilizando fixest, estime o seguinte modelo:
#   
#   Gini = β0 + β1 log(GDP per capita)
# 
# Você deverá:
#   
#   Estimar o modelo
# 
# Reportar os coeficientes
# 
# Interpretar o sinal e magnitude de β1
# 
# 6 — Interpretação econômica
# 
# Escreva um pequeno texto (5–10 linhas) respondendo:
#   
#   Existe evidência de que países mais ricos são menos desiguais?
#   
#   O padrão é consistente entre regiões?
#   
#   A relação parece forte ou fraca?
#   
#   7 — Produtos finais
# 
# Ao final da semana você deverá entregar:
#   
#   1 — Repositório GitHub
# 
# Com:
#   
#   scripts
# 
# gráficos
# 
# dataset limpo
# 
# README explicando o projeto
# 
# 2 — README
# 
# O README deve conter:
#   
#   descrição do projeto
# 
# fonte dos dados
# 
# principais gráficos
# 
# breve interpretação dos resultados
# 
# 3 — Post LinkedIn
# 
# Prepare um pequeno post apresentando:
#   
#   objetivo da análise
# 
# ferramentas utilizadas
# 
# um dos gráficos produzidos
# 
# link para o GitHub
#-------------------------------------------------------------------------------
# Ajuste do banco de dados 
#-------------------------------------------------------------------------------
#
# Pacotes

library(httr2)
library(jsonlite)
library(xml2)
library(dplyr)
library(purrr)
library(zoo)
library(psych)
library(ggplot2)
library(stargazer)
library(fixest)


# Base de dados 

base <- "https://api.worldbank.org/V2/country/all/indicator/SI.POV.GINI"

first <- request(base) |> # elaboração de uma requisição ao banco mundial no endereço de base
  req_url_query(date = "2000:2022", per_page = 20000) |> # Especificação dos dados podendo ser período, ordem e observações
  req_perform() # execução do pedido ao servidor

xml <- first |> resp_body_xml() # converte o corpo da resposta em um objeto XML que representa toda a árvore
# do documento retornado pela API

nodes <- xml_find_all(xml, ".//wb:data") #Note que aqui tomamos todas as observações 
# dentro do nó  de xml e armazenamos em nodes (6118 obs) formando um objeto xml_nodset 
# que contém todos os nós e seus subelementos (filhos)

rows <- nodes |> # Tomamos as observações dentro de nodes
  map(xml_children) |> # para cada nó <wb:data>, extraímos seus filhos (variáveis) e transformamos o conteúdo desses filhos em texto
  map(xml_text) # transformamos os filhos do nó principal em texto

cols <- xml_find_first(xml, ".//wb:data") |> # pega o primeiro nó <wb:data> e extrai os nomes de seus filhos, que correspondem às variáveis (colunas) do dataset
  xml_children() |> # toma os filhos de tudo que está dentro do nó data
  xml_name() # toma o nome desses filhos e atribui ao cols

df <- rows |> # toma a lista rows
  map(set_names, cols) |> # aplica a função set_names em rows utilizando os valores de cols
  bind_rows() # transforma a lista em rows formando um dataframe


# GDP per capita (Constant 2015 US$)


base_gdp <- "https://api.worldbank.org/V2/country/all/indicator/NY.GDP.PCAP.KD"

first_gdp <- request(base_gdp) |> # elaboração de uma requisição ao banco mundial no endereço de base
  req_url_query(date = "2000:2022", per_page = 20000) |> # Especificação dos dados podendo ser período, ordem e observações
  req_perform() # execução do pedido ao servidor

xml_gdp <- first_gdp |> resp_body_xml()

nodes_gdp <- xml_find_all(xml_gdp, ".//wb:data")

rows_gdp <- nodes_gdp |>
  map(xml_children) |>
  map(xml_text)

cols_gdp <- xml_find_first(xml_gdp, ".//wb:data") |>
  xml_children() |>
  xml_name()

df_gdp <- rows_gdp |>
  map(set_names, cols_gdp) |>
  bind_rows()
  
# Population

base_pop <- "https://api.worldbank.org/V2/country/all/indicator/SP.POP.TOTL"

first_pop <- request(base_pop) |>
  req_url_query(date = "2000:2022", per_page = 20000) |>
  req_perform()

xml_pop <- first_pop |> resp_body_xml()

nodes_pop <- xml_find_all(xml_pop, ".//wb:data")

rows_pop <- nodes_pop |>
  map(xml_children) |>
  map(xml_text)

cols_pop <- xml_find_first(xml_pop, ".//wb:data") |>
  xml_children() |>
  xml_name()

df_pop <- rows_pop |>
  map(set_names, cols_pop) |>
  bind_rows()

# O fluxo desse processo foi o estabelecimento do endereço a ser feita a requisição, estabelecimento de um requisição a ser feita
# filtragem dos dados da requisição e execução da requisição. Em seguida, foi criado o objeto xml com toda a árvore para, no passo seguinte, extrair
# o conteúdo de todos seus nós.O passo subsequente se caracteriza por, dentro de cada nó, tomar os nó filho e, em seguida,
# transformar o resultado em uma linha. Note que se trata apenas das linhas puras, sem qualquer nomenclatura, o que é ajustado 
# ao tormar-se o nome de cada uma das variáveis ao selecionar-se o primeiro no do objeto com toda a árvore, buscar no nome do primeiro
# ramo e, por fim estabelecer isso como nomes em col. Finalmente, o dataframe é criado em df ao estabelecer-se o nome das 
# colunas e empilhar-se as linhas.
# Requisição à API → Receber XML → Extrair nós → Transformar em lista → Nomear colunas → Criar dataframe.

rm(cols, cols_gdp, cols_pop, base, base_gdp, base_pop, first, first_gdp, first_pop, nodes, nodes_gdp, nodes_pop, rows, rows_gdp, rows_pop, xml, xml_gdp, xml_pop)


df <- df %>% 
  select(-indicator, -unit, -obs_status, -decimal, -countryiso3code) %>% 
  mutate(
    value = as.numeric(value),
    date = as.numeric(date)
  ) %>% 
  rename(
    gini = "value",
    ano = "date"
  ) 

df <- df[-c(1:1127),]

df <- arrange(df,
              country, ano)


df_gdp <- df_gdp %>% 
  select(-indicator, -unit, -obs_status, -decimal, -countryiso3code) %>% 
  mutate(
    value = as.numeric(value),
    date = as.numeric(date)
  ) %>% 
  rename(
    gdp = "value",
    ano = "date"
  ) 

df_gdp <- df_gdp[-c(1:1127),]

df_gdp <- arrange(df_gdp,
                  country, ano)


df_pop <- df_pop %>% 
  select(-indicator, -unit, -obs_status, -decimal, -countryiso3code) %>% 
  mutate(
    value = as.numeric(value),
    date = as.numeric(date)
  ) %>% 
  rename(
    pop = "value",
    ano = "date"
  )

df_pop <- df_pop[-c(1:1127),]

df_pop <- arrange(df_pop,
                  country, ano)

df <- merge(df, df_gdp, by = c("country", "ano"))

df <- merge(df, df_pop, by = c("country", "ano"))

rm(df_gdp, df_pop)

# Interpolação linear

df <- df %>% # Utilização de IA na quarta linha do comando
  arrange(country, ano) %>% 
  group_by(country) %>% 
  mutate(gini_imputado = na.approx(gini, x=ano, rule=2, na.rm = F),
         gdp_imputado = na.approx(gdp, x=ano, rule=2, na.rm = F),
         pop_imputado = na.approx(pop, x=ano, rule=2, na.rm = F)) %>% # o presente comando realiza a imputação linear e aplica a 
  # regra 2, ou seja, para países com os primeiros anos de análises sem informação (NA) foi tomando o valor do primeiro ano de
  # informações para preencher as lacunas
  mutate(gini_spline = na.spline(gini, x=ano, na.rm = F)) %>% # método spline, mais suave (curvas)
  ungroup()

df$gdp_log <- log(df$gdp)


#-------------------------------------------------------------------------------
# Análise exploratória
#-------------------------------------------------------------------------------

table1 <- describe(df[ , c('gini', 'gdp',"pop", "gini_imputado", "gdp_imputado", "pop_imputado", "gini_spline", "gdp_log")],fast=TRUE)

table1

mean_country <- df %>%
  group_by(country) %>%
  summarise_at(vars(-ano), funs(mean(., na.rm=TRUE))) %>% 
  ungroup() %>% 
  arrange(gini_imputado)


#-------------------------------------------------------------------------------
# Visualização de dados de dados 
#-------------------------------------------------------------------------------

# Evolução do gini no período 
mean_gini <- mean_country[c(1:5, 159:163),]

mean_gini <- mean_gini %>% 
  merge(df, by = c("country"))
base <- ggplot(mean_gini, aes(ano, gini.x, ymin = gini.x, ymax = gini.x))

p <- mean_gini %>% 
  ggplot( aes(x = ano, y = gini.x, color = country, group = country)) +
  geom_line() + 
  geom_point() +   
  theme_test() +
  labs(
    x = "Ano", 
    y = "Gini", 
    colour = "Países",
    title = "Índice de Gini",
    subtitle = "Desenvolvimento do Gini para os 5 mais desiguais e 5 mais iguais"
  )

p + scale_color_brewer(palette = "Paired")

ggsave("Gini_index_mean.png")

# Relação entre renda e desigualdade

q <- df %>% 
  ggplot( aes(x =gini , y = gdp_log)) +
  geom_point() +   
  theme_test() +
  geom_smooth(method = "lm", se = F)+
  labs(
    x = "Gini", 
    y = "GDP per capita (log)", 
    colour = "Países",
    title = "GDP X GINI",
    subtitle = "Relação entre o GDP per capita (log) e o índice de Gini"
  )

q 

ggsave("GDPxGini.png")
#-------------------------------------------------------------------------------
# Regressões simples
#-------------------------------------------------------------------------------

# Utilizando fixest, estime o seguinte modelo:
#   
#   Gini = β0 + β1 log(GDP per capita)
# 
# Você deverá:
#   
#   Estimar o modelo
# 
# Reportar os coeficientes
# 
# Interpretar o sinal e magnitude de β1

r <- feols(gdp_log~gini, data = df)

s <- feols(log(gdp_imputado)~gini_imputado, data = df)

t <- feols(gdp_log~gini_spline, data = df)

etable(r)

etable(s)

etable(t)

# O resultado demonstra a associação negativa entre o índice de gini e o logaritmo natural do
# gdp per capita, de tal forma que, no modelo em que houve imputação linear do gini, um aumento de 
# uma unidade nos valores do dito índice, que para esse estudo possui um domínio que vai de 0 a 100, 
# esta associado negativamente a uma queda no gdp per capita de 5,27%, dado que o modelo utilizando
# é o log-lin. Para o modelo sem imputação, esse resultado foi de 5,52%. Por fim, o modelo com  
# imputação por spline, o coeficiente que mensura a associação entre o índice de desigualdade e o 
# gdp per capita foi de 9,03e-5, ou seja, nulo. 

save(df, file = "Data_exe1.RData")

