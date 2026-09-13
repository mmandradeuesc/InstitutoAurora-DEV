# Checklist de entrega - Modulos 3 a 10

| Modulo | Entregavel | Estado | Evidencia |
|---|---|---|---|
| 3 | Pipelines de ingestao, transformacao, validacao e rejeicoes | Executado com validações SQL de cursos/matrículas | `pipelines/`, `sql/004_carga_matriculas_validas.sql`, evidências |
| 4 | Workflow principal, ordem e caminhos de falha | Executado | `workflows/wf_pipeline_indicadores_academicos.hwf`, evidencia |
| 5 | Campos de log e criterios de status | Documentado | `sql/003_auditoria_execucao.sql`, diario |
| 6 | Carga staging e validacoes SQL | Executado com inconsistência registrada | `sql/001_staging_academico_ficticio.sql`, `sql/002_validacoes_academico.sql`, evidências |
| 7 | Estrutura, convencoes e versionamento | Documentado; commit final pendente | README, `.gitignore`, diario |
| 8 | Variaveis, PII, papeis e riscos | Documentado | README e diario |
| 9 | Falha, reprocessamento e melhoria | Executado | diario e evidencia de falha |
| 10 | Consolidacao, limitacoes e proximos passos | Documentado | README e diario |

## Antes da submissao

- [x] Executar o workflow no Apache Hop.
- [x] Executar falha controlada por arquivo ausente.
- [x] Executar as consultas SQL em cliente PostgreSQL e registrar resultados reais.
- [x] Confirmar que nenhum segredo real foi adicionado aos arquivos do projeto.
- [ ] Criar commit final descritivo.
