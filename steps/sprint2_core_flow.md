# Sprint 2 — Core Flow

## Obiettivo

Implementare il **core flow**:

- Creazione match (admin)
- Votazione (user)
- Supporto `Nessun Vincitore`
- Supporto `free_text`
- Chiusura match (admin)

---

## 1. Creazione match (tutti)

Campi:

- `title` (TextField)
- `type` (Dropdown: Single, Tag, Rumble, ecc.)
- `ppvName` (TextField)
- `isTitleMatch` (Switch)
- `isMainEvent` (Switch)
- `predictionType` (Radio o Dropdown: `standard` / `free_text`)
- Se `standard`:
  - elenco partecipanti (lista di TextField o selettore da roster)
- Pulsante `Crea match`

Logica:

- Valida input.
- Costruisci oggetto `Match` con:
  - `status = "open"`
  - `createdBy = currentUserId`
  - `createdAt = serverTimestamp`
  - `result = null`, `resultText = null`
- Chiama `MatchRepository.createMatch(match)`.

---

**Stato:** completato – UI aggiornata in `CreateMatchCardPage` con campi titolo/tipo/PPV, switch per `isTitleMatch`/`isMainEvent`, selezione `predictionType`, e lista partecipanti per `standard`. Logica spostata in `CreateMatchController`, con validazione e salvataggio in Firestore via `MatchRepository` usando `serverTimestamp`.

## 2. Votazione utente

Schermata: **inline nella card** match (no pagina dedicata)

Mostra:

- Titolo, tipo, PPV
- Badge "Title Match", "Main Event", "Free Prediction"
- Stato match (`🟢 open` / `🔴 closed`)

### Standard prediction

UI:

- Dropdown per ogni wrestler di `wrestlers`
- Opzione aggiuntiva `Nessun Vincitore`
- Pulsante `Conferma voto`

Logica:

- Solo se `status == "open"`.
- Salva in `votes/{matchId}/userVotes/{userId}`:
  - `type: "standard"`
  - `winnerId` = wrestler scelto **oppure** `"Nessun Vincitore"`
  - `winnerText: null`
  - `timestamp = serverTimestamp`

Gestisci:
- Messaggio "Hai già votato" se esiste già un documento per `userId`.
- **Non consentire modifiche** al voto dopo il primo invio.

### Free-text prediction

UI:

- TextField multilinea
- Pulsante `Conferma voto`

Logica:

- Salva in `votes/{matchId}/userVotes/{userId}`:
  - `type: "free_text"`
  - `winnerText` = testo inserito
  - `winnerId = null`
  - `timestamp = serverTimestamp`

---

## 3. Chiusura match (chiunque)

Schermata: stessa card match, ma se `status == "open"`:

- Se `predictionType == "standard"`:
  - UI simile alla votazione standard, ma per selezionare il **risultato ufficiale**
  - Opzione `Nessun Vincitore`
- Se `predictionType == "free_text"`:
  - TextField per inserire `resultText` (es. "Cody Rhodes")

Flow:

1. Utente imposta risultato:
   - Standard:
     - `result = wrestlerId` o `"Nessun Vincitore"`
     - `resultText = null`
   - Free-text:
     - `result = null`
     - `resultText = testo`
2. Salva update del match:
   - `status = "closed"`
3. (Nello Sprint 2 puoi ancora NON calcolare i punti in modo definitivo; quello arriva allo Sprint 3. Qui basta segnare `closed`.)
