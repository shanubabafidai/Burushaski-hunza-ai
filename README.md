# Hunza Burushaski Research — ChatGPT Plugin Starter

**Status:** working starter repository, **not deployed**, **not yet a public-ready plugin**, **no verified Burushaski linguistic content included**. It provides a source-grounded research architecture, not a trained Burushaski language model.

## What's included

- Portable `plugin.json` manifest and `mcp.json` Streamable HTTP endpoint configuration.
- `skills/hunza-burushaski/SKILL.md` for source-grounded research/translation workflow.
- Python Model Context Protocol server with six tools.
- SQLite schema with source rights, approvals, corrections, and audit votes.
- Offline CLI for adding sources, importing records, two-reviewer approval, corrections, and revocation.
- Research JSONL exporter with consent/rights filtering and source/speaker-group partitioning.
- Tests, Dockerfile, ethics/privacy notes, deployment guide, and data templates.

## Quick start (Python 3.11+)

```bash
cd burushaski-hunza-plugin
python -m venv .venv
# Activate: Linux/macOS: source .venv/bin/activate
# Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m burushaski.cli init
python -m burushaski.cli stats
python -m burushaski.server
```

The local server then listens on `http://127.0.0.1:8000/mcp` using Streamable HTTP. For tool discovery, connect an MCP inspector or compatible client; `/mcp` is an MCP endpoint, not a normal browser page. See `docs/DEPLOYMENT.md`.

**Note:** MCP uses Python SDK maintenance-line v1 (`mcp>=1.28,<2`). Porting to v2 requires updating imports and transport settings; see the official MCP SDK migration guide.

## First real data, without fabricated translations

1. Identify a native Hunza Burushaski speaker and a separate pair of qualified reviewers.
2. Obtain and document permission for retrieval, training, and redistribution **separately**. The MIT code license does not grant permission to use a corpus.
3. Create a source record:

```bash
python -m burushaski.cli add-source \
  --id speaker-session-001 \
  --title "Consented elicitation session 001" \
  --creator "Pseudonym-of-consenting-speaker" \
  --license-id "Written project consent form v1" \
  --consent-reference "private-consent-register/session-001" \
  --can-retrieve
python -m burushaski.cli verify-source speaker-session-001 --rights-checked
```

4. Fill a **copy** of `data/records_template.csv` with genuinely verified content, using `source_id=speaker-session-001`, then import:

```bash
python -m burushaski.cli import-csv /path/to/your-private-records.csv
```

5. Each imported ID starts `pending`. Two **different** qualified reviewers must approve each one:

```bash
python -m burushaski.cli review-record RECORD_ID --reviewer reviewer-A --decision approve
python -m burushaski.cli review-record RECORD_ID --reviewer reviewer-B --decision approve
```

6. Search the data via MCP. Only records whose source is verified and allows retrieval, and that have two approvals, are visible.

## Moderated corrections (offline workflow)

Create a JSON proposal file (example **field names only**, not real Burushaski):

```json
{
  "kind": "lexicon",
  "burushaski_text": "REPLACE_WITH_SPEAKER_VERIFIED_FORM",
  "english_text": "REPLACE_WITH_GLOSS",
  "script": "roman"
}
```

Submit and approve it using trusted local access:

```bash
python -m burushaski.cli submit-correction --proposal-json /private/proposal.json \
  --contributor contributor-alias --consent-to-publish --rights-attested
python -m burushaski.cli review-correction CORRECTION_ID \
  --reviewer reviewer-A --decision approve --rights-checked
python -m burushaski.cli review-correction CORRECTION_ID \
  --reviewer reviewer-B --decision approve --rights-checked
```

To correct an existing approved record add `--target ORIGINAL_RECORD_ID`. Approved corrections create a new record version; the original becomes superseded. The submitted contributor alias **must not** be used as the reviewer identity. Training consent is always separate (`--consent-to-training`).

## Future model training: data export, not training execution

Only source-verified, approved entries with `can_train=1` **and** `can_redistribute=1` enter the portable export. For example, `--can-train --can-redistribute` must be documented at source creation, or `--consent-to-training` provided for a community contribution; community contributions default to `can_redistribute=0` and therefore need a **separate license-clearing workflow** before portable export.

```bash
python -m burushaski.cli export --output ./exports/research-v1
```

The exporter writes `train.jsonl`, `validation.jsonl`, `test.jsonl`, `provenance.csv`, and `export_report.json`. These are **research data files**, not a model fine-tuning job or a directly usable OpenAI fine-tuning upload. Group splits by speaker/source to reduce leakage; an empty evaluation split is a blocker for meaningful model evaluation.

## Tests

```bash
python -m pip install pytest
python -m pytest -q
```

## Before putting this online

- Replace `https://replace-with-your-domain.example/mcp` in `mcp.json` with your working **HTTPS** MCP endpoint.
- Use a durable disk/managed database and HTTPS reverse proxy. SQLite is for a single-instance pilot, not an autoscaled public system.
- Implement OAuth 2.1 user identification, scoped write access, abuse prevention and a privacy policy **before** accepting public corrections. Public submissions are disabled by default.
- Add correct publisher metadata, icon, hosted privacy/terms pages, domain verification, and review materials for public plugin submission.
- Confirm allowed uses of any externally published Burushaski corpora; do not assume academic access permits redistribution or commercial training.

See `docs/TECHNICAL_BLUEPRINT.md`, `docs/DEPLOYMENT.md`, `docs/RESEARCH_AND_EVAL.md`, and `docs/SAFETY_PRIVACY.md`.

## Sources for the integration (verified November 2026)

- OpenAI plugin packaging: https://developers.openai.com/plugins/build/plugins
- MCP server guide: https://developers.openai.com/plugins/build/mcp-server
- ChatGPT plugin quickstart: https://developers.openai.com/plugins/quickstart
- Plugin submission: https://developers.openai.com/plugins/deploy/submission
- MCP SDK v1 reference: https://py.sdk.modelcontextprotocol.io/v1/
- Model training availability: https://developers.openai.com/api/docs/guides/supervised-fine-tuning
