# Instituto Aurora - Pipeline Institucional de Dados Academicos

Projeto integrador dos modulos 3 a 10, com ingestao, padronizacao, validacao, orquestracao, carga PostgreSQL, logging, governanca, seguranca e analise operacional.

## Objetivo

Transformar os CSVs academicos ficticios de `data/in` em dados padronizados e verificaveis, separando registros validos de rejeitados e preparando a carga em PostgreSQL.

## Arquitetura

`data/in/*.csv` -> ingestao bruta -> padronizacao -> validacao -> `data/out` -> carga PostgreSQL -> auditoria e indicadores

## Execucao

1. Configure `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD` fora do repositorio.
2. Execute `sql/001_staging_academico_ficticio.sql` no PostgreSQL.
3. No Apache Hop, abra `workflows/wf_pipeline_indicadores_academicos.hwf`.
4. Execute primeiro em modo local e valide os arquivos de `data/out`.
5. Execute `sql/002_validacoes_academico.sql` apos a carga.

Os arquivos `.hpl` e `.hwf` registram o desenho operacional da oficina. A evidencia de execucao deve ser preenchida no ambiente Hop/PostgreSQL local, conforme `docs/evidencias_execucao.md`.

## Estrutura

- `data/in`: fontes brutas preservadas.
- `data/out`: saidas validas e rejeicoes.
- `pipelines/`: ingestao, transformacao, validacao e carga.
- `workflows/`: orquestracao principal.
- `sql/`: DDL, carga e consultas de validacao.
- `metadata/`: conexao e configuracoes locais do Hop sem credenciais reais.
- `docs/`: diario tecnico, checklist, riscos e evidencias.
- `logs/`: destino local de logs; arquivos de log nao devem ser versionados.

## Regras principais

- Datas aceitas em `dd/MM/yyyy`, `yyyy-MM-dd` e `dd-MM-yyyy`, convertidas para ISO.
- Codigos de curso sao aparados, convertidos para maiusculas e normalizados removendo hifen.
- CPF e armazenado somente com digitos e deve ter 11 caracteres.
- Nome, identificadores, curso, data de matricula e situacao sao obrigatorios.
- Situacoes permitidas: `Ativa`, `Trancada`, `Concluida`, `Evasao`.
- Duplicidades sao rejeitadas com motivo e linha de origem.
- Matriculas exigem aluno e curso existentes apos a padronizacao.

## Resultado esperado dos CSVs atuais

| Fonte | Linhas | Validas | Rejeitadas | Principais motivos |
|---|---:|---:|---:|---|
| alunos.csv | 14 | 9 | 5 | duplicidade, obrigatorio, CPF/data/status |
| cursos.csv | 9 | 6 | 3 | duplicidade apos normalizacao |
| matriculas.csv | 15 | 9 | 6 | FK, codigo, data obrigatoria |

Os totais acima sao uma expectativa deterministica para os arquivos atuais e devem ser confirmados pelo log da execucao.

## Execucao validada

Em 2026-09-13, o workflow foi executado no Apache Hop 2.19.0 com o ambiente `InstitutoAurora-DEV`. O pre-requisito passou, as tres ingestões foram executadas, a carga foi idempotente e 10 alunos e 10 matriculas foram gravados no PostgreSQL. Uma falha controlada com `cursos.csv` ausente terminou com exit `1` e sem carga parcial. As validacoes SQL e a auditoria tambem foram executadas. Os detalhes estao em `docs/evidencias_execucao.md` e `logs/`.

## Seguranca e governanca

Nao ha senha real versionada. A conexao usa variaveis e o arquivo local de credenciais deve permanecer fora do Git. Dados pessoais dos CSVs sao ficticios; logs devem registrar contagens e identificadores tecnicos, nunca CPF, e-mail ou nome completo.

Decisoes, riscos, criterios de sucesso/alerta/falha, reprocessamento e checklist estao em `docs/diario_tecnico.md`, `docs/checklist_modulos_3_10.md` e `docs/evidencias_execucao.md`.

A validacao SQL pos-carga esta preparada em `sql/002_validacoes_academico.sql`; sua execucao por cliente SQL ainda deve ser registrada, pois o executavel `psql` nao esta instalado no ambiente local.
