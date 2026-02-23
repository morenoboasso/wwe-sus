# Sprint 3 — Logica Punti e Ranking

## Obiettivo

Implementare:

- Calcolo punti (client side / frontend)
- Normalizzazione free-text
- Comparator
- Aggiornamento statistiche utente
- Ranking

---

## 1. Normalizzazione free-text

Funzione di utilità (es. in `/lib/services/text_normalizer.dart`):

- **Passi**:
  - `toLowerCase()`
  - `trim()`
  - sostituzione spazi multipli con singolo spazio
  - mapping alias (es. mappa `Map<String, String>`):
    - `"the rock" -> "rock"`
    - `"rock" -> "rock"`
    - `"cm punk" -> "punk"`
    - `"punk" -> "punk"`
    - `"cody" -> "cody rhodes"`

Comparator:

- `normalize(voteText) == normalize(resultText)`

---

## 2. Calcolo punti per singolo voto

Regole:

- **Standard**:
  - Se `winnerId == result`:
    - punti base `= 2`
    - se `isTitleMatch` → `+1`
    - se `isMainEvent` → `+1`
  - Altrimenti:
    - `0`
- **Free_text**:
  - Se `normalize(voteText) == normalize(resultText)`:
    - `3`
  - Altrimenti:
    - `0`

Implementazione:

- Crea un servizio `PointsService` (es. in `/lib/services/points_service.dart`) con:
  - `int calculatePoints(Match match, Vote vote)`

---

## 3. Aggiornamento statistiche utente

Per ogni voto quando il match viene chiuso:

- Leggi tutti i `votes` del match.
- Per ogni `vote`:
  - calcola punti con `PointsService`.
  - determina `isCorrect`:
    - standard: `winnerId == result`
    - free_text: `normalize(voteText) == normalize(resultText)`
  - aggiorna il documento `users/{userId}`:
    - `points += punti`
    - `correctPredictions += isCorrect ? 1 : 0`
    - `wrongPredictions += isCorrect ? 0 : 1`
    - `streak`:
      - se `isCorrect`: `streak += 1`
      - se sbagliato: `streak = 0`
    - `accuracy = correctPredictions / (correctPredictions + wrongPredictions)`

N.B.: inizialmente puoi fare questo calcolo **client-side**, lanciato dal pannello admin ("Calcola punti") subito dopo chiusura match. In futuro potresti spostarlo su Cloud Functions.

---

## 4. Ranking

Schermate:

- `RankingScreen` (`/ui/screens/ranking_screen.dart`)

Sottotab:

- **🏆 Generale**:
  - Ordina utenti per `points` desc.
- **🔥 Streak**:
  - Ordina per `streak` desc.
- **🎯 Accuratezza**:
  - Ordina per `accuracy` desc.
- **📈 Ultimi match**:
  - Mostra magari top performer sugli ultimi N match (puoi iniziare con lista semplice degli ultimi match con punti ottenuti).

Implementazione:

- `UserRepository.getAllUsers()` con query:
  - `orderBy('points', descending: true)` (per classifica generale)
  - `orderBy('streak', descending: true)`
  - `orderBy('accuracy', descending: true)`
- UI con `TabBar` o `SegmentedControl` per cambiare vista.
