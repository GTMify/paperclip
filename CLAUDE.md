# Paperclip — GTMify Operations Instance

This is the Paperclip AI control plane repo, deployed to Railway for GTMify Operations.

Read `AGENTS.md` first for repo-level engineering rules, then this file for GTMify-specific deployment context.

---

## Deployment

| Component | Value |
|-----------|-------|
| Production URL | https://paperclip-production-f45e.up.railway.app |
| Railway Project | `ccc19763-909c-4d78-8a5e-fd6f4a1057f4` |
| Railway Service | `1bd01b45-4b24-4487-a2b6-f5827afc3600` |
| Company ID | `bcd90d5a-33cd-4838-9726-9deff47b5773` |
| Company Name | GTMify Operations |
| Brand Color | #F53251 |
| Board Operator | scott@gtmify.io |
| Database | Railway Managed Postgres (internal network via `DATABASE_URL`) |
| Volume | Mounted at `/paperclip` |
| Auth | better-auth (email/password, `BETTER_AUTH_SECRET` from env) |

## Environment Variables (Railway)

- `DATABASE_URL` — Railway Managed Postgres (internal)
- `ANTHROPIC_API_KEY` — for agent LLM calls
- `PAPERCLIP_BASE_URL` — `https://paperclip-production-f45e.up.railway.app`
- `BETTER_AUTH_SECRET` — auto-generated

## entrypoint.sh Customizations

The `entrypoint.sh` was modified from upstream to:
1. Set `$meta` fields (version, instanceId, updatedAt, source=configure)
2. Set `auth.publicBaseUrl` explicitly for better-auth cookie domain
3. Set `logging.mode` to `file`
4. Bootstrap CEO invite on first start (15s delay for server readiness)

---

## 35-Agent Org Chart

See full details: `/Users/scottwueschinski/claude/config/gtmify/agents/paperclip_org_chart.md`

```
Scott (CEO)
├─ ApprovalGate          ├─ ChiefOfStaff
│                        │  ├─ DailyDigest
│                        │  ├─ EscalationManager
│                        │  ├─ HandoffRouter
│                        │  ├─ InboundRouter
│                        │  └─ QualityReviewer
├─ RevenueAgent          ├─ DeliveryAgent
│  ├─ PipelineReviewer   │  ├─ OnboardingOrchestrator
│  ├─ DealWatcher        │  ├─ ClientHealthMonitor
│  ├─ DealTransitioner   │  ├─ ReminderBot
│  ├─ PipelineSnapshotter│  └─ ImplementationArchitect
│  ├─ AccountPursuer     │
│  └─ DealAdvisor        │
├─ GrowthAgent           ├─ IntelAgent              ├─ OpsAgent
│  ├─ CampaignBuilder    │  ├─ MeetingPrepper       │  ├─ VendorMonitor
│  ├─ ContentWriter      │  ├─ FollowUpAgent        │  ├─ AnthropicWatcher
│  └─ CompetitiveAnalyst │  ├─ DeckGenerator        │  ├─ PasswordRotator
                         │  └─ ICPRefiner           │  ├─ InfraHealthCheck
                                                    │  └─ KnowledgeKeeper
```

## 23 Issues (GTM-1 through GTM-23)

9 original issues reassigned from department leads to specialist agents. 14 new issues created for uncovered workflows. All assigned to correct specialist agents.

---

## Agent ↔ n8n ↔ Claude Code Crosswalk

Full mapping: `/Users/scottwueschinski/claude/config/gtmify/agents/agent_map.md`

**Currently wired:**
- MeetingPrepper → `zKs38S1g8Pjp2EKy` (LIVE)
- FollowUpAgent → `bU5JyYcxj0yYrnUF` (published, needs Clarify webhook)

**Next to wire:** PipelineReviewer, DealWatcher, OnboardingOrchestrator, ClientHealthMonitor

---

## API Quick Reference

| Action | Endpoint |
|--------|----------|
| List agents | `GET /api/companies/:companyId/agents` |
| Create agent | `POST /api/companies/:companyId/agents` |
| Update agent | `PATCH /api/agents/:id` |
| Delete agent | `DELETE /api/agents/:id` |
| List issues | `GET /api/companies/:companyId/issues` |
| Update issue | `PATCH /api/issues/:id` |
| Health check | `GET /api/health` |

All requests require auth. Board access uses better-auth session cookies. Agent access uses `Authorization: Bearer <api-key>`.
