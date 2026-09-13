-- Registros reais das execucoes realizadas na oficina.
-- IDs fixos tornam o script idempotente para reexecucao.

INSERT INTO aurora.auditoria_execucao (
    execucao_id, pipeline, etapa, inicio, fim, status,
    linhas_lidas, linhas_validas, linhas_rejeitadas, linhas_carregadas,
    mensagem, commit_ref
) VALUES
(
    '11111111-1111-1111-1111-111111111111',
    'wf_pipeline_indicadores_academicos',
    'carga_postgres',
    '2026-09-13 12:01:26-03',
    '2026-09-13 12:01:27-03',
    'SUCESSO', 15, 10, 5, 10,
    'Workflow completo executado no ambiente DEV.', '06e5a16'
),
(
    '22222222-2222-2222-2222-222222222222',
    'wf_pipeline_indicadores_academicos',
    'pre_requisito',
    '2026-09-13 12:01:48-03',
    '2026-09-13 12:01:48-03',
    'FALHA', 0, 0, 0, 0,
    'Arquivo cursos.csv ausente; workflow abortado antes da carga.', '06e5a16'
)
ON CONFLICT (execucao_id) DO UPDATE SET
    fim = EXCLUDED.fim,
    status = EXCLUDED.status,
    mensagem = EXCLUDED.mensagem;

SELECT execucao_id, pipeline, etapa, status, linhas_lidas,
       linhas_validas, linhas_rejeitadas, linhas_carregadas
FROM aurora.auditoria_execucao
ORDER BY inicio;
