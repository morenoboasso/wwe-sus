# Sprint 1 — Fondamenta

## Obiettivo

Definire e stabilizzare:
- **Modello dati Firestore**
- **Modelli Dart**
- **Ruoli (admin/user)**
- **Regole di sicurezza Firebase**

---

## 1. Modello dati Firestore

Collezioni principali:

- **`users/{userId}`**
  - `name: string`
  - `photo: string`
  - `points: number`
  - `correctPredictions: number`
  - `wrongPredictions: number`
  - `streak: number`
  - `accuracy: number`
  - `role: "admin" | "user"`

- **`matches/{matchId}`**
  - `title: string`
  - `type: string`
  - `isTitleMatch: bool`
  - `isMainEvent: bool`
  - `ppvName: string`
  - `wrestlers: [wrestlerId]` (lista di ID o nomi, vuota se `predictionType = "free_text"`)
  - `predictionType: "standard" | "free_text"`
  - `status: "open" | "closed"`
  - `createdBy: userId`
  - `createdAt: timestamp`
  - `result: wrestlerId | "NO_WINNER" | null`
  - `resultText: string | null`

- **`votes/{matchId}/userVotes/{userId}` (subcollection)**
  - `type: "standard" | "free_text"`
  - `winnerId: wrestlerId | "NO_WINNER" | null`
  - `winnerText: string | null`
  - `timestamp: timestamp`

Struttura suggerita:

- `users/{userId}`
- `matches/{matchId}`
- `votes/{matchId}/userVotes/{userId}`

---

## 2. Modelli Dart (`/lib/models`)

Crea 3 file:

- **`user_model.dart`**
  - Classe `AppUser` con:
    - campi del documento `users`
    - metodi `fromMap` / `toMap`

- **`match_model.dart`**
  - Classe `Match` con:
    - enum o stringhe per `predictionType` e `status`
    - helper tipo `bool get isOpen => status == "open"`

- **`vote_model.dart`**
  - Classe `Vote` con:
    - campi del documento
    - getter per capire se è `standard` o `freeText`

**Stato:** completato – i file `lib/models/user_model.dart`, `lib/models/match_model.dart`, `lib/models/vote_model.dart` sono stati creati con `enum`, `fromMap`, `toMap`, `copyWith` e helper come `isOpen`, `isStandard`, `isFreeText`.

---

## 3. Architettura Flutter di base

Struttura cartelle:

- `/lib/models` – i 3 modelli sopra
- `/lib/services/firebase` – wrapper generici per FirebaseAuth e Firestore
- `/lib/repositories` – logica di accesso dati (users, matches, votes)
- `/lib/state` – BLoC o Riverpod (consigliato Riverpod) per stato globale
- `/lib/ui/screens` – schermate
- `/lib/ui/widgets` – widget riutilizzabili

In questo Sprint:

- Configura Firebase (`firebase_options.dart` già presente).
- Setup Auth (anche solo anonima all'inizio).
- Crea i repository vuoti con metodi base:
  - `UserRepository`
  - `MatchRepository`
  - `VoteRepository`

**Stato:** completato – create le cartelle (`services/firebase`, `repositories`, `ui/*`, `state`), aggiunte dipendenze (`firebase_auth`), wrapper `FirebaseAuthService` e `FirebaseFirestoreService`, auth anonima inizializzata in `main.dart` e repository base (`UserRepository`, `MatchRepository`, `VoteRepository`).

---

## 4. Gestione ruoli (admin/user)

- Nel documento `users/{userId}` mantieni `role: "admin" | "user"`.
- `UserRepository` deve esporre:
  - `Stream<AppUser?> watchCurrentUser()`
  - `Future<AppUser?> getCurrentUserOnce()`

Sul frontend:

- Nel provider/Bloc globale (`AuthState` o simile) tieni:
  - utente Firebase
  - `AppUser` con il ruolo
- Le UI admin (creazione/chiusura match) devono essere visibili solo se `role == "admin"`.

**Stato:** completato – aggiunta dipendenza Riverpod, creati provider in `lib/state/auth_providers.dart` per gestire stato Firebase user + AppUser, con helper `isAdminProvider` e `userRoleProvider`. `UserRepository` espone già i metodi richiesti. Ready per logica UI condizionale su ruolo admin.

---

## 5. Regole di sicurezza Firebase (bozza concettuale)

Obiettivi principali:

- Solo gli **admin** possono:
  - creare/aggiornare/eliminare `matches`
  - scrivere `result`, `status`, `createdBy`, `createdAt`
- Ogni **user** può:
  - scrivere/aggiornare solo il proprio `vote`
  - leggere match e votes (se vuoi le statistiche pubbliche)

Concetti chiave da applicare nelle rules:

- Controllo su `request.auth != null`
- Per `users`:
  - lettura: tutti gli utenti autenticati
  - scrittura:
    - l'utente può aggiornare solo i campi "sicuri" del proprio profilo (es. `photo`, `name`)
    - solo admin possono modificare `role`, `points`, ecc.
- Per `matches`:
  - scrittura permessa solo se `request.auth.uid` è admin.
- Per `votes/{matchId}/userVotes/{userId}`:
  - `userId` deve essere `request.auth.uid`
  - non si può votare se il match è `closed` (controllando via `get(/databases/(default)/documents/matches/{matchId})`).

**Stato:** completato – creato file `firestore.rules` con regole complete per users, matches, votes. Include helper functions `isAdmin()` e `isMatchOpen()`, controllo accessi granulare, e permessi di lettura/scrittura basati su ruoli. Pronto per deploy.
