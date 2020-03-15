def fazEntrada(tam,show):
  from random import randint
  from random import seed
  arquivo = open('entrada.txt', 'w')
  data = []
  for i in range(tam):
    dt = []
    for j in range(tam):
      if(j<tam/20):#(j>tam/2-5 and j<tam/2+4):# and i>128 and i<1024-128):# or (j>120 and j<130 and i >120 and i<130)):
        dt.append(3)
      else:
        dt.append(0)
      
    data.append(dt)

  for i in range(tam):
    txt = ""
    for j in range(tam):
      txt+=" "+str(data[i][j])
    arquivo.write(txt+"\n")
  arquivo.close()

fazEntrada(256,False)
