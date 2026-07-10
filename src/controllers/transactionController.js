const prisma = require("../config/prisma");

// NOTE ON CONVENTION: transaction_type "debit" = money leaving the account
// (an expense) and decreases balance. "credit" = money coming in (income)
// and increases balance. This matches how the Insights/Analytics screens
// distinguish spend vs income. Confirm this with your DB specialist —
// balance recalculation is documented as their area, this is a reference
// implementation so the API has something real behind it.
function signedAmount(transaction_type, amount) {
  const value = Number(amount);
  return transaction_type === "debit" ? -value : value;
}

async function assertOwnsAccount(userId, accountId) {
  return prisma.accounts.findFirst({
    where: { account_id: accountId, user_id: userId }
  });
}

async function assertOwnsCategory(userId, categoryId) {
  return prisma.categories.findFirst({
    where: { category_id: categoryId, user_id: userId }
  });
}

// GET /api/transactions?account_id=&category_id=&type=&from=&to=&limit=&offset=
exports.getTransactions = async (req, res, next) => {
  try {
    const { account_id, category_id, type, from, to, limit, offset } = req.query;

    // Transactions link to accounts, not directly to users, so we scope
    // by joining through the user's own accounts.
    const userAccounts = await prisma.accounts.findMany({
      where: { user_id: req.user.user_id },
      select: { account_id: true }
    });
    const accountIds = userAccounts.map((a) => a.account_id);

    const where = {
      account_id: account_id ? Number(account_id) : { in: accountIds },
      ...(category_id && { category_id: Number(category_id) }),
      ...(type && { transaction_type: type }),
      ...((from || to) && {
        transaction_date: {
          ...(from && { gte: new Date(from) }),
          ...(to && { lte: new Date(to) })
        }
      })
    };

    const transactions = await prisma.transactions.findMany({
      where,
      include: { categories: true, accounts: true },
      orderBy: { transaction_date: "desc" },
      take: limit ? Number(limit) : 50,
      skip: offset ? Number(offset) : 0
    });

    res.json(transactions);
  } catch (error) {
    next(error);
  }
};

// GET /api/transactions/:id
exports.getTransaction = async (req, res, next) => {
  try {
    const transaction = await prisma.transactions.findFirst({
      where: {
        transaction_id: Number(req.params.id),
        accounts: { user_id: req.user.user_id }
      },
      include: { categories: true, accounts: true }
    });

    if (!transaction) return res.status(404).json({ message: "Transaction not found" });
    res.json(transaction);
  } catch (error) {
    next(error);
  }
};

// POST /api/transactions
exports.createTransaction = async (req, res, next) => {
  try {
    const { account_id, category_id, amount, transaction_type, description, transaction_date } = req.body;

    if (!account_id || !category_id || !amount || !transaction_type) {
      return res.status(400).json({
        message: "account_id, category_id, amount and transaction_type are required"
      });
    }

const account = await assertOwnsAccount(req.user.user_id, Number(account_id));
    console.log("Logged in user:", req.user.user_id);
    console.log("Account ID sent:", account_id);
    console.log("Account found:", account);
    if (!account) return res.status(404).json({ message: "Account not found" });

    const category = await assertOwnsCategory(req.user.user_id, Number(category_id));
    if (!category) return res.status(404).json({ message: "Category not found" });

    const result = await prisma.$transaction(async (tx) => {
      const transaction = await tx.transactions.create({
        data: {
          account_id: Number(account_id),
          category_id: Number(category_id),
          amount,
          transaction_type,
          description,
          ...(transaction_date && { transaction_date: new Date(transaction_date) })
        }
      });

      await tx.accounts.update({
        where: { account_id: Number(account_id) },
        data: { balance: { increment: signedAmount(transaction_type, amount) } }
      });

      return transaction;
    });

    res.status(201).json(result);
  } catch (error) {
    next(error);
  }
};

// PUT /api/transactions/:id
exports.updateTransaction = async (req, res, next) => {
  try {
    const transactionId = Number(req.params.id);
    const { category_id, amount, transaction_type, description, transaction_date } = req.body;

    const existing = await prisma.transactions.findFirst({
      where: { transaction_id: transactionId, accounts: { user_id: req.user.user_id } }
    });
    if (!existing) return res.status(404).json({ message: "Transaction not found" });

    if (category_id) {
      const category = await assertOwnsCategory(req.user.user_id, Number(category_id));
      if (!category) return res.status(404).json({ message: "Category not found" });
    }

    const result = await prisma.$transaction(async (tx) => {
      // Reverse the old effect on the balance, then apply the new one.
      const reversal = -signedAmount(existing.transaction_type, existing.amount);
      const newType = transaction_type || existing.transaction_type;
      const newAmount = amount ?? existing.amount;

      await tx.accounts.update({
        where: { account_id: existing.account_id },
        data: {
          balance: {
            increment: reversal + signedAmount(newType, newAmount)
          }
        }
      });

      return tx.transactions.update({
        where: { transaction_id: transactionId },
        data: {
          category_id: category_id ? Number(category_id) : undefined,
          amount,
          transaction_type,
          description,
          ...(transaction_date && { transaction_date: new Date(transaction_date) })
        }
      });
    });

    res.json(result);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/transactions/:id
exports.deleteTransaction = async (req, res, next) => {
  try {
    const transactionId = Number(req.params.id);

    const existing = await prisma.transactions.findFirst({
      where: { transaction_id: transactionId, accounts: { user_id: req.user.user_id } }
    });
    if (!existing) return res.status(404).json({ message: "Transaction not found" });

    await prisma.$transaction(async (tx) => {
      await tx.accounts.update({
        where: { account_id: existing.account_id },
        data: { balance: { increment: -signedAmount(existing.transaction_type, existing.amount) } }
      });

      await tx.transactions.delete({ where: { transaction_id: transactionId } });
    });

    res.status(204).send();
  } catch (error) {
    next(error);
  }
};

// GET /api/transactions/summary?month=7&year=2026
// Powers the Analytics/Insights screen: category breakdown donut +
// month-over-month bar comparison.
exports.getSummary = async (req, res, next) => {
  try {
    const now = new Date();
    const month = Number(req.query.month) || now.getMonth() + 1;
    const year = Number(req.query.year) || now.getFullYear();

    const start = new Date(year, month - 1, 1);
    const end = new Date(year, month, 1);
    const prevStart = new Date(year, month - 2, 1);

    const userAccounts = await prisma.accounts.findMany({
      where: { user_id: req.user.user_id },
      select: { account_id: true }
    });
    const accountIds = userAccounts.map((a) => a.account_id);

    const [currentMonthTx, previousMonthTx] = await Promise.all([
      prisma.transactions.findMany({
        where: {
          account_id: { in: accountIds },
          transaction_date: { gte: start, lt: end }
        },
        include: { categories: true }
      }),
      prisma.transactions.findMany({
        where: {
          account_id: { in: accountIds },
          transaction_date: { gte: prevStart, lt: start }
        }
      })
    ]);

    const byCategory = {};
    let totalIncome = 0;
    let totalExpense = 0;

    for (const tx of currentMonthTx) {
      const amt = Number(tx.amount);
      if (tx.transaction_type === "debit") {
        totalExpense += amt;
        const key = tx.categories.category_name;
        byCategory[key] = (byCategory[key] || 0) + amt;
      } else {
        totalIncome += amt;
      }
    }

    const previousExpense = previousMonthTx
      .filter((t) => t.transaction_type === "debit")
      .reduce((sum, t) => sum + Number(t.amount), 0);

    res.json({
      month,
      year,
      total_income: totalIncome,
      total_expense: totalExpense,
      net: totalIncome - totalExpense,
      by_category: byCategory,
      previous_month_expense: previousExpense
    });
  } catch (error) {
    next(error);
  }
};
