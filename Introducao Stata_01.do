********************************************************************************
********************************************************************************
* Curso de Introdução ao STATA *
* Prof. Gustavo Moreira
* Esalq / USP
********************************************************************************
********************************************************************************

*Motivos para utilizar um do-file:
*---> Reprodução
*---> Automação
*---> Comunicação / compartilhamento

*Lembre-se:
*Stata é um software de padrão internacional: separador de milhar é vírgula, não ponto.
*Evite cedilhas, acentos e caracteres não ingleses para nomes das variáveis

**** UTILIZE CTRL+D PARA EXECUTAR UMA LINHA APÓS SELECIONÁ-LA POR COMPLETO

********************************************************************************
**** Módulo I - Utilizando o Stata como uma calculadora
********************************************************************************

*Soma
display 5+5
di 5+5 // O Stata consegue entender alguns apelidos

*Subtração
di 10-2

*Divisão
di 2500/50

*Exponenciação
di 5^2

*Raíz quadrada
di sqrt(25)

********************************************************************************
**** Módulo II - Aprendendo a importar algumas bases de dados
********************************************************************************

/*
O stata possui algumas bases de dados prontas que são muito úteis
para manipular exemplos, testar comandos, etc.
a maneira mais simples de importar uma base de dados pronta é através do comando 
sysuse. vamos tentar?
*/

help sysuse // Vamos pedir ajuda sobre esse comando primeiro
sysuse auto // Vamos importar uma base de dados chamada de auto
edit // Abre o editor de texto onde estao os dados

clear // limpa toda a base de dados

*E se quisermos importar alguma base de dados da nossa máquina?

/*
leitura de arquivo texto delimitado por TAB
leitura de arquivo de texto separado por espacos em branco
leitura de arquivo texto com colunas fixas
importa planilha do excel
leitura do arquivo .dta
*/

*Definindo o diretório de trabalho onde se encontra os arquivos de interesse:
* cd = change directory
cd "C:\Users\gusta\OneDrive\1 Esalq\Curso Stata"

*No stata, é possível importar bases de dados de diferentes formatos. Isso é bem 
*flexível

*Tipo de importação 1: planilha do excel

/*
O subcomando sheet indica que deve-se ler a aba Dados.
O subcomando firstrow indica que a primeira linha do arquivo contém o nome das
variáveis. A opção clear limpa a memória antes de iniciar a leitura
*/

import excel dados_idh.xlsx, sheet ("Dados") firstrow clear // Vai importar o arquivo
* dados_idh.xlsx, que está na minha pasta.

edit

*salva o arquivo com o nome poluicao (vai gerar um arquivo .dta - formato de base
*de dados do Stata). Você pode dar o nome que quiser

save idh, replace

/*O Stata só vai entender dados separados por ponto. 
Caso seus dados importados estejam com virgula, é necessário utilizar o comando:
destring variável, replace
*/

*E se o nosso separador de milhar/unidades fosse originalmente todo com vírgulas?
import excel dados_idh_virgula.xlsx, sheet ("Dados") firstrow clear

edit

*Os dados com virgula ficam em vermelho. Como contornar? Utilize o comando
* destring com a subopção dpcomma

destring idh_2021, replace dpcomma

edit // Reparem que os dados ficam em preto e não mais em vermelho, ou seja,
*o Stata vai entender agora como um número

********************************************************************************
********************************************************************************

*Tipo de importação 2: texto delimitado por TAB (arquivo em .txt)

* A opção names indica que a primeira linha do arquivo contém o nome das variáveis

insheet using dados_idh.txt, names clear

* exibe 5 primeiras observações do arquivo

list in 1/5

********************************************************************************
********************************************************************************

*Tipo de importação 3: texto separado por virgulas (.csv)

import delimited using dados_idh_csv.csv, clear

********************************************************************************
********************************************************************************

*Tipo de importação 4: texto delimitado por espaços sistematizados

*leitura de arquivo texto com colunas fixas

*Variáveis em formato caracter devem ser especificadas com a opção str. 
* Não é necessário especificar o tamanho da variável, pois essa informações 
* serão definidas pela amplitude das colunas; 

*Todas as linhas precisam ser executadas ao mesmo tempo:
infix str sigla 1-3 ///
str nome 11-48 ///
str idh_classe 49-64 ///
idh_ranking 65-74 ///
idh_2021 75-78 using dados_idh_Colunado.txt, clear

*Ordenando os dados na base por ranking (ordem crescente)
sort idh_ranking

*Ordenando agora por ordem decrescente
gsort -idh_ranking

*Ordenando as variaveis dentro da minha base de dados
order nome

*Renomeando a variável idh_2021 para idh
rename idh_2021 idh

*Desfazendo a operação: produto_int para idh
rename idh idh_2021

*Estatisticas descritivas da variavel idh
summarize idh_2021


********************************************************************************
**** Módulo III - Manipulando variáveis no Stata
********************************************************************************

* Utilizando a base de dados idh, previamente salva:
use idh, clear

*cria a variável idh_ranking*1000 
*Vamos utilizar o comando generate, ele conhece o apelido "g"

g idh_ranking_1000 = idh_ranking*1000
edit

*Vou deletar a variável criada com o comando drop

drop idh_ranking_1000

*cria a variável idh_ranking/idh_2021

g razao = idh_ranking/idh_2021 

*Deletando a variavel criada
drop razao

*************Criando variáveis categóricas

* Podemos criar categorias de valores discretos combinando os comandos 
* generate e replace com a cláusula if:

* Cria a variável grupo que será uma variável categórica de acordo com 
* o idh

g grupo=.
replace grupo=1 if idh_2021>=0.9 /* idh alto */
replace grupo=2 if idh_2021>=0.7 & idh_2021<0.9 /* idh médio */
replace grupo=3 if idh_2021<0.7 /* idh baixo */

*Deletando valores missing
drop if idh_2021 ==.

*Vamos fazer com que o nome do grupo apareça na saída do Stata (criando labels)

label values grupo
label define labeltipo 1 "alto"
label define labeltipo 2 "médio", add
label define labeltipo 3 "baixo", add
label values grupo labeltipo

*Se quiser deletar os labels definidos, aplique: "label drop labeltipo"

*tabela de frequência (tabela de contingência)
tabulate grupo

*Tabelas cruzadas - tabulate

*vamos criar mais uma variável, denominada de BRICS. 

*cria a variável binária contendo 1 para os países BRICS e 0, caso contrário.
*o elemento | significa o operador lógico "ou"

gen brics=0
replace brics =1 if sigla=="BRA"|sigla=="RUS"|sigla=="IND"| ///
sigla=="CHN"|sigla=="ZAF"

* Reparem que a variável brics é inicializada com 0 para todos os países. 
* Em seguida, atribui-se 1 caso a sigla corresponda ao Brasil, Russia, India,
* China ou África do Sul. * O caracter "|" corresponde ao operador lógico "or".

*Gera tabela de frequência cruzadas (tabela de contingencia)
tab grupo brics

* Transformando uma variável string (nome) em numérica:
* Vamos transformar a nossa variável idh_classe em uma variável numérica

encode idh_classe, g(idh_classe_numerica)


********************************************************************************
**** Módulo IV: Gráficos no Stata
********************************************************************************

*Para informações gerais de graficos no Stata, acesse:
*https://www.stata.com/features/publication-quality-graphics/

*Definindo diretótio de trabalho
cd "C:\Users\gusta\OneDrive\1 Esalq\Curso Stata"

*Vamos utilizar uma base de dados que já está no Stata para praticar:
sysuse uslifeexp, clear

**Gráficos de distribuição

kdensity le_male // Distribuição da expectativa de vida de homens brancos

twoway kdensity le_male || kdensity le_female // compara a distribuição de expectativa de vida de homens e mulheres

twoway kdensity le_male, lc(yellow) || kdensity le_female, lcolor(pink) // mudando a cor das linhas

twoway kdensity le_male, lcolor(green) || kdensity le_female, lcolor(pink) ///
title("Expectativa de vida H e M") xtitle(Idade) ytitle(Densidade) // adicionando título geral e também título para o eixo x e y

twoway kdensity le_male, lcolor(green) || kdensity le_female, lcolor(pink) ///
title("Expectativa de vida H e M") xtitle(Idade) ytitle(Densidade) ///
graphregion(color(white))  // alterando a cor azulada do fundo do Stata

twoway kdensity le_male, lcolor(green) || kdensity le_female, lcolor(pink) ///
title("Expectativa de vida H e M") xtitle(Idade) ytitle(Densidade) ///
graphregion(color(white)) ///
saving(expvida, replace) // alterando a cor azulada do fundo do Stata

graph export expvida.png, replace

****Gráficos de linha

*Gráfico expectativa de vida de homens brancos

twoway line le_wmale year, title("Expectativa de vida") ///
ytitle("Expectativa de vida - em anos") ///
xtitle("Ano") note(Fonte: Dados do Stata) ///
graphregion( color(white)) plotregion(fcolor(white)) ///
lc(red) lw(thick)

*Gráfico expectativa de vida de homens e mulheres brancos

twoway line le_wmale le_wfemale year, title("Expectativa de vida") ///
ytitle("Expectativa de vida - em anos") xtitle("Ano") ///
note(Fonte: Dados do Stata) ///
graphregion( color(white)) plotregion(fcolor(white)) lc(red blue)

*Gráfico expectativa de vida mulheres brancas e mulheres negras

twoway line le_wfemale le_bfemale year, title("Expectativa de vida") ///
ytitle("Expectativa de vida - em anos") xtitle("Ano") ///
note(Fonte: Dados do Stata) ///
graphregion(color(white)) plotregion(fcolor(white)) lc(red blue)

****Gráficos em barra
*Para mais opções de gráficos em barra, acesse:
*https://www.stata.com/manuals/g-2graphbar.pdf#g-2graphbarRemarksandexamples

*Gráfico de barras vertical que representa a expectativa de vida de mulheres brancas e negras para os anos acima de 1995

graph bar le_wfemale le_bfemale if year>=1995, over(year) ///
graphregion(color(white)) ///
plotregion(fcolor(white))

*Gráfico de barras horizontal que representa a expectativa de vida de mulheres brancas e negras para os anos acima de 1995

graph hbar le_wfemale le_bfemale if year>=1995, over(year)

*Gráfico de barras vertical com a expectativa de vida de homens e mulheres brancos e negros, no ano de 1980 e 1999

graph bar le_wfemale le_bfemale le_wmale le_bmale if year==1980|year==1999, ///
over(year) graphregion( color(white)) plotregion(fcolor(white))

*Gráficos em pizza da expectativa de vida de mulheres brancas e negras

graph pie le_wfemale le_bfemale, plabel(_all name) graphregion( color(white)) ///
plotregion(fcolor(white)) legend(on)

********************************************************************************
*********************************#FIM*******************************************
********************************************************************************
