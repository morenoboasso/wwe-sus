# Firebase Security Rules - Step 5

## File Creato
`firestore.rules` - Regole di sicurezza per Firestore

## Regole Implementate

### Helper Functions
- `isAdmin()`: Verifica se l'utente corrente è admin tramite il campo `role` nel documento utente
- `isMatchOpen(matchId)`: Verifica se un match è aperto al voto

### Collection Rules

#### `/users/{userId}`
- **Read**: Tutti gli utenti autenticati possono leggere i profili
- **Write**: 
  - Gli utenti possono aggiornare solo i propri campi sicuri (`name`, `photo`)
  - Gli admin possono aggiornare qualsiasi profilo
- **Create**: Solo gli admin possono creare utenti

#### `/matches/{matchId}`
- **Read**: Tutti gli utenti autenticati possono leggere i match
- **Write/Create/Delete**: Solo gli admin possono creare/aggiornare/eliminare match

#### `/votes/{matchId}/userVotes/{userId}`
- **Read**: Tutti gli utenti autenticati possono leggere i voti (per statistiche)
- **Write/Create**: 
  - Gli utenti possono scrivere solo il proprio voto
  - Il voto è permesso solo se il match è aperto (`status == 'open'`)
- **Delete**: 
  - Gli utenti possono eliminare il proprio voto
  - Gli admin possono eliminare qualsiasi voto

## Deploy delle Regole

Per deployare le regole su Firebase:

```bash
firebase deploy --only firestore:rules
```

Oppure via Firebase Console:
1. Vai a Firestore Database → Rules
2. Copia e incolla il contenuto di `firestore.rules`
3. Pubblica le regole

## Test delle Regole

Testare con Firebase Rules Playground nella console o con test unitari Firebase.
