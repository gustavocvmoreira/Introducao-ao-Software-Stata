********************************************************************************
********************************************************************************
* Curso de Introdução ao STATA *
* Prof. Gustavo Moreira
* Esalq / USP
********************************************************************************
********************************************************************************
 
 *Tópico: Importando dados da PNAD
 
*Definindo o diretório de trabalho
cd "C:\Users\gusta\OneDrive\1 Esalq\Curso Stata\PNAD"

*Importando os dados com o comando infix* 
infix ano 1-4 trimestre 5-5 uf 6-7 urb 33-33 sexo 95-95 idade 104-106 ///
raca 107-107 rendimento 200-207 horastrab 462-464 ///
anosest 406-407 peso 50-64 using "PNADC_012023.txt", clear

*Fazendo algumas manipulações nos dados apenas para praticar:

*Criando variável homem
gen homem = 1 if sexo==1
replace homem=0 if sexo==2
tab homem

*Ubano/rural
g urbano = 1 if urb == 1
replace urbano = 0 if urb==2
tab urbano 

*Regiões
gen regiao=.
replace regiao = 1 if uf==50|uf==51|uf==52|uf==53 //CO
replace regiao = 2 if uf==31|uf==32|uf==33|uf==35 // SE
replace regiao = 3 if uf==11|uf==12|uf==13|uf==14|uf==15|uf==16|uf==17 //N
replace regiao = 4 if uf >=41 & uf <=43 // S
replace regiao = 5 if uf >=21 & uf <=29 // NE

*Nomeando as variáveis de regiao
la var regiao "Região"
label define regiao 1 "Centro-oeste" 2 "Sudeste" 3 "Norte" 4 "Sul" 5 "Nordeste"
label values regiao regiao
tab regiao

* O uso de pesos amostrais na PNAD
* A PNAD é uma pesquisa amostral e precisamos contabilizar o peso das observações
* Indivíduos para obtermos a representatividade da população

*Exemplo:
ta regiao [iw=peso]

*Estatísticas com e sem peso são distintas. Veja:
sum idade // sem considerar pesos
sum idade [iw=peso] // considerando pesos amostrais

save pnad_2023_01, replace

********************************************************************************
********************************************************************************
** Empilhando PNADs
********************************************************************************
********************************************************************************

*Importando os dados com o comando infix* 
infix ano 1-4 trimestre 5-5 uf 6-7 urb 33-33 sexo 95-95 idade 104-106 ///
raca 107-107 rendimento 200-207 horastrab 462-464 ///
anosest 406-407 peso 50-64 using "PNADC_022023.txt", clear

*Fazendo algumas manipulações nos dados apenas para praticar:

*Criando variável homem
gen homem = 1 if sexo==1
replace homem=0 if sexo==2
tab homem

*Ubano/rural
g urbano = 1 if urb == 1
replace urbano = 0 if urb==2
tab urbano 

*Regiões
la drop regiao
gen regiao=.
replace regiao = 1 if uf==50|uf==51|uf==52|uf==53 //CO
replace regiao = 2 if uf==31|uf==32|uf==33|uf==35 // SE
replace regiao = 3 if uf==11|uf==12|uf==13|uf==14|uf==15|uf==16|uf==17 //N
replace regiao = 4 if uf >=41 & uf <=43 // S
replace regiao = 5 if uf >=21 & uf <=29 // NE

*Nomeando as variáveis de regiao
la var regiao "Região"
label define regiao 1 "Centro-oeste" 2 "Sudeste" 3 "Norte" 4 "Sul" 5 "Nordeste"
label values regiao regiao
tab regiao

* O uso de pesos amostrais na PNAD
* A PNAD é uma pesquisa amostral e precisamos contabilizar o peso das observações
* Indivíduos para obtermos a representatividade da população

*Exemplo:
ta regiao [iw=peso]

*Estatísticas com e sem peso são distintas. Veja:
sum idade // sem considerar pesos
sum idade [iw=peso] // considerando pesos amostrais

save pnad_2023_02, replace

********************************************************************************
********************************************************************************
** Empilhando PNADs

** Empilhando PNADs por meio do comando append (uma das bases de dados
* já deve estar carregada no Stata

append using pnad_2023_01

save pnad_empilhada, replace

*Cuidado agora no momento da obtenção das estatísticas descritivas uma vez que
* as PNADs estão empilhadas:
ta regiao [iw=peso]

*Agora, precisamos obter as estatísticas descritivas de maneira separada:
ta regiao [iw=peso] if ano==2023 & trimestre==1
ta regiao [iw=peso] if ano==2023 & trimestre==2

*Alternativamente, por meio do comando bysort:
bys trimestre ano: ta regiao [iw=peso]


********************************************************************************
*********************************#FIM*******************************************
********************************************************************************
