const prisma = require("../config/prisma");

// GET /api/accounts
exports.getAccounts = async (req, res, next) => {
  try {
    const accounts = await prisma.accounts.findMany({
      where: { user_id: req.user.user_id },
      orderBy: { created_at: "asc" }
    });
    res.json(accounts);
  } catch (error) {
    next(error);
  }
};

// GET /api/accounts/:id
exports.getAccount = async (req, res, next) => {
  try {
    const account = await prisma.accounts.findFirst({
      where: { account_id: Number(req.params.id), user_id: req.user.user_id }
    });

    if (!account) return res.status(404).json({ message: "Account not found" });
    res.json(account);
  } catch (error) {
    next(error);
  }
};

// POST /api/accounts
exports.createAccount = async (req, res, next) => {
  try {
    const { account_name, account_type, balance } = req.body;

    if (!account_name || !account_type) {
      return res.status(400).json({ message: "account_name and account_type are required" });
    }

    const account = await prisma.accounts.create({
      data: {
        user_id: req.user.user_id,
        account_name,
        account_type,
        balance: balance ?? 0
      }
    });

    res.status(201).json(account);
  } catch (error) {
    next(error);
  }
};

// PUT /api/accounts/:id
exports.updateAccount = async (req, res, next) => {
  try {
    const { account_name, account_type, is_active } = req.body;
    const accountId = Number(req.params.id);

    const existing = await prisma.accounts.findFirst({
      where: { account_id: accountId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Account not found" });

    const updated = await prisma.accounts.update({
      where: { account_id: accountId },
      data: { account_name, account_type, is_active }
    });

    res.json(updated);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/accounts/:id
exports.deleteAccount = async (req, res, next) => {
  try {
    const accountId = Number(req.params.id);

    const existing = await prisma.accounts.findFirst({
      where: { account_id: accountId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Account not found" });

    await prisma.accounts.delete({ where: { account_id: accountId } });
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
