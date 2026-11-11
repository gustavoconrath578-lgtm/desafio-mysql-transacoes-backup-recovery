# Desafio MySQL – Transações, Procedure, Backup e Recovery

## Arquivos

- `atividade_transacoes.sql`: prepara duas tabelas de exemplo mais pedidos e log, executa duas transações, cria procedure com rollback automático, cria trigger e event desabilitado, e cria o banco adicional `ecommerce_relatorios`.
- `README_INSTRUCOES.md`: procedimentos de execução, backup, restauração e entrega.

**Atenção:** a execução de `atividade_transacoes.sql` redefine as tabelas de demonstração `desafio_produtos`, `desafio_pedidos` e `desafio_log_estoque` e os objetos `sp_desafio_registrar_pedido`, `trg_desafio_estoque` e `ev_desafio_limpeza_log`. Não executá-lo se você já tiver dados importantes com esses mesmos nomes. Nenhuma outra tabela deve ser alterada pelo script. As tabelas usam o mecanismo transacional InnoDB. Se o banco real não se chamar `ecommerce`, ajuste o SQL e os comandos abaixo.

## 1. Executar no MySQL Workbench

1. Abrir MySQL Workbench e conectar ao servidor MySQL.
2. Abrir o arquivo `atividade_transacoes.sql` (File > Open SQL Script).
3. Executar o script inteiro, conferindo as mensagens e resultados.
4. Verificar o resultado das transações: preço do teclado 105,00; estoque do teclado 15, após a falha provocada no pedido duplicado; estoque do mouse 14.
5. Conferir que aparecem a procedure, trigger e event desabilitado nos resultados finais.

## 2. Backup no Prompt de Comando do Windows (CMD), não no editor SQL

Abra o **Prompt de Comando (cmd.exe)**. Se MySQL estiver no PATH, execute:

```bat
mkdir C:\backup_mysql
cd /d C:\backup_mysql
mysqldump -u root -p --single-transaction --routines --events --triggers --databases ecommerce > backup_ecommerce.sql
mysqldump -u root -p --single-transaction --routines --events --triggers --databases ecommerce ecommerce_relatorios > backup_multibancos.sql
```

O comando solicitará a senha do MySQL. `--routines` inclui procedures/functions, `--events` inclui eventos, e `--triggers` inclui triggers. `--single-transaction` fornece cópia consistente das tabelas InnoDB durante o dump, desde que não ocorram alterações estruturais concorrentes. O recurso de eventos pode exigir o privilégio `EVENT`.

**Se aparecer 'mysqldump não é reconhecido':** use o caminho completo do executável, ajustando a versão instalada, por exemplo:

```bat
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqldump.exe" -u root -p --single-transaction --routines --events --triggers --databases ecommerce ecommerce_relatorios > backup_multibancos.sql
```

## 3. Recovery (restauração)

**Faça isso em um MySQL de teste, não em um banco de produção.** A importação pode substituir tabelas e dados existentes. Para restaurar o backup completo no mesmo servidor de teste, abra o Prompt de Comando na pasta do backup e execute:

```bat
cd /d C:\backup_mysql
mysql -u root -p < backup_multibancos.sql
```

Se `mysql` não estiver no PATH, use `"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"` no lugar de `mysql`. Após restaurar, confira no Workbench:

```sql
USE ecommerce;
SELECT * FROM desafio_produtos;
SELECT * FROM desafio_pedidos;
SHOW PROCEDURE STATUS WHERE Db = 'ecommerce';
SHOW TRIGGERS FROM ecommerce;
SHOW EVENTS FROM ecommerce;

USE ecommerce_relatorios;
SELECT * FROM desafio_resumo;
```

## 4. Evidências de execução

Tire capturas de tela da execução do SQL (principalmente os resultados de `COMMIT`, `ROLLBACK` e do `CALL` com erro), do terminal após criar o arquivo de backup e das consultas depois de restaurar. O arquivo de backup real **não** está incluso neste pacote, pois precisa ser gerado a partir do seu próprio servidor MySQL.

## 5. Entrega no GitHub

Crie um repositório e inclua:

- `atividade_transacoes.sql`
- `README_INSTRUCOES.md`
- `backup_ecommerce.sql` e/ou `backup_multibancos.sql` **gerados por você no CMD**
- Capturas de tela, se a atividade pedir provas visuais

Antes de publicar, confira se o backup contém apenas dados fictícios. Um dump real pode incluir nomes, e-mails, dados pessoais ou outros segredos; não publique dados reais em um repositório público.

## Resumo breve da atividade (para relatório)

Na primeira parte, foram executadas transações manuais com controle do autocommit e uso de COMMIT, SAVEPOINT e ROLLBACK TO SAVEPOINT. Na segunda, foi criada uma procedure que realiza atualização de estoque e registro de pedidos, com tratamento de erros para desfazer operações em caso de falha. Na terceira, foram criados uma trigger, um evento desabilitado e um banco adicional, permitindo demonstrar a exportação de objetos e de múltiplos bancos usando mysqldump, seguida de restauração via mysql.
