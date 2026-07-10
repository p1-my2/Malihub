# Malihub Backend

Node.js + Express + Prisma + MySQL backend for the Malihub personal finance app.

## What changed from the previous version

The backend as received wouldn't start (`@prisma/client did not initialize`)
and, once that was fixed, only had one working endpoint (`register`) — every
other controller and route file was an empty placeholder, and `server.js`
only ever mounted the auth route. This version fills in all 7 entities with
working CRUD, wires everything into the app, and fixes several things that
would have broken on Railway even if the endpoints had existed:

- `server.js` hardcoded `PORT = 5000` → now reads `process.env.PORT`, required for Railway.
- `.env` was never loaded at runtime (no `dotenv.config()` call) → now loaded first thing in `server.js`.
- The committed Prisma client only had a **Windows** query engine binary → `schema.prisma` now declares `binaryTargets` for Linux too, and `postinstall` runs `prisma generate` automatically so Railway always builds a client for the OS it's actually running on.
- Two dead/broken files (`src/app.js` was empty, `configprisma.ts` had a syntax error) → `app.js` is now the real Express app definition; the broken file is removed.
- No JWT/auth was wired anywhere despite being a dependency → added `login`, a `requireAuth` middleware, and every data route now requires a valid token.
- No CORS despite being a dependency → enabled globally.
- Multiple controllers were each about to create their own `PrismaClient()` → consolidated into one shared client (`src/config/prisma.js`) so Railway's free-tier connection limit doesn't get exhausted.

## One thing to confirm with your DB specialist

`transaction_type` is `debit` or `credit`. I implemented **debit = money out
(expense, decreases account balance)** and **credit = money in (income,
increases balance)**, and account balances now update automatically whenever
a transaction is created, edited, or deleted (see `transactionController.js`).
Balance recalculation was flagged as your DB specialist's territory — treat
this as a reference implementation and have them confirm the convention
matches what the frontend/team assumed before you rely on it.

## Setup

```bash
npm install          # also runs `prisma generate` automatically (postinstall)
cp .env.example .env # then fill in your real DATABASE_URL and a JWT_SECRET
npx prisma db push   # or run malihub_schema.sql directly against MySQL
npm run dev          # nodemon, for local development
```

Root check: `GET /` → `"Malihub Backend is running"`.

## Deploying to Railway

1. Set `DATABASE_URL` and `JWT_SECRET` in Railway's environment variables (don't reuse your local `JWT_SECRET`).
2. Do **not** set `PORT` — Railway provides it automatically.
3. Railway's build step runs `npm install`, which now triggers `prisma generate` with the correct Linux binary target automatically.

## API reference

All routes except register/login require an `Authorization: Bearer <token>` header.

### Auth — `/api/auth`
| Method | Path | Notes |
|---|---|---|
| POST | `/register` | Creates user + 5 default categories, returns `{ token, user }` |
| POST | `/login` | Returns `{ token, user }` |

### Users — `/api/users`
| Method | Path |
|---|---|
| GET | `/me` |
| PUT | `/me` |
| PUT | `/me/password` |

### Accounts — `/api/accounts`
| Method | Path |
|---|---|
| GET | `/` |
| GET | `/:id` |
| POST | `/` |
| PUT | `/:id` |
| DELETE | `/:id` |

### Categories — `/api/categories`
| Method | Path |
|---|---|
| GET | `/` |
| POST | `/` |
| PUT | `/:id` |
| DELETE | `/:id` (blocked for default categories) |

### Transactions — `/api/transactions`
| Method | Path | Notes |
|---|---|---|
| GET | `/?account_id=&category_id=&type=&from=&to=&limit=&offset=` | |
| GET | `/summary?month=&year=` | Powers Analytics/Insights: category breakdown + prior-month comparison |
| GET | `/:id` | |
| POST | `/` | Also updates the linked account's balance |
| PUT | `/:id` | Reverses old balance effect, applies new one |
| DELETE | `/:id` | Reverses balance effect |

### Budgets — `/api/budgets`
| Method | Path | Notes |
|---|---|---|
| GET | `/` | Each budget includes computed `spent`, `remaining`, `percent_used` for its current period |
| POST | `/` | |
| PUT | `/:id` | |
| DELETE | `/:id` | |

### Goals — `/api/goals`
| Method | Path | Notes |
|---|---|---|
| GET | `/` | |
| POST | `/` | |
| PUT | `/:id` | Edit name/target/deadline |
| PATCH | `/:id/contribute` | `{ amount }` — adds to `current_amount` |
| DELETE | `/:id` | |

### Notifications — `/api/notifications`
| Method | Path |
|---|---|
| GET | `/` |
| PATCH | `/:id/read` |
| PATCH | `/read-all` |
| DELETE | `/:id` |

## Open items still worth deciding as a team

- Whether a budget spans one category or several (affects `Budget → Category` cardinality) — schema currently assumes one category per budget.
- Whether `notifications` needs `budget_id`/`goal_id` traceability columns — not added here since it wasn't in the verified DB schema; add a migration if you decide you want it.
