const prisma = require("../config/prisma");

function periodEnd(start_date, period_type) {
  const end = new Date(start_date);
  if (period_type === "weekly") end.setDate(end.getDate() + 7);
  else if (period_type === "monthly") end.setMonth(end.getMonth() + 1);
  else if (period_type === "yearly") end.setFullYear(end.getFullYear() + 1);
  return end;
}

async function withSpent(userId, budget) {
  const userAccounts = await prisma.accounts.findMany({
    where: { user_id: userId },
    select: { account_id: true }
  });
  const accountIds = userAccounts.map((a) => a.account_id);
  const end = periodEnd(budget.start_date, budget.period_type);

  const spentAgg = await prisma.transactions.aggregate({
    where: {
      account_id: { in: accountIds },
      category_id: budget.category_id,
      transaction_type: "debit",
      transaction_date: { gte: budget.start_date, lt: end }
    },
    _sum: { amount: true }
  });

  const spent = Number(spentAgg._sum.amount || 0);
  const budgetAmount = Number(budget.budget_amount);

  return {
    ...budget,
    spent,
    remaining: budgetAmount - spent,
    percent_used: budgetAmount > 0 ? Math.round((spent / budgetAmount) * 100) : 0
  };
}

// GET /api/budgets
exports.getBudgets = async (req, res, next) => {
  try {
    const budgets = await prisma.budgets.findMany({
      where: { user_id: req.user.user_id },
      include: { categories: true },
      orderBy: { start_date: "desc" }
    });

    const withProgress = await Promise.all(
      budgets.map((b) => withSpent(req.user.user_id, b))
    );

    res.json(withProgress);
  } catch (error) {
    next(error);
  }
};

// POST /api/budgets
exports.createBudget = async (req, res, next) => {
  try {
    const { category_id, budget_amount, period_type, start_date, alert_threshold } = req.body;

    if (!category_id || !budget_amount || !period_type || !start_date) {
      return res.status(400).json({
        message: "category_id, budget_amount, period_type and start_date are required"
      });
    }

    const category = await prisma.categories.findFirst({
      where: { category_id: Number(category_id), user_id: req.user.user_id }
    });
    if (!category) return res.status(404).json({ message: "Category not found" });

    const budget = await prisma.budgets.create({
      data: {
        user_id: req.user.user_id,
        category_id: Number(category_id),
        budget_amount,
        period_type,
        start_date: new Date(start_date),
        alert_threshold
      }
    });

    res.status(201).json(budget);
  } catch (error) {
    next(error);
  }
};

// PUT /api/budgets/:id
exports.updateBudget = async (req, res, next) => {
  try {
    const budgetId = Number(req.params.id);
    const { budget_amount, period_type, start_date, alert_threshold } = req.body;

    const existing = await prisma.budgets.findFirst({
      where: { budget_id: budgetId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Budget not found" });

    const updated = await prisma.budgets.update({
      where: { budget_id: budgetId },
      data: {
        budget_amount,
        period_type,
        ...(start_date && { start_date: new Date(start_date) }),
        alert_threshold
      }
    });

    res.json(updated);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/budgets/:id
exports.deleteBudget = async (req, res, next) => {
  try {
    const budgetId = Number(req.params.id);

    const existing = await prisma.budgets.findFirst({
      where: { budget_id: budgetId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Budget not found" });

    await prisma.budgets.delete({ where: { budget_id: budgetId } });
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
