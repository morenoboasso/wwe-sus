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


In v1 puoi anche fare una lista numerica (senza grafico) e introdurre il grafico in v3.
