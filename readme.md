# Estado atual do trabalho
[Link para o PDF do artigo](readmeContent/ICCSA_2020.pdf)

[Link para o notebook do colab](readmeContent/colabNotebook.ipynb)

## Tarefas:

- Implementar versão Karma em CPU(openMP)
- Descobrir o motivo de não conseguir mais do que 1024x1024 modelSize

## [08/03] ~ [24:55] -- [27:30]
- Melhorar as duas figuras represetando a memória seguindo o padrão do paper(continuação)


## [09/03] ~ [24:55] -- [27:30]
- Melhorar as duas figuras represetando a memória seguindo o padrão do paper
- Funçao para criar os blocos na figura

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/exfig01.PNG" height="200">


## [09/03] ~ [19:00] -- [23:55]
- Geração de uma figura com as etapas do espiral para o paper

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiralImageForPaper_4x5_1200_c2.png" height="200">
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiralImageForPaper_5x12_1200_c2.png" height="200">
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiralImageForPaper_7x5_1200_c2.png" height="200">
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiralImageForPaper_7x10_1200_c2.png" height="200">


- Conserto da label da figura do grafico 768x768



## [08/03] ~ [22:40] -- [26:00]
- Adicionado callbacks de erro para tentar descobrir o motivo de ao rodar tamanhos maiores
- Alguns testes realizados e descobri que para alguns tamanho o erro de aparecer em cima acontece pra outras quantidades de timesteps

## [05/03] ~ [19:00] -- [21:30]

- Simulação spiral de 1 times adicionada para tentar identificar um erro do modelo de propagação

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/animatedSpiral1times.gif" height="200">


- O Certo é não voltar o campo para 0.5 volts

Resetando

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiral1timesNoDvReset12000steps.png" height="200">

Não resetando

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiral1timesDvReset12000steps.png" height="200">

- Para varios quatidades de instantes de tempo diferentes constatei que o erro acontece acima de 10 por chamada de kernel, e aumenta gradativamente.

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/spiralDvReset12000stepsVariosTimesComparison.png" height="200">

## [26/02] ~ [18:30] -- [22:00]
- Adicionado simulação de espiral:

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/animatedSpiral.gif" height="200">

- Ao rodar testes e gravar o desempenho de varias combinações de tamanho de bloco 8x8 16x16 32x32 8x16 4x4 4x8 4x16 16x64 8x128, gera resultados diferentes e não consegui descobrir ainda o motivo. 
- Plotar gráfico da memória para várias combinações de tamanho de bloco:

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/graficoSharedTam.PNG" height="200">

## [25/02] ~ [17:23] -- [20:28]
- Adicionei os dois gráficos no paper usando o tikz
- Releitura do artigo
- Escrevi algumas linhas e tentei corrigir alguns detalhes 

## [24/02] ~ [13:30] -- [20:28]
- Ao chegar na minha sala, o computador estava inesperadamente ligado mas não respondia, constatei que o problema estava na memória RAM, e uma limpeza com uma borracha resolveu o problema.
- Adicionei um teste de 768x768 19000 instantes variando o blockingTimeSteps

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/desempenho768x768_19000steps_timesVar.PNG" height="200">

- Plotar os gráficos utilizando o tikz
- Sinto que hoje o trabalho não rendeu muito, teve um movimento maior na minha sala e acho que tirou um pouco minha atenção.

## [23/02] ~ [12:00] -- [22:00]
- Terminei os preparativos para fazer os testes de tempo
- Organizei o notebook e os códigos para rodar em diferentes tamanhos de domínio
- Realizei um teste travando o tamanho em 96x96 e a quantidade de instantes de tempo em 12000 e variando a quantidade de instantes de tempo por chamada de kernel e plotei o resultado no grafico:

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/desempenho96x96_12000steps_timesVar.PNG" height="200">


- Para conferir os resultados gerei os gifs para varios tamanhos diferentes de domínio com  quantidade de instantes de tempo por chamada de kernel igual a 15 e  quantidade de instantes de tempo igual 19000 e atualizei as vizualizações com elas, até este commit as vizualizações eram por  quantidade de instantes de tempo por chamada de kernel.
- Atualização nos códigos para plotar o tempo em função do tamanhos para varios timeStepSize diferentes com quantidade de instantes de tempo total em 19000

desempenhoShared&Blocking_3timeStep_19000steps_modelSizeVar

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/Blocking_3timeStep_19000steps_modelSizeVar.PNG" height="200">

## [22/02] ~ [22:15] -- [24:30]
- Atualização das vizualizações
- Configuração para os testes de desempenho

## [22/02] ~ [20:00] -- [22:00]
- Tentei simplificar uma parte do código onde acreditava ser o problema e fiz desenhos para visualizar melhor, como resultado dessa abordagem consegui que o algoritmo funcionasse utilizando 2 instantes de tempo, como a universidade não permite o acesso após 22hrs, ao chegar em casa vou atualizar o restante dos instantes de tempo e constatar se está funcionando corretamente.

- O segundo instante de tempo se encontra assim:

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_96x96_12000steps_2times-22-02.gif" height="200">


## [21/02] ~ [6:30] -- [12:00]
- Fui até o rio de janeiro para comprar dois monitores para minha sala, através da olx, configurei um dos computadores que ganhei do LMDC (uns velhos que seriam descartados) e organizei tudo em minha sala, na parte da tarde trabalhei com will no projeto do bikenit e a noite ja estava bastante cansado para trabalhar nesse projeto.


## [20/02] ~ [20:00] -- [23:26]
- Conferência da logica desde o inicicio do programa levando em consideração que os erros podem estar no local onde achamos que mais temos certeza que esta certo
- Depois de alguns testes percebi que o erro só poderia estar no envio dos indices para o calculo do stencil
- constatei um erro, uma confusão entre a variável do tamanho do tile do tempo atual e do tamanho inicial do tile está assim agora, mudou um pouco mas ainda tem alguma coisa estranha.
- Atualização das imagens.

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_96x96_12000steps_2times-20-02.gif" height="200">


## [19/02] ~ [24:00] -- [25:00]
- Atualização das vizualizações

## [18/02] ~ [20:00] -- [23:25]
- Conferência das variáveis de entrada.
- Retirada de um parâmetro que não esta mais sendo utilizado pelo motivo que não é necessário variar a ordem do stencil até porque a nova logica não perimite isso sendo a ordem sempre 2, mesma coisa com os coeficientes.
- Alguns comentarios adicionados.
- Descobri um valor errado no calculo do tamanho da borda na hora de enviar o indice para a função do calculo do stencil testei apenas com 2 instantes de tempo por vez está assim agora.

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_96x96_12000steps_2times-18-02.gif" height="200">


## [17/02] ~ [19:30] -- [22:00]
- Alguns erros estão ocorrendo nas copias entre os blocos, estou tentando resolver esse problema, quando percebi que não estava tendo muitas ideias pra tentar resolver o problema, me voltei a corrigir os erros na escrita do artigo. Com dois instantes de tempo o resultado se encontra assim:

<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_96x96_12000steps_2times-17-02.gif" height="200">



## Vizualização da propagação variando o tamanho do domínio

### blocking_352x352_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_32x32_19000steps_15times.gif" height="200">

### blocking_64x64_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_64x64_19000steps_15times.gif" height="200">

### blocking_96x96_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_96x96_19000steps_15times.gif" height="200">

### blocking_128x128_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_128x128_19000steps_15times.gif" height="200">

### blocking_160x160_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_160x160_19000steps_15times.gif" height="200">

### blocking_192x192_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_192x192_19000steps_15times.gif" height="200">

### blocking_224x224_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_224x224_19000steps_15times.gif" height="200">

### blocking_256x256_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_256x256_19000steps_15times.gif" height="200">

### blocking_288x288_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_288x288_19000steps_15times.gif" height="200">

### blocking_320x320_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_320x320_19000steps_15times.gif" height="200">

### blocking_352x352_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_352x352_19000steps_15times.gif" height="200">

### blocking_384x384_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_384x384_19000steps_15times.gif" height="200">

### blocking_416x416_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_416x416_19000steps_15times.gif" height="200">

### blocking_448x448_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_448x448_19000steps_15times.gif" height="200">

### blocking_480x480_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_480x480_19000steps_15times.gif" height="200">

### blocking_512x512_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_512x512_19000steps_15times.gif" height="200">

### blocking_544x544_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_544x544_19000steps_15times.gif" height="200">

### blocking_576x576_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_576x576_19000steps_15times.gif" height="200">

### blocking_608x608_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_608x608_19000steps_15times.gif" height="200">

### blocking_640x640_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_640x640_19000steps_15times.gif" height="200">

### blocking_672x672_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_672x672_19000steps_15times.gif" height="200">

### blocking_704x704_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_704x704_19000steps_15times.gif" height="200">

### blocking_736x736_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_736x736_19000steps_15times.gif" height="200">

### blocking_768x768_19000steps_15times
<img src="https://github.com/sabiomito/uffgpu2019/blob/master/readmeContent/blocking_768x768_19000steps_15times.gif" height="200">
