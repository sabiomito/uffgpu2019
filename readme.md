## Estado atual do trabalho
[Link para o PDF do artigo](readmeContent/ICCSA_2020.pdf)

[Link para o notebook do colab](readmeContent/colabNotebook.ipynb)

# [18/02] ~ [20:00] -- [23:25]
- Conferência das variáveis de entrada.
- Retirada de um parâmetro que não esta mais sendo utilizado pelo motivo que não é necessário variar a ordem do stencil até porque a nova logica não perimite isso sendo a ordem sempre 2, mesma coisa com os coeficientes.
- Alguns comentarios adicionados.
- Descobri um valor errado no calculo do tamanho da borda na hora de enviar o indice para a função do calculo do stencil testei apenas com 2 instantes de tempo por vez está assim agora.
![](readmeContent/blocking_96x96_12000steps_2times.gif)

# [17/02] ~ [19:30] -- [22:00]
Alguns erros estão ocorrendo nas copias entre os blocos, estou tentando resolver esse problema, quando percebi que não estava tendo muitas ideias pra tentar resolver o problema, me voltei a corrigir os erros na escrita do artigo.

## Vizualização da propagação

# global_96x96_12000steps -- (Atualizado - [17/02])
![](readmeContent/global_96x96_12000steps.gif)

# blocking_96x96_12000steps_1times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_1times.gif)

# blocking_96x96_12000steps_2times -- (Atualizado - [18/02])
![](readmeContent/blocking_96x96_12000steps_2times.gif)

# blocking_96x96_12000steps_3times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_3times.gif)

# blocking_96x96_12000steps_4times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_4times.gif)

# blocking_96x96_12000steps_5times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_5times.gif)

# blocking_96x96_12000steps_6times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_6times.gif)

# blocking_96x96_12000steps_7times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_7times.gif)

# blocking_96x96_12000steps_8times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_8times.gif)

# blocking_96x96_12000steps_9times -- (Atualizado - [17/02])
![](readmeContent/blocking_96x96_12000steps_9times.gif)