-- Instituto Aurora — Módulo 3
-- Consultas de validação para conferir os resultados produzidos pelo Apache Hop.
-- Ajuste os nomes das tabelas caso os destinos do pipeline usem outra nomenclatura.

-- 1) Quantidade de registros por etapa
-- SELECT 'alunos_entrada' etapa, COUNT(*) qtd FROM staging.stg_alunos
-- UNION ALL SELECT 'matriculas_entrada', COUNT(*) FROM staging.stg_matriculas;

-- 2) Alunos duplicados
SELECT id_aluno, COUNT(*) AS qtd
FROM staging.stg_alunos
GROUP BY id_aluno
HAVING COUNT(*) > 1;

-- 3) Matrículas sem aluno correspondente
SELECT m.id_matricula, m.id_aluno
FROM staging.stg_matriculas m
LEFT JOIN staging.stg_alunos a ON a.id_aluno = m.id_aluno
WHERE a.id_aluno IS NULL;

-- 4) Matrículas sem curso correspondente
-- A tabela de cursos consolidada deve ser criada pelo pipeline de ingestão de cursos.
-- Exemplo:
-- SELECT m.id_matricula, m.codigo_curso
-- FROM staging.stg_matriculas m
-- LEFT JOIN staging.stg_cursos c ON c.codigo_curso = m.codigo_curso
-- WHERE c.codigo_curso IS NULL;

-- 5) Datas inválidas/futuras de nascimento, se a origem já estiver tipada como DATE
SELECT id_aluno, data_nascimento
FROM staging.stg_alunos
WHERE data_nascimento > CURRENT_DATE;

-- 6) Domínio de status de aluno
SELECT id_aluno, status_aluno
FROM staging.stg_alunos
WHERE status_aluno NOT IN ('Ativo', 'Inativo');

-- 7) Matrículas com campos críticos nulos
SELECT id_matricula, id_aluno, codigo_curso, data_matricula
FROM staging.stg_matriculas
WHERE id_aluno IS NULL
   OR codigo_curso IS NULL
   OR data_matricula IS NULL;
