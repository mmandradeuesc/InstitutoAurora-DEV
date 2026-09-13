# Diario tecnico - Modulos 3 a 10

## Modulo 3 - Ingestao, transformacao e validacao

Fontes: `alunos.csv`, `cursos.csv` e `matriculas.csv`. A ingestao preserva a origem com `arquivo_origem`, `linha_origem` e `dt_ingestao`. A transformacao padroniza espacos, caixa, codigos, CPF e datas. A validacao separa `data/out/*.csv` e registra `motivo_rejeicao`.

Regras criticas: obrigatoriedade de chaves e nomes; CPF com 11 digitos; data existente e nao futura; dominio de situacao; codigo de curso canonico; existencia de aluno e curso; unicidade de identificadores.

Amostra dos dados atuais: alunos 9 validos/5 rejeitados; cursos 6/3; matriculas 9/6. As rejeicoes sao intencionais para demonstrar o tratamento de qualidade.

## Modulo 4 - Workflow

Ordem: `01_verificar_entradas` -> `02_ingestao_alunos` -> `03_ingestao_cursos` -> `04_ingestao_matriculas` -> `05_transformar_validar` -> `06_carregar_postgres` -> `07_validar_carga` -> `08_registrar_sucesso`. Cada etapa deve seguir pelo hop de sucesso; qualquer falha segue para `09_registrar_falha` e aborta o workflow.

Pre-requisitos: tres arquivos existem e nao estao vazios, variaveis de banco estao definidas e o schema de destino foi criado.

## Modulo 5 - Logging e rastreabilidade

Destino planejado: tabela `aurora.auditoria_execucao` e arquivo local em `logs/`. Campos minimos: `execucao_id`, inicio, fim, status, etapa, lidas, validas, rejeitadas, carregadas, mensagem e pipeline. Criterios: SUCESSO quando terminou sem erro; ALERTA quando terminou com rejeicoes dentro do esperado; FALHA quando uma etapa nao concluiu ou o resultado ficou inconsistente.

## Modulo 6 - PostgreSQL

Estrategia escolhida: carga completa idempotente em staging, com truncamento controlado antes da carga. Motivo: volume pequeno, dados didaticos e prioridade de reprodutibilidade. A camada staging preserva a origem; as consultas em `sql/002_validacoes_academico.sql` verificam contagens, duplicidade e chaves sem correspondencia.

## Modulo 7 - Governanca e versionamento

Pipelines, workflows, SQL, documentacao e metadados sem segredos sao versionaveis. Logs, caches, arquivos temporarios, senhas e exportacoes locais nao sao versionaveis. Commits sugeridos: `feat: adiciona ingestao e regras de validacao`, `feat: cria workflow de orquestracao`, `feat: adiciona carga e auditoria postgres`, `docs: consolida governanca e seguranca`.

Ambientes simulados: `local` para desenvolvimento e `test` para validacao. A configuracao e parametrizada por variaveis; nao ha valores reais no repositorio.

## Modulo 8 - Seguranca operacional

Riscos: credencial em metadado, PII em log, permissao excessiva e CSV compartilhado. Mitigacoes: variaveis de ambiente/secret store, mascaramento e contagens nos logs, papeis separados e acesso minimo. Papeis simulados: desenvolvedor (edita), operador (executa), revisor (aprova) e validador (consulta resultados).

Evidencias do modulo: a conexao `CONN_POSTGRES_AURORA` usa `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER` e `DB_PASSWORD` sem valor real no repositorio; `logs/README.md` restringe o registro de CPF, e-mail, nome completo, senha e token; `data/in/alunos.csv` permanece como principal ponto de atencao por conter PII ficticia em pasta compartilhada de laboratorio. A consolidacao da revisao, com variaveis sensiveis, minimizacao de dados, papeis simulados e matriz de riscos, esta no arquivo `Oficina_Prática_Módulo_8_Segurança_Operacional_Controle_Acesso.md`.

## Modulo 9 - Desempenho e falhas

A primeira linha de base e a contagem dos CSVs. O gargalo esperado e a leitura/validacao de arquivos, nao o volume. Falha simulada: remover `cursos.csv`; o pre-requisito deve impedir carga parcial. Reprocessamento e seguro porque a carga completa limpa staging antes de gravar.

Melhoria proposta: adicionar indice nas chaves de join e persistir metricas por etapa. Impacto esperado: menor custo de lookup e diagnostico mais rapido, sem alterar regra de negocio.

## Modulo 10 - Consolidacao

A entrega final reune os artefatos dos modulos anteriores, registra limitacoes (execucao Hop/PostgreSQL depende do ambiente local) e proximos passos: CI, secret manager, testes automatizados de contrato, particionamento e monitoramento historico.
