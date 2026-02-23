# Sprint 5 — UX e UI

## Obiettivo

Rifinire:

- UX & UI
- Badge, stati match
- Evidenziare vincitori
- Visual identity

---

## 1. Badge & stato match

Per ogni card match (`MatchCardWidget` in `/ui/widgets`):

- Mostra badge:
  - **Title Match** se `isTitleMatch`
  - **Main Event** se `isMainEvent`
  - **Free Prediction** se `predictionType == "free_text"`
- Colore stato:
  - `🟢 open` (colore verde)
  - `🔴 closed` (colore rosso)
- Se l'utente ha già votato:
  - testo "Hai già votato" o icona check sul match.

---

## 2. Highlight vincitori & avatar votanti

Per match **chiusi**:

- Evidenzia:
  - Wrestler vincente (o testo risultante free-text)
- Se vuoi mostrare chi ha votato cosa:
  - schermata dettaglio admin o schermata "Distribuzione voti"
    - Avatar circolari degli utenti (da `photo`)
    - accanto al wrestler votato.

In v1 puoi limitarti a:
- mostrare solo il vincitore ufficiale
- mostrare quanti hanno indovinato (es. "8/20 corretti").

---

## 3. Progress votazioni

Per match **aperti**:

- Mostra numero di voti già fatti:
  - `X utenti hanno votato`
- Se vuoi una barra:
  - per `standard`: percentuale per wrestler (es. 40% Cody, 60% Roman)
  - per `free_text`: magari solo numero totale voti (i nomi possono essere molto variabili).

---

## 4. Struttura UI complessiva

Schermate:

- **Home**:
  - lista match `open`
- **Match detail**:
  - dettaglio + UI di voto
- **Closed matches**:
  - lista match `closed`, con filtri per PPV
- **Ranking**:
  - tab classifiche (generale, streak, accuracy, ultimi match)
- **Profile**:
  - profilo utente, stats, storico
- **PPV view**:
  - match raggruppati per PPV
- **History**:
  - storico voti o match passati (può sovrapporsi a Closed matches/PPV view)

Bottom navigation (`/lib/widgets/bottom_navigation_bar_widget.dart`):

- Home
- Ranking
- History/PPV
- Profile

---

## 5. Roadmap di prodotto (v1, v2, v3)

- **v1**
  - Prediction standard (no free-text)
  - Ranking generale
  - Profili semplici (punti, streak, accuracy)
- **v2**
  - Free-text prediction (Rumble, Battle Royale, Surprise Match)
  - Royal Rumble flow dedicato
- **v3**
  - Statistiche avanzate
  - Stagioni (reset manuale admin dei punti)
  - PPV performance + grafici avanzati
