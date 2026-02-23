---
title: Modello dati Firestore — Sprint 1 / Step 1
date: 2026-02-20
---

## Obiettivo
Definire la struttura definitiva delle collezioni Firestore per l'app WWE SUS, così da poter:
1. allineare i modelli Dart (step 2);
2. predisporre repository e regole di sicurezza coerenti (step 3 e 5).

## Panoramica collezioni
| Collezione | Chiave | Descrizione sintetica |
|------------|--------|-----------------------|
| `users` | `users/{userId}` | Profilo applicativo dell'utente autenticato Firebase. |
| `matches` | `matches/{matchId}` | Match pubblicati dagli admin, con stato e risultato. |
| `votes` (subcollection) | `votes/{matchId}/userVotes/{userId}` | Voto espresso da un singolo utente per uno specifico match. |

## Schema dettagliato
### `users/{userId}`
| Campo | Tipo | Obbligatorio | Default | Note |
|-------|------|--------------|---------|------|
| `name` | `string` | sì | — | Nome visualizzato. Unico lato client. |
| `photo` | `string` (URL) | no | `""` | Avatar opzionale. |
| `points` | `number` | sì | `0` | Punteggio globale accumulato. |
| `correctPredictions` | `number` | sì | `0` | Conteggio pronostici corretti. |
| `wrongPredictions` | `number` | sì | `0` | Conteggio pronostici errati. |
| `streak` | `number` | sì | `0` | Serie positiva corrente. |
| `accuracy` | `number` | sì | `0` | Percentuale (0–100). |
| `role` | `string` (`admin`\|`user`) | sì | `user` | Determina permessi UI e rules. |

### `matches/{matchId}`
| Campo | Tipo | Obbligatorio | Default | Note |
|-------|------|--------------|---------|------|
| `title` | `string` | sì | — | Nome del match. |
| `type` | `string` | sì | — | Es. "Singles", "Tag Team". |
| `isTitleMatch` | `bool` | sì | `false` | Evidenzia match titolati. |
| `isMainEvent` | `bool` | sì | `false` | Evidenzia main event. |
| `ppvName` | `string` | sì | — | Evento di riferimento. |
| `wrestlers` | `array<string>` | sì | `[]` | Lista ID o nomi. Può essere vuota se `predictionType = "free_text"`. |
| `predictionType` | `string` (`standard`\|`free_text`) | sì | `standard` | Determina UI di voto. |
| `status` | `string` (`open`\|`closed`) | sì | `open` | Controlla se si può votare. |
| `createdBy` | `string` (`userId`) | sì | — | Deve essere un admin. |
| `createdAt` | `timestamp` | sì | `FieldValue.serverTimestamp()` | Server-side. |
| `result` | `string` (`wrestlerId`\|`NO_WINNER`\|`null`) | no | `null` | Esito per match standard. |
| `resultText` | `string` | no | `null` | Testo libero per `free_text`. |

### `votes/{matchId}/userVotes/{userId}`
| Campo | Tipo | Obbligatorio | Default | Note |
|-------|------|--------------|---------|------|
| `type` | `string` (`standard`\|`free_text`) | sì | — | Copiato dal match al momento del voto. |
| `winnerId` | `string` (`wrestlerId`\|`NO_WINNER`\|`null`) | condizionale | `null` | Compilato solo per `standard`. |
| `winnerText` | `string` | condizionale | `null` | Compilato solo per `free_text`. |
| `timestamp` | `timestamp` | sì | `FieldValue.serverTimestamp()` | Quando il voto è stato espresso. |

## Relazioni e vincoli
1. `votes` dipende da `matches`: il documento `userVotes/{userId}` esiste solo se anche `matches/{matchId}` esiste.
2. `userId` nella subcollection deve combaciare con `request.auth.uid` (vincolo applicato via rules).
3. Un utente può avere al massimo un voto per match → ID documento = `userId` (o scrittura con `set` merge false).
4. Il campo `result` o `resultText` può essere valorizzato solo quando `status = "closed"`.

## Query e indici suggeriti
| Use case | Query | Index necessario |
|----------|-------|------------------|
| Lista match aperti | `matches` dove `status == "open"` ordine per `createdAt desc` | Indice singolo (`status`) + ordinamento implicito su `createdAt`. |
| Storico PPV | `matches` dove `ppvName == <nome>` ordine per `createdAt desc` | Indice composto (`ppvName`, `createdAt desc`). |
| Leaderboard | `users` ordine per `points desc` | Indice singolo `points`. |
| Verifica streak | `users` ordine per `streak desc` | Indice singolo `streak`. |
| Voti per match | `votes/{matchId}/userVotes` ordine per `timestamp desc` | Nessun indice (subcollection). |

## Implicazioni per step successivi
- **Step 2 (modelli Dart)**: le classi dovranno riflettere uno a uno i campi sopra con `fromMap`/`toMap`, enumerazioni per `predictionType` e `status`, helper per `isOpen`.
- **Step 3 (architettura)**: repository `UserRepository`, `MatchRepository`, `VoteRepository` devono assumere questa struttura e NON quella legacy.
- **Step 4-5 (ruoli e rules)**: i vincoli descritti (solo admin crea match, ogni user un singolo voto, etc.) discendono esattamente da questi campi.

## Open question
- Identificatore `wrestlerId`: verrà gestito come string (nome) o come riferimento a futura collezione `wrestlers`? Per ora assumiamo string, ma conviene valutare una collezione dedicata nello sprint successivo.
