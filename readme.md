# Estado atual do trabalho
[Link para o PDF do artigo](readmeContent/ICCSA_2020.pdf)

[Link para o notebook do colab](readmeContent/colabNotebook.ipynb)

## [20/02] ~ [20:00] -- [22:16]
- Conferência da logica desde o inicicio do programa levando em consideração que os erros podem estar no local onde achamos que mais temos certeza que esta certo
- Depois de alguns testes percebi que o erro só poderia estar no envio dos indices para o calculo do stencil
- constatei um erro, uma confusão entre a variável do tamanho do tile do tempo atual e do tamanho inicial do tile está assim agora, mudou um pouco mas ainda tem alguma coisa estranha.
![](readmeContent/blocking_96x96_12000steps_2times-20-02.gif)

## [19/02] ~ [24:00] -- [25:00]
- Atualização das vizualizações

## [18/02] ~ [20:00] -- [23:25]
- Conferência das variáveis de entrada.
- Retirada de um parâmetro que não esta mais sendo utilizado pelo motivo que não é necessário variar a ordem do stencil até porque a nova logica não perimite isso sendo a ordem sempre 2, mesma coisa com os coeficientes.
- Alguns comentarios adicionados.
- Descobri um valor errado no calculo do tamanho da borda na hora de enviar o indice para a função do calculo do stencil testei apenas com 2 instantes de tempo por vez está assim agora.
![](readmeContent/blocking_96x96_12000steps_2times-18-02.gif)

## [17/02] ~ [19:30] -- [22:00]
Alguns erros estão ocorrendo nas copias entre os blocos, estou tentando resolver esse problema, quando percebi que não estava tendo muitas ideias pra tentar resolver o problema, me voltei a corrigir os erros na escrita do artigo.

## Vizualização da propagação

### global_96x96_12000steps
![](readmeContent/global_96x96_12000steps.gif)

### blocking_96x96_12000steps_1times
![](readmeContent/blocking_96x96_12000steps_1times.gif)

### blocking_96x96_12000steps_2times
![](readmeContent/blocking_96x96_12000steps_2times.gif)

### blocking_96x96_12000steps_3times
![](readmeContent/blocking_96x96_12000steps_3times.gif)

### blocking_96x96_12000steps_4times
![](readmeContent/blocking_96x96_12000steps_4times.gif)

### blocking_96x96_12000steps_5times
![](readmeContent/blocking_96x96_12000steps_5times.gif)

### blocking_96x96_12000steps_6times
![](readmeContent/blocking_96x96_12000steps_6times.gif)

### blocking_96x96_12000steps_7times
![](readmeContent/blocking_96x96_12000steps_7times.gif)

### blocking_96x96_12000steps_8times
![](readmeContent/blocking_96x96_12000steps_8times.gif)

### blocking_96x96_12000steps_9times
![](readmeContent/blocking_96x96_12000steps_9times.gif)