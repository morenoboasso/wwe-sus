# Sprint 4 — Profili e Statistiche

## Obiettivo

Costruire:

- Schermata profilo utente
- Storico pronostici
- Statistiche dettagliate
- PPV performance
- Grafico andamento

---

## 1. Profilo utente

Schermata: `ProfileScreen` (`/ui/screens/profile_screen.dart`)

Mostra:

- Avatar (da `photo`)
- Nome
- **Punti totali**
- **Streak corrente**
- **Accuracy (%)**
- `correctPredictions` / `wrongPredictions`
- Pulsante per vedere storico, PPV performance, ecc.

Dati:

- `AppUser` dal `UserRepository` (documento corrente).

---

## 2. Storico pronostici

Modello dati:

- I voti sono già in `votes/{matchId}/userVotes/{userId}`.

Per lo storico di un utente:

- Opzione 1 (semplice):
  - Query per tutti i `matches` chiusi.
  - Per ognuno, recupera il `vote` di `userId` se esiste.
- Opzione 2 (più efficiente, in futuro):
  - Duplicare i voti in una collezione `userVotes/{userId}/votes/{matchId}` tramite Cloud Function.

In v1 puoi fare **Opzione 1**.

UI:

- Lista di card:
  - Nome match + PPV + badge (Title/Main/Free)
  - Scelta dell'utente (wrestler o testo)
  - Risultato ufficiale
  - Punti ottenuti
  - Icona verde/rossa per corretto/sbagliato.

---

## 3. PPV performance

Obiettivo:

- Mostrare statistiche aggregate per `ppvName`.

Implementazione:

- Recupera tutti i match chiusi dove l'utente ha votato.
- Raggruppa in memoria per `ppvName`:
  - totale punti in quel PPV
  - % pronostici corretti in quel PPV
- UI:
  - Lista di PPV con:
    - Nome PPV
    - Punti totali
    - Accuracy nel PPV
    - Numero di match votati.

---

## 4. Grafico andamento

Visualizzare l'andamento dei **punti nel tempo**.

Strategia semplice:

- Quando calcoli i punti per un match, oltre ad aggiornare `users/{userId}`, salvi anche una entry in una collezione:
  - `userStats/{userId}/timeline/{matchId}`:
    - `pointsAfterMatch`
    - `totalPoints`
    - `matchDate`
- Poi nella `ProfileScreen`:
  - leggi timeline ordinata per `matchDate`
  - usa un semplice line chart (plugin Flutter per grafici) per mostrare la curva dei punti.

In v1 puoi anche fare una lista numerica (senza grafico) e introdurre il grafico in v3.
