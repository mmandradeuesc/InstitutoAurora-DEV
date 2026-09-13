$out = 'C:\Projetos\InstitutoAurora\docs\evidencias_pdf'
$reports = @{
  3 = @('Modulo 3 - Ingestao, Transformacao e Validacao','Resultado: Apache Hop 2.19.0 executado.','Alunos: 14 lidos; 1 duplicidade removida; 10 carregados.','Cursos: 9 linhas lidas; 6 codigos distintos.','Matriculas: 15 lidas; 10 carregadas.','Datas, chaves, CPF, nome e duplicidades tratados.');
  4 = @('Modulo 4 - Orquestracao','Resultado: workflow executado com sucesso e falha controlada.','Fluxo: entradas -> ingestoes -> transformacao -> validacao -> carga -> sucesso.','Falha: cursos.csv ausente; pre-requisito abortou com exit 1; arquivo restaurado.');
  5 = @('Modulo 5 - Logging e Rastreabilidade','Resultado: logs e auditoria registrados.','SUCESSO: carga_postgres; lidas=15; validas=10; rejeitadas=5; carregadas=10.','FALHA: cursos.csv ausente; pre_requisito; exit=1.','Tabela: aurora.auditoria_execucao.');
  6 = @('Modulo 6 - Integracao PostgreSQL','Resultado: carga e validacoes SQL executadas.','Banco: aurora_dw | localhost:5432 | CONN_POSTGRES_AURORA.','stg_alunos: 10 registros; stg_matriculas: 10 registros.','Matriculas sem aluno: 0; duplicidades: 0.');
  7 = @('Modulo 7 - Governanca e Versionamento','Resultado: projeto sincronizado com origin/main.','Commit: 8efda52.','Mensagem: feat: conclui pipeline academico dos modulos 3 a 10.','Working tree limpo; configuracao parametrizada.');
  8 = @('Modulo 8 - Seguranca Operacional','Resultado: credenciais parametrizadas e riscos documentados.','Variaveis: DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD.','Valores ficam no ambiente InstitutoAurora-DEV.','Papeis: desenvolvedor, operador, revisor e validador.');
  9 = @('Modulo 9 - Desempenho e Falhas','Resultado: execucao medida e reprocessamento validado.','Duracao: 1,3 segundos.','14 alunos lidos; 1 duplicidade; 3 rejeicoes; 10 carregados.','Falha controlada exit 1; reprocessamento idempotente com sucesso.');
  10 = @('Modulo 10 - Consolidacao','Resultado: pacote consolidado e publicado em origin/main.','Pipelines, workflow, PostgreSQL, logs, auditoria e checklist entregues.','10 alunos e 10 matriculas validas.','Commit 8efda52 sincronizado com origin/main.');
}
function New-Pdf($path, $lines) {
  $content = "BT`n/F1 16 Tf`n50 780 Td`n"
  $first = $true
  foreach ($line in $lines) {
    $safe = $line.Replace('\','\\').Replace('(','\(').Replace(')','\)')
    if (-not $first) { $content += "0 -24 Td`n" }
    $content += "($safe) Tj`n"
    $first = $false
  }
  $content += "ET`n"
  $objects = @()
  $objects += '<< /Type /Catalog /Pages 2 0 R >>'
  $objects += '<< /Type /Pages /Kids [3 0 R] /Count 1 >>'
  $objects += '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Resources << /Font << /F1 4 0 R >> >> /Contents 5 0 R >>'
  $objects += '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>'
  $objects += "<< /Length $([Text.Encoding]::ASCII.GetByteCount($content)) >>`nstream`n$content`nendstream"
  $pdf = "%PDF-1.4`n%`xE2`xE3`xCF`xD3`n"
  $offsets = @(0)
  for ($i=0; $i -lt $objects.Count; $i++) { $offsets += [Text.Encoding]::ASCII.GetByteCount($pdf); $pdf += "$($i+1) 0 obj`n$($objects[$i])`nendobj`n" }
  $xref = [Text.Encoding]::ASCII.GetByteCount($pdf)
  $pdf += "xref`n0 $($objects.Count+1)`n0000000000 65535 f `n"
  for ($i=1; $i -lt $offsets.Count; $i++) { $pdf += ('{0:0000000000} 00000 n ' -f $offsets[$i]) + "`n" }
  $pdf += "trailer`n<< /Size $($objects.Count+1) /Root 1 0 R >>`nstartxref`n$xref`n%%EOF`n"
  [IO.File]::WriteAllBytes($path, [Text.Encoding]::ASCII.GetBytes($pdf))
}
foreach ($n in 3..10) { New-Pdf (Join-Path $out "modulo_$n.pdf") $reports[$n] }
