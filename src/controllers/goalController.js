const prisma = require("../config/prisma");

// GET /api/goals
exports.getGoals = async (req, res, next) => {
  try {
    const goals = await prisma.financial_goals.findMany({
      where: { user_id: req.user.user_id },
      orderBy: { deadline: "asc" }
    });
    res.json(goals);
  } catch (error) {
    next(error);
  }
};

// POST /api/goals
exports.createGoal = async (req, res, next) => {
  try {
    const { goal_name, target_amount, current_amount, deadline } = req.body;

    if (!goal_name || !target_amount) {
      return res.status(400).json({ message: "goal_name and target_amount are required" });
    }

    const goal = await prisma.financial_goals.create({
      data: {
        user_id: req.user.user_id,
        goal_name,
        target_amount,
        current_amount: current_amount ?? 0,
        deadline: deadline ? new Date(deadline) : null
      }
    });

    res.status(201).json(goal);
  } catch (error) {
    next(error);
  }
};

// PUT /api/goals/:id  (edit goal details)
exports.updateGoal = async (req, res, next) => {
  try {
    const goalId = Number(req.params.id);
    const { goal_name, target_amount, deadline } = req.body;

    const existing = await prisma.financial_goals.findFirst({
      where: { goal_id: goalId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Goal not found" });

    const updated = await prisma.financial_goals.update({
      where: { goal_id: goalId },
      data: {
        goal_name,
        target_amount,
        ...(deadline && { deadline: new Date(deadline) })
      }
    });

    res.json(updated);
  } catch (error) {
    next(error);
  }
};

// PATCH /api/goals/:id/contribute  (add money towards a goal)
exports.contributeToGoal = async (req, res, next) => {
  try {
    const goalId = Number(req.params.id);
    const { amount } = req.body;

    if (!amount || Number(amount) <= 0) {
      return res.status(400).json({ message: "A positive amount is required" });
    }

    const existing = await prisma.financial_goals.findFirst({
      where: { goal_id: goalId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Goal not found" });

    const updated = await prisma.financial_goals.update({
      where: { goal_id: goalId },
      data: { current_amount: { increment: Number(amount) } }
    });

    res.json(updated);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/goals/:id
exports.deleteGoal = async (req, res, next) => {
  try {
    const goalId = Number(req.params.id);

    const existing = await prisma.financial_goals.findFirst({
      where: { goal_id: goalId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Goal not found" });

    await prisma.financial_goals.delete({ where: { goal_id: goalId } });
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
