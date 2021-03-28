# Importação da biblioteca
import csv
# Declaração de um dicionario de cidades
cities = {}

# Leitura do arquivo CSV
with open('DNIT-Distancias.csv', newline='') as f:
  reader = csv.reader(f, delimiter=';')   # Define o delimitador e associa ao ponteiro "reader"
  header = next(reader)                   # Le o cabeçalho do arquivo
  for i in range(0, len(header)):         # Para cada elemento do cabeçalho 
    cities[header[i].replace(' ','')] = i # Adiciona ao dicionario associando a um indice
  data_as_list = list(reader)             # Le os dados para uma matriz

# Declaracao de variaveis globais
opcao=0
custoKM = 1.0
litrosKM = 2.57

# Definição das funções
def setCustoKM():                         # Esta função define o Custo por Km rodado
  global custoKM
  custoKM = -1
  while (1):                              # Solicita a entrada e substitui a ',' do decimal por '.'
    data = input("Digite o valor do custo por Km rodado:\n").replace(',','.')
    dataaux = data.replace('.','')
    if (dataaux.isdigit()):                  # Checa a integridade da entrada
      custoKM = float(data)
    if (custoKM>0):                       # Se a entrada foi valida, imprime e quebra o laço
      print("O custo por KM rodado foi defino como: R$", custoKM)
      break

def getDistance(a,b):                     # Esta função retorna a distancia entre duas cidades
  distance = int(data_as_list[a][b])      # indexa na matriz através dos parametros 'a' e 'b'
  return distance

def checkCity(city):                      # Esta função checa se uma cidade está na lista
  city = city.upper()                     # A string é passada para letra maiuscula
  if (city in cities.keys()):             # Caso a cidade esteja na lista retorna o indice da cidade
    return cities[city]
  else:                                   # Se a cidade entrada nao estiver na lista retorna -1
    return -1

def consultaTrecho():                     # Esta função implementa a consulta do custo da viagem entre duas cidades
  global custoKM
  
  while (1):                              # Laço que testa a entrada
    cidade = str(input("Digite o nome da cidade de origem:\n")) # solicita a entrada por teclado
    a=checkCity(cidade.replace(' ',''))                   # Utiliza a funçao de verificação de nome de cidade
    if (a==-1):                           # Se não constar na lista de cidades informa erro e repete
      print("### Cidade invalida!!!")
    else:                                 # Se constar na lista de cidades quebra o laço
      break
  while (1):                              # Repete o procedimento acima para a segunda cidade
    cidade2 = str(input("Digite o nome da cidade de Destino: \n"))
    b=checkCity(cidade2.replace(' ',''))                  # Esta função retona o indice da cidade
    if (b==-1):
      print("### Cidade invalida!!!")
    else:
      break

  KMs=getDistance(a,b)                     # Consulta a distancia entre as cidades que agora se tornaram indices
  valor = custoKM * KMs                    # O Valor da viagem é calculado multiplicando o custo pela quilometragem
  print("\nA distância entre", cidade, 'e', cidade2, "é de", KMs, "Km")
  print("O custo da viagem é de: R$", valor) # Imprime na tela os resultados

def consultaRota():                         # Esta função implementa a consulta do custo da viagem entre duas ou mais cidades
  global custoKM
  distanciaTotal=0
  cidades = []                              # vetor de cidades entradas no teclado

  # Solicita a entrada do usuário e formata de acordo com o os dados internos e armazena em uma string
  rota_str = str(input("Digite o nome de duas ou mais cidades separados por virgula: \n").replace(' ',''))
  rota = rota_str.split(",")                # Associa a um vetor de cidades dividindo a string utilizando a separação por virgulas
  for i in range(len(rota)):                # Para cada cidade entrada
    check = checkCity(rota[i])              # Checa se é valida
    if (check==-1):                         # Se alguma não for, retona sem fazer operação alguma
      print('A lista contém uma cidade inválida! A operação será cancelada!')
      return
    else:                                   # Se For válida, adiciona o indice dela a um vetor
      cidades.append(check)
  for i in range(len(rota)-1):              # Loop que calcula as distancias entre cada cidade
    dist = getDistance(cidades[i],cidades[i+1]) # Calcula a distancia entre uma cidade e a próxima da lista
    print(rota[i],'-->',rota[i+1],'=', dist, 'Km')  # Imprime a distancia na tela
    distanciaTotal += dist                  # Acrescenta a distancia calculada a um acumulador
  #Imprime os resultados calculados
  print('')
  print('Distancia total =',distanciaTotal,'Km')
  print('O custo total da viagem é de: R$',round(distanciaTotal*custoKM,2))
  print('O total de litros de gasolina gastos é:',round(distanciaTotal*litrosKM,2), 'litros')
  print('A viagem durará ', round(distanciaTotal/283,2), 'dias')

# Ao inicio do programa chama a função que define o custo por Km
setCustoKM()

# Loop do Menu Principal
while (1):
  opcao=0                                  # Seta a variavel
  # Imprime o Menu
  print("")
  print("***MENU***")
  print("1) Atualizar o custo por Km")
  print("2) Consultar trecho")
  print("3) Consultar rota")
  print("4) Sair\n")
  while (opcao<=0 or opcao>4):             # Enquanto for opção invalida repete
    read = input("Digite a opção desejada:\n")
    if (read.isdigit()):                   # Checa se o valor digitado é um numero
      opcao=int(read)                      # Se sim, associa à variavel opcao
    if (opcao<=0 or opcao>4):              # Testa se é uma opção valida
      print("### Opção invalida!!!")
  # Chamada das funções de acordo com a opção escolhida
  if (opcao==1):                           
    setCustoKM()
  elif (opcao==2):
    consultaTrecho()
  elif (opcao==3):
    consultaRota()
  elif (opcao==4):
    print("Terminando o programa...")
    break                                 # Opção 4 quebra o laço principal finalizando o programa
# Fim do programa