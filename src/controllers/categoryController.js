const prisma = require("../config/prisma");

// GET /api/categories
exports.getCategories = async (req, res, next) => {
  try {
    const categories = await prisma.categories.findMany({
      where: { user_id: req.user.user_id },
      orderBy: { category_name: "asc" }
    });
    res.json(categories);
  } catch (error) {
    next(error);
  }
};

// POST /api/categories
exports.createCategory = async (req, res, next) => {
  try {
    const { category_name, icon } = req.body;

    if (!category_name) {
      return res.status(400).json({ message: "category_name is required" });
    }

    const category = await prisma.categories.create({
      data: { user_id: req.user.user_id, category_name, icon }
    });

    res.status(201).json(category);
  } catch (error) {
    next(error);
  }
};

// PUT /api/categories/:id
exports.updateCategory = async (req, res, next) => {
  try {
    const { category_name, icon } = req.body;
    const categoryId = Number(req.params.id);

    const existing = await prisma.categories.findFirst({
      where: { category_id: categoryId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Category not found" });

    const updated = await prisma.categories.update({
      where: { category_id: categoryId },
      data: { category_name, icon }
    });

    res.json(updated);
  } catch (error) {
    next(error);
  }
};

// DELETE /api/categories/:id
exports.deleteCategory = async (req, res, next) => {
  try {
    const categoryId = Number(req.params.id);

    const existing = await prisma.categories.findFirst({
      where: { category_id: categoryId, user_id: req.user.user_id }
    });
    if (!existing) return res.status(404).json({ message: "Category not found" });

    if (existing.is_default) {
      return res.status(400).json({ message: "Default categories cannot be deleted" });
    }

    await prisma.categories.delete({ where: { category_id: categoryId } });
    res.status(204).send();
  } catch (error) {
    next(error);
  }
};
