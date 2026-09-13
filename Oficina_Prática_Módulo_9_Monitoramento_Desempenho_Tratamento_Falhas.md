# Oficina Prática Módulo 9 - Monitoramento, Desempenho e Tratamento de Falhas

## 1. Objetivo da análise

Este relatório avalia o comportamento operacional do workflow institucional do Instituto Aurora com base nas evidências já registradas no projeto: logs locais, auditoria SQL, artefatos do Apache Hop e documentação técnica.

O foco desta oficina foi responder:

- se o workflow executou corretamente;
- quais métricas de tempo e volume foram observadas;
- qual etapa tende a concentrar maior custo;
- como a falha simulada foi tratada;
- se o pipeline suporta reprocessamento sem carga parcial ou duplicidade;
- qual melhoria técnica faz sentido a partir das evidências.

## 2. Evidências utilizadas

- `logs/execucao-2026-09-13-sucesso.log`
- `logs/execucao-2026-09-13-falha-controlada.log`
- `docs/evidencias_execucao.md`
- `docs/diario_tecnico.md`
- `sql/003_auditoria_execucao.sql`
- `sql/006_registro_auditoria_execucao.sql`
- `sql/004_carga_matriculas_validas.sql`
- `sql/002_validacoes_academico.sql`
- `pipelines/carga/carga_staging_postgres.hpl`
- `pipelines/transformacao/padronizacao_academica.hpl`
- `pipelines/validacao/validacao_academica.hpl`

## 3. Evidência da execução do workflow completo

O workflow principal `wf_pipeline_indicadores_academicos` possui evidência de execução bem-sucedida no ambiente `InstitutoAurora-DEV`.

Resumo observado:

- status final: `SUCESSO`
- tempo total registrado: `1,3 s`
- conexão utilizada: `CONN_POSTGRES_AURORA`
- validações SQL executadas após a carga
- auditoria de execução registrada em banco

No cenário de erro, também há evidência de falha controlada:

- status final: `FALHA`
- causa simulada: ausência de `data/in/cursos.csv`
- ação observada: desvio para `09_registrar_falha`
- código de saída: `1`
- carga parcial: não ocorreu

## 4. Métricas coletadas

### 4.1 Métricas gerais da execução com sucesso

| Métrica | Valor observado |
|---|---|
| Workflow | `wf_pipeline_indicadores_academicos` |
| Ambiente | `InstitutoAurora-DEV` |
| Status | `SUCESSO` |
| Duração total | `1,3 s` |
| Linhas lidas de alunos | 14 |
| Linhas lidas de cursos | 9 |
| Linhas lidas de matrículas | 15 |
| Duplicidades removidas em alunos | 1 |
| Rejeições de qualidade em alunos | 3 |
| Registros carregados em `stg_alunos` | 10 |
| Registros carregados em `stg_matriculas` | 10 |

### 4.2 Volumes esperados por fonte

| Fonte | Lidas | Válidas | Rejeitadas | Observação |
|---|---:|---:|---:|---|
| `alunos.csv` | 14 | 9 | 5 | inclui 1 duplicidade e 4 inconsistências de qualidade |
| `cursos.csv` | 9 | 6 | 3 | duplicidade após normalização |
| `matriculas.csv` | 15 | 9 | 6 | regras de chave, curso e data |

### 4.3 Métricas de auditoria em banco

A tabela `aurora.auditoria_execucao` armazena:

- `inicio` e `fim`;
- `status`;
- `linhas_lidas`, `linhas_validas`, `linhas_rejeitadas` e `linhas_carregadas`;
- `mensagem`;
- `commit_ref`.

Esse desenho já permite identificar sucesso, alerta ou falha por execução. O ponto fraco atual é a ausência de tempo detalhado por transform ou por etapa interna do Hop.

## 5. Análise de gargalo e desempenho

### 5.1 Etapa mais custosa identificada

Com a telemetria disponível hoje, não é possível afirmar com precisão o tempo de cada etapa interna do workflow, porque os pipelines estão com `capture_transform_performance=N`. Mesmo assim, a etapa com maior custo esperado e melhor sustentada pelas evidências é a de carga e validação final, especialmente em torno de `carga_staging_postgres`.

Justificativas técnicas:

- o pipeline de carga executa `SortRows`, `Unique`, `ScriptValueMod`, `FilterRows` e `TableOutput`;
- a escrita em banco inclui `TRUNCATE` e nova carga para `staging.stg_alunos`;
- a carga de matrículas em `sql/004_carga_matriculas_validas.sql` faz normalização com `trim`, `replace`, `upper`, `regexp_replace`, deduplicação por `DISTINCT ON` e `JOIN` com `stg_alunos`;
- o cenário descrito no módulo menciona aumento de volume de matrículas, e esse é justamente o trecho que mais depende de operações de comparação, deduplicação e integração com o banco.

Conclusão operacional: a carga final e as validações associadas são o melhor candidato a gargalo do fluxo atual, principalmente quando o volume de matrículas cresce.

### 5.2 O volume processado ficou dentro do esperado?

Sim, para o conjunto de dados atual o volume ficou dentro do esperado:

- alunos: 14 lidos, 9 válidos e 5 rejeitados;
- cursos: 9 lidos, 6 válidos e 3 rejeitados;
- matrículas: 15 lidas, 9 válidas e 6 rejeitadas.

Não há evidência de aumento inesperado de rejeições nesta execução; as rejeições observadas são compatíveis com o conjunto didático preparado para demonstrar regras de qualidade e integridade.

### 5.3 Comportamentos inesperados ou limitações

O comportamento mais relevante não é uma falha funcional, e sim uma limitação de observabilidade:

- o projeto registra o tempo total da execução, mas não registra o tempo por transform;
- a equipe ainda depende de inspeção manual do workflow para localizar custo interno;
- o repositório já possui auditoria funcional, mas ainda não possui monitoramento fino de desempenho por etapa.

## 6. Análise da falha simulada

Falha analisada: ausência do arquivo `data/in/cursos.csv`.

Comportamento observado:

- o pré-requisito detectou o problema antes da carga;
- o workflow desviou para `09_registrar_falha`;
- o processo terminou com `exit_code=1`;
- o log registrou `carga_parcial=NA`;
- o arquivo foi restaurado após a simulação.

Conclusão: a falha foi registrada e tratada corretamente. O desenho do workflow evita que a carga prossiga quando uma entrada obrigatória está ausente.

## 7. Reprocessamento

O pipeline está preparado para reprocessamento controlado.

Evidências:

- `carga_staging_postgres.hpl` usa `truncate=Y` em `staging.stg_alunos`;
- `sql/004_carga_matriculas_validas.sql` executa `TRUNCATE TABLE staging.stg_matriculas`;
- a documentação do projeto já descreve a estratégia como carga completa idempotente em staging.

Impacto dessa escolha:

- reduz o risco de duplicidade em nova execução;
- evita acumular carga parcial entre tentativas;
- simplifica o diagnóstico operacional em ambiente didático.

Ponto de atenção:

- em volumes maiores, recarga completa pode aumentar o tempo total e o custo de indisponibilidade da tabela staging durante a janela de atualização.

## 8. Proposta de melhoria técnica

### Melhoria proposta

Ativar a captura de desempenho por transform no Apache Hop e persistir métricas por etapa na auditoria de execução.

### Justificativa técnica

Hoje o projeto já mede sucesso, falha, volume e duração total, mas ainda não mede custo por transform. Isso impede responder com evidência fina:

- qual transform consumiu mais tempo;
- qual etapa degradou quando o volume cresceu;
- se a lentidão veio da leitura de arquivo, script, ordenação, deduplicação, escrita em banco ou validação SQL.

Como os pipelines estão configurados com `capture_transform_performance=N`, a melhoria mais valiosa neste momento não é alterar regra de negócio, e sim melhorar a observabilidade operacional do fluxo.

### Impacto esperado

- identificação objetiva do gargalo real por etapa;
- diagnóstico mais rápido em cenários de lentidão;
- comparação entre execuções com diferentes volumes;
- redução da dependência de inspeção manual do workflow;
- base mais sólida para futuras otimizações de SQL, índices ou paralelismo.

### Efeito colateral a observar

- a coleta de métricas adiciona pequeno overhead de execução;
- será necessário definir retenção para não inflar logs e tabelas de auditoria;
- métricas por transform sem padronização de nomes podem dificultar comparação histórica.

## 9. Respostas às perguntas norteadoras

1. O workflow executou corretamente?
   Sim. Há evidência de execução com `SUCESSO` e duração total de `1,3 s`.

2. Quantas linhas foram lidas, gravadas e rejeitadas?
   Foram lidos 14 alunos, 9 cursos e 15 matrículas; ao final houve 10 alunos e 10 matrículas carregados em staging, com rejeições compatíveis com o conjunto de teste.

3. Qual etapa apresentou maior custo?
   Com os dados atuais, a melhor hipótese sustentada é a etapa de carga e validação final. Ainda falta medição granular por transform para confirmar com precisão.

4. Houve aumento de rejeições ou erros?
   Não há evidência de aumento anômalo nesta execução. As rejeições observadas são esperadas para o conjunto didático.

5. A falha simulada foi registrada e tratada?
   Sim. A ausência de `cursos.csv` gerou falha controlada, sem carga parcial.

6. O pipeline está preparado para reprocessamento?
   Sim. O uso de `TRUNCATE` e carga idempotente em staging reduz risco de duplicidade e de carga parcial residual.

7. Que melhoria foi proposta?
   Ativar monitoramento de desempenho por transform e persistir métricas por etapa na auditoria.

## 10. Conclusão

O pipeline do Instituto Aurora executa corretamente e já possui uma base razoável de logging, auditoria e tratamento de falhas. O principal avanço necessário para o Módulo 9 não é corrigir uma falha funcional crítica, e sim aumentar a observabilidade do desempenho para localizar gargalos com evidência objetiva quando o volume de matrículas crescer.
