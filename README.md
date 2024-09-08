
# Template para Desafio CLI

Este template tem o objetivo de servir como 
ponto de partida para a implementação de desafios
de contratação da Cumbuca que envolvam implementar
uma interface de linha de comando em Elixir.

## Pré-requisitos

Primeiro, será necessário [instalar o Elixir](https://elixir-lang.org/install.html)
em versão igual ou superior a 1.16.
Com o Elixir instalado, você terá a ferramenta de build `mix`.

Para buildar o projeto, use o comando `mix escript.build` nesta pasta.
Isso irá gerar um binário com o mesmo nome do projeto na pasta.
Executando o binário, sua CLI será executada.

<!--toc:start-->
- [Desafio CLI Cumbuca](#desafio-cli-cumbuca)
- [Como executar](#como-executar)
- [Solução](#solução)
- [CLI](#cli)
- [Comandos aceitos pela CLI e o seu comportamento no contexto do programa:](#comandos-aceitos-pela-cli-e-o-seu-comportamento-no-contexto-do-programa)
- [Como o *parsing* dos inputs do usuário é feito](#como-o-parsing-dos-inputs-do-usuário-é-feito)
- [KVDB](#kvdb)
- [Modelagem da estrutura](#modelagem-da-estrutura)
- [Persistência](#persistência)
<!--toc:end-->

# Desafio CLI Cumbuca

Esse repositório guarda a minha solução para o [Desafio Backend](https://github.com/appcumbuca/desafios/blob/master/desafio-back-end-pleno.md) do processo seletivo para desenvolvedor Backend Pleno da Cumbuca.

## Como executar

Para facilitar, disponibilizei um Makefile no repositório, então caso deseje, é possível utilizar os comandos:
- `make tests`: para executar os testes do projeto
- `make`: para compilar e executar o programa

## Solução

A solução gira em torno da separação do código em 2 módulos:
- CLI
- Kvdb (abreviação de Key-Value Database)

### CLI

O módulo CLI é responsável por manter o loop da aplicação, ler as entradas do usuário, processar as entradas e, encaminhar o processamento adequado ou retornar o erro adequado.

#### Comandos aceitos pela CLI e o seu comportamento no contexto do programa:

- `HELP`: Exibe todos os comandos aqui citados.
- `SET <chave> <valor>`: Define/Modificar o valor de uma chave na transação atual, retorna se a chave já existia e o valor dela.
	- `<chave>`: é do tipo string.
	- `<valor>`: pode ser do tipo string, inteiro ou booleano.
	- Chaves ou valores do tipo string, podem ser definidos utilizando **ASPAS SIMPLES**, isso pode ser util em alguns casos:
		- Quando a string contém apenas números - para evitar confusões com o tipo inteiro;
		- Quando a string contém o conteúdo 'FALSE', 'TRUE ou 'NIL' - para evitar confusões com o tipo booleano e o valor nil;
		- Quando a string contém espaços;
		- Quando a string contém **aspas simples escapadas** (\');
- `GET <chave>`: Consulta o valor de uma chave na transação atual e retorna o seu valor, caso a chave não exista, retornará NIL.
	- A string será retornada envolta em aspas simples em alguns casos, para evitar confusões:
		- Quando a string contém apenas números
		- Quando a string contém o conteúdo 'FALSE', 'TRUE ou 'NIL'
		- Quando a string contém espaços;
- `BEGIN`: Inicia uma nova transação e retorna o nível da transação atual.
- `ROLLBACK`: Finaliza a transação atual **sem aplicar suas alterações**. Retorna o nível da transação após o ROLLBACK. Caso seja utilizado na transação 0, retorna um erro.
- `COMMIT`: Finaliza a transação atual **aplicando suas alterações na transação de nível inferior**. Retorna o nível de transação após o COMMIT.
- `EXIT`: Finaliza o programa.


#### Como o *parsing* dos inputs do usuário é feito

Todo input do usuário é tratado, e o programa tenta separar ele em COMANDO e ARGUMENTOS. Para isso, processa-se o INPUT de maneira recursiva um caractere por vez até que se encontre o final da string.

Para cada caractere, verificamos se ele se enquadra em algum dos casos:
1. Caracteres escapados:
	- É um caractere barra invertida (`\`): se o caractere for uma barra invertida e estivermos dentro de aspas simples, marcamos o próximo caractere como escapado e continuamos.
	- É um caractere normal, porém marcado como escapado: ele é adicionado sem a barra invertida na string resultante.
2. Início e Fim de Aspas Simples: 
	- Se o caractere for uma aspas simples (`'`) e não estamos dentro de aspas simples, a função entrará no modo 'entre aspas'.
	- Se a função está no modo 'entre aspas' e encontramos outra aspas simples, finaliza-se a string atual e a função sai do modo 'entre aspas'.
3. Espaços e Fim de Argumentos:
	- Se um caractere de espaço for encontrado e a função não estiver no modo 'entre aspas', percebemos que é o fim de um argumento.
4. Outros:
	- Em qualquer outro caso, adicionamos o caractere atual no argumento atual.

Após ser processado o input, teremos uma lista com todas as partes dele separadas, por exemplo:

- "SET a 'ola mundo'" -> ["SET", "a", "ola mundo"]
- "SET a b c" -> ["SET", "a", "b", "c"]
- "GET 'ola mundo'" -> ["GET", "ola mundo"]

A partir daí, consideramos o primeiro elemento da lista como o COMANDO e tentamos realizar o processamento desse comando utilizando o resto dos itens da lista como argumentos. Caso os argumentos sejam válidos, eles são repassados para o módulo KVDB, responsável por realizar os processamentos no banco, caso não sejam válidos, um erro será retornado.

### KVDB

O módulo Kvdb é o módulo que vai de fato interagir com o nosso banco de dados chave-valor e aplicar nele as operações disponíveis.

#### Modelagem da estrutura

A ideia geral da solução foi modelar cada transação como um hashmap e a estrutura geral do banco como uma pilha de transações (uma pilha da hashmaps), onde:
- O estado do banco é representado pelo hashmap na base da pilha.
- Operações de consulta e modificação (SET e GET) são aplicadas no hashmap que está no topo da pilha.
- Operações ROLLBACK e COMMIT são nada mais do que operações de POP, onde removemos a transação do topo da pilha.
	- Com efeito colateral de modificação do próximo TOPO, no caso do COMMIT.
- A operação de BEGIN é apenas uma operação de PUSH, onde adicionamos um hashmap vazio no topo da pilha.

A modelagem da pilha nesse contexto, foi feita utilizando listas, onde o item com index 0 é o topo da pilha (para aproveitar a facilidade do pattern matching).

#### Persistência

A persistência foi feita de uma maneira bem simples, para toda operação de SET na transação de nível 0 ou COMMIT que resulte em aplicações na transação de nível 0, o estado do banco é salvo num arquivo. O arquivo recebe todas as chaves e valores contidas no banco, no seguinte formato `tamanho_chave chave valor tipo_valor`, observe um exemplo abaixo:

```
16 'minha variavel' 'meu valor' str
1 a tchau mundo str
1 b false bool
1 c true bool
1 d NIL str
1 k 12345 int
4 kkkk 123995 int
3 lll 'a' str
9 ola mundo kekw str
```

O valor numérico no inicio da linha é o tamanho da string que representa a chave, logo em seguida temos a chave em si, depois temos o valor e por fim, o tipo desse valor.

Com essa representação, é possível, na inicialização do programa recarregar o estado do banco de maneira bem simples:
- Lemos o tamanho da chave (tudo antes do primeiro espaço);
- Lemos a chave utilizando o seu tamanho;
- Lemos o tipo do valor;
- Tudo o que sobrar no meio é o valor;
