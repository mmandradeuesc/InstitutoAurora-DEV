-- Validacoes pos-carga para PostgreSQL.
-- Substitua os nomes abaixo caso o ambiente use tabelas consolidadas.

SET search_path TO staging, public;

-- Volumes basicos.
SELECT 'alunos' AS entidade, COUNT(*) AS total FROM stg_alunos
UNION ALL SELECT 'matriculas', COUNT(*) FROM stg_matriculas;

-- Duplicidades de identificadores.
SELECT id_aluno, COUNT(*) AS ocorrencias
FROM stg_alunos GROUP BY id_aluno HAVING COUNT(*) > 1;

SELECT id_matricula, COUNT(*) AS ocorrencias
FROM stg_matriculas GROUP BY id_matricula HAVING COUNT(*) > 1;

-- Integridade referencial de matriculas.
SELECT m.id_matricula, m.id_aluno
FROM stg_matriculas m
LEFT JOIN stg_alunos a ON a.id_aluno = m.id_aluno
WHERE a.id_aluno IS NULL;

-- Campos obrigatorios.
SELECT COUNT(*) AS alunos_sem_nome FROM stg_alunos
WHERE NULLIF(BTRIM(nome_completo), '') IS NULL;

SELECT COUNT(*) AS matriculas_sem_curso FROM stg_matriculas
WHERE NULLIF(BTRIM(codigo_curso), '') IS NULL;

-- Datas impossiveis ou futuras.
SELECT COUNT(*) AS datas_nascimento_invalidas FROM stg_alunos
WHERE data_nascimento > CURRENT_DATE;

SELECT COUNT(*) AS matriculas_futuras FROM stg_matriculas
WHERE data_matricula > CURRENT_DATE;

-- Distribuicao para auditoria.
SELECT situacao, COUNT(*) AS total
FROM stg_matriculas GROUP BY situacao ORDER BY situacao;
