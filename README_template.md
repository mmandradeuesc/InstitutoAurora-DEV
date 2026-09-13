# Instituto Aurora — Pipeline Institucional de Dados Acadêmicos

## 1. Objetivo
Pipeline de ingestão, transformação, validação e carga de dados acadêmicos
(alunos, cursos, matrículas) para geração de indicadores de matrícula,
frequência, conclusão e evasão.

## 2. Arquitetura
CSV (data/in) → Pipeline de ingestão (Hop) → Validação → Staging (PostgreSQL)
→ Consolidado (PostgreSQL) → Indicadores

## 3. Estrutura de pastas
- data/in      : arquivos de entrada (brutos, preservados)
- data/out     : saídas e rejeições geradas pelo pipeline
- pipelines/   : pipelines .hpl (carga, ingestao, transformacao, validacao)
- workflows/   : workflow principal .hwf
- sql/         : DDL e validações
- logs/        : logs de execução (não versionado)
- docs/        : evidências e diário técnico

## 4. Como executar
1. Verificar pré-requisitos (arquivos em data/in, conexão PostgreSQL ativa)
2. Executar workflow principal: wf_pipeline_indicadores_academicos.hwf
3. Consultar auditoria em aurora.auditoria_execucao

## 5. Variáveis de ambiente (sem valores reais — ver Módulo 8)
- ${DB_HOST}, ${DB_PORT}, ${DB_NAME}, ${DB_USER}, ${DB_PASSWORD}

## 6. Regras de validação aplicadas (Módulo 3)
| Regra | Motivo |
|---|---|
| id_aluno duplicado | integridade da dimensão aluno |
| nome obrigatório | identificação mínima do aluno |
| data_nascimento nula/inválida | datas impossíveis (ex.: 40/13/1990) |
| situacao fora do domínio | Ativa, Trancada, Concluída, Evasão |
| curso inexistente | chave estrangeira |
| CPF vazio/inválido | dado pessoal crítico |

## 7. Logs e monitoramento (Módulo 5)
Execuções registradas em aurora.auditoria_execucao com status
SUCESSO / ALERTA / FALHA, volumes e tempos.

## 8. Decisões técnicas registradas
(ver diário técnico em docs/)

## 9. Limitações e próximos passos
