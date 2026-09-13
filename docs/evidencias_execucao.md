# Evidencias de execucao

Este arquivo separa resultados calculados a partir dos CSVs de evidencias que precisam ser produzidas no ambiente Apache Hop/PostgreSQL.

## Cenario executado com sucesso

Entradas presentes: `alunos.csv`, `cursos.csv`, `matriculas.csv`.

| Etapa | Lidas | Validas | Rejeitadas |
|---|---:|---:|---:|
| alunos | 14 | 9 | 5 |
| cursos | 9 | 6 | 3 |
| matriculas | 15 | 9 | 6 |

Resultado observado em 2026-09-13: `SUCESSO`. O workflow executou em 1,3 s, leu 14 alunos, deduplicou para 13, rejeitou 3 registros por nome/CPF/data e carregou 10 registros em `staging.stg_alunos`. O PostgreSQL foi acessado pela conexao `CONN_POSTGRES_AURORA` usando o ambiente `InstitutoAurora-DEV`.

## Cenario executado de falha controlada

`data/in/cursos.csv` foi renomeado temporariamente. O pre-requisito falhou, o workflow executou `09_registrar_falha` e terminou com codigo `1`; o arquivo foi restaurado automaticamente.

## Registro real a preencher

- `execucao_id`: execucao local do Hop em 2026-09-13
- `inicio/fim`: 12:01:26 / 12:01:27
- `versao/commit`: Apache Hop 2.19.0 / `06e5a16`
- `status`: SUCESSO; falha controlada separada com exit `1`
- `linhas lidas/validas/rejeitadas/carregadas`: 14 / 10 / 4 (1 duplicada + 3 invalidas) / 10
- `mensagem de erro`: arquivo de cursos ausente no cenario de falha
- `caminho do log`: saida do Hop; arquivos orientativos em `logs/`
- `operador/revisor`: execucao local / revisao pendente

## Validacao SQL executada

Em 2026-09-13, `sql/002_validacoes_academico.sql` foi executado com `psql` 18 contra `aurora_dw`.

- `stg_alunos`: 10 registros.
- `stg_matriculas`: 10 registros válidos após recarga completa.
- Duplicidades de alunos: 0.
- Duplicidades de matriculas: 0.
- Alunos sem nome: 0.
- Matriculas sem curso: 0.
- Datas de nascimento invalidas/futuras: 1.
- Matriculas sem aluno correspondente: 0.
- `cursos.csv`: 9 linhas lidas e 6 códigos distintos após normalização.
- `matriculas.csv`: 15 linhas lidas, 11 com aluno e curso correspondentes e 10 carregadas após as regras de data e chave.

O script `sql/003_auditoria_execucao.sql` foi executado com sucesso e criou `aurora.auditoria_execucao` e seus índices. O script `sql/006_registro_auditoria_execucao.sql` inseriu os registros reais de SUCESSO e FALHA.

Nao inserir CPF, e-mail, senha ou token neste documento.

## Analise operacional do Modulo 9

- duração total observada do workflow: `1,3 s`;
- falha controlada observada: arquivo `data/in/cursos.csv` ausente com `exit_code=1`;
- reprocessamento considerado seguro no ambiente didático por uso de `TRUNCATE` antes da recarga;
- principal limitação atual: ausência de métricas por transform nos pipelines do Hop;
- principal melhoria proposta: ativar captura de desempenho por transform e persistir métricas por etapa na auditoria.
