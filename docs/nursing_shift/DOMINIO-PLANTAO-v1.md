### Domínio: Plantão / Checklist (Arkham MVP v1)

Versão: 1.0
Data: 2026-07-28
Status: **fase futura** (não implementado)
Fontes: [PRD-Arkham-MVP-v1.md](PRD-Arkham-MVP-v1.md) FR-002 (parte futura), FR-003, FR-004, FR-005; [HLD-Arkham-MVP-v1.md](HLD-Arkham-MVP-v1.md) seções "Componentes e responsabilidades" e "Modelo de dados"

Este documento isola tudo que diz respeito ao **fluxo operacional de plantão e checklist** — ainda não implementado — separado do domínio de Usuário (ver [DOMINIO-USUARIO-v1.md](DOMINIO-USUARIO-v1.md)), que já está pronto.

---

### Entidades (proposta — HLD deixa o modelo físico para o FDD)

**items** (catálogo de itens de checklist)
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| name | string | |
| description | text | nullable |
| active | boolean | default true |

**activities** (item + regra de quando/para quem aparece)
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| item_id | uuid | FK → items |
| periodicity_type | string | `daily / weekly / biweekly / monthly / multiple_per_day / fixed_time / fixed_weekday` |
| periodicity_config | jsonb | detalhes do tipo (ex.: `{weekday: 3}`, `{times: 4}`, `{hour: "14:00"}`) |
| assignment_type | string | `shift` ou `user` |
| assigned_user_id | uuid | FK → users, nullable (só quando `assignment_type = user`) |
| active | boolean | default true |
| created_by_id | uuid | FK → users |

**shifts** (plantão)
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| shift_date | date | |
| shift_type | string | ex.: `diurno`/`noturno` |
| status | string | `open / execution_finalized / review_finalized` |
| execution_finalized_at / execution_finalized_by_id | datetime / uuid | nullable |
| review_finalized_at / review_finalized_by_id | datetime / uuid | nullable |
| system_unavailable_pending | boolean | default false — pendência "Sistema indisponível" |
| índice único | | `(shift_date, shift_type)` |

**shift_occurrences** (ocorrência materializada — execução + revisão no mesmo registro)
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| shift_id | uuid | FK → shifts (plantão que executa) |
| activity_id | uuid | FK → activities |
| checked / checked_by_id / checked_at | boolean / uuid / datetime | execução |
| impossible / impossible_reason | boolean / text | motivo obrigatório se `impossible = true` |
| review_status | string | `pending / confirmed / divergent` |
| reviewed_by_id / reviewed_at | uuid / datetime | usuário do plantão **seguinte** |
| divergence_note | text | obrigatório se `review_status = divergent` |

**audit_events** (transversal, mas as trilhas críticas do PRD são as de plantão/checklist)
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| user_id | uuid | FK → users, quem executou |
| action | string | ex.: `check_item`, `finalize_execution` |
| auditable_type / auditable_id | string / uuid | polimórfico |
| changes | jsonb | diff antes/depois quando aplicável |
| created_at | datetime | quando |

**system_parameters** (operações do perfil `maintainer`, FR-005)
| coluna | tipo | nota |
| --- | --- | --- |
| id | uuid | PK |
| key | string | único |
| value | jsonb | |
| updated_by_id | uuid | FK → users |

---

### Regras de negócio

- Atividade tem periodicidade e é atribuída **a um plantão** ou **a um usuário**
- Materialização: o sistema gera as ocorrências que aparecem em cada plantão conforme a periodicidade cadastrada
- **Execução**: plantão vigente marca/desmarca itens com salvamento contínuo e finaliza o plantão
- Item impossível de cumprir: motivo obrigatório em texto + tentativa síncrona de notificação (WhatsApp)
- **Revisão**: plantão seguinte revisa o checklist executado pelo plantão anterior, com salvamento contínuo, finalizando como correto ou com divergência registrada (auditável) + notificação síncrona se divergente
- Após finalização da execução, edição só via `administrator`
- Sem internet: acordo verbal → `administrator` encerra plantão com pendência "Sistema indisponível"
- Visibilidade: enfermagem vê checado/revisado (nível combinado); `administrator` vê também divergências e status agregado, para mediar atritos
- Auditoria obrigatória (quem, quando, o quê) em toda mutação relevante do checklist
- Listagem de plantões (relatório) com detalhe ao abrir, respeitando visibilidade por perfil (FR-004, prioridade baixa)
- Operações de `maintainer`: parâmetros de sistema, exportação de auditoria, impersonação (FR-005)

---

### RBAC por funcionalidade (parte "fase futura" do FR-002)

Diferente do domínio Usuário (que trata de *quem mexe em qual usuário*), aqui a autorização é *quem pode fazer o quê no fluxo operacional*:

| Grupo | Execução enfermagem | Parametrização enfermagem | Admin/financeiro | Config sistema | Dev/troubleshooting | Consultas |
| --- | --- | --- | --- | --- | --- | --- |
| maintainer | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| administrator | ✅ | ✅ | ✅ | ✅ | ❌ | ✅ |
| nursing_leaders | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| nursing_team | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ |
| employer | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |

Mapeamento prático:
- **Executar/checar item** (`shift_occurrences.checked`) → `nursing_team` e acima
- **Cadastrar item/atividade** (`items`, `activities`) → `nursing_leaders` e acima
- **Ver divergência e status agregado no relatório** → `administrator` e acima
- **Parâmetros de sistema, exportar auditoria, impersonação** → só `maintainer`
- **Consulta básica de listagem de plantão** → todos os grupos, incluindo `employer` (nível mais restrito)

> Nota do PRD (linha 44, 157): as regras de plantão/checklist ainda referenciam os nomes de perfil anteriores (Desenvolvedor/ADM/Enfermagem) e precisam ser revisadas em conjunto com o time de negócio antes da implementação, mapeando cada regra ao grupo correspondente na tabela acima.

---

### Observações de modelagem

- `shift_occurrences` junta execução e revisão na mesma linha — evita duplicar a referência ao item/atividade e casa com a regra de que a revisão sempre olha para uma checagem específica já feita
- `audit_events.auditable_*` é polimórfico para cobrir qualquer entidade sem uma tabela de auditoria por entidade
- `activities.periodicity_config` em `jsonb` evita coluna por tipo de periodicidade, mas exige validação de shape via contrato Dry::Validation
- Retenção de 5 anos (HLD) incide principalmente sobre `audit_events` e `shifts`/`shift_occurrences`; arquivamento fica para o FDD

Ver também [ROADMAP-v1.md](ROADMAP-v1.md) para o sequenciamento deste domínio em relação ao restante do MVP.
