# Sprint 2 — Core Flow

## Obiettivo

Implementare il **core flow**:

- Creazione match (admin)
- Votazione (user)
- Supporto `NO_WINNER`
- Supporto `free_text`
- Chiusura match (admin)

---

## 1. Creazione match (admin)

Schermata: `CreateMatchScreen` (`/ui/screens/create_match_screen.dart`)

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

## 2. Votazione utente

Schermata: `MatchDetailScreen` (`/ui/screens/match_detail_screen.dart`)

Mostra:

- Titolo, tipo, PPV
- Badge "Title Match", "Main Event", "Free Prediction"
- Stato match (`🟢 open` / `🔴 closed`)

### Standard prediction

UI:

- Lista pulsanti / RadioListTile per ogni wrestler di `wrestlers`
- Opzione aggiuntiva `NO_WINNER`
- Pulsante `Conferma voto`

Logica:

- Solo se `status == "open"`.
- Salva in `votes/{matchId}/userVotes/{userId}`:
  - `type: "standard"`
  - `winnerId` = wrestler scelto **oppure** `"NO_WINNER"`
  - `winnerText: null`
  - `timestamp = serverTimestamp`

Gestisci:
- Messaggio "Hai già votato" se esiste già un documento per `userId`.
  - Puoi consentire update fino a quando il match è `open` (decidi policy).

### Free-text prediction

UI:

- TextField multilinea
- (Facoltativo) suggerimenti sotto forma di chip cliccabili
- Pulsante `Conferma voto`

Logica:

- Salva in `votes/{matchId}/userVotes/{userId}`:
  - `type: "free_text"`
  - `winnerText` = testo inserito
  - `winnerId = null`
  - `timestamp = serverTimestamp`

---

## 3. Chiusura match (admin)

Schermata: stessa `MatchDetailScreen`, ma se `admin` e `status == "open"`:

- Se `predictionType == "standard"`:
  - UI simile alla votazione standard, ma per selezionare il **risultato ufficiale**
  - Opzione `NO_WINNER`
- Se `predictionType == "free_text"`:
  - TextField per inserire `resultText` (es. "Cody Rhodes")

Flow:

1. Admin imposta risultato:
   - Standard:
     - `result = wrestlerId` o `"NO_WINNER"`
     - `resultText = null`
   - Free-text:
     - `result = null`
     - `resultText = testo`
2. Salva update del match:
   - `status = "closed"`
3. (Nello Sprint 2 puoi ancora NON calcolare i punti in modo definitivo; quello arriva allo Sprint 3. Qui basta segnare `closed`.)
