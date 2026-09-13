CREATE SCHEMA IF NOT EXISTS aurora;

CREATE TABLE IF NOT EXISTS aurora.auditoria_execucao (
    execucao_id UUID PRIMARY KEY,
    pipeline TEXT NOT NULL,
    etapa TEXT NOT NULL,
    inicio TIMESTAMPTZ NOT NULL,
    fim TIMESTAMPTZ,
    status TEXT NOT NULL CHECK (status IN ('SUCESSO', 'ALERTA', 'FALHA')),
    linhas_lidas INTEGER NOT NULL DEFAULT 0,
    linhas_validas INTEGER NOT NULL DEFAULT 0,
    linhas_rejeitadas INTEGER NOT NULL DEFAULT 0,
    linhas_carregadas INTEGER NOT NULL DEFAULT 0,
    mensagem TEXT,
    commit_ref TEXT,
    CHECK (linhas_lidas >= 0 AND linhas_validas >= 0 AND linhas_rejeitadas >= 0 AND linhas_carregadas >= 0)
);

CREATE INDEX IF NOT EXISTS ix_auditoria_inicio ON aurora.auditoria_execucao (inicio);
CREATE INDEX IF NOT EXISTS ix_auditoria_status ON aurora.auditoria_execucao (status);
